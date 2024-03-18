library("tidymodels")
library(data.table)


reanalysis <- fread('reanalysis_training_data.csv') |>
              mutate(month = as.factor(month), day = as.factor(day), hour = as.factor(hour))
cmip_6 <- fread('cmip6_to_predict_data.csv') |>
  mutate(month = as.factor(month), day = as.factor(day), hour = as.factor(hour))

model_recipe <- recipe(temp ~ hour + month + avg_temp, data = reanalysis) |>
                step_dummy(all_integer())

model <- linear_reg() %>% set_engine("lm")

model_workflow <- 
  workflow() %>% 
  add_model(model) %>% 
  add_recipe(model_recipe)

model_fit <- fit(model_workflow, reanalysis)
predicted <- predict(model_fit, cmip_6)

res <-  reanalysis |>
  select(temp) |>
  bind_cols(predicted)

metrics <- metric_set(rmse, mape)
metrics(res, temp, .pred)

mape(res$.pred, res$temp)
