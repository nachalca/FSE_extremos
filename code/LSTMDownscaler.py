import pandas as pd
import numpy as np
import pickle
from feature_engine import encoding
import yaml 
import os

from tensorflow.keras import optimizers
from tensorflow.keras.models import Model
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Input
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import LSTM
from tensorflow.keras.layers import RepeatVector
from tensorflow.keras.layers import TimeDistributed
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Bidirectional
from tensorflow.keras.callbacks import EarlyStopping
from  tensorflow.python.keras.utils.layer_utils import count_params
from  tensorflow import random

from sklearn import model_selection, preprocessing
from numpy.random import seed

from keras_tuner.tuners import Hyperband
from keras_tuner import Objective
from keras_tuner import errors

class LSTMDownscaler():

    TIMESTEPS, N_FEATURES = 0, 0

    def __init__(self):
        pass

    #Add past observations and next observations as predictors, also do the onehot encoding
    @staticmethod
    def transform(window_size, data_x, data_y=None):

        #TAKEN FROM THE BOOK
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
            for i in range(lookback, len(X) - lookback):
                t = []
                for j in range(lookback, -1, -1):
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
        window_size =  24 if "hour" in data.columns else 28  
        print(f"Transforming dataset for prediction")      
        data = self.transform(window_size, data_x = data)
        print(f"Predicting with model {model}")
        model = pickle.load(open(model, "rb"))
        predictions = model.predict(data)

        print(res.iloc[window_size][["time"]])

        print(res.iloc[len(res) - window_size]["time"])

        res = res.iloc[window_size:len(res) - window_size] # Match the sizes
        res["lstm"] = predictions
        return res[["time", "lstm"]]

    def optimize(self, hp):
        try:
            # Define the model        
            lstm = Sequential()
            
            lstm.add(Input(shape=(self.TIMESTEPS, self.N_FEATURES), 
                            name='input'))

            for i in range(hp.Int('num_layers', 1, 2)):
                lstm.add(
                    LSTM(units=hp.Int(f'units_{i}', min_value=8, max_value=48, step=8),
                        activation='tanh',
                        return_sequences=True,
                        recurrent_dropout=hp.Float('recurrent_dropout_rate', min_value=0.1, max_value=0.5, step=0.1),
                        name=f'lstm_layer_{i}'))
                
            lstm.add(Flatten())

            if hp.Boolean("dropout"):
                lstm.add(Dropout(
                    rate=hp.Float('dropout_rate', min_value=0.1, max_value=0.5, step=0.1)
                ))

            lstm.add(Dense(units=1,
                            activation='linear', 
                            name='output'))
            lstm.compile(
                            optimizer='adam',
                            loss='mse',
                            metrics=['mean_absolute_error']
                        )
            return lstm
        
        except Exception as _e:
            # raise error as failed to build
            raise errors.FailedTrialError(
                f"Failed to build model with error: {_e}"
            )

    """
        TRAIN ALL LSTM MODELS FOR DIFFERENT VARIABLES. THIS FUNCTION WILL SAVE THE MODELS IN THE MODELS FOLDER.
    """
    def fit(self, testing=False):
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

                if testing:
                    data = data.head(365*24*2) #Train with 2 years of data

                # Split the data into features and target
                X_train = data.drop(columns=["target"])
                y_train = data["target"]

                #Split the data in train and validation
                X_train, X_valid, y_train, y_valid = model_selection.train_test_split(X_train, y_train, test_size=0.2, shuffle=False)   

                #Set the amount of future and past observations to be taken into account  
                window_size =  24 if VARIABLES[variable_name]["daily"] else 28
                
                # Transform the data
                print("Transforming the data ...")
                X_train, y_train = self.transform(window_size, X_train, y_train)

                X_valid, y_valid = self.transform(window_size, X_valid, y_valid)

                self.TIMESTEPS = X_train.shape[1]  # equal to the lookback
                self.N_FEATURES = X_train.shape[2]  # the number of features        

                tuner = Hyperband(
                    self.optimize,
                    objective="val_mean_absolute_error",
                    max_epochs=50,
#                    overwrite=True,
                    directory = "models/hyperparameters",
                    project_name = f'lstm/{variable_name}', 
                    seed=SEED
                )

                callbacks = [EarlyStopping(patience=5)]           

                if VARIABLES[variable_name]["daily"]:
                    #For hourly data use a smaller dataset for the search of hyperparameters (We keep only 20%). 

                    x_train_subset, x_valid_subset, y_train_subset, y_valid_subset = model_selection.train_test_split(
                                                                                        X_train, y_train, 
                                                                                        test_size=0.25, #.8*.25 = .2 
                                                                                        shuffle=False)   
                    tuner.search(x_train_subset, 
                                 y_train_subset,  
                                 batch_size=128,  # Fixed batch size
                                 validation_data=(x_valid_subset, y_valid_subset), 
                                 callbacks=[callbacks]
                                )

                else:
                    tuner.search(X_train, 
                                 y_train,  
                                 batch_size=128,  # Fixed batch size
                                 validation_data=(X_valid, y_valid), 
                                 callbacks=[callbacks]
                                )
                            
                callbacks = [EarlyStopping(patience=10)]           
                
                best_hps = tuner.get_best_hyperparameters()[0]
                lstm = tuner.hypermodel.build(best_hps)
                lstm.fit(X_train, 
                         y_train, 
                         epochs=100 if VARIABLES[variable_name]["daily"] else 200, 
                         batch_size=128,                         
                         validation_data=(X_valid, y_valid),
                         callbacks=[callbacks]
                         )

                #Save the model
                if os.path.exists(f"models/{variable_name}") == False:
                    os.makedirs(f"models/{variable_name}")
                pickle.dump(lstm, open(f"models/{variable_name}/lstm.pkl", "wb"))

def main():
    lstm_downscaler = LSTMDownscaler()
    lstm_downscaler.fit(testing=True)
    

if __name__ == "__main__":
    main()
