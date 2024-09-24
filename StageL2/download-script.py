import pandas as pd
import cdsapi
import zipfile
import re
import os
from os.path import exists

def extract_criteria():
  file = pd.read_csv("CMIP6-table-for-Amine.csv", sep=";")
  c = cdsapi.Client()
  for i in range(len(file["Time resolution"])):
#    newFile = file["Time resolution"][i]+file["Experience"][i]+file["Variable"][i]+file["Model"][i]+".zip"
    tres = file["Time resolution"][i]
    exp = file["Experience"][i]
    var = file["Variable"][i]
    mod = file["Model"][i]
    newFile = tres+exp+var+mod+".zip"
    if not exists(newFile):
      # the year range differ for historical;
      if exp == "historical":
        try:
          c.retrieve("projections-cmip6", 
                    {"temporal_resolution": tres,
                    "experiment": exp,
                    "variable": var,
                    "model": mod,
                    "year": [str(year) for year in range(2000, 2015)],
                    "month": [str(month).zfill(2) for month in range(1, 13)],
                    "day": [str(day).zfill(2) for day in range(1, 32)],
                    "area": [-30, -59, -35, -53],
                    "format": "zip"
                    }, newFile)
          with zipfile.ZipFile(newFile, "r") as zip_f:
            for f in zip_f.namelist():
              m = re.search(re.compile(".*\.nc$"), f)
              if m:
                zip_f.extract(f)
        except:
          print(newFile + " cannot be found.")
      else:
        try:
          c.retrieve("projections-cmip6", 
                    {"temporal_resolution": tres,
                    "experiment": exp,
                    "variable": var,
                    "model": mod,
                    "year": [str(year) for year in range(2015, 2051)],
                    "month": [str(month).zfill(2) for month in range(1, 13)],
                    "day": [str(day).zfill(2) for day in range(1, 32)],
                    "area": [-30, -59, -35, -53],
                    "format": "zip"
                    }, newFile)
          with zipfile.ZipFile(newFile, "r") as zip_f:
            for f in zip_f.namelist():
              m = re.search(re.compile(".*\.nc$"), f)
              if m:
                zip_f.extract(f)
        except:
          print(newFile + " cannot be found.")

extract_criteria()
