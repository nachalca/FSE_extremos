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
metrics_unpaired_hourly <- function(time, truth, estimate, model){
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "amplitude_ratio_of_means" = c(amplitude_ratio_of_means(time, truth, estimate)),
    "maximum_error" = c(maximum_error(time, truth, estimate)),
    "sign_error" = c(sign_error(time, truth, estimate)),
    "qqplot_mae" = c(qqplot_mae(truth, estimate))    
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
metrics_unpaired_daily <- function(time, truth, estimate, model){
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
  #  "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "monthly_amplitude_ratio_of_means" = c(monthly_amplitude_ratio_of_means(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "qqplot_mae" = c(qqplot_mae(truth, estimate))
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
metrics_unpaired_monthly <- function(time, truth, estimate, model){
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "yearly_amplitude_ratio_of_means" = c(yearly_amplitude_ratio_of_means(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
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
metrics_paired_hourly <- function(time, truth, estimate, model){
  df <- data.frame(
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" =  c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
    "amplitude_mae" = c(amplitude_mae(time, truth, estimate)),
    "maximum_correlation" = c(maximum_correlation(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "acf_mae" = c(acf_mae(truth,estimate)),
    "extremogram_mae" = c(extremogram_mae(truth,estimate))
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
metrics_paired_hourly_rain <- function(time, truth, estimate, model){
  df <- data.frame(
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" =  c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
    "amplitude_mae" = c(amplitude_mae(time, truth, estimate)),
    "maximum_correlation" = c(maximum_correlation(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "acf_mae" = c(acf_mae(truth,estimate)),
    "extremogram_mae" = c(extremogram_mae(truth,estimate)),
    "amount_rainy_hours_mae" = amount_rainy_hours_mae(time, truth, estimate)
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
metrics_paired_daily <- function(time, truth, estimate, model){
  df <- data.frame(
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" =  c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
#    "amplitude_mae" = c(amplitude_mae(time, truth, estimate)),
#    "maximum_correlation" = c(maximum_correlation(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate)),
    "acf_mae" = c(acf_mae(truth,estimate)),
    "extremogram_mae" = c(extremogram_mae(truth,estimate))
  )
  rownames(df) <- c(model)
  df
}

diff_of_means <- function(truth, estimate){
  mean(truth) - mean(estimate)
}

diff_of_means_per <- function(truth, estimate){
  100*diff_of_means(truth, estimate)/mean(truth)
}

correlation <- function(truth, estimate){
  cor(truth, estimate)
}

ratio_of_sd <- function(truth, estimate){
  sd(estimate)/sd(truth)
}

rmse <- function(truth, estimate){
  sqrt(sum((truth - estimate)^2)/length(truth))
}

mae <- function(truth, estimate){
  sum(abs(truth - estimate))/length(truth)
}
mape <- function(truth, estimate){
  (sum(abs((truth - estimate)/truth))/length(truth))*100
}

ks <- function(truth, estimate){
  p <- ks.test(truth, estimate)
  p$p.value
}

sign_error <- function(time, truth, estimate) {
  n <- n_distinct(getDate(time))
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  
  cor <- df |> mutate(hour = getHour(time),
                      nxt_truth = if_else(lead(truth) > truth, 1, 0), 
                      nxt_estimate = if_else(lead(estimate) > estimate, 1, 0)) |>
               na.omit() |>
               group_by(hour) |>
               summarise(sgn = abs(sum(nxt_truth)/n - sum(nxt_estimate)/n)) |>
               ungroup() |>
               summarise(result = sum(sgn)/24)
  cor[[1]]
}

sign_correlation <- function(truth, estimate) {
  df <- data.frame("truth" = truth, "estimate" = estimate)
  cor <- df |> mutate(nxt_truth = if_else(lead(truth) > truth, 1, -1), 
                      nxt_estimate = if_else(lead(estimate) > estimate, 1, -1)) |> 
    mutate(same_behaviour = if_else(nxt_truth == nxt_estimate,1, 0)) |>
    filter(row_number() <= n() - 1) |>
    summarise(cor = sum(sign_correlation = same_behaviour)/n())
  cor[[1]]
}


amplitude_mae <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() 
  
  mae(r$truth_amplitude, r$estimate_amplitude)
}

#Daily amplitude by model.
amplitude_plot <- function(data){
  df <- data |>
    pivot_longer(cols = -c(time),
                 names_to = "model",
                 values_to = "value") |>
    mutate(date = as.factor(getDate(time)))
  
  r <- df |> 
    group_by(date,model) |>
    mutate(amplitude = max(value) - min(value), daily_mean = mean(value)) |>
    ungroup() 
  
  ggplot(r, aes(model, amplitude, colour=daily_mean), alpha = 1/10000) +
    scale_color_continuous_sequential("Batlow") +
    geom_sina()
}

amplitude_mape <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() 
  mape(r$truth_amplitude, r$estimate_amplitude)
}


amplitude_difference_of_means <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() |>
    summarize(difference_of_means = mean(truth_amplitude) - mean(estimate_amplitude))
  r[[1]]
}


amplitude_mean <- function(time, var){
  df <- data.frame("time" = time, "var" = var)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(amplitude = max(var) - min(var)) |>
    ungroup() |>
    summarize(amplitude_mean = mean(amplitude))
  r[[1]]
}

amplitude_ratio_of_means <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() |>
    summarize(difference_of_means = mean(estimate_amplitude)/mean(truth_amplitude))
  r[[1]]
}

monthly_amplitude_ratio_of_means <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getYearMonth(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() |>
    summarize(difference_of_means = mean(estimate_amplitude)/mean(truth_amplitude))
  r[[1]]
}

yearly_amplitude_ratio_of_means <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getYear(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() |>
    summarize(difference_of_means = mean(estimate_amplitude)/mean(truth_amplitude))
  r[[1]]
}

## For internal use 
#Returns the hour where the max value happen
maximum_hour <- function(time, truth, estimate){

  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  
  max_truth_per_day <- df |> mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(truth_max = max(truth)) 
  
  hours_max_truth_per_day <- df |> mutate(date = getDate(time)) |> 
    inner_join(max_truth_per_day, by = join_by(date, truth == truth_max)) |>
    distinct(date, .keep_all = TRUE) |>
    mutate(truth_hour = getHour(time)) |> 
    select(truth_hour)
  
  max_est_values_per_day <- df |> mutate(date = getDate(time)) |>
    group_by(date) |>
    summarize(est_max = max(estimate)) 
  
  hours_max_est_values_per_day <- df |> mutate(date = getDate(time)) |> 
    inner_join(max_est_values_per_day, by = join_by(date, estimate == est_max)) |>
    distinct(date, .keep_all = TRUE) |>
    mutate(est_hour = getHour(time)) |> 
    select(est_hour)
  
  hours_max_truth_per_day |> 
    bind_cols(hours_max_est_values_per_day)
}

maximum_correlation <- function(time, truth, estimate){
  
  result <- maximum_hour(time, truth, estimate) |> 
    mutate(coincidence = if_else(truth_hour == est_hour, 1, 0)) |>
    summarize(sum(coincidence)/n())
  
  result[[1]]
}

maximum_difference <- function(time, truth, estimate){
  
  result <- maximum_hour(time, truth, estimate)  |> 
    mutate(dif = abs(truth_hour - est_hour)) |>
    summarize(sum(dif)/n())
  
  result[[1]]
}

maximum_error <- function(time, truth, estimate){
  n <- n_distinct(getDate(time))
  temp <- maximum_hour(time, truth, estimate)
  t <- temp |> group_by(truth_hour) |> summarize(n_t_hour = n())
  e <- temp |> group_by(est_hour) |> summarize(n_e_hour = n())
  result <- t |> 
    inner_join(e, by = join_by(truth_hour == est_hour)) |> 
    mutate(diff = abs(n_t_hour - n_e_hour)) |> 
    summarise(maximum_error = sum(diff)/(2*n))
  result[[1]]
}

maximum_histograms <- function(time, truth, estimate){
  r <- maximum_hour(time, truth, estimate) |> pivot_longer(cols = c(truth_hour, est_hour),
                                                           names_to = "model",
                                                           values_to = "hour",
                                                           values_drop_na = TRUE
                                                          ) |> mutate(hour = as.factor(hour))
  ggplot(r, aes(x = hour, fill = model)) + 
    geom_bar(position = "dodge2") 
}

#For downscaling report, for legacy purpose we will not use the other functions related to maximum (if it works, don't touch it)
maximum_histograms_downscaling <- function(data, exp){
 data <- data |> 
    filter(experiment == exp) |>
    pivot_wider(names_from = model, values_from = value) |>
    distinct() |>
    mutate(day = getDate(time),
           hour = getHour(time)) |>
   select(-c(time, undownscaled, experiment))
 
 columns <- colnames(data)
 columns <- columns[columns != "hour" & columns !=  "day"]
 
 data_to_plot <- data |>
   group_by(day) |>
   summarise(
     across(columns,
            ~ hour[which.max(.x)],        # Applies function to get the hour of peak value
            .names = "{col}")   # Renames the new columns
   ) |>
   ungroup() |>
   pivot_longer(-c(day),
                names_to = "model",
                values_to = "hour") |>
   mutate(hour = as.factor(hour))

 ggplot(data_to_plot, aes(x = hour, fill = model)) + 
   geom_bar(position = "dodge2")  +
   labs(x = "hour")
   
}

monthly_boxplot <- function(time, truth, estimate){
  p <- data.frame(time = time, truth = truth, estimate = estimate) |>
        pivot_longer(cols = c(truth, estimate),
                     names_to = "model",
                     values_to = "value") |>
        mutate(month = as.factor(getMonth(time)))
    
  ggplot(p, aes(x = model, y = value, fill = model)) +
    geom_boxplot() + 
    scale_color_viridis() +
    theme(legend.position = "none") +
    facet_wrap(~month)
}

monthly_boxplot_2 <- function(data){
    p <- data |> 
      mutate(month = as.factor(getMonth(time)))
    
    ggplot(p, aes(x = model, y = value, fill = model)) +
      geom_boxplot() + 
      scale_color_viridis() +
      theme(legend.position = "none") +
      facet_wrap(~month)
}

qqplot_mae <- function(truth, estimate){
  ref_col <- "reanalysis"
  sample_data <- estimate
  ref_data <- truth
  
  # Sort the data
  sample_data_sorted <- sort(sample_data)
  ref_data_sorted <- sort(ref_data)
  
  # Calculate quantiles
  n <- min(length(sample_data_sorted), length(ref_data_sorted))
  quantiles_sample <- sample_data_sorted[seq(1, length(sample_data_sorted), length.out = n)]
  quantiles_ref <- ref_data_sorted[seq(1, length(ref_data_sorted), length.out = n)]
  
  mae(truth = quantiles_ref, estimate = quantiles_sample)
}

acf_mae <- function(truth, estimate){
  t <- acf(truth, lag.max = 47, plot = F)$acf
  e <- acf(estimate, lag.max = 47, plot = F)$acf
  mae(t,e)
}

extremogram_mae <- function(truth, estimate){
  t <- extremogram1(truth, quant = .97, maxlag = 48, type = 1, ploting = 0)
  e <- extremogram1(estimate, quant = .97, maxlag = 48, type = 1, ploting = 0)
  mae(t,e)
}

#Calculates the MAE of the amount of rainy hour in a day. We considered rainy if it rains more than 0.1 mm/hour.
amount_rainy_hours_mae <- function(time, truth, estimate, threshold = 0.1){
  data <- data.frame(
    time = time,
    truth = truth,
    estimate = estimate
  ) |> 
    mutate(date = getDate(time),
           truth_it_rain = if_else(truth >= threshold, 1, 0),
           estimate_it_rain = if_else(estimate >= threshold, 1, 0))
  
  data_2 <- data |> 
    group_by(date) |>
    summarize(t = sum(truth_it_rain),
              e = sum(estimate_it_rain)) |>
    ungroup()
  mae(data_2$t,data_2$e)
}

#Extremes accuracy
extreme_accuracy <- function(time, truth, estimate, quant = 0.97){
  truth_threshold <- quantile(truth, quant)
  estimate_threshold <- quantile(estimate, quant)
  
  data <- data.frame(
    time = time,
    truth = truth,
    estimate = estimate
  ) |> 
    mutate(truth_is_extreme= if_else(truth >= truth_threshold, 1, 0),
           estimate_is_extreme = if_else(estimate >= estimate_threshold, 1,0))
  
  precision(data, truth_is_extreme, estimate_is_extreme)
  recall(data, truth_is_extreme, estimate_is_extreme)
}

#Extreme value plot
mean_on_days_with_extremes <- function(time, value, quant){
  threshold <- quantile(value, probs = quant, names = F)
  
  df <- data.frame(
    time = time,
    value = value,
    is_extreme = if_else(value >= threshold, 1, 0),
    date = getDate(time)
  ) 
  
  days_with_extremes <- df |>
    filter(is_extreme == 1)
  
  mean_of_these_days <- df |>
    filter(date %in% days_with_extremes$date) |>
    group_by(date) |>
    summarize(undownscaled_value = mean(value)) |>
    ungroup()
  
  
  mean_of_these_days$undownscaled_value
}

mean_on_days_with_extremes_plot <- function(data, quant = .97){
  models <- data |> 
    select(-c("time")) |> 
    colnames()
  
  p <- lapply(models, function(x) {
    data.frame(
      model = x,
      undownscaled_value = mean_on_days_with_extremes(time = data$time, value = data[[x]], quant)
    )
  })
  
  df <- do.call(rbind, p)
  
  ggplot(df, aes(x=undownscaled_value, color = model)) +
    geom_density(bw = "nrd") +
    labs(x = "Undownscaled Value")
}