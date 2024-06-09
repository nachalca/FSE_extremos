import pandas as pd
import numpy as np
from scipy.stats import ks_2samp

def diff_of_means(truth, estimate):
    return np.mean(truth) - np.mean(estimate)

def correlation(truth, estimate):
    return np.corrcoef(truth, estimate)[0, 1]

def ratio_of_sd(truth, estimate):
    return np.std(estimate) / np.std(truth)

def rmse(truth, estimate):
    return np.sqrt(np.mean((truth - estimate) ** 2))

def mae(truth, estimate):
    return np.mean(np.abs(truth - estimate))

def ks(truth, estimate):
    return ks_2samp(truth, estimate).pvalue

def sign_error(time, truth, estimate):
    df = pd.DataFrame({"time": time, "truth": truth, "estimate": estimate})
    df["date"] = df["time"].dt.date
    n = df["date"].nunique()
    df["hour"] = df["time"].dt.hour
    df["nxt_truth"] = np.where(df["truth"].shift(-1) > df["truth"], 1, 0)
    df["nxt_estimate"] = np.where(df["estimate"].shift(-1) > df["estimate"], 1, 0)
    
    grouped = df.dropna().groupby("hour").apply(lambda x: abs(x["nxt_truth"].sum()/n - x["nxt_estimate"].sum()/n))
    return grouped.sum() / 24

def sign_correlation(truth, estimate):
    df = pd.DataFrame({"truth": truth, "estimate": estimate})
    df["nxt_truth"] = np.where(df["truth"].shift(-1) > df["truth"], 1, -1)
    df["nxt_estimate"] = np.where(df["estimate"].shift(-1) > df["estimate"], 1, -1)
    df["same_behaviour"] = np.where(df["nxt_truth"] == df["nxt_estimate"], 1, 0)
    
    return df["same_behaviour"].mean()

def amplitude_rmse(time, truth, estimate):
    df = pd.DataFrame({"time": time, "truth": truth, "estimate": estimate})
    df["date"] = df["time"].dt.date
    
    r = df.groupby("date").apply(lambda x: [x["truth"].max() - x["truth"].min(), x["estimate"].max() - x["estimate"].min()])
    r = pd.DataFrame(r.tolist(), index=r.index, columns=["truth_amplitude", "estimate_amplitude"])
    
    return rmse(r["truth_amplitude"], r["estimate_amplitude"])

def amplitude_ratio_of_means(time, truth, estimate):
    df = pd.DataFrame({"time": time, "truth": truth, "estimate": estimate})
    df["date"] = df["time"].dt.date
    
    r = df.groupby("date").apply(lambda x: [x["truth"].max() - x["truth"].min(), x["estimate"].max() - x["estimate"].min()])
    r = pd.DataFrame(r.tolist(), index=r.index, columns=["truth_amplitude", "estimate_amplitude"])
    
    return np.mean(r["estimate_amplitude"]) / np.mean(r["truth_amplitude"])

def maximum_hour(time, truth, estimate):
    df = pd.DataFrame({"time": time, "truth": truth, "estimate": estimate})
    df["date"] = df["time"].dt.date
    
    max_truth_per_day = df.groupby("date")["truth"].idxmax()
    hours_max_truth_per_day = df.loc[max_truth_per_day].reset_index(drop=True)
    hours_max_truth_per_day["truth_hour"] = hours_max_truth_per_day["time"].dt.hour
    
    max_est_values_per_day = df.groupby("date")["estimate"].idxmax()
    hours_max_est_values_per_day = df.loc[max_est_values_per_day].reset_index(drop=True)
    hours_max_est_values_per_day["est_hour"] = hours_max_est_values_per_day["time"].dt.hour

    result = pd.concat([hours_max_truth_per_day["truth_hour"], hours_max_est_values_per_day["est_hour"]], axis=1)
    return result

def maximum_correlation(time, truth, estimate):
    result = maximum_hour(time, truth, estimate)
    result["coincidence"] = np.where(result["truth_hour"] == result["est_hour"], 1, 0)
    return result["coincidence"].mean()

def maximum_difference(time, truth, estimate):
    result = maximum_hour(time, truth, estimate)
    result["dif"] = np.abs(result["truth_hour"] - result["est_hour"])
    return result["dif"].mean()

def maximum_error(time, truth, estimate):
    n = pd.to_datetime(time).date.nunique()
    temp = maximum_hour(time, truth, estimate)
    t = temp.groupby("truth_hour").size().reset_index(name="n_t_hour")
    e = temp.groupby("est_hour").size().reset_index(name="n_e_hour")

    merged = pd.merge(t, e, left_on="truth_hour", right_on="est_hour", how="inner")
    merged["diff"] = np.abs(merged["n_t_hour"] - merged["n_e_hour"])
    return merged["diff"].sum() / (2 * n)

def metrics(time, truth, estimate, model):
    df = pd.DataFrame({
        "diff_of_means": [diff_of_means(truth, estimate)],
        "ratio_of_sd": [ratio_of_sd(truth, estimate)],
        "ks_test": [ks(truth, estimate)],
        "amplitude_ratio_of_means": [amplitude_ratio_of_means(time, truth, estimate)],
        "maximum_error": [maximum_error(time, truth, estimate)],
        "sign_error": [sign_error(time, truth, estimate)]
    }, index=[model])
    return df

def metrics_2(time, truth, estimate, model):
    df = pd.DataFrame({
        "rmse": [rmse(truth, estimate)],
        "mae": [mae(truth, estimate)],
        "cor": [correlation(truth, estimate)],
        "ks_test": [ks(truth, estimate)],
        "amplitude_rmse": [amplitude_rmse(time, truth, estimate)],
        "maximum_correlation": [maximum_correlation(time, truth, estimate)],
        "sign_correlation": [sign_correlation(truth, estimate)]
    }, index=[model])
    return df
