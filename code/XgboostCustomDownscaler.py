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
from scipy.stats import gamma


class XgboostCustomDownscaler():

    alpha, beta = None, None

    def __init__(self):
        pass

    def custom_loss(self, y_true, y_pred):
        
        # Calculate the gradient
        penalty_mask = (y_true > y_pred).astype(float) #1 if y_true > y_pred, 0 otherwise
        gamma_cummulative = gamma.cdf(y_true, a=self.alpha, scale=self.beta)
        gradient = 2 * (y_pred - y_true) - gamma_cummulative * penalty_mask #remember that here we are operating with vectors!
    
        # Calculate the Hessian
        hessian = np.full_like(gradient, 2)  # Constant Hessian for MSE. full_like creates a vector with the same shape as gradient and fill it with 2.
    
        return gradient, hessian

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
    
    def predict(self, data, model):
        data = pd.read_csv(data)

        # Delete the target column if it exists (We don't have it in CMIP)
        data.drop(columns=["target"], inplace=True, errors="ignore")

        #Set the window size
        window_size =  24 if "hour" in data.columns else 1  
        
        print(f"Transforming dataset for prediction")      
        data = self.transform(window_size, data)
        
        print(f"Predicting with model {model}")

        with open(model, "rb") as f:
            model = pickle.load(f) # Load the model
        
        data = data[model.feature_names_in_] # Get the features that the model was trained on and in the SAME ORDER.
        predictions = model.predict(data) # Predict

        data["xgboost_custom"] = predictions
        data.reset_index(inplace=True)
        
        return data[["time", "xgboost_custom"]]

    def optimize(self, X_train, y_train, **space):
    #    model = xgboost.XGBRegressor(**space) # Define the model

        # Do Cross Validation
    #    score = model_selection.cross_val_score(model, X_train, y_train, cv=5, scoring="neg_mean_squared_error").mean()
    #    return {'loss': -score, 'status': STATUS_OK, 'model': model}
        pass

    """
        TRAIN ALL XGBOOST MODELS FOR DIFFERENT VARIABLES. THIS FUNCTION WILL SAVE THE MODELS IN THE MODELS FOLDER.
    """
    def fit(self, testing=False):
        #Load the configuration file
        with open("code/conf.yml", 'r') as file:
            conf = yaml.safe_load(file)
        
        VARIABLES = conf["VARIABLES"]
        SEED = conf["SEED"]        

        # List all the training datataset
        files = os.listdir("data/training")
        for f in files:
            if f.endswith('.csv') and f.startswith("pr"):
                variable_name = f.split(".")[0] #Get the variable name from the filename
                print(f"Training model for \033[92m{variable_name}\033[0m")
            
                data = pd.read_csv(f"data/training/{f}")

                if testing:
                    data = data.iloc[:24*365*2] #Get the first two years

                # Split the data into features and target
                X_train = data.drop(columns=["target"])
                y_train = data["target"]

                #Estimate gamma parameters
                self.alpha = y_train.mean()**2/y_train.var()
                self.beta = y_train.var()/y_train.mean()

                #Set the amount of future and past observation to be taked account  
                window_size =  24 if VARIABLES[variable_name]["daily"] else 1
                
                # Transform the data
                print("Transforming the data ...")
                X_train = self.transform(window_size, X_train)
                y_train = y_train.iloc[window_size:-window_size] # delete first #window_size rows and the last #window_size rows, to have the same size as X_train.

                # Define the search space
                # hyper_params = {
                #     'max_depth': hp.choice('max_depth', np.arange(1, 8, dtype=int)),  # tree
                #     'min_child_weight': hp.loguniform('min_child_weight', -2, 3),
                #     'subsample': hp.uniform('subsample', 0.5, 1),   # stochastic
                #     'colsample_bytree': hp.uniform('colsample_bytree', 0.5, 1),
                #     'reg_alpha': hp.uniform('reg_alpha', 0, 10),
                #     'reg_lambda': hp.uniform('reg_lambda', 1, 10),
                #     'gamma': hp.loguniform('gamma', -10, 10), # regularization
                #     'learning_rate': hp.loguniform('learning_rate', -7, 0),  # boosting
                #     'random_state': SEED,
                #     'importance_type': 'gain', #Feature importance
                #     'objective': 'reg:custom_loss' #Regression
                # }     
                
                # Optimize the hyperparameters
                # print("Doing the hyperparameters optimization ...")
                # trials = Trials()
                # best = fmin(
                #         fn=lambda space: self.optimize(X_train=X_train, y_train=y_train, **space),            
                #         space=hyper_params,           
                #         algo=tpe.suggest,            
                #         max_evals=5,            
                #         trials=trials,
                #         rstate=np.random.default_rng(SEED)
                # )
                # print(best)

                #Save the trials
                # if os.path.exists("models/hyperparameters") == False:
                #     os.makedirs("models/hyperparameters")            
                # pickle.dump(trials, open(f"models/hyperparameters/{variable_name}.pkl", "wb"))

                #Train the model with the best hyperparameters
                print("Training the model with the best hyperparameters ...")
                xgb = xgboost.XGBRegressor(objective=self.custom_loss)
                xgb.fit(X=X_train, y=y_train)

                #Save the model
                if os.path.exists(f"models/{variable_name}") == False:
                    os.makedirs(f"models/{variable_name}")
                pickle.dump(xgb, open(f"models/{variable_name}/xgboost_custom.pkl", "wb"))

def main():
    xgb_custom_downscaler = XgboostCustomDownscaler()
    xgb_custom_downscaler.fit(testing=False) 

if __name__ == "__main__":
    print("Starting the training of the XGBoost models with custom loss function ...")
    main()
