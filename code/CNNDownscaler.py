import pandas as pd
import numpy as np
import pickle
from feature_engine import encoding
import yaml 
import os
import tensorflow as tf
from tensorflow.keras import optimizers
from tensorflow.keras.models import Model
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Input
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import Conv1D
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import MaxPool1D
from tensorflow.keras.layers import AveragePooling1D
from tensorflow.keras.layers import MaxPool2D
from tensorflow.keras.layers import ReLU
from tensorflow.keras.layers import Flatten
from tensorflow.python.keras import backend as K

from sklearn import model_selection, preprocessing


from collections import Counter

from numpy.random import seed

class CNNDownscaler():

    def __init__(self):
        pass

    #Add past observations and next observations as predictors, also do the onehot encoding
    @staticmethod
    def transform(window_size, data_x, data_y=None):

        #TOOKED FROM THE BOOK
        def temporalize(X, y, lookback):
            '''
            Inputs
            X         A 2D numpy array ordered by time of shape: (n_observations x n_features)
            y         A 1D numpy array with indexes aligned with X, i.e. y[i] should correspond to X[i]. Shape: n_observations.
            lookback  The window size to look back in the past records. Shape: a scalar.

            Output
            output_X  A 3D numpy array of shape: ((n_observations-2*lookback -1) x (lookback*2) x n_features)
            output_y  A 1D array of shape: (n_observations-2*lookback - 1), aligned with X. 
            '''
            #TODO: Check the shape of the output
            output_X = []
            output_y = []
            for i in range(lookback, len(X) - lookback - 1):
                t = []
                for j in range(lookback, 0, -1):
                    # Gather the past records upto the lookback period
                    t.append(X[[(i - j)], :])
                for j in range(0, lookback): 
                    # Gather the future records upto the lookback period
                    t.append(X[[(i + j + 1)], :]) #
                output_X.append(t)
                if y is not None:
                    output_y.append(y[i])
            if y is None:
                return np.squeeze(np.array(output_X)), None
            else:
                return np.squeeze(np.array(output_X)), np.array(output_y)

        def flatten(X):
            '''
            Flatten a 3D array.

            Input
            X            A 3D array for lstm, where the array is sample x timesteps x features.

            Output
            flattened_X  A 2D array, sample x features.
            '''
            flattened_X = np.empty(
                (X.shape[0], X.shape[2]))  # sample x features array.
            for i in range(X.shape[0]):
                flattened_X[i] = X[i, (X.shape[1] - 1), :]
            return flattened_X

        def scale(X, scaler):
            '''
            Scale 3D array.

            Inputs
            X            A 3D array for lstm, where the array is sample x timesteps x features.
            scaler       A scaler object, e.g., sklearn.preprocessing.StandardScaler, sklearn.preprocessing.normalize

            Output
            X            Scaled 3D array.
            '''
            for i in range(X.shape[0]):
                X[i, :, :] = scaler.transform(X[i, :, :])

            return X

        # Do the OhE
        categorical_variables = ["month", "hour"] if "month" in data_x.columns and "hour" in data_x.columns else ["month"]
        data_x[categorical_variables] = data_x[categorical_variables].astype("object")                
        data_x = encoding.OneHotEncoder(variables=categorical_variables).fit_transform(data_x)

        input_X =  data_x.loc[:, ].values  # Convert to numpy array
        input_y = data_y.loc[:, ].values if data_y is not None else None
        
        lookback = window_size

        X_train, y_train = temporalize(X=input_X, 
                            y=input_y, 
                            lookback=lookback)
        
        # Initialize a scaler using the training data.
        scaler = preprocessing.StandardScaler().fit(flatten(X_train))
        X_train_scaled = scale(X_train, scaler).astype(np.float32)

        if y_train is None:
            return X_train_scaled
        else:
            return X_train_scaled, y_train
        
    def predict(self, data, model):
        data = pd.read_csv(data)
        res = data.copy() # To keep the time
        data.drop(columns=["target", "time"], inplace=True, errors="ignore")
        window_size =  24 if "hour" in data.columns else 30  
        print(f"Transforming dataset for prediction")      
        data = self.transform(window_size, data_x = data)
        print(f"Predicting with model {model}")
        model = pickle.load(open(model, "rb"))
        predictions = model.predict(data)
        res = res.iloc[window_size+1:] # Match the sizes
        res["cnn"] = predictions
        return res[["time", "cnn"]]

    def optimize():
        pass

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

        #For each dataset, train a model
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

                #Split the data in train and validation
                X_train, X_valid, y_train, y_valid = model_selection.train_test_split(X_train, y_train, test_size=0.2, shuffle=False)

                #Set the amount of future and past observation to be taked account  
                window_size =  24 if VARIABLES[variable_name]["daily"] else 30
                
                # Transform the data
                print("Transforming the data ...")
                X_train, y_train = self.transform(window_size, X_train, y_train)

                X_valid, y_valid = self.transform(window_size, X_valid, y_valid)

                TIMESTEPS = X_train.shape[1]  # equal to the lookback
                N_FEATURES = X_train.shape[2]  # the number of features        

                # Define the model        
                cnn = Sequential()
                cnn.add(Input(shape=(TIMESTEPS, 
                                    N_FEATURES), 
                                name='input'))
                cnn.add(Conv1D(filters=16, 
                                kernel_size=4,
                                activation='relu', 
                                padding='valid'))
                cnn.add(MaxPool1D(pool_size=4, 
                                    padding='valid'))
                cnn.add(Flatten())
                cnn.add(Dense(units=16, 
                                activation='relu'))
                cnn.add(Dense(units=1, 
                                activation='linear', 
                                name='output'))

                cnn.compile(optimizer='adam',
                            loss='mse',
                            metrics=[
                                tf.keras.metrics.RootMeanSquaredError()
                            ])
                history = cnn.fit(x=X_train,
                                    y=y_train,
                                    batch_size=128,
                                    epochs=150,
                                    validation_data=(X_valid, y_valid),
                                    verbose=1).history

                #Save the model
                if os.path.exists(f"models/{variable_name}") == False:
                    os.makedirs(f"models/{variable_name}")
                pickle.dump(cnn, open(f"models/{variable_name}/cnn.pkl", "wb"))

def main():
    cnn_downscaler = CNNDownscaler()
    cnn_downscaler.fit()

if __name__ == "__main__":
    main()