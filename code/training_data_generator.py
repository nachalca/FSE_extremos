import pandas as pd
import yaml
import os


VARIABLES = {}
MODELS = []
EXPERIMENTS = []
VARIABLES_TO_BE_DOWNSCALED = {}
SEED = 1234

#Load the configuration from the conf.json file
def load_configuration():
    global VARIABLES, MODELS,EXPERIMENTS,VARIABLES_TO_BE_DOWNSCALED

    with open("code/conf.yml", 'r') as file:
        conf = yaml.safe_load(file)
    
    #OVERWRITE THE GLOBAL VARIABLES
    VARIABLES = conf["VARIABLES"]
    MODELS = conf["MODELS"]
    EXPERIMENTS = conf["EXPERIMENTS"]
    VARIABLES_TO_BE_DOWNSCALED = conf["VARIABLES_TO_BE_DOWNSCALED"]
    return conf

#First step, upscale the data to daily or monthly depending on the variable
def upscale(data):

    data_len = len(data)
    data = data.set_index("time")  

    for col in data.columns:
        if col == "time" or col == "target":
            continue
        
        if VARIABLES.get(col).get("daily"):
            if col == "tasmax":
                data[col] = data[col].resample("D").max()
            elif col == "tasmin":
                data[col] = data[col].resample("D").min()
            else:
                data[col] = data[col].resample("D").mean()
        else:
            data[col] = data[col].resample("MS").mean()

    data = data.ffill()
    data = data.reset_index()
    assert data_len == len(data), f"Data has the wrong size: {len(data)}, when it should be {data_len}"
    return data

#Third step - Case 1, add hour variable, month variable, year variable and sun data
def add_hour_month_year_sun(data):
    data["hour"] = data["time"].dt.hour
    data["month"] = data["time"].dt.month

    #Save data lenght
    data_len = len(data)

    sun = pd.read_csv("data/external_data/sun.csv")
    sun["time"] = pd.to_datetime(sun["time"])
    data = data.merge(sun, how='inner', on='time')  

    data["date"] = pd.to_datetime(data["time"].dt.date)
    daylight = pd.read_csv("data/external_data/daylight.csv")
    daylight["date"] = pd.to_datetime(daylight["time"])
    daylight.drop(columns=["time"], inplace=True)
    data = data.merge(daylight, how='inner', on="date")
    data.drop(columns=["date"], inplace=True)

    assert data_len == len(data), f"Data has the wrong size: {len(data)}, when it should be {data_len}"

    return data

#Third step - Case 2, add hour variable and sunlight time
def add_hour_month_sunlight(data):

    data["month"] = data["time"].dt.month

    #Save data lenght
    data_len = len(data)

    daylight = pd.read_csv("data/external_data/daylight.csv")
    daylight["time"] = pd.to_datetime(daylight["time"])
    data = data.merge(daylight, how='inner', on='time')  

    assert data_len == len(data), f"Data has the wrong size: {len(data)}, when it should be {data_len}"

    return data

#Truncate is used to truncate the data to the first N years, if it is -1 we don't truncate
def generate_dataframe(model, experiment = "", truncate = -1):
    data = pd.DataFrame()
    if model == "reanalysis":
        data = pd.read_csv(f"data/reanalysis/reanalysis.csv")
    else:
        data = pd.read_csv(f"data/cmip/projections/{model}/{experiment}/{experiment}.csv")

    data["time"] = pd.to_datetime(data["time"])

    for variable in VARIABLES_TO_BE_DOWNSCALED:

        print(f"Generating training dataset for \033[92m{variable}\033[0m of model \033[92m{model}\033[0m")

        data_variable = data.copy()
        data_variable["target"] = data_variable[variable]

        # #To test the model I will use the first 8 years (We don't truncate the dailies datasets)
        # if(VARIABLES_TO_BE_DOWNSCALED.get(variable).get("daily") and truncate != -1):
        #     #Get the first day of the dataset
        #     first_day = data_variable["time"].iloc[0]
        #     #Truncate the data to the first N years
        #     data_variable = data_variable[data_variable["time"] < f"{first_day.year + truncate}-01-01"]

        data_variable = upscale(data_variable)

        #If the variable is gonna be downscaled to daily, we need to group by day
        if(not VARIABLES_TO_BE_DOWNSCALED.get(variable).get("daily")):
            data_len = len(data)
            data_variable["time"] = data_variable["time"].dt.date
            data_variable = data_variable.groupby("time").mean()
            data_variable["time"] = pd.to_datetime(data_variable.index)
            data_variable.reset_index(drop=True, inplace=True)
            data_variable = data_variable[["time"] + [col for col in data_variable.columns if col != "time"]]
            assert data_len == len(data), f"Data has the wrong size: {len(data)}, when it should be {data_len/24}"
            
        # If the variable is gonna be downscaled to hourly, we add hour,month, sun position and azimuth.
        # Else we only add the month and sunligth time
        if(VARIABLES_TO_BE_DOWNSCALED.get(variable).get("daily")):
            data_variable = add_hour_month_year_sun(data_variable)
        else:
            data_variable = add_hour_month_sunlight(data_variable)
        
        if(model == "reanalysis"):
            if not os.path.exists("data/training"):
                os.makedirs("data/training")

            if not os.path.exists("data/testing"):
                os.makedirs("data/testing")

            #Save the data up to 2014 so later it can be used to train the model
            data_train = data_variable[data_variable["time"] < "2015-01-01"]
            data_train.to_csv(f"data/training/{variable}.csv", index=False)

            #Save the data from 2015 to 2023, so later it can be used to test the model
            data_test = data_variable[data_variable["time"] >= "2015-01-01"]
            data_test.to_csv(f"data/testing/{variable}.csv", index=False)

        else:
            if not os.path.exists(f"data/to_be_downscaled//{variable}"):
                os.makedirs(f"data/to_be_downscaled/{variable}")            
            data_variable.drop(columns=["target"], inplace=True) #We don't have the target for the cmip models

            #To test the model I will use the first N years (We don't truncate the dailies datasets)
            if(VARIABLES_TO_BE_DOWNSCALED.get(variable).get("daily") and truncate != -1):
                #Get the first day of the dataset
                first_day = data_variable["time"].iloc[0]
                #Truncate the data to the first N years
                data_variable = data_variable[data_variable["time"] < f"{first_day.year + truncate}-01-01"]            
            
            data_variable.to_csv(f"data/to_be_downscaled/{variable}/{model}_{experiment}.csv", index=False)

def main():

    load_configuration()

    generate_dataframe("reanalysis")
    
    for model in MODELS:
        for experiment in EXPERIMENTS:
            #If the dataset of the model and experiment exists, we generate the dataset to be downscaled
            if os.path.exists(f"data/cmip/projections/{model}/{experiment}/{experiment}.csv"):
                generate_dataframe(model, experiment, 10)

if __name__ == "__main__":
    main()