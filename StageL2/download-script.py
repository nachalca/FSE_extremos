#!/usr/bin/env python
# coding: utf-8

# In[59]:


import pandas as pd
import cdsapi
import zipfile
import re
import os
from os.path import exists


#file = pd.read_csv("CMIP6-table-for-Amine.csv", sep=";")
#file.head()


# In[77]:


def extract_criteria():
    file = pd.read_csv("CMIP6-table-for-Amine.csv", sep=";")
    c = cdsapi.Client()
    for tres in file["Time resolution"]:
        print(tres)
        for exp in file["Experience"]:
            for var in file["Variable"]:
                for mod in file["Model"]:
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
                                    for file in zip_f.namelist():
                                        m = re.search(re.compile(".*\.nc$"), file)
                                        if m:
                                            zip_f.extract(file)
                            except:
                                print(newfile + " cannot be found.")
                        else:
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
                                for file in zip_f.namelist():
                                    m = re.search(re.compile(".*\.nc$"), file)
                                    if m:
                                        zip_f.extract(file)


# In[78]:


# c = cdsapi.Client()
# newFile = "example.zip"
# c.retrieve("projections-cmip6", 
#     {"temporal_resolution": "monthly",
#      "experiment": "historical",
#      "variable": "surface_downwelling_shortwave_radiation",
#      "model": "cesm2",
#      "year": [str(year) for year in range(2000, 2015)],
#      "month": [str(month).zfill(2) for month in range(1, 13)],
#      "day": [str(day).zfill(2) for day in range(1, 32)],
#      "area": [-30, -59, -35, -53],
#      "format": "zip"
#      }, newFile)
# with zipfile.ZipFile(newFile, "r") as zip_f:
#     for file in zip_f.namelist():
#         # another way to find the .nc file;
#         # if os.path.extension("nc"):
#         m = re.search(re.compile(".*\.nc$"), file)
#         if m:
#             zip_f.extract(file)


# In[ ]:




extract_criteria()
