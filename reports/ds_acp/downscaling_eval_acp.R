# Fichero: downscaling_eval_acp.R
# Descripcion : Analisis de las metricas de 3 variables (tas, clt, sfcWind) para todos los
# escenarios con todos los predictores
library(tidyverse)
library(FactoMineR)

ff <- list.files("reports/ds_acp/", full.names = T, pattern = '.csv')

d_tas <- lapply(ff[grep('tas_', ff)], read_csv) |>
  bind_rows() |>
  mutate(response = 'tas')

glimpse(d_tas)

d_pr <- lapply(ff[grep('pr_', ff)], read_csv) |>
  bind_rows() |>
  mutate(response = 'pr')

d_sfcWind <- lapply(ff[grep('sfcWind_', ff)], read_csv) |>
  bind_rows() |>
  mutate(response = 'wind')


# clt and rsds are monthly variables #
#d_clt <- read.table("~/Documents/clt_metrics.txt", header = TRUE, row.names = 1)
#rownames(d_clt) <- paste0("clt_", rownames(d_clt))
#d_rsds <- read.table("~/Documents/rsds_metrics.txt", header = TRUE, row.names = 1)
#rownames(d_rsds) <- paste0("rsds_", rownames(d_rsds))

d <- list(d_tas, d_pr, d_sfcWind) |>
  bind_rows() |>
  #separate(sce, into=c('model', 'sce'), sep= '_' ) |>
  pivot_longer(cols = cnn:lstm, values_to = 'vv', names_to = 'predictor') |>
  pivot_wider(names_from = Metric, values_from = vv) |>
  mutate(
    exp = strsplit(sce, "_") |> lapply(function(z) z[length(z)]) |> unlist()
  ) |>
  mutate(center = sub("_ssp\\d+$", "", sce))

# transform each measurment to represent 'error'
# at the end: all positive measures, the smaller the better

dd <- d |>
  mutate(
    diff_of_means = abs(diff_of_means),
    ratio_of_sd = abs(1 - ratio_of_sd),
    amplitude_ratio_of_means = abs(1 - amplitude_ratio_of_means),
    ks_mean_on_coarse_res_with_extremes = 1 -
      ks_mean_on_coarse_res_with_extremes
  ) |>
  select(-rainy_hours_ratio_of_means)

nm_cols <- sapply(dd, is.numeric)
dd[, nm_cols] <- scale(dd[, nm_cols])
summary(dd)


library(GGally)
ggcorr(dd[, nm_cols])

dd |>
  #filter(response == 'tas') |>
  ggparcoord(
    columns = colnames(dd)[nm_cols],
    groupColumn = 'predictor',
    order = 'allClass'
  ) +
  facet_grid(response ~ center)


dd |>
  pivot_longer(
    cols = diff_of_means:extremogram_mae,
    names_to = 'metric',
    values_to = 'error'
  ) |>
  ggplot(aes(x = center, y = error, color = predictor)) +
  #geom_jitter( position = position_dodge(.5)) +
  geom_boxplot() +
  facet_wrap(~response)

dd_long <- dd |>
  pivot_longer(
    cols = diff_of_means:extremogram_mae,
    names_to = 'metric',
    values_to = 'error'
  )

# try with linear model
library(ggthemes)
library(modelbased)
library(parameters)
library(xtable)

mm <- lm(
  error ~ response + response:exp + predictor / response + response * center,
  data = dd_long
)
anova(mm) # significant: response, center, response:center, response:predictor

mm <- lm(
  error ~ response + response:exp + response:predictor + response:center,
  data = dd_long
)
anova(mm) # exp is not relevant: it is ok to compare downscaled series under dif scenarios
anova(mm) |> model_parameters() |> xtable()

mm1 <- lm(
  error ~ predictor * center,
  data = filter(dd_long, response == 'pr')
)
anova(mm1)


# compute estimated marginal means
?estimate_means
res.mn <- estimate_means(mm, by = c('response', 'center', 'predictor'))

ggplot(res.mn, aes(x = predictor, y = Mean, color = center)) +
  geom_point(size = 2) +
  facet_wrap(~Response) +
  labs(colo = '', x = '', y = 'Error mean') +
  scale_color_colorblind() +
  theme_bw() +
  theme(legend.position = 'bottom', aspect.ratio = 1)

res.mn |>
  mutate(
    resp = factor(Response, labels = c('Precipitation', 'Temperature', 'Wind'))
  ) |>
  # with( table(resp, Response))
  ggplot() +
  geom_pointrange(
    aes(x = predictor, y = Mean, color = center, ymin = CI_low, ymax = CI_high),
    position = position_dodge(.5)
  ) +
  #facet_grid(Response ~ center) +
  facet_grid(~resp) +
  labs(color = '', x = '', y = 'Error mean') +
  scale_color_colorblind() +
  theme_bw() +
  theme(legend.position = 'bottom')

ggsave(filename = 'reports/figures/DSerrormean.png', height = 3.5, width = 7)

# try with pca...
pca.res <- PCA(dd, quali.sup = c(1:3, 12:13), graph = FALSE)

names(pca.res)
#plot(pca.res, graph.type = 'ggplot', habillage = 3, label = 'var' )

pl.pca <- cbind(dd, pca.res$ind$coord[, 1:2]) |>
  mutate(
    resp = factor(response, labels = c('Precipitation', 'Temperature', 'Wind'))
  ) |>
  filter(center == 'cesm2') |>
  ggplot() +
  geom_point(
    aes(x = Dim.1, y = Dim.2, color = predictor, shape = resp),
    size = 3,
    alpha = .7
  ) +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  facet_wrap(~resp, ncol = 2) +
  scale_color_brewer(palette = 'Dark2') +
  theme(aspect.ratio = 1) +
  theme_bw()

# plot(pca.res, graph.type = 'ggplot', habillage = 3, label = 'var' )
pl.varpca <- plot(pca.res, choix = 'var', graph.type = 'ggplot', cex = .7) +
  labs(title = '') +
  theme_void()

library(patchwork)
pl.pca +
  inset_element(
    pl.varpca,
    left = 0.55,
    bottom = 0.01,
    right = 1,
    top = 0.55,
    align_to = 'plot'
  )

ggsave(filename = 'reports/figures/DSerrorpca.png', height = 6, width = 7)

#install.packages('Factoshiny')
library(Factoshiny)
PCAshiny(dd)
