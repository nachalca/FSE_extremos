import yaml
import os
import pandas as pd

# import models
from LSTMDownscaler import LSTMDownscaler
from NaiveDownscaler import NaiveDownscaler
from XgboostDownscaler import XgboostDownscaler
from CNNDownscaler import CNNDownscaler

###

#Load YML
with open("code/conf.yml", 'r') as file:
    conf = yaml.safe_load(file)
VARIABLES_TO_BE_DOWNSCALED = conf["VARIABLES_TO_BE_DOWNSCALED"]

#Define models
nv = NaiveDownscaler()
xgb = XgboostDownscaler()
lstm = LSTMDownscaler()
cnn = CNNDownscaler()

for var in VARIABLES_TO_BE_DOWNSCALED:
    files = sorted(os.listdir(f'data/to_be_downscaled/{var}'))
    downscaled_data = []
    for f in files:
        #Extract lab-experiment from file name
        lab_experiment = f.split('.')[0]

        lab = lab_experiment.split('-')[0]
        scenario = lab_experiment.split('-')[1]
        scenario = scenario.replace("_", "")  # Make the name more readable.

        #Downscaling  
        nv_downscaled = nv.predict(data= f'data/to_be_downscaled/{var}/{f}',
                                 model = f'models/{var}/naive.pkl')
        xgb_downscaled = xgb.predict(data= f'data/to_be_downscaled/{var}/{f}',
                                     model = f'models/{var}/xgboost.pkl')
        lstm_downscaled = lstm.predict(data= f'data/to_be_downscaled/{var}/{f}',
                                       model = f'models/{var}/lstm.pkl')
        cnn_downscaled = cnn.predict(data= f'data/to_be_downscaled/{var}/{f}',
                                     model = f'models/{var}/cnn.pkl')
        
        #Get undownscaled data
        undownscaled = pd.read_csv(f'data/to_be_downscaled/{var}/{f}')
        undownscaled = undownscaled[['time', var]]
        undownscaled.rename(columns={var: 'undownscaled'}, inplace=True)

        res = pd.merge(undownscaled, nv_downscaled, on='time', how='inner')
        res = pd.merge(res, xgb_downscaled, on='time', how='inner')
        res = pd.merge(res, lstm_downscaled, on='time', how='inner')    
        res = pd.merge(res, cnn_downscaled, on='time', how='inner')
        
        #Assert that we don't loss any observation
        assert len(res) == len(nv_downscaled), f"Length mismatch for {var} in {lab_experiment}"

        res['lab_experiment'] = f'{lab}.{scenario}'
        res = res.melt(id_vars=['time', 'lab_experiment'], var_name='model', value_name='value')
        downscaled_data.append(res)
        
    #Concatenate all downscaled data
    downscaled_data = pd.concat(downscaled_data, ignore_index=True)
    
    # Pivot wide
    downscaled_data = downscaled_data.pivot(index='time', columns=['model', 'lab_experiment'], values='value')
    
    # Flatten the multi-index columns
    downscaled_data.columns = ['.'.join(col).strip() for col in downscaled_data.columns.values]

    # Restore time as a column
    downscaled_data.reset_index(inplace=True)
    
    #Save downscaled data
    downscaled_data.to_csv(f'data/downscaled_ute/{var}.csv', index=False)
        