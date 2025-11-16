library(tidyverse)
library(here)
library("extremogram")
source('code/metrics.R')
source('code/utils.R')
# install.packages('openair')
library(openair) # taylor diagram
library(patchwork)

# obtener los datos --------------------
# params <- vector(mode = 'list')
# params$variable <- 'tas'
# x <- paste0('data/validation/', params$variable, ".csv")
# variable <- read.csv(x)
# variable_long <- variable |>
#   pivot_longer(!time, names_to = "model", values_to = "value")

ff <- list.files(
  'data/validation/',
  full.names = TRUE,
  pattern = 'tas.csv|pr|sfcWind'
)
vars <- gsub('.csv', '', basename(ff))

# all data
dds <- lapply(ff, read.csv) |>
  set_names(nm = vars) |>
  bind_rows(.id = 'respuesta') |>
  pivot_longer(cols = -c(1:3), names_to = "model", values_to = "value") |>
  as.data.frame()


# armar qq plot -----------------
pps = (0:99 + .5) / 100
dds |>
  group_by(model, respuesta) |>
  reframe(
    qq.obs = quantile(reanalysis, probs = pps),
    qq.pred = quantile(value, probs = pps, na.rm = TRUE),
    per = pps
  ) |>
  mutate(
    rr = factor(
      respuesta,
      labels = c('Precipitation', 'Wind Speed', 'Temperature')
    )
  ) |>
  ggplot() +
  geom_line(aes(y = qq.pred, x = qq.obs, color = model)) +
  geom_abline(slope = 1, linetype = 'dashed') +
  facet_wrap(~rr, scale = 'free') +
  labs(y = 'Quantiles CMIP6', color = '', x = 'Quantiles Reanalysis') +
  scale_color_brewer(palette = 'Dark2') +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = 'bottom')

ggsave(here('reports/informes_anii/qq_cmip6_all.png'), width = 8, height = 6)

# armar acf plot -----------------
zz <- dds |>
  group_by(model, respuesta) |>
  reframe(
    qq.obs = acf(reanalysis, lag.max = 47, plot = F)$acf,
    qq.pred = acf(value, lag.max = 47, plot = F)$acf,
    lag = 1:48
  ) |>
  mutate(
    rr = factor(
      respuesta,
      labels = c('Precipitation', 'Wind Speed', 'Temperature')
    )
  ) |>
  filter(lag > 1)

ggplot(zz) +
  geom_col(
    data = zz |> filter(model == 'cesm2_ssp2_4_5'),
    mapping = aes(x = lag, y = qq.obs),
    fill = 'grey'
  ) +
  geom_line(mapping = aes(lag, qq.pred, color = model)) +
  facet_wrap(~rr, scale = 'free') +
  scale_color_brewer(palette = 'Dark2') +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = 'bottom')

ggsave(here('reports/informes_anii/qq_acf_all.png'), width = 8, height = 6)

# armar extremogram plot -----------------
zz <- dds |>
  group_by(model, respuesta) |>
  reframe(
    qq.obs = extremogram1(
      reanalysis,
      quant = .95,
      maxlag = 11,
      type = 1,
      ploting = 0
    ),
    qq.pred = extremogram1(
      value,
      quant = .95,
      maxlag = 11,
      type = 1,
      ploting = 0
    ),
    lag = 1:11
  ) |>
  mutate(
    rr = factor(
      respuesta,
      labels = c('Precipitation', 'Wind Speed', 'Temperature')
    )
  ) |>
  filter(lag > 1)

ggplot(zz) +
  geom_col(
    data = zz |> filter(model == 'cesm2_ssp2_4_5'),
    mapping = aes(x = lag, y = qq.obs),
    fill = 'grey'
  ) +
  geom_line(
    mapping = aes(lag, qq.pred, color = model)
  ) +
  facet_wrap(~rr, scale = 'free') +
  scale_color_brewer(palette = 'Dark2') +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = 'bottom')

ggsave(here('reports/informes_anii/qq_ext_all.png'), width = 8, height = 6)

# taylor diagram -----------------
dds_mm <- dds |>
  mutate(dd = ymd(time)) |>
  group_by(year(dd), month(dd), model, respuesta) |>
  summarise(reanalysis = mean(reanalysis), value = mean(value)) |>
  data.frame()


TaylorDiagram(
  mydata = dds_mm,
  obs = 'reanalysis',
  mod = 'value',
  group = c('model'),
  type = 'respuesta',
  normalise = TRUE
)


########################################################################
########################################################################
########################################################################
#-----------------
# Taylor para validacion CMIP6 ------------------

tas <- read.csv('data/validation/tas.csv')

validation_taylor_fn <- function(dd, mm) {
  res_long <- dd |>
    pivot_longer(cols = -c(1:2), names_to = "model_exp", values_to = "value") |>
    separate(
      col = model_exp,
      sep = "_ss",
      into = c("model", "experiment"),
      extra = "merge",
      remove = FALSE
    ) |>
    mutate(experiment = paste0('ss', experiment))

  TaylorDiagram(
    mydata = res_long,
    obs = 'reanalysis',
    group = 'model_exp',
    mod = 'value',
    main = mm,
    cex = 2
  )
}


ff <- list.files('data/validation/', full.names = TRUE)
pls <- vector(mode = 'list', length = length(ff))
vars <- gsub('.csv', '', basename(ff))

# individual taylor plots
for (i in 1:length(ff)) {
  dt <- read.csv(ff[i])
  pls[[i]] <- validation_taylor_fn(dt, mm = vars[i])
}

# all data
dds <- lapply(ff, read.csv) |>
  set_names(nm = vars) |>
  bind_rows(.id = 'respuesta') |>
  pivot_longer(cols = -c(1:3), names_to = "model", values_to = "value") |>
  as.data.frame()

separate(
  col = model,
  sep = "_ss",
  into = c("model", "experiment"),
  extra = "merge"
) |>
  mutate(
    experiment = paste0('ss', experiment),
    date = as.Date(time, format = "%Y-%m-%d")
  ) |>

  prueba <- filter(dds, respuesta %in% c('tas', 'tasmax', 'tasmin')) |>
  select(date, reanalysis, value, respuesta) |>
  as.data.frame()

TaylorDiagram(
  mydata = dds,
  obs = 'reanalysis',
  mod = 'value',
  group = c('model'),
  type = 'respuesta',
  normalise = TRUE
)

p1$data |>
  separate(MyGroupVar, into = c("respuesta", "experiment"), extra = "merge") |>
  ggplot() +
  geom_point(aes(x = R, y = sd.mod, color = respuesta))


#-----------------
# Resultados de "model_evaluation"
#-----------------
ff <- list.files('data/model_evaluation_data/', full.names = TRUE)
dds <- lapply(ff, read.csv)
vars <- gsub('.csv', '', basename(ff))
names(dds) <- vars

dt <- bind_rows(dds, .id = 'respuesta') |>
  pivot_longer(cols = -c(1:3), values_to = 'value', names_to = 'model')

pls <- vector(mode = 'list', length = length(vars))

for (i in 1:length(vars)) {
  m <- vars[i]
  pls[[i]] <- TaylorDiagram(
    mydata = filter(dt, respuesta == m),
    obs = 'reanalysis',
    group = 'model',
    mod = 'value',
    main = m,
    normalise = TRUE
  )
}
names(pls) <- vars

lapply(pls, function(x) x$data) |>
  bind_rows(.id = 'respuesta')


pl <- TaylorDiagram(
  mydata = dt,
  obs = 'reanalysis',
  group = c('respuesta', 'model'),
  mod = 'value',
  normalise = TRUE,
  cex = 1
)


pl$data |> View()

pl$data |>
  separate(MyGroupVar, into = c('var', 'predictor'), extra = 'merge') |>
  ggplot() +
  geom_point(aes(x = R, y = sd.mod, shape = predictor, color = var)) +
  scale_color_brewer(palette = 'Dark2')


pps <- (0:99 + .5) / 100

res |>
  pivot_longer(cols = -c(1:2), values_to = 'value', names_to = 'model') |>
  group_by(model) |>
  reframe(
    qq.obs = quantile(reanalysis, probs = pps),
    qq.pred = quantile(value, probs = pps, na.rm = TRUE),
    per = pps
  ) |>
  ggplot() +
  geom_line(aes(qq.obs, qq.pred, color = model)) +
  geom_abline(slope = 1, linetype = 'dashed') +
  #facet_wrap(~respuesta, scale='free') +
  scale_color_brewer(palette = 'Dark2') +
  theme_bw()

res |>
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


#########################################################
res <- dds[[5]]

models <- res |> select(-c("time", "reanalysis")) |> colnames()

r <- lapply(models, function(x) {
  metrics_paired_hourly(
    time = res$time,
    truth = res$reanalysis,
    estimate = res[[x]],
    model = x
  )
})

results <- do.call(rbind, r) |>
  mutate(across(where(is.numeric), round, digits = 3))


pps <- (0:99 + .5) / 100
res_qq <- dt |>
  group_by(model, respuesta) |>
  reframe(
    qq.obs = quantile(reanalysis, probs = pps),
    qq.pred = quantile(value, probs = pps, na.rm = TRUE),
    per = pps
  )

ggplot(res_qq) +
  geom_line(aes(qq.obs, qq.pred, color = model)) +
  geom_abline(slope = 1, linetype = 'dashed') +
  facet_wrap(~respuesta, scale = 'free') +
  scale_color_brewer(palette = 'Dark2') +
  theme_bw()

ggplot(res_qq) +
  geom_line(aes(y = qq.pred - qq.obs, x = per, color = model)) +
  geom_hline(yintercept = 0, linetype = 'dashed') +
  facet_wrap(~respuesta, scales = 'free_y') +
  scale_color_brewer(palette = 'Dark2') +
  theme_bw()


#########################################################

#-----------------
# Taylor con resultados  DS ------------------
# Load re-analisis
reanalysis <- read.csv('data/reanalysis/reanalysis.csv')
reanalysis <- reanalysis |> select(time, reanalysis = 'tas')

# TAS downscaled data
res_validation_wide <- read.csv('data/downscaled_data/tas.csv') |>
  inner_join(reanalysis)

res_prediction_wide <- res_validation_wide |>
  filter(!(time %in% res_validation_wide$time))

res_long <- res_validation_wide |>
  pivot_longer(cols = 3:37, names_to = "model", values_to = "value") |>
  separate(
    col = model,
    sep = "\\.",
    into = c("model", "experiment"),
    extra = "merge"
  )

# taylor plot
TaylorDiagram(
  mydata = res_long,
  obs = 'reanalysis',
  group = c('model', 'experiment'),
  mod = 'value'
)
#-----------------
