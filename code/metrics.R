library(ggplot2)
library('here')
setwd(here())
source('code/utils.R')

metrics <- function(time, truth, estimate, model){
  df <- data.frame(
    "diff_of_means" = c(diff_of_means(truth, estimate)),
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "ks_test" = c(ks(truth, estimate)),
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
    "ratio_of_sd" = c(ratio_of_sd(truth, estimate)),
    "ks_test" = c(ks(truth, estimate))
  )
  rownames(df) <- c(model)
  df
}


#use when the truth and the estimate come from the same model
metrics_2 <- function(time, truth, estimate, model){
  df <- data.frame(
    "rmse" = c(rmse(truth, estimate)),
    "mae" = c(mae(truth, estimate)),
    "cor" = c(correlation(truth, estimate)),
    "ks_test" = c(ks(truth, estimate)),
    "amplitude_rmse" = c(amplitude_rmse(time, truth, estimate)),
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


amplitude_rmse <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() 
  
  rmse(r$truth_amplitude, r$estimate_amplitude)
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

amplitude_ratio_of_means <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() |>
    summarize(difference_of_means = mean(estimate_amplitude)/mean(truth_amplitude))
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


## For internal use 
maximum_hour <- function(time, truth, estimate){
  #Returns the hour where the max value happen
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

maximum_histograms <- function(time, truth, estimate){
  r <- maximum_hour(time, truth, estimate) |> pivot_longer(cols = c(truth_hour, est_hour),
                                                           names_to = "model",
                                                           values_to = "hour",
                                                           values_drop_na = TRUE
                                                          ) |> mutate(hour = as.factor(hour))
  ggplot(r, aes(x = hour, fill = model)) + 
    geom_bar(position = "dodge2") 
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