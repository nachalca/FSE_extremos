"""
This script downloads the ERA5 reanalysis data from the Copernicus Climate Data Store (CDS) using the cdsapi library.
Also transform the data.
"""
import cdsapi
import os
import pandas as pd
import numpy as np
import xarray as xr
import yaml    
from datetime import datetime, timedelta

CDS = cdsapi.Client()
ROOT_FOLDER = os.getcwd()

VARIABLES = {}
YEARS = []
AREA = []
SEED = 0

#Load the configuration from the conf.json file
def load_configuration():
    global VARIABLES, YEARS, AREA, SEED

    with open("code/conf.yml", 'r') as file:
        conf = yaml.safe_load(file)
    
    #OVERWRITE THE GLOBAL VARIABLES
    VARIABLES = conf["VARIABLES"]
    YEARS = list(range(conf["REANALYSIS_YEARS"]["START"], conf["REANALYSIS_YEARS"]["END"] + 1))
    SEED = conf["SEED"]
    AREA = conf["AREA"]

    return conf

def download_data(variable, variable_name):

    print(f"Downloading data for variable \033[92m{variable}\033[0m")

    os.chdir(ROOT_FOLDER)

    #If the directory does not exist, create it
    if not os.path.exists(f"data/reanalysis/reanalysis-{variable_name}"):
        print(f"Creating directory data/reanalysis/reanalysis-{variable_name}")
        os.makedirs(f"data/reanalysis/reanalysis-{variable_name}")

    
    file = f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}"    
    os.chdir(file)

#    for year in YEARS:
        #If the file already exists, do not download it
    if not os.path.exists(f"{variable_name}.nc"):
        #Download the data in 10 years batches
        for i in range(0, len(YEARS), 10):
            if not os.path.exists(f"{variable_name}_part{i//10 + 1}.nc"):
                CDS.retrieve(
                    'reanalysis-era5-single-levels',
                    {
                        'variable': variable,
                        'year': YEARS[i:min(i+10,len(YEARS))],
                        'area': AREA,
                        'format': 'netcdf',
                        'product_type': ['reanalysis'],  
                        "download_format": "unarchived",    
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
                        ]
                    },
                    f"{variable_name}_part{i//10 + 1}.nc"
                )
            
            #Change chunking to make it faster
            os.system(f"nccopy -d0 -s {variable_name}_part{i//10 + 1}.nc u_{variable_name}_part{i//10 + 1}.nc")
            os.system(f"ncks --cnk_plc=g2d --cnk_dmn time,365 u_{variable_name}_part{i//10 + 1}.nc m_{variable_name}_part{i//10 + 1}.nc")
            os.system(f"rm u_{variable_name}_part{i//10 + 1}.nc")

            #os.system(f"mv m_{variable_name}_part{i//10 + 1}.nc {variable_name}_part{i//10 + 1}.nc")
            
    os.chdir(ROOT_FOLDER)

            
# A function to join all the nc files
def join_files(variable_name):
    print(f"Joining the data for variable \033[92m{variable_name}\033[0m")
    os.chdir(ROOT_FOLDER)
    #If the file already exists, remove it
    if not os.path.exists(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.nc"):
        #os.remove(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.nc")
        os.chdir(f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}")
        os.system(f"cdo -v -f nc4c -z zip_4 mergetime m_*.nc {variable_name}.nc")
        os.system(f"rm m_*.nc")
        os.chdir(ROOT_FOLDER)

#Check if the generated nc file is correct
def validate_nc(variable_name):
    print(f"Validating the data for variable \033[92m{variable_name}\033[0m")
    os.chdir(f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}")
    data_nc = xr.open_dataset(f"{variable_name}.nc")
    #Get first year
    y = YEARS[0]
    for i in range(0, len(YEARS), 10):
        data_nc_part = xr.open_dataset(f"{variable_name}_part{i//10 + 1}.nc")
        #Select specific days
        data2 = data_nc[variable_name].sel(valid_time=f"{y+i}-01-01T10:00:00")
        data1 = data_nc_part[variable_name].sel(valid_time=f"{y+i}-01-01T10:00:00")
        # Check if they are equal
        are_equal = np.allclose(data1.values, data2.values, atol=1e-6)

        if are_equal:
            print("The files are equal at the specified time.")
        else:
            print("The files are NOT equal at the specified time.")
            diff = data1 - data2
            print(diff)            

    os.chdir(ROOT_FOLDER)

def wind_transform():

    print("Transforming the wind data")

    # Load the NetCDF file
    u10 = xr.open_dataset(f'data/reanalysis/reanalysis-u10/u10.nc')
    v10 = xr.open_dataset(f'data/reanalysis/reanalysis-v10/v10.nc')

    # Extract the variables (assuming they are named 'u' and 'v')
    u = u10['u10']
    v = v10['v10']

    # Compute the Euclidean norm
    norm = np.sqrt(u**2 + v**2)

    norm.attrs = u.attrs.copy()  # Copy from u, or v depending on what metadata is more relevant
    norm.encoding = u.encoding.copy()  # Copy all encoding properties

    # Create a new dataset to store the norm
    norm_ds = xr.Dataset({'u10': norm})

	# Save the result to a new NetCDF file
    norm_ds.to_netcdf(f'data/reanalysis/reanalysis-u10/w10.nc')

#A function to summarize all the spatial data on a single point, also generate a csv file
def summarize_data(variable):
    print(f"Summarizing the spatial data into a single point for variable \033[92m{variable}\033[0m")
    os.chdir(ROOT_FOLDER)
    variable_name = VARIABLES[variable]["reanalysis_name"][0][1]

    os.chdir(f"{ROOT_FOLDER}/data/reanalysis/reanalysis-{variable_name}")
    if not os.path.exists(f"{variable_name}.csv"):

        data_nc = xr.open_dataset(f"{variable_name}.nc")
        
        #Assert that the nc file doesn't contain missing values
        assert data_nc[variable_name].where(data_nc[variable_name] == data_nc[variable_name].encoding['missing_value']).count() == 0 or \
                data_nc[variable_name].isnull().sum() == 0, f"Missing values in the nc file {variable_name}.nc"
        
        reanalysis = pd.DataFrame()
        reanalysis['valid_time'] = pd.to_datetime(data_nc.valid_time)
        
        #Assert that time has the correct size
        days_between = (datetime(YEARS[-1] + 1,1,1) - datetime(YEARS[0], 1, 1)).days

        assert days_between * 24 == len(reanalysis), \
            f"Time has the wrong size: {len(reanalysis)}, when it should be {days_between * 24}"
        
        if(variable_name == "mx2t"):
            reanalysis[variable] = data_nc[variable_name].max(dim=["latitude","longitude"])
        elif(variable_name == "mn2t"):
            reanalysis[variable] = data_nc[variable_name].min(dim=["latitude","longitude"])
        else:
            reanalysis[variable] = data_nc[variable_name].mean(dim=["latitude","longitude"]) 
        
        reanalysis.to_csv(f"{variable_name}.csv", index=False)
    #    os.remove(f"{variable_name}.nc") #drop the nc file to realese space

    os.chdir(ROOT_FOLDER)


# A function to merge all the dataframes
def merge_all_data():
    print(f"\033[92mMerging all the dataframes\033[0m")
    data = pd.DataFrame()
    for variable in VARIABLES:
        variable_name = VARIABLES[variable]["reanalysis_name"][0][1]
        if data.empty:
            data = pd.read_csv(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.csv")
        else:
            data = data.merge(pd.read_csv(f"data/reanalysis/reanalysis-{variable_name}/{variable_name}.csv"), how='inner', on='valid_time')

    #Rename valid_time column to time
    data.rename(columns={"valid_time": "time"}, inplace=True)
    
    data.to_csv("data/reanalysis/reanalysis.csv", index=False)


def final_dataset():

    print(f"\033[92mObtaining the final dataset\033[0m")

    data = pd.read_csv(f"data/reanalysis/reanalysis.csv")
    #total_precipitation column needs to be transformed to kg m-2 h-1 (Cmip6 pr is in kg m-2 s-1 but it's to small)
    data['pr'] = data['pr'] * 1000

    #We need to transform the cloud cover to percentage
    data['clt'] = data['clt']*100
    #We need to transform the toa_incident_solar_radiation to W m-2
    data['rsdt'] = data['rsdt'] / (60*60)
    #We need to transform the solar radiation to W m-2
    data['rsds'] = data['rsds'] / (60*60)

    data.to_csv("data/reanalysis/reanalysis.csv", index=False)


def main():

    load_configuration()

#    Download the data for each variable
#    for cmip_variable in VARIABLES:
    #    for reanalysis_name in VARIABLES[cmip_variable]["reanalysis_name"]:
        #     try:
        #         download_data(reanalysis_name[0], reanalysis_name[1])
        #         join_files(reanalysis_name[1])

        #     except Exception as e:
        #         print(f"\033[91mError with variable {reanalysis_name[0]}: {e}\033[0m")

        validate_nc(VARIABLES[cmip_variable]["reanalysis_name"][0][1])
        # if(cmip_variable == "sfcWind"):
        #     wind_transform()

        # try:
        #     summarize_data(cmip_variable)
        # except Exception as e:
        #     print(f"\033[91mError with variable {cmip_variable}: {e}\033[0m")

    merge_all_data()
    final_dataset()

if __name__ == "__main__":
    main()
