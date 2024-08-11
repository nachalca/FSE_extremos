import pandas as pd
import os

VARIABLES = {
    "sfcWind": {
        "daily": True,
    },    
    "tas": {
       "daily": True,
    },
    "pr": {
        "daily": True,
    },
    "tasmax": {
        "daily": True,
    },
    "tasmin": {
        "daily": True,
   },
    "psl": {
        "daily": True,
    },
    "clt": {
        "daily": False,
    },   
    "rsdt": { 
        "cmip6_name":"rsdt",
        "daily": False,
    },
    "rsds": {
        "daily": False,
    },
}

VARIABLES_TO_BE_DOWNSCALED = {
    "sfcWind": {
        "daily": True,
    },
    "tas": {
       "daily": True,
    },
    "pr": {
        "daily": True,
    },  
    "clt": {
        "daily": False,
    },       
    "rsds": {
        "daily": False,
    },    
}

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

    assert data_len == len(data), f"Data has the wrong size: {len(data)}, when it should be {data_len}"

    return data

#Last step, add past observations ad next observations as predictors
def add_past_future(data, window_size):
    # Filter columns to process
    cols_to_process = [col for col in data.columns if col not in ["time", "target", "hour", "month"]]
    
    new_columns = []

    for col in cols_to_process:
        for i in range(1, window_size + 1):
            new_columns.append(data[col].shift(i).rename(f"{col}_past_{i}"))
            new_columns.append(data[col].shift(-i).rename(f"{col}_future_{i}"))
    
    # Add all new columns to the DataFrame at once
    data = pd.concat([data] + new_columns, axis=1)
        
    # Delete the first #window_size rows and the last #window_size rows
    data = data.iloc[window_size:-window_size]
    
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

def main():
    data = pd.read_csv("data/reanalysis/reanalysis.csv")
    data["time"] = pd.to_datetime(data["time"])

    #Create main folder if non existent
    if not os.path.exists("data/training"):
        os.makedirs("data/training")

    for variable in VARIABLES_TO_BE_DOWNSCALED:
        data_variable = data.copy()
        data_variable["target"] = data_variable[variable]
        
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
        
        if(VARIABLES_TO_BE_DOWNSCALED.get(variable).get("daily")):
            data_variable = add_past_future(data_variable, 24) #Add previous and next 24 hours
        else:
            data_variable = add_past_future(data_variable, 1) #Add previous and next day

        data_variable.to_csv(f"data/training/{variable}.csv", index=False)

if __name__ == "__main__":
    main()