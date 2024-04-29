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

maximum_correlation <- function(time, truth, estimate){
  
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
  
  result <- hours_max_truth_per_day |> 
    bind_cols(hours_max_est_values_per_day) |> 
    mutate(coincidence = if_else(truth_hour == est_hour, 1, 0)) |>
    summarize(sum(coincidence))
  
  result[[1]]
}

maximum_difference <- function(time, truth, estimate){
  
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
  
  result <- hours_max_truth_per_day |> 
    bind_cols(hours_max_est_values_per_day) |> 
    mutate(dif = abs(truth_hour - est_hour)) |>
    summarize(sum(dif))
  
  result[[1]]
}