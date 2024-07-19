import pandas as pd
import cdsapi
import zipfile
from shutil import rmtree
from shutil import unpack_archive
import os

HISTORICAL_YEARS = [str(i) for i in range(2000,2015)]
PROJECTION_YEARS = [str(i) for i in range(2015,2101)] 
AREA = [-30, -59, -35, -53] #If we want to do the Salto Grande area we need to set the invervals to  [-26,-60,-36,-48]
CDS = cdsapi.Client()
ROOT_FOLDER = os.getcwd()
EXPERIMENTS = ["ssp2_4_5","ssp4_3_4", "ssp3_7_0", "ssp5_8_5"]
MODELS = ["ec_earth3", "ec_earth3_veg_lr", 
          "cesm2","cesm2_waccm","cnrm_cm6_1",
          "mri_esm2_0", "ukesm1_0_ll"]
VARIABLES = {
    "near_surface_air_temperature": {
       "cmip6_name": "tas",
       "daily": True,
    },
    "precipitation": {
        "cmip6_name":"pr",
        "daily": True,
    },
    "near_surface_wind_speed": {
        "cmip6_name":"sfcWind",
        "daily": True,
    },
    "daily_maximum_near_surface_air_temperature": {
        "reanalysis_name": "mx2t", 
        "cmip6_name":"tasmax",
        "daily": True,
    },
    "daily_minimum_near_surface_air_temperature": {
        "reanalysis_name": "mn2t", 
        "cmip6_name":"tasmin",
        "daily": True,
   },
    "sea_level_pressure": {
        "cmip6_name":"slp",
        "daily": True,
    },
    "total_cloud_cover_percentage": {
        "cmip6_name":"clt",
        "daily": False,
    },   
    "toa_incident_shortwave_radiation": { 
        "cmip6_name":"rsdt",
        "daily": False,
    },
    "surface_downwelling_shortwave_radiation": {
        "cmip6_name":"rsds",
        "daily": False,
    },
}

def unzip_file(file):
    #get folder from file
    extract_dir = os.path.dirname(file)
    file_name = os.path.basename(file).split(".")[0]
    unpack_archive(file, extract_dir + "/tmp")
    for f in os.listdir(extract_dir + "/tmp"):
        if f.endswith(".nc"):
            os.rename(extract_dir + "/tmp/" + f, extract_dir + "/" + file_name + ".nc")
    rmtree(extract_dir + "/tmp")
    os.remove(file)

def download_data(model, download_historical = False):

    #Download projections data
    for experiment in EXPERIMENTS:
        variable_name = ""
        try:
            for variable in VARIABLES:
                print(f"Downloading data for model: \033[92m{model}\033[0m experiment: \033[92m{experiment}\033[0m variable: \033[92m{variable}\033[0m")
                variable_name = VARIABLES.get(variable).get("cmip6_name")
        
                #If the directory does not exist, create it
                if not os.path.exists(f"data/cmip/projections/{model}/{experiment}"):
                    os.makedirs(f"data/cmip/projections/{model}/{experiment}")

                file = f"data/cmip/projections/{model}/{experiment}/{variable_name}.zip"
                #If the file does not exist, download it
                if not os.path.exists(file):
                    if(VARIABLES.get(variable).get("daily")):
                        try:
                            CDS.retrieve(
                                'projections-cmip6',
                                {
                                    'experiment': experiment,
                                    'model': model,
                                    'variable': variable,
                                    'year': PROJECTION_YEARS,
                                    'temporal_resolution': 'daily',
                                    'area': AREA,
                                    'format': 'zip',
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
                                file)
                            unzip_file(file)
                        except Exception as e:
                            if "matching" in str(e):
                                raise ""
                            else:
                                raise e
                                 
                    else:
                        try:
                            CDS.retrieve(
                            'projections-cmip6',
                                {
                                    'experiment': experiment,
                                    'model': model,
                                    'variable': variable,
                                    'year': PROJECTION_YEARS,
                                    'temporal_resolution': 'monthly',
                                    'area': AREA,
                                    'format': 'zip',
                                    'month': [
                                        '01', '02', '03',
                                        '04', '05', '06',
                                        '07', '08', '09',
                                        '10', '11', '12',
                                    ]
                                },
                                file)
                            unzip_file(file)
                        except Exception as e:
                            if "matching" in str(e):
                                raise ""
                            else:
                                pass                            
                    
        except:
            print(f"The experiment \033[91m{experiment}\033[0m of the model \033[91m{model}\033[0m doesn't contain \033[91m{variable}\033[0m")
            rmtree(f"data/cmip/projections/{model}/{experiment}")
        
        if(download_historical):
            #Download historical data
            for variable in VARIABLES:
                variable_name = VARIABLES.get(variable).get("cmip6_name")
                if not os.path.exists(f"{variable_name}.nc"):
                    if(VARIABLES.get(variable).get("daily")):
                        CDS.retrieve(
                            'projections-cmip6',
                            {
                                'variable': variable,
                                'year': HISTORICAL_YEARS,
                                'area': AREA,
                                'format': 'zip',
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
                            f"{variable_name}.nc")
                    else:
                        CDS.retrieve(
                            'projections-cmip6',
                            {
                                'variable': variable,
                                'year': HISTORICAL_YEARS,
                                'area': AREA,
                                'format': 'zip',   
                                'month': [
                                    '01', '02', '03',
                                    '04', '05', '06',
                                    '07', '08', '09',
                                    '10', '11', '12',
                                ]
                            },
                            f"{variable_name}.nc")


def main():
    for model in MODELS:
        download_data(model, download_historical = False)

if __name__ == "__main__":
    main()