## Following is a brief description of the files contained within this folder

### Important: All the scripts located here were designed to call them from the root folder of the project. Don't execute them in this folder!!

|File|Description|
|------|-----------|
|`OLD`|Subfolder with older code, which now is not used at all. We keep it for reference purposes only.|
|`downscaling_reports_generator`|Generates all the reports related to downscaling performance. The output can be found in `downscaling_evaluation`|
|`model_evaluation_reports_generator`|Generates all the reports related to the performance of different models at downscaling the `testing` data. The output can be found in `model_evaluation`.|
|`validation_reports_generator`|Generates all the reports that compare the `CMIP` projections with the upscaled `reanalysis` values. The output can be found in `validation`|
|`cmip_data.py`|Used to download the `CMIP` data.|
|`conf.yml`|Stores paramaters of the project. Some variables of interest and if they are on a daily or hourly scale, the region of study, `CMIP` models-experiment combinations that we wish to downscale, etc.|
|`CNNDownscaler.py`|For each variable, a CNN model is trained, allowing us to downscale new data. To train the models we execute the script. If we want to downscale new observations we have to make an instance of the class `CNNDownscaler` and call the `predict` function, passing it the path where the new dataset is located and the path of the corresponding `.pkl` file.|
|`NaiveDownscaler.py`|For each variable we train a linear model (we call it naive) which will allow us to downscale new data. To train the models we execute the script. If we want to downscale new observations we have to make an instance of the class `NaiveDownscaler` and call the `predict` function, passing it the path where the new dataset is located and the path of the corresponding `.pkl` file.|
|`reanalysis_data.py`|Used to download the `reanalysis` data. The downloading is really slow, it may take more than one day! (a good idea can be parallelize on the variables).|
|`metrics.R`|Implements useful new metrics and plots for evaluating the downscaling model.|
|`training_data_generator.py`|Generates the data needed to train/test the models. The outputs can be found in the `training` and `testing` folders. It's also the responsible of building the datasets that will be downscaled.|
|`validation_data.py`|Generates the datasets needed to build the `validation_reports`.|
|`utils.R`|Common use functions.|
|`XgboostDownscaler.py`|Analogous to the `NaiveDownscaler` and the `CNNDownscaler`. `XgboostDownscaler` is right now the only model on which we do hyperparameters optimization and we do it with the `hyperopt` library (Bayesian Optimization).|

** Note 1: all the models take the same input but they do some transformation depending on what their expect as an input, for example the neural nets require several transformations. All of the transformations along with the hyperparameters optimization are done in the corresponding script.

** Note 2: The training part can be computationally demanding. I (Bruno) had to run it on the Google Compute Engine platform.