# Generate ouptut for model-evaluation reports:

# R packages
library(here)
library(tidyverse)
library(gt)
library(plotly)
library(yaml)
library(extremogram)

# custom functions
source(here('code/metrics.R'))
source(here('code/utils.R'))
conf <- yaml.load_file(here("code/conf.yml"))

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

    #  "ratio_of_sd"         "KGE"
    #  "cor"
    #  "sign_correlation"    "extreme_correlation"
    #  "mae"
    # "amplitude_mae"       "maximum_difference"
    #   "qqplot_mae"          "acf_mae"
    #  "extremogram_mae"

    # a function for color the best cell in each metric
    fncol <- function(x) {
      n <- length(x)

      if (x[n] == 0) {
        x <- abs(x - 1)
        x[n] <- -1
      }
      x <- x[n] * x
      wm <- which.max(x[-n])

      o <- character(n)
      o <- rep("white", n)
      o[wm] <- "#045a8d"
      return(o)
    }

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
    pps <- (0:99 + .5) / 100
    OO <- res |>
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
    OO <- hourly_distribution(res)
  }

  if (output == 'amplitude') {
    OO <- amplitude_plot(res)
  }

  if (output == 'acf') {
    models <- res |> select(-c("time")) |> colnames()

    results <- lapply(models, function(x) {
      acf(res[[x]], lag.max = 47, plot = F)$acf
    }) |>
      set_names(nm = models) |>
      bind_rows(.id = 'models') |>
      tibble() |>
      mutate(lag = 1:48) |>
      pivot_longer(cols = -lag, names_to = "model", values_to = "acf") |>
      filter(lag > 1)

    res.acf.obs <- filter(results, model == 'reanalysis')

    OO <- ggplot() +
      geom_col(
        data = res.acf.obs,
        mapping = aes(x = lag, y = acf),
        fill = 'grey'
      ) +
      geom_line(
        data = filter(results, model != 'reanalysis'),
        mapping = aes(lag, acf, color = model)
      ) +
      scale_color_brewer(palette = 'Dark2') +
      theme_bw()
  }

  if (output == 'extremogram') {
    models <- res |> select(-c("time")) |> colnames()
    results <- lapply(models, function(x) {
      extremogram1(res[[x]], quant = .97, maxlag = 48, type = 1, ploting = 0)
    }) |>
      set_names(nm = models) |>
      bind_rows(.id = 'models') |>
      tibble() |>
      mutate(lag = 1:48) |>
      pivot_longer(
        cols = -lag,
        names_to = "model",
        values_to = "extremogram"
      ) |>
      filter(lag > 1)

    res.acf.obs <- filter(results, model == 'reanalysis')

    OO <- ggplot() +
      geom_col(
        data = res.acf.obs,
        mapping = aes(x = lag, y = extremogram),
        fill = 'grey'
      ) +
      geom_line(
        data = filter(results, model != 'reanalysis'),
        mapping = aes(lag, extremogram, color = model)
      ) +
      scale_color_brewer(palette = 'Dark2') +
      theme_bw()
  }

  return(OO)
}


mdeval_report_out(variable = 'tas', output = 'metrics')
mdeval_report_out(variable = 'tas', output = 'extremogram')


mdeval_report_out(variable = 'clt', output = 'metrics')
