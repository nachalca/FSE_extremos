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

VARIABLES = {}
MODELS = []
SEED = 1234

#Load the configuration from the conf.json file
def load_configuration():
    global VARIABLES, MODELS

    with open("code/conf.yml", 'r') as file:
        conf = yaml.safe_load(file)
    
    #OVERWRITE THE GLOBAL VARIABLES
    VARIABLES = conf["VARIABLES"]
    MODELS = conf["MODELS"]

    return conf

def xgboost_fit(X_train, y_train, **space):

    # Define the model
    model = xgboost.XGBRegressor(**space)

    # Do Cross Validation
    score = model_selection.cross_val_score(model, X_train, y_train, cv=5, scoring="neg_mean_squared_error").mean()
    return {'loss': -score, 'status': STATUS_OK, 'model': model}


def main():
    load_configuration()

    # List all the training datataset
    files = os.listdir("data/training")
    for f in files:
        if f.endswith('.csv'):
            variable_name = f.split(".")[0] #Get the variable name from the filename
            print(f"Training model for \033[92m{variable_name}\033[0m")
           
            data = pd.read_csv(f"data/training/{f}")
            data = data.set_index("time")

            categorical_variables = ["month", "hour"] if VARIABLES[variable_name]["daily"] else ["month"]

            # Split the data into features and target
            X = data.drop(columns=["target"])
            y = data["target"]

            # Do the OneHot Encoding
            X[categorical_variables] = X[categorical_variables].astype("object")
            encoder = encoding.OneHotEncoder(variables=categorical_variables)
            X = encoder.fit_transform(X)

            # Split the data into training and test
            X_train, X_test, y_train, y_test = model_selection.train_test_split(X, y, test_size=0.2, shuffle=False)

            #Save the test and train in a csv (we will do the report later with R)
            if os.path.exists("data/testing") == False:
                os.makedirs("data/testing")

            pd.concat([X_test, y_test], axis=1).to_csv(f"data/testing/{variable_name}.csv")   

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
                'random_state': 42
            }     
            
            trials = Trials()

            best = fmin(
                    fn=lambda space: xgboost_fit(X_train=X_train, y_train=y_train, **space),            
                    space=hyper_params,           
                    algo=tpe.suggest,            
                    max_evals=3,            
                    trials=trials
            )

            print(best)

            #Save the trials
            if os.path.exists("models/hyperparameters") == False:
                os.makedirs("models/hyperparameters")            
            pickle.dump(trials, open(f"models/hyperparameters/{variable_name}.pkl", "wb"))

            #Train the model with the best hyperparameters
            model = xgboost.XGBRegressor(**best)
            model.fit(X_train, y_train)

            #Save the model
            if os.path.exists(f"models/{variable_name}") == False:
                os.makedirs(f"models/{variable_name}")
            pickle.dump(model, open(f"models/{variable_name}/xgboost.pkl", "wb"))

if __name__ == "__main__":
    main()