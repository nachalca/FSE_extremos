import pandas as pd
import numpy as np

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

from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

from collections import Counter

import matplotlib.pyplot as plt
import seaborn as sns

from numpy.random import seed
seed(1234)

SEED = 1234
DATA_SPLIT_PCT = 0.2

model = Sequential()
model.add(Input(shape=(TIMESTEPS, 
                       N_FEATURES), 
                name='input'))
model.add(Conv1D(filters=16, 
                 kernel_size=4,
                 activation='relu', 
                 padding='valid'))
model.add(MaxPool1D(pool_size=4, 
                    padding='valid'))
model.add(Flatten())
model.add(Dense(units=16, 
                activation='relu'))
model.add(Dense(units=1, 
                activation='linear', 
                name='output'))
model.summary()