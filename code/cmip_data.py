import cdsapi
from shutil import rmtree
from shutil import unpack_archive
import os
import pandas as pd
import xarray as xr    
from datetime import datetime, timedelta
import yaml

CDS = cdsapi.Client()
ROOT_FOLDER = os.getcwd()

HISTORICAL_YEARS = [str(i) for i in range(2000,2015)]
PROJECTION_YEARS = [] 
AREA = [] 
MODELS = []
EXPERIMENTS = []
VARIABLES = {}
SEED = 0

#Load the configuration from the conf.json file
def load_configuration():
    global PROJECTION_YEARS, AREA, MODELS, EXPERIMENTS, VARIABLES, SEED

    with open("code/conf.yml", 'r') as file:
        conf = yaml.safe_load(file)
    
    #OVERWRITE THE GLOBAL VARIABLES
    PROJECTION_YEARS = [str(num) for num in range(conf["PROJECTION_YEARS"]["START"], conf["PROJECTION_YEARS"]["END"] + 1)]

    AREA = conf["AREA"]
    MODELS = conf["MODELS"]   
    EXPERIMENTS = conf["EXPERIMENTS"]            
    VARIABLES = conf["VARIABLES"]
    SEED = conf["SEED"]

    return conf

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

#A function to find the folders that are completed
def find_folders(path):
    folders = []
    for folder in os.listdir(path):
        if os.path.exists(os.path.join(path, folder, "COMPLETED")):
            folders.append(folder)
    return folders

def download_data(model, download_historical = False):

    #If the directory does not exist, create it
    if not os.path.exists(f"data/cmip/projections/{model}"):
        os.makedirs(f"data/cmip/projections/{model}")    

    #Download projections data
    completed_folders = find_folders(f"data/cmip/projections/{model}")
    for experiment in EXPERIMENTS:
        if experiment not in completed_folders:
            cmip6_name = ""
            try:
                for variable in VARIABLES:
                    print(f"Downloading data for model: \033[92m{model}\033[0m experiment: \033[92m{experiment}\033[0m variable: \033[92m{variable}\033[0m")
                    cmip6_name = VARIABLES.get(variable).get("cmip6_name")
            
                    #If the directory does not exist, create it
                    if not os.path.exists(f"data/cmip/projections/{model}/{experiment}"):
                        os.makedirs(f"data/cmip/projections/{model}/{experiment}")

                    file = f"data/cmip/projections/{model}/{experiment}/{variable}.zip"
                    file_nc = f"data/cmip/projections/{model}/{experiment}/{variable}.nc"
                    #If the file does not exist, download it
                    if not os.path.exists(f"{file_nc}"):
                        if(VARIABLES.get(variable).get("daily")):
                            KEEP_TRYING = True
                            while (KEEP_TRYING):
                                try:
                                    CDS.retrieve(
                                        'projections-cmip6',
                                        {
                                            'experiment': experiment,
                                            'model': model,
                                            'variable': cmip6_name,
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
                                    KEEP_TRYING = False
                                except Exception as e:
                                    if "matching"  or "are not in the list" in str(e):
                                        raise ""
                                    else:
                                        KEEP_TRYING = True
                                    
                        else:
                            KEEP_TRYING = True
                            while (KEEP_TRYING):                        
                                try:
                                    CDS.retrieve(
                                    'projections-cmip6',
                                        {
                                            'experiment': experiment,
                                            'model': model,
                                            'variable': cmip6_name,
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
                                    KEEP_TRYING = False
                                except Exception as e:
                                    if "matching" in str(e):
                                        raise ""
                                    else:     
                                        KEEP_TRYING = True
    
                if os.path.exists(os.path.join(f"data/cmip/projections/{model}/{experiment}", "UNCOMPLETED")):
                    os.remove(os.path.join(f"data/cmip/projections/{model}/{experiment}", "UNCOMPLETED"))

                with open(os.path.join(f"data/cmip/projections/{model}/{experiment}", "COMPLETED"), 'w') as fp:
                    pass                       
                        
            except:
                print(f"The experiment \033[91m{experiment}\033[0m of the model \033[91m{model}\033[0m doesn't contain \033[91m{variable}\033[0m. Try again later!!")
            #rmtree(f"data/cmip/projections/{model}/{experiment}")
                with open(os.path.join(f"data/cmip/projections/{model}/{experiment}", "UNCOMPLETED"), 'w') as fp:
                    fp.write(f"Doesn't contain the variable {variable}")
                    
        
        if(download_historical):

            print(f"Downloading historical data for model: \033[92m{model}\033[0m")
            
            if not os.path.exists(f"data/cmip/historical/{model}/"):
                os.makedirs(f"data/cmip/historical/{model}/")

            #Download historical data
            for variable in VARIABLES:
                cmip6_name = VARIABLES.get(variable).get("cmip6_name")

                
                file = f"data/cmip/historical/{model}/{cmip6_name}.zip"
                file_nc = f"data/cmip/historical/{model}/{cmip6_name}.nc"
                
                if not os.path.exists(f"{file_nc}"):
                    if(VARIABLES.get(variable).get("daily")):
                        CDS.retrieve(
                            'projections-cmip6',
                            {
                                'variable': variable,
                                'year': HISTORICAL_YEARS,
                                'area': AREA,
                                'model': model,
                                'experiment': 'historical',
                                'temporal_resolution': 'daily',
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
                            f"{file}")
                    else:
                        CDS.retrieve(
                            'projections-cmip6',
                            {
                                'variable': variable,
                                'year': HISTORICAL_YEARS,
                                'area': AREA,
                                'model': model,
                                'temporal_resolution': 'daily',
                                'experiment': 'historical',
                                'format': 'zip',   
                                'month': [
                                    '01', '02', '03',
                                    '04', '05', '06',
                                    '07', '08', '09',
                                    '10', '11', '12',
                                ]
                            },
                            f"{file}")
                    unzip_file(file)

def diff_month(d1, d2):
    return (d1.year - d2.year) * 12 + d1.month - d2.month


def count_leap_years(start_year, end_year):
    """
    Returns the number of leap years between start_year and end_year inclusive.
    
    Parameters:
    start_year (int): The starting year.
    end_year (int): The ending year.
    
    Returns:
    int: The number of leap years in the range.
    """
    def is_leap_year(year):
        # Determine if a year is a leap year
        if year % 4 == 0:
            if year % 100 == 0:
                if year % 400 == 0:
                    return True
                else:
                    return False
            else:
                return True
        else:
            return False

    leap_years_count = 0

    for year in range(start_year, end_year + 1):
        if is_leap_year(year):
            leap_years_count += 1

    return leap_years_count


#A function to summarize all the spatial data on a single point, also generate a csv file
def summarize_data(model):
   
    completed_folders = find_folders(f"data/cmip/projections/{model}")
    for experiment in EXPERIMENTS:
        if experiment in completed_folders:
            print(f"Summarizing data for model: \033[92m{model}\033[0m experiment: \033[92m{experiment}\033[0m")
            for variable in VARIABLES:
                data_nc = xr.open_dataset(f"data/cmip/projections/{model}/{experiment}/{variable}.nc")
    
                #Assert that the nc file doesn't contain missing values
                assert data_nc[variable].where(data_nc[variable] == data_nc[variable].encoding['missing_value']).count() == 0 or \
                        data_nc[variable].isnull().sum() == 0, f"Missing values in the nc file {variable}.nc"
                
                dataset = pd.DataFrame()
                try:
                    dataset['time'] = pd.to_datetime(data_nc.time)
                except:
                    dataset['time'] = pd.to_datetime(data_nc.indexes["time"].to_datetimeindex())

                #Set the hour to 00:00
                dataset['time'] = dataset['time'].dt.floor('d')
                
                #Set the day to the first day of the month
                if not VARIABLES.get(variable).get("daily"):
                    dataset['time'] = dataset['time'].apply(lambda x: x.replace(day=1))
                
                #Assert that time has the correct size
                days_between = (datetime(int(PROJECTION_YEARS[-1]) + 1,1,1) - datetime(int(PROJECTION_YEARS[0]), 1, 1)).days
                days_between_without_leap_years = days_between - count_leap_years(int(PROJECTION_YEARS[0]), int(PROJECTION_YEARS[-1]))
                months_between = diff_month(datetime(int(PROJECTION_YEARS[-1]) + 1,1,1), datetime(int(PROJECTION_YEARS[0]), 1, 1))
                
                if VARIABLES.get(variable).get("daily"):
                    assert days_between == len(dataset) or days_between_without_leap_years == len(dataset), \
                        f"Time for {variable} has the wrong size: {len(dataset)}, when it should be {days_between} or {days_between_without_leap_years}"
                else:
                    assert months_between == len(dataset),\
                        f"Time for {variable} has the wrong size: {len(months_between)}, when it should be {months_between}"

                if(variable == "tasmax"):
                    dataset[variable] = data_nc[variable].max(dim=["lat","lon"])
                elif(variable == "tasmin"):
                    dataset[variable] = data_nc[variable].min(dim=["lat","lon"])
                else:
                    dataset[variable] = data_nc[variable].mean(dim=["lat","lon"]) 

                dataset.to_csv(f"data/cmip/projections/{model}/{experiment}/{variable}.csv", index=False)   

#A function to expand the variables to a hourly scale using the csv file obtained in summarize_data
def expand_data(model):
    completed_folders = find_folders(f"data/cmip/projections/{model}")
    for experiment in EXPERIMENTS:
        if experiment in completed_folders:
            print(f"Expanding data for model: \033[92m{model}\033[0m experiment: \033[92m{experiment}\033[0m")
            for variable in VARIABLES:
                data = pd.read_csv(f"data/cmip/projections/{model}/{experiment}/{variable}.csv")

                data['time'] = pd.to_datetime(data['time'])
                data = data.set_index('time')

                days_between = (datetime(int(PROJECTION_YEARS[-1]) + 1,1,1) - datetime(int(PROJECTION_YEARS[0]), 1, 1)).days
                days_between_without_leap_years = days_between - count_leap_years(int(PROJECTION_YEARS[0]), int(PROJECTION_YEARS[-1]))

                #If we have monthly data, we need to expand it to a daily scale first
                if(not VARIABLES.get(variable).get("daily")):
                    # Append an extra day to handle the last month edge case
                    last_day = data.index[-1] + pd.Timedelta(days=31)
                    data.loc[last_day] = [1]
                    
                    data = data.resample('D').ffill()
                    
                    # Remove the extra day
                    data = data[data.index < last_day]                   

                    assert days_between == len(data) or days_between_without_leap_years == len(data), \
                        f"Time for {variable} has the wrong size: {len(data)}, when it should be {days_between} or {days_between_without_leap_years}"
                
                ##All the data needs to be expanded to a hourly scale
                
                # Append an extra day to handle the last day edge case
                last_day = data.index[-1] + pd.Timedelta(days=1)
                data.loc[last_day] = [1]
                
                data = data.resample('h').ffill()
                
                # Remove the extra day
                data = data[data.index < last_day]

                #Assert that time has the correct size
                assert days_between * 24 == len(data), f"Time has the wrong size: {len(data)}, when it should be {days_between * 24}"
                
                data.to_csv(f"data/cmip/projections/{model}/{experiment}/{variable}.csv")

# A function to merge all the dataframes
def merge_all_data(model):
    completed_folders = find_folders(f"data/cmip/projections/{model}")
    for experiment in EXPERIMENTS:    
        if experiment in completed_folders:
            print(f"Merging data for model: \033[92m{model}\033[0m experiment: \033[92m{experiment}\033[0m")
            data = pd.DataFrame()
            for variable in VARIABLES:
                if data.empty:
                    data = pd.read_csv(f"data/cmip/projections/{model}/{experiment}/{variable}.csv")
                else:
                    data = data.merge(pd.read_csv(f"data/cmip/projections/{model}/{experiment}/{variable}.csv"), how='inner', on='time')

            data["pr"] = data["pr"]*3600
            data.to_csv(f"data/cmip/projections/{model}/{experiment}/{experiment}.csv", index=False)


def main():
    load_configuration()    
    for model in MODELS:
        download_data(model, download_historical = False)
        summarize_data(model)
        expand_data(model)
        merge_all_data(model)
if __name__ == "__main__":
    main()