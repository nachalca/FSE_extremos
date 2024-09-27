library(ggplot2)
library('here')
library('viridis')
library('metrica')
library('ggforce')
library(colorspace)
setwd(here())
source('code/utils.R')

metrics <- function(time, truth, estimate, model){
  df <- data.frame(
    "diff_of_means" = c(diff_of_means_per(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
   # "ks_test" = c(ks(truth, estimate)),
    "amplitude_ratio_of_means" = c(amplitude_ratio_of_means(time, truth, estimate)),
    "maximum_error" = c(maximum_error(time, truth, estimate)),
    "sign_error" = c(sign_error(time, truth, estimate))
  )
  rownames(df) <- c(model)
  df
}

metrics_daily <- function(time, truth, estimate, model){
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

metrics_monthly <- function(time, truth, estimate, model){
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


#use when the truth and the estimate come from the same model
metrics_2 <- function(time, truth, estimate, model){
  df <- data.frame(
  #  "rmse" = c(rmse(truth, estimate)),
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ratio_of_sd" =  c(ratio_of_sd(truth, estimate)),
    "KGE" = KGE(obs = truth, pred = estimate),
  #  "ks_test" = c(ks(truth, estimate)),
    "amplitude_mae" = c(amplitude_mae(time, truth, estimate)),
    "maximum_correlation" = c(maximum_correlation(time, truth, estimate)),
    "sign_correlation" = c(sign_correlation(truth, estimate))
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

amount_of_rainy_hours <- function(time, truth, estimate){
  
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
      pivot_longer(cols = -c(time), names_to = "model", values_to = "value") |>
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