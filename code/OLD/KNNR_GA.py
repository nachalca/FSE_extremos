import pandas as pd
import numpy as np

variable = "sfcWind"
avg_variable = "avg_" + variable

def prepare_data(data):

    # create a new column with the hour
    data["hour"] = data["time"].apply(lambda x: int(x.split(" ")[1].split(":")[0]))

    # transform the first column to get only the date without time
    data["time"] = data["time"].apply(lambda x: x.split(" ")[0])


    # Reshape the dataframe to a wide format (| avg_variable | hour_1 | hour_2 | ... | hour_24)
    data = data.pivot(index=['time', avg_variable], columns=['hour'], values=variable).reset_index()
    data = data.rename_axis(None, axis=1)
    
    # make date be the index
    data.set_index('time', inplace=True)
    return data

def get_probability(index, k):
    d = np.sum([1/(1 + i) for i in range(k)])
    return (1/index)/d

def k_nearest_neighbours(observations, targets, day, k):
    k_nearest = observations.copy()
    k_nearest["difference"] = abs(k_nearest[avg_variable]- targets.loc[day][avg_variable])
    # sort the values by the difference
    k_nearest = k_nearest.sort_values(by="difference")
    # get the first k values
    k_nearest = k_nearest.head(k)
    k_nearest = k_nearest.reset_index()
    k_nearest["prob"] = k_nearest.apply(lambda x: get_probability(x.name + 1, k), axis=1)
    return k_nearest

def select(k_nearest_neighbours):
    k_nearest_neighbours["cum_prob"] = k_nearest_neighbours["prob"].cumsum()
    # select the first value that is greater than the random number
    r = np.random.rand()
    first = k_nearest_neighbours[k_nearest_neighbours["cum_prob"] > r].head(1)
    #drop the selected value from the dataframe
    k_nearest_neighbours = k_nearest_neighbours.drop(first.index)
    #reevaluate the probabilities
    k_nearest_neighbours["prob"] = k_nearest_neighbours["prob"]/(1 - first["prob"].values[0])
    #select the second value
    r = np.random.rand()
    second = k_nearest_neighbours[k_nearest_neighbours["cum_prob"] > r].head(1)
    return first, second

def crossover(first, second, p_c):
    
    prediction = first.copy()

    for i in range(0,24):
        r = np.random.rand()
        if(p_c > r):
            prediction[i] = second[i].iloc[0]

    return prediction

def adjust(prediction,target_value):
    sum = 0

    for i in range(0,24):    
        sum += prediction[i].iloc[0]
        
    for i in range(0,24): 
        prediction[i] = prediction[i].iloc[0]*target_value*24/sum
    
    prediction[avg_variable] = target_value


def main():

    observations_file = "code/reanalysis_" + variable + "_training_data.csv"
    targets_file = "code/cmip6_" + variable + "_to_downscale_data.csv"

    observations = prepare_data(pd.read_csv(observations_file))
    targets = prepare_data(pd.read_csv(targets_file))

    k = int(np.sqrt(observations.shape[0]))

    results = []

    for day in targets.index:
        temp_results = []
        #We repeat the process 10 times 
        for i in range(0,10):
            k_nearest = k_nearest_neighbours(observations, targets, day, k)
            
            first, second = select(k_nearest)
            prediction = crossover(first, second, 0.3)
            prediction["time"] = day
            adjust(prediction,targets.loc[day][avg_variable])

            #drop the last three columns
            prediction = prediction.drop(columns=["difference","prob","cum_prob"])
            temp_results.append(prediction)
        #get the mean of the 30 predictions
        temp_results = pd.concat(temp_results).groupby("time").mean().reset_index()
        adjust(temp_results,targets.loc[day][avg_variable])
        results.append(temp_results)
    
    predictions = pd.concat(results)
    
    #reshape to the original format
    predictions = predictions.melt(id_vars=["time",avg_variable], var_name="hour", value_name=variable)
    #add hour to time and cast to date
    predictions["time"] = predictions["time"] + " " + predictions["hour"].apply(lambda x: str(x) + ":00:00")
    #transform time to datetime
    predictions["time"] = pd.to_datetime(predictions["time"])
    #order by tim
    predictions = predictions.sort_values(by="time")

    print(predictions.head())
    predictions.to_csv("code/predictions.csv", index=False)
main()

# 0.5274469