from feature_engine import encoding
import pandas as pd
import os
import yaml 
import numpy as np
import pickle

from sklearn import base, pipeline, model_selection
from sklearn.linear_model import LinearRegression

class NaiveDownscaler():

    def __init__(self):
        pass

    #Add past observations and next observations as predictors, also do the onehot encoding (It's the same function as in XgboostDownscaler.py)
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

        return data

    #Analagous to XgboostDownscaler too.    
    def predict(self, data, model):
        data = pd.read_csv(data)
        res = data.copy() # To keep the time
        data.drop(columns=["target", "time"], inplace=True, errors="ignore")
        window_size =  24 if "hour" in data.columns else 1  
        print(f"Transforming dataset for prediction")      
        data = self.transform(window_size, data)
        print(f"Predicting with model {model}")
        model = pickle.load(open(model, "rb"))
        data = data[model.feature_names_in_]
        predictions = model.predict(data)
        res = res.iloc[window_size:-window_size] # Match the sizes
        res["naive"] = predictions
        return res[["time", "naive"]]

    def optimize(self, X_train, y_train, **space):
        pass

    """
        TRAIN ALL NAIVE MODELS FOR DIFFERENT VARIABLES. THIS FUNCTION WILL SAVE THE MODELS IN THE MODELS FOLDER.
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
                window_size =  24 if VARIABLES[variable_name]["daily"] else 1
                
                # Transform the data
                print("Transforming the data ...")
                X_train = self.transform(window_size, X)
                y_train = y.iloc[window_size:-window_size] # delete first #window_size rows and the last #window_size rows, to have the same size as X_train.

                #Train the model with the best hyperparameters
                print("Training the model with the best hyperparameters ...")
                nv = LinearRegression()
                nv.fit(X_train, y_train)

                #Save the model
                if os.path.exists(f"models/{variable_name}") == False:
                    os.makedirs(f"models/{variable_name}")
                pickle.dump(nv, open(f"models/{variable_name}/naive.pkl", "wb"))

def main():
    nv_downscaler = NaiveDownscaler()
    nv_downscaler.fit()

if __name__ == "__main__":
    main()