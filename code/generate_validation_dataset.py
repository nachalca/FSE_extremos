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
        "dataset_name": "mx2t", 
        "cmip6_name":"tasmax",
        "daily": True,
    },
    "tasmin": {
        "daily": True,
   },
    "psl": {
        "cmip6_name":"psl",
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

#A function to find the folders that are completed
def find_folders(path):
    folders = []
    for folder in os.listdir(path):
        if os.path.exists(os.path.join(path, folder, "COMPLETED")):
            folders.append(folder)
    return folders

def upscale(data, variable):
    if VARIABLES.get(variable).get("daily"):
        data["time"] = pd.to_datetime(data["time"])
        data = data.set_index("time")
        if variable == "tasmax":
            data = data.resample("D").max()
        elif variable == "tasmin":
            data = data.resample("D").min()
        else:
            data = data.resample("D").mean()
        data = data.reset_index()

    else:
        data["time"] = pd.to_datetime(data["time"])
        data = data.set_index("time")
        data = data.resample("M").mean()
        data = data.reset_index()

def generate_validation_dataset(variable):
    data = pd.read_csv(f"data/reanalysis/reanalysis.csv")
    data = data[["time", variable]]
    data = data[data["time"] >= "2015-01-01"]
    data = data.rename(columns={variable: "reanalysis"})
    upscale(data, variable)
    MODELS = [
                "ec_earth3", 
                "ec_earth3_veg_lr", 
                "cesm2",
                "cesm2_waccm",
                "cnrm_cm6_1",
                "mri_esm2_0", 
                "ukesm1_0_ll"
            ]
    EXPERIMENTS = ["ssp2_4_5","ssp4_3_4", "ssp3_7_0", "ssp5_8_5"]
    for model in MODELS:
        completed_folders = find_folders(f"data/cmip/projections/{model}")
        for experiment in EXPERIMENTS:
            if experiment in completed_folders:
                model_data = pd.read_csv(f"data/cmip/projections/{model}/{experiment}/{experiment}.csv")
                model_data = model_data[["time", variable]]
                model_data = model_data.rename(columns={variable: f"{model}_{experiment}"})
                upscale(model_data, variable)
                data = pd.merge(data, model_data, on="time", how="left")


    #If the folder validation does not exist, create it
    if not os.path.exists("data/validation"):
        os.makedirs("data/validation")

    data.to_csv(f"data/validation/{variable}.csv", index=False)

for variable in VARIABLES:
    print(f"Generating {variable} validation dataset")
    generate_validation_dataset(variable)
    print(f"Validation dataset for {variable} generated\n")