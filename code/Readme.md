Following there is a brief description about the files inside this folder.

|File|Description|
|`validating_reanalysis_cmip6`|Compare the different CMIP models with respect to how well they adjust to the reanalysis data on a daily scale. We are only using temperature, but it may be a good idea to do it for all the variables.
|`prepare_data.ipynb`|Prepare the data to be used in the model. The input consists of the reanalysis netCDF files and the netCDF files corresponding to the CESM2_WACCM model. For now, only temperature and wind speed variables are generated, but the idea is for this file to contain all the necessary preparation.|
|`cmip6_tas_to_downscale_data.csv`,`cmip6_tas_to_downscale_data.csv`,`reanalysis_wind_training_data.csv`,`cmip6_wind_to_downscale_data`|Output of `prepare_data.ipynb`|
|`naive_model.Rmd`|It features a first model in which we employ a linear model, trained with the reanalysis data, to downscale the CMIP6 data. We focus on the temperature variable|
|`wind_model.Rmd`|Similar to `naive_model.Rmd` but applied to wind speed.|
|`spatial_downscaling.R`|Spatial downscaling of CESM2-WACCM using climate4R, it's not used|