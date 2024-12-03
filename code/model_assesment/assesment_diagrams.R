library(tidyverse)
library(here)

# install.packages('openair')
library(openair) # taylor diagram

# Taylor con resultados  DS ------------------
# Load re-analisis
reanalysis <- read.csv('data/reanalysis/reanalysis.csv')
reanalysis <- reanalysis |> select(time, reanalysis = 'tas') 

# TAS downscaled data
res_validation_wide <- read.csv('data/downscaled_data/tas.csv') |> 
  inner_join(reanalysis)

res_prediction_wide <- res_wide |> 
  filter(!(time %in% res_validation_wide$time))

res_long <-  res_validation_wide |> 
  pivot_longer(cols = 3:37, names_to="model", values_to="value") |>
  separate(col = model, sep = "\\.", into = c("model", "experiment"), extra = "merge")

# taylor plot
TaylorDiagram(mydata = res_long, obs='reanalysis',
              group=c('model', 'experiment'), 
              mod = 'value' )
#-----------------

# Taylor para validacion CMIP6 ------------------


tas <- read.csv('data/validation/tas.csv')

validation_taylor_fn <- function(dd, mm) { 
  res_long <-  dd |>
    pivot_longer(cols = -c(1:2), names_to="model", values_to="value") |>
    separate(col = model, sep = "_ss", into = c("model", "experiment"), extra = "merge") |> 
    mutate(experiment = paste0('ss', experiment) )
  
  TaylorDiagram(mydata = res_long, obs='reanalysis',
                group=c('model', 'experiment'), 
                mod = 'value' , 
                main = mm) 
  
  }


ff <- list.files('data/validation/', full.names = TRUE)
pls <- vector(mode='list', length=length(ff))
vars <- gsub('.csv', '', basename(ff) )

for 




