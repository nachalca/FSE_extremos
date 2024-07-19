import pandas as pd
import cdsapi
import zipfile
import re
import os
from os.path import exists

HISTORICAL_YEARS = range(2000,2015)
PROJECTION_YEARS = range(2015,2101)
AREA = [-30, -59, -35, -53] #If we want to do the Salto Grande area we need to set the invervals to  [-26,-60,-36,-48]
CDS = cdsapi.Client()
ROOT_FOLDER = os.getcwd()
EXPERIMENTS = ["ssp4_3_4",  "ssp2_4_5", "ssp3_7_0", "ssp5_8_5"]
MODELS = ["ec_earth3", "","mri_esm2_0", "ukesm1_0_ll"]
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
    "toa_incident_solar_radiation": { #Check 
        "cmip6_name":"rsdt",
        "daily": False,
    },
    "surface_solar_radiation_downwards": {#Check
        "cmip6_name":"rsds",
        "daily": False,
    },
}




# def extract_criteria():
#   file = pd.read_csv("CMIP6-table-for-Amine.csv", sep=";")
#   c = cdsapi.Client()
#   for i in range(len(file["Time resolution"])):
# #    newFile = file["Time resolution"][i]+file["Experience"][i]+file["Variable"][i]+file["Model"][i]+".zip"
#     tres = file["Time resolution"][i]
#     exp = file["Experience"][i]
#     var = file["Variable"][i]
#     mod = file["Model"][i]
#     newFile = tres+exp+var+mod+".zip"
#     if not exists(newFile):
#       # the year range differ for historical;
#       if exp == "historical":
#         try:
#           c.retrieve("projections-cmip6", 
#                     {"temporal_resolution": tres,
#                     "experiment": exp,
#                     "variable": var,
#                     "model": mod,
#                     "year": [str(year) for year in range(2000, 2015)],
#                     "month": [str(month).zfill(2) for month in range(1, 13)],
#                     "day": [str(day).zfill(2) for day in range(1, 32)],
#                     "area": [-30, -59, -35, -53],
#                     "format": "zip"
#                     }, newFile)
#           with zipfile.ZipFile(newFile, "r") as zip_f:
#             for f in zip_f.namelist():
#               m = re.search(re.compile(".*\.nc$"), f)
#               if m:
#                 zip_f.extract(f)
#         except:
#           print(newFile + " cannot be found.")
#       else:
#         try:
#           c.retrieve("projections-cmip6", 
#                     {"temporal_resolution": tres,
#                     "experiment": exp,
#                     "variable": var,
#                     "model": mod,
#                     "year": [str(year) for year in range(2015, 2051)],
#                     "month": [str(month).zfill(2) for month in range(1, 13)],
#                     "day": [str(day).zfill(2) for day in range(1, 32)],
#                     "area": [-30, -59, -35, -53],
#                     "format": "zip"
#                     }, newFile)
#           with zipfile.ZipFile(newFile, "r") as zip_f:
#             for f in zip_f.namelist():
#               m = re.search(re.compile(".*\.nc$"), f)
#               if m:
#                 zip_f.extract(f)
#         except:
#           print(newFile + " cannot be found.")

# extract_criteria()