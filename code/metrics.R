library(ggplot2)
library(here)
library(viridis)
library(metrica)
library(ggforce)
library(colorspace)
library(extremogram)

setwd(here())
source('code/utils.R')

#' Computes metrics for unpaired models on a hourly scale. Used to assess shared statistical properties
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_unpaired_hourly <- function(time, truth, estimate, model) {
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "amplitude_ratio_of_means" = c(amplitude_ratio_of_means(
      time,
      truth,
      estimate
    )),
    "maximum_error" = c(maximum_error(time, truth, estimate)),
    "ks_mean_on_coarse_res_with_extremes" = c(mean_on_coarse_res_with_extremes_ks(
      time,
      truth,
      estimate,
      daily = T
    )),
    "qqplot_mae" = c(qqplot_mae(truth, estimate)),
    "acf_mae" = c(acf_mae(truth, estimate)),
    "extremogram_mae" = c(extremogram_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

#' Computes metrics for unpaired models on a hourly scale. Adds new metrics for rain. Used to assess shared statistical properties
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_unpaired_hourly_rain <- function(time, truth, estimate, model) {
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "amplitude_ratio_of_means" = c(amplitude_ratio_of_means(
      time,
      truth,
      estimate
    )),
    "maximum_error" = c(maximum_error(time, truth, estimate)),
    "ks_mean_on_coarse_res_with_extremes" = c(mean_on_coarse_res_with_extremes_ks(
      time,
      truth,
      estimate,
      daily = T
    )),
    "rainy_hours_ratio_of_means" = c(rainy_hours_ratio_of_means(
      time,
      truth,
      estimate
    )),
    "qqplot_mae" = c(qqplot_mae(truth, estimate)),
    "acf_mae" = c(acf_mae(truth, estimate)),
    "extremogram_mae" = c(extremogram_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

#' Computes metrics for unpaired models on a daily scale. Used to asses shared statistical properties
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_unpaired_daily <- function(time, truth, estimate, model) {
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "monthly_amplitude_ratio_of_means" = c(monthly_amplitude_ratio_of_means(
      time,
      truth,
      estimate
    )),
    "ks_mean_on_coarse_res_with_extremes" = c(mean_on_coarse_res_with_extremes_ks(
      time,
      truth,
      estimate,
      daily = F
    )),
    "qqplot_mae" = c(qqplot_mae(truth, estimate)),
    "acf_mae" = c(acf_mae(truth, estimate)),
    "extremogram_mae" = c(extremogram_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

#' Computes metrics for unpaired models on a monthly scale. Used to assess shared statistical properties
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_unpaired_monthly <- function(time, truth, estimate, model) {
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "yearly_amplitude_ratio_of_means" = c(yearly_amplitude_ratio_of_means(
      time,
      truth,
      estimate
    )),
    "qqplot_mae" = c(qqplot_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}


#' Computes metrics for paired models on a hourly scale. Used to asses shared statistical properties
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_paired_hourly <- function(time, truth, estimate, model) {
  df <- data.frame(
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
    "amplitude_mae" = c(amplitude_mae(time, truth, estimate)),
    "maximum_difference" = c(maximum_difference(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "extreme_correlation" = c(extreme_correlation(
      time,
      truth,
      estimate,
      daily = T
    )),
    "qqplot_mae" = c(qqplot_mae(truth, estimate)),
    "acf_mae" = c(acf_mae(truth, estimate)),
    "extremogram_mae" = c(extremogram_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

#' Computes metrics for paired models on a hourly scale. Adds new metrics for rain. Used to asses shared statistical properties
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_paired_hourly_rain <- function(time, truth, estimate, model) {
  df <- data.frame(
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
    "amplitude_mae" = c(amplitude_mae(time, truth, estimate)),
    "maximum_difference" = c(maximum_difference(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "extreme_correlation" = c(extreme_correlation(
      time,
      truth,
      estimate,
      daily = T
    )),
    "amount_rainy_hours_mae" = amount_rainy_hours_mae(time, truth, estimate),
    "qqplot_mae" = c(qqplot_mae(truth, estimate)),
    "acf_mae" = c(acf_mae(truth, estimate)),
    "extremogram_mae" = c(extremogram_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

#' Computes metrics for paired models on a daily scalethat are used to assesss downscaling performance.
#'
#' @param time A vector representing the time points of the data.
#' @param truth A vector containing the true (or reference) values. Typically, this would be a reanalysis dataset.
#' @param estimate A vector representing the simulated values, typically derived from CMIP or downscaled CMIP data. #'
#'
#' @returns A dataframe containing the calculated metrics.
metrics_paired_daily <- function(time, truth, estimate, model) {
  df <- data.frame(
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
    "amplitude_mae_monthly" = c(amplitude_mae_monthly(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "extreme_correlation" = c(extreme_correlation(
      time,
      truth,
      estimate,
      daily = F
    )),
    "qqplot_mae" = c(qqplot_mae(truth, estimate)),
    "acf_mae" = c(acf_mae(truth, estimate)),
    "extremogram_mae" = c(extremogram_mae(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

diff_of_means <- function(truth, estimate) {
  mean(truth) - mean(estimate)
}

diff_of_means_per <- function(truth, estimate) {
  100 * diff_of_means(truth, estimate) / mean(truth)
}

correlation <- function(truth, estimate) {
  cor(truth, estimate)
}

ratio_of_sd <- function(truth, estimate) {
  sd(estimate) / sd(truth)
}

rmse <- function(truth, estimate) {
  sqrt(sum((truth - estimate)^2) / length(truth))
}

mae <- function(truth, estimate) {
  sum(abs(truth - estimate)) / length(truth)
}
mape <- function(truth, estimate) {
  (sum(abs((truth - estimate) / truth)) / length(truth)) * 100
}

sign_error <- function(time, truth, estimate) {
  n <- n_distinct(getDate(time))
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)

  cor <- df |>
    mutate(
      hour = getHour(time),
      nxt_truth = if_else(lead(truth) > truth, 1, 0),
      nxt_estimate = if_else(lead(estimate) > estimate, 1, 0)
    ) |>
    na.omit() |>
    group_by(hour) |>
    summarise(sgn = abs(sum(nxt_truth) / n - sum(nxt_estimate) / n)) |>
    ungroup() |>
    summarise(result = sum(sgn) / 24)
  cor[[1]]
}

sign_correlation <- function(truth, estimate) {
  df <- data.frame("truth" = truth, "estimate" = estimate)
  cor <- df |>
    mutate(
      nxt_truth = if_else(lead(truth) > truth, 1, -1),
      nxt_estimate = if_else(lead(estimate) > estimate, 1, -1)
    ) |>
    mutate(same_behaviour = if_else(nxt_truth == nxt_estimate, 1, 0)) |>
    filter(row_number() <= n() - 1) |>
    summarise(cor = sum(sign_correlation = same_behaviour) / n())
  cor[[1]]
}

# detredn QQ plot

detrend_qq <- function(data, pps = (0:99 + .5) / 100) {
  data |>
    pivot_longer(cols = -c(1:2), values_to = 'value', names_to = 'model') |>
    group_by(model) |>
    reframe(
      qq.obs = quantile(reanalysis, probs = pps),
      qq.pred = quantile(value, probs = pps, na.rm = TRUE),
      per = pps
    ) |>
    ggplot() +
    geom_line(aes(y = qq.pred - qq.obs, x = per, color = model)) +
    geom_hline(yintercept = 0, linetype = 'dashed') +
    scale_color_brewer(palette = 'Dark2') +
    theme_bw()
}


#Hourly distribution
hourly_distribution <- function(data) {
  df <- data |>
    pivot_longer(cols = -c(time), names_to = "model", values_to = "value") |>
    mutate(
      hour = getHour(time),
      season = getSeason(time)
    ) |>
    group_by(hour, season, model) |>
    summarize(
      hourly_mean = mean(value),
      hourly_sd = sd(value),
      .groups = "drop"
    ) |>
    mutate(
      ymin = hourly_mean - hourly_sd,
      ymax = hourly_mean + hourly_sd
    )

  ggplot() +
    geom_line(
      data = filter(df, model == 'reanalysis'),
      aes(x = hour, y = hourly_mean),
      color = 'grey',
      linewidth = 1,
      alpha = .8
    ) +
    geom_point(
      data = filter(df, model == 'reanalysis'),
      aes(x = hour, y = hourly_mean),
      color = 'grey',
      alpha = .8,
      size = I(2)
    ) +
    geom_line(
      data = filter(df, model != 'reanalysis'),
      aes(x = hour, y = hourly_mean, color = model)
    ) +
    scale_x_continuous(breaks = seq(0, 24, 3)) +
    scale_color_brewer(palette = 'Dark2') +
    labs(
      x = "Hour of Day",
      y = "Average Value",
      color = "Model"
    ) +
    theme_minimal() +
    facet_wrap(~season, nrow = 2, scales = 'free_y')
}

amplitude_mae <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup()

  mae(r$truth_amplitude, r$estimate_amplitude)
}

amplitude_mae_monthly <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(yearMonth = getYearMonth(time)) |>
    group_by(yearMonth) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup()

  mae(r$truth_amplitude, r$estimate_amplitude)
}

# day of year distribution (for monthly variables)
week_distribution <- function(data) {
  df <- data |>
    pivot_longer(cols = -c(time), names_to = "model", values_to = "value") |>
    mutate(
      ww = week(time),
      season = getSeason(time)
    ) |>
    group_by(ww, season, model) |>
    summarize(
      w_mean = mean(value),
      .groups = "drop"
    )

  df$ww[df$season == 'SUMMER' & df$ww < 12] <- df$ww[
    df$season == 'SUMMER' & df$ww < 12
  ] +
    max(df$ww)

  ggplot() +
    geom_line(
      data = filter(df, model == 'reanalysis'),
      aes(x = ww, y = w_mean),
      color = 'grey',
      linewidth = 1,
      alpha = .8
    ) +
    geom_point(
      data = filter(df, model == 'reanalysis'),
      aes(x = ww, y = w_mean),
      color = 'grey',
      alpha = .8,
      size = I(2)
    ) +
    geom_line(
      data = filter(df, model != 'reanalysis'),
      aes(x = ww, y = w_mean, color = model)
    ) +
    facet_wrap(~season, nrow = 2, scales = 'free_x') +
    # scale_x_continuous(breaks = seq(0, 12, 1)) +
    scale_color_brewer(palette = 'Dark2') +
    labs(
      x = "Week of the season",
      y = "Average",
      color = "Model"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_blank())
}


#Daily amplitude by model.
amplitude_plot <- function(data) {
  df <- data |>
    pivot_longer(cols = -c(time), names_to = "model", values_to = "value") |>
    mutate(date = as.factor(getDate(time)))

  r <- df |>
    group_by(date, model) |>
    mutate(amplitude = max(value) - min(value), daily_mean = mean(value)) |>
    ungroup()

  violin <- r |> filter(model != 'reanalysis')

  ref <- r |>
    filter(model == 'reanalysis') |>
    slice(rep(1:n(), 4)) |>
    mutate(model = rep(c("naive", "xgboost", "lstm", "cnn"), each = n() / 4))

  ggplot(violin, aes(x = model, y = amplitude)) +
    geom_boxplot(
      data = ref,
      aes(x = model, y = amplitude),
      color = 'grey',
      fill = 'white'
    ) +
    geom_violin(aes(color = model), fill = NA) +
    labs(
      x = "Model",
      y = "Daily amplitude"
    ) +
    scale_color_brewer(palette = 'Dark2') +
    theme_minimal()
}

amplitude_mape <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup()
  mape(r$truth_amplitude, r$estimate_amplitude)
}


amplitude_difference_of_means <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup() |>
    summarize(
      difference_of_means = mean(truth_amplitude) - mean(estimate_amplitude)
    )
  r[[1]]
}


amplitude_mean <- function(time, var) {
  df <- data.frame("time" = time, "var" = var)
  r <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(amplitude = max(var) - min(var)) |>
    ungroup() |>
    summarize(amplitude_mean = mean(amplitude))
  r[[1]]
}

amplitude_ratio_of_means <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup() |>
    summarize(
      difference_of_means = mean(estimate_amplitude) / mean(truth_amplitude)
    )
  r[[1]]
}

monthly_amplitude_ratio_of_means <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(date = getYearMonth(time)) |>
    group_by(date) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup() |>
    summarize(
      difference_of_means = mean(estimate_amplitude) / mean(truth_amplitude)
    )
  r[[1]]
}

yearly_amplitude_ratio_of_means <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |>
    mutate(date = getYear(time)) |>
    group_by(date) |>
    summarize(
      truth_amplitude = max(truth) - min(truth),
      estimate_amplitude = max(estimate) - min(estimate)
    ) |>
    ungroup() |>
    summarize(
      difference_of_means = mean(estimate_amplitude) / mean(truth_amplitude)
    )
  r[[1]]
}

amplitude_monthly_plot <- function(data) {
  df <- data |>
    pivot_longer(cols = -c(time), names_to = "model", values_to = "value") |>
    mutate(yy = year(time), mm = month(time)) |>
    group_by(yy, mm, model) |>
    summarise(amplitude = max(value) - min(value)) |>
    ungroup() |>
    pivot_wider(values_from = amplitude, names_from = model) |>
    pivot_longer(
      cols = c(3, 4, 5, 7),
      values_to = 'amplitude',
      names_to = 'model'
    )

  ggplot(df) +
    geom_boxplot(
      aes(x = model, y = reanalysis),
      color = 'grey',
      fill = 'white'
    ) +
    geom_violin(aes(x = model, y = amplitude, color = model), fill = NA) +
    labs(
      x = "Model",
      y = "Monthly amplitude"
    ) +
    scale_color_brewer(palette = 'Dark2') +
    theme_minimal()
}

## For internal use
#Returns the hour where the max value happen
maximum_hour <- function(time, truth, estimate) {
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)

  max_truth_per_day <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(truth_max = max(truth))

  hours_max_truth_per_day <- df |>
    mutate(date = getDate(time)) |>
    inner_join(max_truth_per_day, by = join_by(date, truth == truth_max)) |>
    distinct(date, .keep_all = TRUE) |>
    mutate(truth_hour = getHour(time)) |>
    select(truth_hour)

  max_est_values_per_day <- df |>
    mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(est_max = max(estimate))

  hours_max_est_values_per_day <- df |>
    mutate(date = getDate(time)) |>
    inner_join(
      max_est_values_per_day,
      by = join_by(date, estimate == est_max)
    ) |>
    distinct(date, .keep_all = TRUE) |>
    mutate(est_hour = getHour(time)) |>
    select(est_hour)

  hours_max_truth_per_day |>
    bind_cols(hours_max_est_values_per_day)
}

maximum_correlation <- function(time, truth, estimate) {
  result <- maximum_hour(time, truth, estimate) |>
    mutate(coincidence = if_else(truth_hour == est_hour, 1, 0)) |>
    summarize(sum(coincidence) / n())

  result[[1]]
}

maximum_difference <- function(time, truth, estimate) {
  result <- maximum_hour(time, truth, estimate) |>
    mutate(dif = abs(truth_hour - est_hour)) |>
    summarize(sum(dif) / n())

  result[[1]]
}

maximum_error <- function(time, truth, estimate) {
  n <- n_distinct(getDate(time))
  temp <- maximum_hour(time, truth, estimate)
  t <- temp |> group_by(truth_hour) |> summarize(n_t_hour = n())
  e <- temp |> group_by(est_hour) |> summarize(n_e_hour = n())
  result <- t |>
    inner_join(e, by = join_by(truth_hour == est_hour)) |>
    mutate(diff = abs(n_t_hour - n_e_hour)) |>
    summarise(maximum_error = sum(diff) / (2 * n))
  result[[1]]
}

maximum_histograms <- function(time, truth, estimate) {
  r <- maximum_hour(time, truth, estimate) |>
    pivot_longer(
      cols = c(truth_hour, est_hour),
      names_to = "model",
      values_to = "hour",
      values_drop_na = TRUE
    ) |>
    mutate(hour = as.factor(hour))
  ggplot(r, aes(x = hour, fill = model)) +
    geom_bar(position = "dodge2")
}

#For downscaling report, for legacy purpose we will not use the other functions related to maximum (if it works, don't touch it)
maximum_histograms_downscaling <- function(data, exp) {
  data <- data |>
    filter(experiment == exp) |>
    pivot_wider(names_from = model, values_from = value) |>
    distinct() |>
    mutate(day = getDate(time), hour = getHour(time)) |>
    select(-c(time, undownscaled, experiment))

  columns <- colnames(data)
  columns <- columns[columns != "hour" & columns != "day"]

  data_to_plot <- data |>
    group_by(day) |>
    summarise(
      across(
        columns,
        ~ hour[which.max(.x)], # Applies function to get the hour of peak value
        .names = "{col}"
      ) # Renames the new columns
    ) |>
    ungroup() |>
    pivot_longer(-c(day), names_to = "model", values_to = "hour") |>
    mutate(hour = as.factor(hour))

  ggplot(data_to_plot, aes(x = hour, fill = model)) +
    geom_bar(position = "dodge2") +
    labs(x = "hour")
}

monthly_boxplot <- function(time, truth, estimate) {
  p <- data.frame(time = time, truth = truth, estimate = estimate) |>
    pivot_longer(
      cols = c(truth, estimate),
      names_to = "model",
      values_to = "value"
    ) |>
    mutate(month = as.factor(getMonth(time)))

  ggplot(p, aes(x = model, y = value, fill = model)) +
    geom_boxplot() +
    scale_color_viridis() +
    theme(legend.position = "none") +
    facet_wrap(~month)
}

monthly_boxplot_2 <- function(data) {
  p <- data |>
    mutate(month = as.factor(getMonth(time)))

  ggplot(p, aes(x = model, y = value, fill = model)) +
    geom_boxplot() +
    scale_color_viridis() +
    theme(legend.position = "none") +
    facet_wrap(~month)
}

qqplot_mae <- function(truth, estimate) {
  ref_col <- "reanalysis"
  sample_data <- estimate
  ref_data <- truth

  # Sort the data
  sample_data_sorted <- sort(sample_data)
  ref_data_sorted <- sort(ref_data)

  # Calculate quantiles
  n <- min(length(sample_data_sorted), length(ref_data_sorted))
  quantiles_sample <- sample_data_sorted[seq(
    1,
    length(sample_data_sorted),
    length.out = n
  )]
  quantiles_ref <- ref_data_sorted[seq(
    1,
    length(ref_data_sorted),
    length.out = n
  )]

  mae(truth = quantiles_ref, estimate = quantiles_sample)
}

acf_mae <- function(truth, estimate) {
  t <- acf(truth, lag.max = 47, plot = F)$acf
  e <- acf(estimate, lag.max = 47, plot = F)$acf
  mae(t, e)
}

extremogram_mae <- function(truth, estimate) {
  t <- extremogram1(truth, quant = .97, maxlag = 48, type = 1, ploting = 0)
  e <- extremogram1(estimate, quant = .97, maxlag = 48, type = 1, ploting = 0)
  mae(t, e)
}

acf_plot <- function(data) {
  models <- data |> select(-c("time")) |> colnames()

  df <- lapply(models, function(x) {
    acf(data[[x]], lag.max = 47, plot = F)$acf
  }) |>
    set_names(nm = models) |>
    bind_rows(.id = 'models') |>
    tibble() |>
    mutate(lag = 1:48) |>
    pivot_longer(cols = -lag, names_to = "model", values_to = "acf") |>
    filter(lag > 1)

  acf.obs <- filter(df, model == 'reanalysis')

  ggplot() +
    geom_col(data = acf.obs, mapping = aes(x = lag, y = acf), fill = 'grey') +
    geom_line(
      data = filter(df, model != 'reanalysis'),
      mapping = aes(lag, acf, color = model)
    ) +
    scale_color_brewer(palette = 'Dark2') +
    theme_bw()
}

extremogram_plot <- function(data) {
  models <- data |> select(-c("time")) |> colnames()

  df <- lapply(models, function(x) {
    extremogram1(data[[x]], quant = .97, maxlag = 48, type = 1, ploting = 0)
  }) |>
    set_names(nm = models) |>
    bind_rows(.id = 'models') |>
    tibble() |>
    mutate(lag = 1:48) |>
    pivot_longer(cols = -lag, names_to = "model", values_to = "extremogram") |>
    filter(lag > 1)

  acf.obs <- filter(df, model == 'reanalysis')

  ggplot() +
    geom_col(
      data = acf.obs,
      mapping = aes(x = lag, y = extremogram),
      fill = 'grey'
    ) +
    geom_line(
      data = filter(df, model != 'reanalysis'),
      mapping = aes(lag, extremogram, color = model)
    ) +
    scale_color_brewer(palette = 'Dark2') +
    theme_bw()
}

hour_max_plot <- function(data) {
  res.mx <- data |>
    pivot_longer(-time, names_to = 'model', values_to = 'vs') |>
    mutate(date = ymd_hms(time) - hours(3)) |>
    mutate(dd = as_date(date), hh = hour(date)) |>
    group_by(dd, model) |>
    mutate(mx = max(vs)) |>
    ungroup() |>
    filter(vs == mx)

  ggplot() +
    geom_bar(
      data = filter(res.mx, model == 'reanalysis'),
      mapping = aes(x = hh),
      fill = 'grey'
    ) +
    geom_freqpoly(
      data = filter(res.mx, model != 'reanalysis'),
      mapping = aes(x = hh, color = model)
    ) +
    scale_color_brewer(palette = 'Dark2') +
    theme_bw()
}

#Calculates the MAE of the amount of rainy hour in a day. We considered rainy if it rains more than 0.1 mm/hour.
amount_rainy_hours_mae <- function(time, truth, estimate, threshold = 0.1) {
  data <- data.frame(
    time = time,
    truth = truth,
    estimate = estimate
  ) |>
    mutate(
      date = getDate(time),
      truth_it_rain = if_else(truth >= threshold, 1, 0),
      estimate_it_rain = if_else(estimate >= threshold, 1, 0)
    )

  data_2 <- data |>
    group_by(date) |>
    summarize(t = sum(truth_it_rain), e = sum(estimate_it_rain)) |>
    ungroup()
  mae(data_2$t, data_2$e)
}

rainy_hours_ratio_of_means <- function(time, truth, estimate, threshold = 0.1) {
  data <- data.frame(
    time = time,
    truth = truth,
    estimate = estimate
  ) |>
    mutate(
      date = getDate(time),
      truth_it_rain = if_else(truth >= threshold, 1, 0),
      estimate_it_rain = if_else(estimate >= threshold, 1, 0)
    )

  data_2 <- data |>
    group_by(date) |>
    summarize(t = sum(truth_it_rain), e = sum(estimate_it_rain)) |>
    ungroup()

  mean(data_2$t) / mean(data_2$e)
}

#Extremes accuracy
extreme_correlation <- function(time, truth, daily, estimate, quant = 0.97) {
  truth_threshold <- quantile(truth, quant)
  estimate_threshold <- quantile(estimate, quant)

  data <- data.frame(
    date = getCoarseResolution(time, daily),
    truth = truth,
    estimate = estimate
  ) |>
    mutate(
      truth_is_extreme = if_else(truth >= truth_threshold, 1, 0),
      estimate_is_extreme = if_else(estimate >= estimate_threshold, 1, 0)
    ) |>
    group_by(date) |>
    summarize(
      max_truth = max(truth_is_extreme),
      max_estimate = max(estimate_is_extreme)
    ) |>
    filter(max_truth == 1 | max_estimate == 1) |>
    mutate(coincidence = if_else(max_truth == max_estimate, 1, 0)) |>
    summarize(sum(coincidence) / n())

  data[[1]]
}

#Extreme value plot
mean_on_coarse_res_with_extremes <- function(
  time,
  value,
  daily,
  quant,
  standarize
) {
  if (standarize) {
    value <- scale(value)
  }

  # Look for the value associated with the quant
  threshold <- quantile(value, probs = quant, names = F)

  #Generate new indicator column, that is one if the day have an extreme (i.e. value is greather than the threshold)
  df <- data.frame(
    time = time,
    value = value,
    is_extreme = if_else(value >= threshold, 1, 0),
    date = getCoarseResolution(time, daily)
  )

  # Filter days with extreme values
  days_with_extremes <- df |>
    filter(is_extreme == 1)

  # Calculate the mean of these days, using all the values not only the extremes.
  mean_of_these_days <- df |>
    filter(date %in% days_with_extremes$date) |>
    group_by(date) |>
    summarize(daily_mean = mean(value)) |>
    ungroup()

  mean_of_these_days$daily_mean
}

mean_on_coarse_res_with_extremes_plot <- function(
  data,
  daily,
  quant = .97,
  standarize = T
) {
  models <- data |>
    select(-c("time")) |>
    colnames()

  p <- lapply(models, function(x) {
    data.frame(
      model = x,
      daily_mean = mean_on_coarse_res_with_extremes(
        time = data$time,
        value = data[[x]],
        daily = daily,
        quant,
        standarize
      )
    )
  })

  df <- do.call(rbind, p)

  if (daily) {
    plot_text <- "Daily mean"
  } else {
    plot_text <- "Monthly mean"
  }

  ggplot(df, aes(x = daily_mean, color = model)) +
    geom_density(bw = "nrd") +
    labs(x = plot_text)
}

mean_on_coarse_res_with_extremes_ks <- function(
  time,
  truth,
  estimate,
  daily,
  quant = .97,
  standarize = T
) {
  t1 <- mean_on_coarse_res_with_extremes(
    time,
    truth,
    daily,
    quant = quant,
    standarize = standarize
  )
  t2 <- mean_on_coarse_res_with_extremes(
    time,
    estimate,
    daily,
    quant = quant,
    standarize = standarize
  )
  unlist(ks.test(t1, t2, alternative = 'two.sided')$statistic)
}


series_plot_ds <- function(data) {
  data |>
    mutate(time = as_datetime(time)) |>
    pivot_wider(names_from = model, values_from = value) |>
    pivot_longer(
      cols = -c('time', 'reanalysis', 'undownscaled', 'experiment'),
      names_to = 'model',
      values_to = 'values'
    ) |>
    ggplot() +
    geom_line(aes(x = time, y = reanalysis), color = 'grey') +
    geom_line(
      aes(x = time, y = undownscaled),
      color = 'black',
      linetype = 'dashed'
    ) +
    geom_line(aes(x = time, y = values, color = model)) +
    labs(color = '', y = 'response') +
    scale_color_brewer(palette = 'Dark2') +
    theme_bw() +
    theme(aspect.ratio = 1 / 2)
}

detrend_qq_ds <- function(data, pps = (0:99 + .5) / 100) {
  data |>
    pivot_longer(
      cols = -c('time', 'reanalysis', 'undownscaled'),
      values_to = 'value',
      names_to = 'model'
    ) |>
    group_by(model) |>
    reframe(
      qq.obs = quantile(reanalysis, probs = pps),
      qq.und = quantile(undownscaled, probs = pps),
      qq.pred = quantile(value, probs = pps, na.rm = TRUE),
      per = pps
    ) |>
    ggplot() +
    geom_line(aes(y = qq.pred - qq.obs, x = per, color = model)) +
    geom_line(
      aes(y = qq.und - qq.obs, x = per),
      color = 'black',
      linetype = 'dashed'
    ) +
    geom_hline(yintercept = 0, linewidth = 2, color = 'grey') +
    scale_color_brewer(palette = 'Dark2') +
    theme_bw()
}


##############################################################
# Function to compute metrics table or individual plots
# variables: "sfcWind" "tas" "pr" "clt" "rsds"
# output: 'metrics', 'qqplot', 'maximum', 'hourly_dist',
#         'amplitude', 'acf', 'extremogram'
mdeval_report_out <- function(variable, output) {
  OO <- NULL # return object
  res <- paste0('data/model_evaluation_data/', variable, ".csv") |>
    here() |>
    read.csv()

  if (output == 'metrics') {
    models <- res |> select(-c("time", "reanalysis")) |> colnames()
    if (conf[["VARIABLES"]][[variable]][["daily"]]) {
      if (variable == "pr") {
        r <- lapply(models, function(x) {
          metrics_paired_hourly_rain(
            time = res$time,
            truth = res$reanalysis,
            estimate = res[[x]],
            model = x
          )
        })
      } else {
        r <- lapply(models, function(x) {
          metrics_paired_hourly(
            time = res$time,
            truth = res$reanalysis,
            estimate = res[[x]],
            model = x
          )
        })
      }
    } else {
      r <- lapply(models, function(x) {
        metrics_paired_daily(
          time = res$time,
          truth = res$reanalysis,
          estimate = res[[x]],
          model = x
        )
      })
    }

    tabla <- do.call(rbind, r) |>
      mutate(across(where(is.numeric), \(x) round(x, digits = 3))) # |>  select()

    # vector indicating if the metric is an error(-1), a gof (1), or a ratio (0)
    metr.dir <- rep(1, length(names(tabla)))
    metr.dir[grep('mae', names(tabla))] <- -1
    metr.dir[grep('ratio', names(tabla))] <- 0

    OO <- data.frame(Metric = names(tabla), t(tabla)) |>
      mutate(dr = metr.dir) |> # error direction
      as_tibble() |>
      gt() |>
      fmt_number(
        columns = everything(),
        decimals = 2
      ) |>
      data_color(
        columns = -Metric,
        method = 'numeric',
        direction = 'row',
        fn = fncol
      ) |>
      cols_hide(dr)
  }

  if (output == 'qqplot') {
    OO <- detrend_qq(res)
  }

  if (output == 'maximum') {
    # just for dayly vars so far

    if (conf[["VARIABLES"]][[variable]][["daily"]]) {
      res.mx <- res |>
        pivot_longer(-time, names_to = 'model', values_to = 'vs') |>
        mutate(date = ymd_hms(time) - hours(3)) |>
        mutate(dd = as_date(date), hh = hour(date)) |>
        group_by(dd, model) |>
        mutate(mx = max(vs)) |>
        ungroup() |>
        filter(vs == mx)

      OO <- ggplot() +
        geom_bar(
          data = filter(res.mx, model == 'reanalysis'),
          mapping = aes(x = hh),
          fill = 'grey'
        ) +
        geom_freqpoly(
          data = filter(res.mx, model != 'reanalysis'),
          mapping = aes(x = hh, color = model)
        ) +
        scale_color_brewer(palette = 'Dark2') +
        theme_bw()
    }
  }

  if (output == 'hourly_dist') {
    if (conf[["VARIABLES"]][[params$variable]][["daily"]]) {
      OO <- hourly_distribution(res)
    } else {
      OO <- week_distribution(res)
    }
  }

  if (output == 'amplitude') {
    if (conf[["VARIABLES"]][[params$variable]][["daily"]]) {
      OO <- amplitude_plot(res)
    } else {
      OO <- amplitude_monthly_plot(res)
    }
  }

  if (output == 'acf') {
    OO <- acf_plot(res)
  }

  if (output == 'extremogram') {
    OO <- extremogram_plot(res)
  }

  return(OO)
}
