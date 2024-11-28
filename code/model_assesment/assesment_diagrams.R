library(tidyverse)
library(here)

# install.packages('openair')
library(openair) # taylor diagram


# Load re-analisis
reanalysis <- read.csv('data/reanalysis/reanalysis.csv')

reanalysis <- reanalysis |> 
  select(time, reanalysis = 'tas') 

# laod TAS downscaled data
res_wide <- read.csv('data/downscaled_data/tas.csv')

res_validation_wide <- reanalysis |> 
  inner_join(res_wide)

res_prediction_wide <- res_wide |> 
  filter(!(time %in% res_validation_wide$time))

taylor_diagram(res_validation_wide[, -1], plot_type = 'half')
sd(res_validation_wide$reanalysis)

mm <- c('undown', 'xgboost', 'cnn', 'nv', 'lstm')

res_validation_wide |> 
  select(reanalysis, contains('ssp585')) |> 
  taylor_diagram( plot_type = 'half', model_labels = colnames(zz),
                  point_palette = terrain.colors(6)) + 
  scale_fill_manual( )
  
  theme(legend.key = )

#-----------------
install.packages('plotrix')
library(plotrix)
? taylor.diagram

zz <- res_validation_wide |> 
  select(reanalysis, contains('ssp585'))


with(zz, taylor.diagram( reanalysis, undownscaled.cesm2.ssp585 ) )
colores <- rainbow(6)
for (i in 1:6  ) {
  v <- colnames(zz)[i+1]
  with(zz, taylor.diagram(ref=reanalysis, model=  zz[,v], add = TRUE, col = colores[i]) )
}
legend(8, 10, legend=colnames(zz)[-1], pch=19, col=colores)






res_long <-  res_validation_wide |> 
  pivot_longer(cols = 3:37, names_to="model", values_to="value") |>
  separate(col = model, sep = "\\.", into = c("model", "experiment"), extra = "merge")


TaylorDiagram(mydata = res_long[,-1], obs='reanalysis',
              group=c('model', 'experiment'), 
              mod = 'value' )


#-----------------


