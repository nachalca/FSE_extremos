## Following is a brief description of the subfolders contained within this folder

|Folder|Description|
|------|-----------|
|`03-05` and `20-05`|Reports made during Bruno's stay in Lyon. The intention of these reports was to show the work done there.|
|`downscaling_evaluation`|Reports that show the performance of different models at downscaling `CMIP` data. We have a report for each variable that we downscaled. We can find the data used to make these reports in `to_be_downscaled`, also we are using the `reanalysis` data as a reference for the first years. The code, which generates these reports, can be found in `downscaling_reports_generator`| 
|`model_evaluation`|Reports that show the performance of different models at downscaling the `testing` data. Remember that these `testing` data is the part of the `reanalysis` data that was not used to train the model (we have the reanalysis "observations" upscaled as if they are `CMIP` projections). We have a report for each variable we wish to downscale. We can find the data used to make these reports in `model_evaluation`. The code, which generates these reports, can be found in `model_evaluation_reports_generator`|
|`validation`|Reports that compare the `CMIP` projections with the upscaled reanalysis values for the years 2015-2023. Each one of the variables has their corresponding report. We can find the data used to create these reports in `validation`. The code, which generates these reports, can be found in `validation_reports_generator`.|
|`ds_acp`| acp with evaluation metrics results. 


