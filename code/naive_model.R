library("tidymodels")
library(data.table)


reanalysis <- fread('reanalysis_training_data.csv') |>
              mutate(month = as.factor(month), day = as.factor(day), hour = as.factor(hour))
cmip_6 <- fread('cmip6_to_predict_data.csv') |>
  mutate(month = as.factor(month), day = as.factor(day), hour = as.factor(hour))

model_recipe <- recipe(temp ~ hour + month + avg_temp, data = reanalysis) |>
                step_dummy(all_integer()) |>
                step_interact(~ hour:avg_temp)

model <- linear_reg() %>% set_engine("lm")

model_workflow <- 
  workflow() %>% 
  add_model(model) %>% 
  add_recipe(model_recipe)

model_fit <- fit(model_workflow, reanalysis)

engine <- extract_fit_engine(model_fit)
#Hours are statistically significant, as is their interaction with the avg_temperature are; months are not. 
summary(engine)


predicted <- predict(model_fit, cmip_6)

res <-  reanalysis |>
  select(time, temp, avg_temp) |>
  inner_join(cmip_6, by = join_by(time)) |>
  bind_cols(predicted)

metrics <- metric_set(rmse, mape)
metrics(res, temp, .pred)

#The error is greater when we fix that all the hours use the average value.
metrics(res, temp, avg_temp.y)

res_to_plot <- res[1:72,]

ggplot(res_to_plot, aes(x=time)) +
  geom_line(aes(y=temp)) +
  geom_line(aes(y=.pred), color = "red") +
  geom_line(aes(y=avg_temp.x), linetype="dotted", color = "black") +
  geom_line(aes(y=avg_temp.y), linetype="dotted", color = "red")
  xlab("")
