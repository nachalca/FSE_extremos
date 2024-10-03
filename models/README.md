## Models

Each one of the variables that we wish to downscale has its corresponding subfolder. All of the subfolders contain a `.pkl` file for each model that we trained. The `.pkl` files store a model and if we want to downscale a variable we load these `.pkl` files. 

We also have a `hyperparameters` subfolder that contains the best hyperparameters of the `xgboost` models for each one of the variables. If we optimize the hyperparameters of the neural nets in the future, we can save them here too.