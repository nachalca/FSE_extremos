from feature_engine import encoding
import pandas as pd
from sklearn import base, pipeline, model_selection
from hyperopt import STATUS_OK, Trials, fmin, hp, tpe, space_eval 
from hyperopt.early_stop import no_progress_loss
import os
import xgboost
import yaml 
import numpy as np
import pickle
import os
import dask.dataframe as dd
from dask_ml.preprocessing import Categorizer, OneHotEncoder as DaskOneHotEncoder
from dask.distributed import Client, LocalCluster

class XgboostDownscaler():

    def __init__(self):

        with open("code/conf.yml", 'r') as file:
            conf = yaml.safe_load(file)
        
        self.VARIABLES = conf["VARIABLES"]
        self.MODELS = conf["MODELS"]
        self.SEED = conf["SEED"]

    #Add past observations and next observations as predictors, also do the onehot encoding
    @staticmethod
    def transform(window_size, data):
        
        # Filter columns to process
        cols_to_process = [col for col in data.columns if col not in ["time", "hour", "month"]]
        
        new_columns = []

        for col in cols_to_process:
            for i in range(1, window_size + 1):
                new_columns.append(data[col].shift(i).rename(f"{col}_past_{i}"))
                new_columns.append(data[col].shift(-i).rename(f"{col}_future_{i}"))
        
        # Add all new columns to the DataFrame at once
        data = pd.concat([data] + new_columns, axis=1)
            
        # Delete the first #window_size rows and the last #window_size rows
        data = data.iloc[window_size:-window_size]

        # Do the OhE
        categorical_variables = ["month", "hour"] if "month" in data.columns and "hour" in data.columns else ["month"]
        data[categorical_variables] = data[categorical_variables].astype("object")                
        data = encoding.OneHotEncoder(variables=categorical_variables).fit_transform(data)
        print("month" in data.columns)

        return data

    @staticmethod
    def transform_with_dask(window_size, data):

        # Convert pandas DataFrame to Dask DataFrame if not already a Dask DataFrame
        if not isinstance(data, dd.DataFrame):
            data = dd.from_pandas(data, npartitions=4)  # Adjust npartitions based on your systemW
        
        # Filter columns to process
        cols_to_process = [col for col in data.columns if col not in ["time", "hour", "month"]]
        
        new_columns = []
        
        for col in cols_to_process:
            for i in range(1, window_size + 1):
                new_columns.append(data[col].shift(i).rename(f"{col}_past_{i}"))
                new_columns.append(data[col].shift(-i).rename(f"{col}_future_{i}"))
        
        # Add all new columns to the DataFrame at once
        data = dd.concat([data] + new_columns, axis=1)
        
        # Create a mask to remove rows with NaNs resulting from shifts
        mask = data.index >= window_size
        mask &= data.index < (data.index[-1] - window_size + 1)
        data = data.loc[mask]
        
        # Do the One-Hot Encoding (OhE)
        categorical_variables = ["month", "hour"] if "month" in data.columns and "hour" in data.columns else ["month"]
        data[categorical_variables] = data[categorical_variables].astype("object")
        
        # Use dask-ml's OneHotEncoder
        enc = DaskOneHotEncoder(cols=categorical_variables)
        data_encoded = enc.fit_transform(data)

        return data_encoded
        
    def predict(self, data, model):
        data = pd.read_csv(data)
        data.drop(columns=["target", "time"], inplace=True, errors="ignore")
        window_size =  24 if "hour" in data.columns else 1  
        print(f"Transforming dataset for prediction")      
        data = self.transform(window_size, data)
        print(f"Predicting with model {model}")
        model = pickle.load(open(model, "rb"))
        data = data[model.feature_names_in_]
        predictions = model.predict(data)
        return predictions

    def optimize(self, X_train, y_train, **space):
        model = xgboost.XGBRegressor(**space) # Define the model

        # Do Cross Validation
        score = model_selection.cross_val_score(model, X_train, y_train, cv=5, scoring="neg_mean_squared_error").mean()
        return {'loss': -score, 'status': STATUS_OK, 'model': model}

    def fit(self):
        # List all the training datataset
        files = os.listdir("data/training")
        for f in files:
            if f.endswith('.csv'):
                variable_name = f.split(".")[0] #Get the variable name from the filename
                print(f"Training model for \033[92m{variable_name}\033[0m")
            
                data = pd.read_csv(f"data/training/{f}")
                data = data.set_index("time")

                # Split the data into features and target
                X = data.drop(columns=["target"])
                y = data["target"]
                                
                # Split the data into training and test (without shuffling)
                X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=0.2, shuffle=False)

                #Save the test in a csv (we will do the report later with R)
                if os.path.exists("data/testing") == False:
                    os.makedirs("data/testing")
                pd.concat([X_test, y_test], axis=1).to_csv(f"data/testing/{variable_name}.csv")   

                #Set the amount of future and past observation to be taked account  
                window_size =  24 if self.VARIABLES[variable_name]["daily"] else 1
                
                # Transform the data
                print("Transforming the data ...")
                X_train = self.transform(window_size, X)
                y_train = data.iloc[window_size:-window_size] # delete first #window_size rows and the last #window_size rows, to have the same size as X_train.

                # Define the search space
                hyper_params = {
                    'max_depth': hp.choice('max_depth', np.arange(1, 8, dtype=int)),  # tree
                    'min_child_weight': hp.loguniform('min_child_weight', -2, 3),
                    'subsample': hp.uniform('subsample', 0.5, 1),   # stochastic
                    'colsample_bytree': hp.uniform('colsample_bytree', 0.5, 1),
                    'reg_alpha': hp.uniform('reg_alpha', 0, 10),
                    'reg_lambda': hp.uniform('reg_lambda', 1, 10),
                    'gamma': hp.loguniform('gamma', -10, 10), # regularization
                    'learning_rate': hp.loguniform('learning_rate', -7, 0),  # boosting
                    'random_state': 42,
                    'importance_type': 'gain' #Feature importance
                }     
                
                # Optimize the hyperparameters
                print("Doing the hyperparameters optimization ...")
                trials = Trials()
                best = fmin(
                        fn=lambda space: self.optimize(X_train=X_train, y_train=y_train, **space),            
                        space=hyper_params,           
                        algo=tpe.suggest,            
                        max_evals=5,            
                        trials=trials,
                        rstate=np.random.default_rng(self.SEED)
                )

                print(best)

                #Save the trials
                if os.path.exists("models/hyperparameters") == False:
                    os.makedirs("models/hyperparameters")            
                pickle.dump(trials, open(f"models/hyperparameters/{variable_name}.pkl", "wb"))

                #Train the model with the best hyperparameters
                print("Training the model with the best hyperparameters ...")
                xgb = xgboost.XGBRegressor(**best)
                xgb.fit(X_train, y_train)

                #Save the model
                if os.path.exists(f"models/{variable_name}") == False:
                    os.makedirs(f"models/{variable_name}")
                pickle.dump(xgb, open(f"models/{variable_name}/xgboost.pkl", "wb"))

def main():
    xgb_downscaler = XgboostDownscaler()
    xgb_downscaler.fit()

if __name__ == "__main__":
    main()