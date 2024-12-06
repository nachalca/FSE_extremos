from feature_engine import encoding
import pandas as pd
from sklearn import base, pipeline, model_selection
from hyperopt import STATUS_OK, Trials, fmin, hp, tpe, space_eval 
from hyperopt.early_stop import no_progress_loss
import xgboost
import yaml 
import numpy as np
import pickle
import os
import shap

class XgboostDownscaler():

    def __init__(self):
        pass

    #Add past observations and next observations as predictors, also do the onehot encoding
    @staticmethod
    def transform(window_size, data):
        
        #Set the time as index and not as a feature
        data = data.set_index("time")
        
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

        return data
    
    def predict(self, data, model, variable=None):
        data = pd.read_csv(data)

        # Delete the target column if it exists (We don't have it in CMIP)
        data.drop(columns=["target"], inplace=True, errors="ignore")

        #Set the window size
        window_size =  24 if "hour" in data.columns else 28  
        
        print(f"Transforming dataset for prediction")      
        data = self.transform(window_size, data)
        
        print(f"Predicting with model {model}")
        model = pickle.load(open(model, "rb")) # Load the model
        data = data[model.feature_names_in_] # Get the features that the model was trained on and in the SAME ORDER.

        predictions = model.predict(data) # Predict
        data["xgboost"] = predictions
        data["xgboost"] = data["xgboost"].clip(lower=0, upper=100 if variable == "clt" else None)
        
        data.reset_index(inplace=True)
        
        return data[["time", "xgboost"]]

    def optimize(self, X_train, y_train, **space):
        model = xgboost.XGBRegressor(**space) # Define the model

        # Do Cross Validation
        score = model_selection.cross_val_score(model, X_train, y_train, cv=5, scoring="neg_mean_squared_error").mean()
        return {'loss': -score, 'status': STATUS_OK, 'model': model}

    def explain(self, data, model):
        data = pd.read_csv(data)

        data.drop(columns=["target"], inplace=True, errors="ignore")
        window_size =  24 if "hour" in data.columns else 28 
        
        data = self.transform(window_size, data)
        
        model = pickle.load(open(model, "rb"))
        data = data[model.feature_names_in_] # Get the features that the model was trained on and in the SAME ORDER.

        explainer = shap.Explainer(model, data)
        shap_values = explainer.shap_values(data)

        feature_importance = np.abs(shap_values).mean(axis=0)
        feature_names = data.columns 

        # Combine into a DataFrame for better readability
        importance_df = pd.DataFrame({
            "Feature": feature_names,
            "Importance": feature_importance
        }).sort_values(by="Importance", ascending=False)

        return importance_df
    
    """
        TRAIN ALL XGBOOST MODELS FOR DIFFERENT VARIABLES. THIS FUNCTION WILL SAVE THE MODELS IN THE MODELS FOLDER.
    """
    def fit(self):
        #Load the configuration file
        with open("code/conf.yml", 'r') as file:
            conf = yaml.safe_load(file)
        
        VARIABLES = conf["VARIABLES"]
        SEED = conf["SEED"]        

        # List all the training datataset
        files = os.listdir("data/training")
        for f in files:
            if f.endswith('.csv'):
                variable_name = f.split(".")[0] #Get the variable name from the filename
                print(f"Training model for \033[92m{variable_name}\033[0m")
            
                data = pd.read_csv(f"data/training/{f}")

                # Split the data into features and target
                X_train = data.drop(columns=["target"])
                y_train = data["target"]
                                
                #Set the amount of future and past observation to be taked account  
                window_size =  24 if VARIABLES[variable_name]["daily"] else 28
                
                # Transform the data
                print("Transforming the data ...")
                X_train = self.transform(window_size, X_train)
                y_train = y_train.iloc[window_size:-window_size] # delete first #window_size rows and the last #window_size rows, to have the same size as X_train.

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
                        max_evals=50,            
                        trials=trials,
                        rstate=np.random.default_rng(SEED)
                )

                print(best)

                #Save the trials
                if os.path.exists("models/hyperparameters/xgboost") == False:
                    os.makedirs("models/hyperparameters/xgboost")            
                pickle.dump(trials, open(f"models/hyperparameters/xgboost/{variable_name}.pkl", "wb"))

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