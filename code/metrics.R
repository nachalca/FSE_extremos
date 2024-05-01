library(ggplot2)
source("utils.R")

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
    ungroup() |>
    rmse(truth_amplitude, estimate_amplitude)
  r[[3]]
}

amplitude_mape <- function(time, truth, estimate){
  df <- data.frame("time" = time, "truth" = truth, "estimate" = estimate)
  r <- df |> mutate(date = getDate(time)) |> 
    group_by(date) |>
    summarize(truth_amplitude = max(truth) - min(truth), estimate_amplitude = max(estimate) - min(estimate)) |>
    ungroup() |>
    mape(truth_amplitude, estimate_amplitude)
  r[[3]]
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
    summarize(sum(coincidence))
  
  result[[1]]
}

maximum_difference <- function(time, truth, estimate){
  
  result <- maximum_hour(time, truth, estimate)  |> 
    mutate(dif = abs(truth_hour - est_hour)) |>
    summarize(sum(dif))
  
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