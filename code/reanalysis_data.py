"""
This script downloads the ERA5 reanalysis data from the Copernicus Climate Data Store (CDS) using the cdsapi library.
Also transform the data.
"""

import cdsapi
import os

YEARS = range(1980,2024)
AREA = [-30, -59, -35, -53]
CDS = cdsapi.Client()
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
        "need_to_transform": True,
    },
    "10m_u_component_of_wind": {
        "reanalysis_name": "u10", 
        "cmip6_name":"uas",
        "hourly": True,
        "need_to_transform": True, #We need to take the module sqrt(u10^2 + v10^2)
    },
    "10m_v_component_of_wind": {
        "reanalysis_name": "u10", 
        "cmip6_name":"vas",
        "hourly": True,   
        "need_to_transform": True, #We need to take the module sqrt(u10^2 + v10^2)
    },
    "maximum_2m_temperature_since_previous_post_processing": {
        "reanalysis_name": "mx2t", 
        "cmip6_name":"tasmax",
        "hourly": True,
        "need_to_transform": False, #TODO: Check if this is correct

    },
    "minimum_2m_temperature_since_previous_post_processing": {
        "reanalysis_name": "mn2t", 
        "cmip6_name":"tasmin",
        "hourly": True,
        "need_to_transform": False, #TODO: Check if this is correct
    },
    "surface_pressure": {
        "reanalysis_name": "sp", 
        "cmip6_name":"ps",
        "hourly": True,
        "need_to_transform": False, #TODO: Check if this is correct
    },
    "total_cloud_cover": {
        "reanalysis_name": "tcc", 
        "cmip6_name":"clt",
        "hourly": False,
        "need_to_transform": False, #TODO: Check if this is correct
    },   
    "toa_incident_solar_radiation": {
        "reanalysis_name": "tisr", 
        "cmip6_name":"rsdt",
        "hourly": False,
        "need_to_transform": False, #TODO: Check if this is correct
    },
    "surface_solar_radiation_downwards": {
        "reanalysis_name": "ssrd", 
        "cmip6_name":"rsds",
        "hourly": False,
        "need_to_transform": False, #Look for the correct transformation
    },
}

def download_data(variable):
    variable_name = VARIABLES.get(variable).get("reanalysis_name")
    #If the directory does not exist, create it
    if not os.path.exists(f"data/reanalysis/reanalysis-{variable_name}"):
        os.makedirs(f"data/reanalysis/reanalysis-{variable_name}")

    file = f"{os.getcwd()}/data/reanalysis/reanalysis-{variable_name}"    
    os.chdir(file)

    for year in YEARS:
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

def main():
    for variable in VARIABLES:
        try:
            print(f"\033[92mDownloading data for {variable}\033[0m")
            download_data(variable)
        except Exception as e:
            #Print with red color the error
            print(f"\033[91mError downloading data for {variable}: {e}\033[0m")

if __name__ == "__main__":
    main()