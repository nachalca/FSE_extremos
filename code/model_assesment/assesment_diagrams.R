library(tidyverse)
library(here)
library("extremogram")
source('code/metrics.R')
source('code/utils.R')


# install.packages('openair')
library(openair) # taylor diagram

#-----------------
# Taylor para validacion CMIP6 ------------------

tas <- read.csv('data/validation/tas.csv')

validation_taylor_fn <- function(dd, mm) { 
  res_long <-  dd |>
    pivot_longer(cols = -c(1:2), names_to="model_exp", values_to="value") |>
    separate(col = model_exp, sep = "_ss", into = c("model", "experiment"), extra = "merge", remove = FALSE) |> 
    mutate(experiment = paste0('ss', experiment) )
  
  TaylorDiagram(mydata = res_long, obs='reanalysis',
                group= 'model_exp', 
                mod = 'value' , 
                main = mm, 
                cex = 2) 
  }


ff <- list.files('data/validation/', full.names = TRUE)
pls <- vector(mode='list', length=length(ff))
vars <- gsub('.csv', '', basename(ff) )

# individual taylor plots
for  (i in 1:length(ff) ) {
  dt <- read.csv(ff[i])
  pls[[i]] <- validation_taylor_fn(dt, mm = vars[i])
}

# all data
dds <- lapply(ff, read.csv) |> set_names(nm=vars) |> 
  bind_rows(.id='respuesta') |> 
  pivot_longer(cols = -c(1:3), names_to="model", values_to="value")  |>
  as.data.frame()

  separate(col = model, sep = "_ss", into = c("model", "experiment"), extra = "merge") |> 
  mutate(experiment = paste0('ss', experiment),
         date= as.Date(time, format="%Y-%m-%d") ) |> 
  
  
prueba <- filter(dds, respuesta %in% c('tas', 'tasmax', 'tasmin')) |> 
  select(date, reanalysis, value, respuesta) |> 
  as.data.frame()

TaylorDiagram(mydata = dds, 
              obs= 'reanalysis',
              mod = 'value', 
              group = c('model'),
              type='respuesta', 
              normalise = TRUE )

p1$data |> 
  separate(MyGroupVar, into = c("respuesta", "experiment"), extra = "merge") |> 
  ggplot() + 
  geom_point(aes(x=R, y=sd.mod, color=respuesta))



#-----------------
# Resultados de "model_evaluation"
#-----------------
ff <- list.files('data/model_evaluation_data/', full.names = TRUE)
dds <- lapply(ff, read.csv)
vars <- gsub('.csv', '', basename(ff) )
names(dds) <- vars

dt <- bind_rows(dds, .id='respuesta') |> 
  pivot_longer(cols = -c(1:3), values_to = 'value', 
               names_to = 'model')
  
pls <- vector(mode='list', length=length(vars))

for (i in 1:length(vars)) {
  m <- vars[i]
  pls[[i]] <- TaylorDiagram(mydata = filter(dt, respuesta==m),
                obs='reanalysis',
                group= 'model', 
                mod = 'value', 
                main = m, 
                normalise = TRUE)
}
names(pls) <- vars

lapply(pls, function(x) x$data ) |> 
  bind_rows(.id='respuesta')


pl <- TaylorDiagram(mydata = dt,
                          obs='reanalysis',
                          group= c('respuesta', 'model'), 
                          mod = 'value', 
                          normalise = TRUE, cex=1
              )



pl$data |> View()

pl$data |> 
  separate(MyGroupVar, into=c('var', 'predictor'), extra = 'merge' ) |> 
  ggplot() + 
  geom_point(aes(x=R, y=sd.mod, shape=predictor, color=var) ) +
  scale_color_brewer(palette = 'Dark2')




pps <- (0:99+.5)/100

res |> 
  pivot_longer(cols = -c(1:2), values_to = 'value', 
               names_to = 'model') |> 
  group_by(model) |> 
  reframe(qq.obs  = quantile(reanalysis, probs = pps),
          qq.pred = quantile(value, probs = pps, na.rm = TRUE),
          per = pps) |> 
  ggplot() + 
  geom_line(aes(qq.obs, qq.pred, color=model) ) + 
  geom_abline(slope = 1, linetype='dashed') + 
  #facet_wrap(~respuesta, scale='free') + 
  scale_color_brewer(palette = 'Dark2') + 
  theme_bw()

res |> 
  pivot_longer(cols = -c(1:2), values_to = 'value', 
               names_to = 'model') |> 
  group_by(model) |> 
  reframe(qq.obs  = quantile(reanalysis, probs = pps),
          qq.pred = quantile(value, probs = pps, na.rm = TRUE),
          per = pps) |> 
  ggplot() + 
  geom_line(aes( y=qq.pred-qq.obs, x=per, color=model)) + 
  geom_hline(yintercept = 0, linetype='dashed') + 
  scale_color_brewer(palette = 'Dark2') + 
  theme_bw()











#########################################################
res <- dds[[5]]

models <- res |> select(-c("time", "reanalysis")) |> colnames()

r <- lapply(models, function(x) {
  metrics_paired_hourly(time = res$time, truth = res$reanalysis, estimate = res[[x]], model = x)
})    

results <- do.call(rbind, r) |> 
  mutate(across(where(is.numeric), round, digits = 3)) 


pps <- (0:99+.5)/100
res_qq <- dt |> 
  group_by(model, respuesta) |> 
  reframe(qq.obs  = quantile(reanalysis, probs = pps),
          qq.pred = quantile(value, probs = pps, na.rm = TRUE),
          per = pps)

ggplot(res_qq) + 
  geom_line(aes(qq.obs, qq.pred, color=model) ) + 
  geom_abline(slope = 1, linetype='dashed') + 
  facet_wrap(~respuesta, scale='free') + 
  scale_color_brewer(palette = 'Dark2') + 
  theme_bw()

ggplot(res_qq) + 
  geom_line(aes( y=qq.pred-qq.obs, x=per, color=model)) + 
  geom_hline(yintercept = 0, linetype='dashed') + 
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

res_long <-  res_validation_wide |> 
  pivot_longer(cols = 3:37, names_to="model", values_to="value") |>
  separate(col = model, sep = "\\.", into = c("model", "experiment"), extra = "merge")

# taylor plot
TaylorDiagram(mydata = res_long, obs='reanalysis',
              group=c('model', 'experiment'), 
              mod = 'value' )
#-----------------

