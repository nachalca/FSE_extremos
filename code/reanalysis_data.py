"""
This script downloads the ERA5 reanalysis data from the Copernicus Climate Data Store (CDS) using the cdsapi library.
Also transform the data.
"""

import cdsapi
import os
import pandas as pd
import xarray as xr    
from datetime import datetime, timedelta
import pvlib

YEARS = range(1980,2024)
AREA = [-30, -59, -35, -53] #If we want to do the Salto Grande area we need to set the invervals to  [-26,-60,-36,-48]
CDS = cdsapi.Client()
ROOT_FOLDER = os.getcwd()
VARIABLES = {
  "2m_temperature": {
       "reanalysis_name": "t2m", 
       "cmip6_name": "tas",
       "hourly": True,
       "need_to_transform": False,
   },
    "total_precipitation": {
        "reanalysis_name": "tp", 
        "cmip6_name":"pr",
        "hourly": True,
        "need_to_transform": True, #We need to divide by 3.6 
    },
    "10m_u_component_of_wind": {
        "reanalysis_name": "u10", 
        "cmip6_name":"uas",
        "hourly": True,
        "need_to_transform": True, #We need to take the module sqrt(u10^2 + v10^2)
    },
    "10m_v_component_of_wind": {
        "reanalysis_name": "v10", 
        "cmip6_name":"vas",
        "hourly": True,   
        "need_to_transform": True, #We need to take the module sqrt(u10^2 + v10^2)
    },
    "maximum_2m_temperature_since_previous_post_processing": {
        "reanalysis_name": "mx2t", 
        "cmip6_name":"tasmax",
        "hourly": True,
        "need_to_transform": False, 
    },
    "minimum_2m_temperature_since_previous_post_processing": {
        "reanalysis_name": "mn2t", 
        "cmip6_name":"tasmin",
        "hourly": True,
        "need_to_transform": False, 
   },
    "mean_sea_level_pressure": {
        "reanalysis_name": "msl", 
        "cmip6_name":"psl",
        "hourly": True,
        "need_to_transform": False, 
    },
    "total_cloud_cover": {
        "reanalysis_name": "tcc", 
        "cmip6_name":"clt",
        "hourly": False,
        "need_to_transform": True, #We need to multiply by 100
    },   
    "toa_incident_solar_radiation": {
        "reanalysis_name": "tisr", 
        "cmip6_name":"rsdt",
        "hourly": False,
        "need_to_transform": True, # We need to transform Joules to Watts, so we need to divide by the amount of seconds 60*60*24
    },
    "surface_solar_radiation_downwards": {
        "reanalysis_name": "ssrd", 
        "cmip6_name":"rsds",
        "hourly": False,
        "need_to_transform": True, # We need to transform Joules to Watts, so we need to divide by the amount of seconds 60*60*24
   },
}

def download_data(variable):

    print(f"Downloading data for variable \033[92m{variable}\033[0m")

    os.chdir(ROOT_FOLDER)
    variable_name = VARIABLES.get(variable).get("reanalysis_name")
    #If the directory does not exist, create it
    if not os.path.exists(f"data/reanalysis/reanalysis-{variable_name}"):
        os.makedirs(f"data/reanalysis/reanalysis-{variable_name}")

    
    file = f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}"    
    os.chdir(file)

    for year in YEARS:
        #If the file already exists, do not download it
        if not os.path.exists(f"{year}.nc"):
            if(VARIABLES.get(variable).get("hourly")):
                CDS.retrieve(
                    'reanalysis-era5-single-levels',
                    {
                        'variable': variable,
                        'year': year,
                        'area': AREA,
                        'format': 'netcdf',
                        'product_type': 'reanalysis',       
                        'month': [
                            '01', '02', '03',
                            '04', '05', '06',
                            '07', '08', '09',
                            '10', '11', '12',
                        ],
                        'day': [
                            '01', '02', '03',
                            '04', '05', '06',
                            '07', '08', '09',
                            '10', '11', '12',
                            '13', '14', '15',
                            '16', '17', '18',
                            '19', '20', '21',
                            '22', '23', '24',
                            '25', '26', '27',
                            '28', '29', '30',
                            '31',
                        ],
                        'time': [
                            '00:00', '01:00', '02:00',
                            '03:00', '04:00', '05:00',
                            '06:00', '07:00', '08:00',
                            '09:00', '10:00', '11:00',
                            '12:00', '13:00', '14:00',
                            '15:00', '16:00', '17:00',
                            '18:00', '19:00', '20:00',
                            '21:00', '22:00', '23:00',
                        ],
                    },
                    f"{year}.nc")
            else:
                CDS.retrieve(
                    'reanalysis-era5-single-levels',
                    {
                        'variable': variable,
                        'year': year,
                        'area': AREA,
                        'format': 'netcdf',
                        'product_type': 'reanalysis',       
                        'month': [
                            '01', '02', '03',
                            '04', '05', '06',
                            '07', '08', '09',
                            '10', '11', '12',
                        ],
                        'day': [
                            '01', '02', '03',
                            '04', '05', '06',
                            '07', '08', '09',
                            '10', '11', '12',
                            '13', '14', '15',
                            '16', '17', '18',
                            '19', '20', '21',
                            '22', '23', '24',
                            '25', '26', '27',
                            '28', '29', '30',
                            '31',
                        ],
                    },
                    f"{year}.nc")
    os.chdir(ROOT_FOLDER)

            
# A function to join all the nc files
def join_files(variable):
    print(f"Joining the data for variable \033[92m{variable}\033[0m")
    os.chdir(ROOT_FOLDER)
    variable_name = VARIABLES.get(variable).get("reanalysis_name")
    #If the file already exists, remove it
    if os.path.exists(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.nc"):
        os.remove(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.nc")
    os.chdir(f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}")
    os.system(f"cdo -b F64 mergetime *.nc {variable_name}.nc")
    os.chdir(ROOT_FOLDER)

#A function to summarize all the spatial data on a single point, also generate a csv file
def summarize_data(variable):
    print(f"Summarizing the spatial data into a single point for variable \033[92m{variable}\033[0m")
    os.chdir(ROOT_FOLDER)
    variable_name = VARIABLES.get(variable).get("reanalysis_name")
    variable_cmip6_name = VARIABLES.get(variable).get("cmip6_name")
    os.chdir(f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}")
    data_nc = xr.open_dataset(f"{variable_name}.nc")
    
    #Assert that the nc file doesn't contain missing values
    assert data_nc[variable_name].where(data_nc[variable_name] == data_nc[variable_name].encoding['missing_value']).count() == 0 or \
            data_nc[variable_name].isnull().sum() == 0, f"Missing values in the nc file {variable_name}.nc"
    
    reanalysis = pd.DataFrame()
    reanalysis['time'] = pd.to_datetime(data_nc.time)
    
    #Assert that time has the correct size
    days_between = (datetime(YEARS[-1] + 1,1,1) - datetime(YEARS[0], 1, 1)).days
    if VARIABLES.get(variable).get("hourly"):
        assert days_between * 24 == len(reanalysis), \
            f"Time has the wrong size: {len(reanalysis)}, when it should be {days_between * 24}"
    else:
        assert days_between == len(reanalysis),\
            f"Time has the wrong size: {len(reanalysis)}, when it should be {days_between}"
    
    reanalysis[variable_cmip6_name] = data_nc[variable_name].mean(dim=["latitude","longitude"]) 
    reanalysis.to_csv(f"{variable_name}.csv", index=False)
    os.remove(f"{variable_name}.nc") #drop the nc file to realese space
    os.chdir(ROOT_FOLDER)

#A function to expand the daily variables to a hourly scale using the csv file obtained in summarize_data
def expand_daily_to_hourly(variable):
    print(f"Expanding the daily data to an hourly scale for variable \033[92m{variable}\033[0m")
    os.chdir(ROOT_FOLDER)
    variable_name = VARIABLES.get(variable).get("reanalysis_name")
    os.chdir(f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}")
    data = pd.read_csv(f"{variable_name}.csv")

    #Substract 12 hr to time column, idk but the time is setted to 12:00 so we need to change it to 00:00
    data['time'] = pd.to_datetime(data['time']) - timedelta(hours=12)
    data = data.set_index('time')

    # Append an extra day with NaN value to handle the last day edge case
    last_day = data.index[-1] + pd.Timedelta(days=1)
    data.loc[last_day] = [1]
    
    data = data.resample('h').ffill()
    
    # Remove the extra day
    data = data[data.index < last_day]

    #Assert that time has the correct size
    days_between = (datetime(YEARS[-1] + 1,1,1) - datetime(YEARS[0], 1, 1)).days
    assert days_between * 24 == len(data), f"Time has the wrong size: {len(data)}, when it should be {days_between * 24}"
    data.to_csv(f"{variable_name}.csv")
    os.chdir(ROOT_FOLDER)


# A function to merge all the dataframes
def merge_all_data():
    print(f"\033[92mMerging all the dataframes\033[0m")
    data = pd.DataFrame()
    for variable in VARIABLES:
        variable_name = VARIABLES.get(variable).get("reanalysis_name")
        if data.empty:
            data = pd.read_csv(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.csv")
        else:
            data = data.merge(pd.read_csv(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.csv"), how='inner', on='time')

    data.to_csv("data/reanalysis/reanalysis.csv", index=False)

def sun_position(time):
    
    latitude = (AREA[0] + AREA[2]) / 2
    longitude = (AREA[1] + AREA[3]) / 2

    solar_position = pvlib.solarposition.get_solarposition(time, latitude, longitude)
    elevation = solar_position['elevation'].values[0]
    azimuth = solar_position['azimuth'].values[0]
    
    return elevation, azimuth

def final_dataset():

    print(f"\033[92mObtaining the final dataset\033[0m")

    data = pd.read_csv(f"data/reanalysis/reanalysis.csv")
    #total_precipitation column needs to be transformed to kg m-2 s-1
    data['pr'] = data['pr'] * 1000 / 3600
    #We need to take the module of the wind
    data['sfcWind'] = (data['uas']**2 + data['vas']**2)**0.5
    data = data.drop(columns=['uas', 'vas'])
    #We need to transform the cloud cover to percentage
    data['clt'] = data['clt']*100
    #We need to transform the toa_incident_solar_radiation to W m-2
    data['rsdt'] = data['rsdt'] / (60*60*24)
    #We need to transform the solar radiation to W m-2
    data['rsds'] = data['rsds'] / (60*60*24)

    #Get the solar position.
    data['time_2'] = pd.to_datetime(data['time'])
    print("Getting the solar position, it may take some time")
    data[['elevation', 'azimuth']] = data['time_2'].apply(lambda x: pd.Series(sun_position(x)))    #Add the solar position

    data.drop(columns=['time_2'], inplace=True)

    data.to_csv("data/reanalysis/reanalysis.csv", index=False)


def main():
#    Download the data for each variable
    for variable in VARIABLES:
        try:
            download_data(variable)
            join_files(variable)
            summarize_data(variable)
            if not VARIABLES.get(variable).get("hourly"):
                expand_daily_to_hourly(variable)

        except Exception as e:
            print(f"\033[91mError with variable {variable}: {e}\033[0m")
    
    merge_all_data()
    final_dataset()

if __name__ == "__main__":
    main()
