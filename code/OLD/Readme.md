## Following is a brief description of the files contained within this folder

|File|Description|
|------|-----------|
|`validating_reanalysis_cmip6`|Compare the different CMIP models with respect to how well they adjust to the reanalysis data on a daily scale. We are only using temperature, but it may be a good idea to do it for all the variables.
|`prepare_data.ipynb`|Prepare the data to be used in the model. The input consists of the reanalysis netCDF files and the netCDF files corresponding to the CESM2_WACCM model. For now, only temperature and wind speed variables are generated, but the idea is for this file to contain all the necessary preparation.|
|`cmip6_tas_to_downscale_data.csv`, <br>`cmip6_tas_to_downscale_data.csv`,<br>`reanalysis_sfcWind_training_data.csv`,<br>`cmip6_sfcWind_to_downscale_data`|Output of `prepare_data.ipynb`|
|`naive_model.Rmd`|It features a first model in which we employ a linear model, trained with the reanalysis data, to downscale the CMIP6 data. We focus on the temperature variable|
|`wind_model.Rmd`|Similar to `naive_model.Rmd` but applied to wind speed.|
|`spatial_downscaling.R`|Spatial downscaling of CESM2-WACCM using climate4R, it's not used.|
|`KNNR_GA.py`|Implements the algorithm shown in Taesam Lee and Changsam Jeong (2014) [^1]|
|`metrics.R`|Implements useful new metrics for evaluating the downscaling model.|
|`utils.R`|Common use functions.|

[^1] https://www.sciencedirect.com/science/article/pii/S0022169413009244