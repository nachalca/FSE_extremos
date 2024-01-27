# Stages L2 INFO

We will use this space to communicate about the tasks to be carried out and the progress of the work done during the internship. Please keep this file as clean as possible and keep it up to date.

## List of tasks to be carried out

- [x] Translate everything to English 🏴
- [ ] Familiarize yourself with the netCDF format (https://www.unidata.ucar.edu/software/netcdf/)
- What Python modules exist for processing this data? If you need to run tests, feel free to explore the files in the "datos" folder at the root of the GitHub repository.
- [ ] How to visualize the data? The default solution is Panoply (https://www.giss.nasa.gov/tools/panoply/)
  - Use the software to get acquainted (import a data file, produce some graphical representations)
  - Try and/or propose alternatives (e.g., very nice-looking -> https://github.com/blendernc/blendernc)
- [ ] Explore the [Climate Data Store](https://cds.climate.copernicus.eu/#!/home) (CDS) API

## Décrire l'objectif à long term 

The CDS contains simulated trajectories of different climatological variables (e.g. temperature, precipitation) obtainted by the research consontium CMIP6. The simulation is done over a spatial grid covering the whole planet, and a time grid that may be daily or monthly (depending on the climatological variable). Each research center produce its owns simulations. Different conditions of particles concentration are assumed:
- historical: no more climate change than the already observed
- SSP2
- ...
- SSP8

For each relevant climate variable, we need a data base in a tabular format:

timestamp  | exp1 | exp2  | ... | expM
---------- | ---- | ----- | --- | ---
1-jan-2015 |  24.3 | 24.1 | ... | 23.9
2-jan-2015 |  23.4 | 21.7 | ... | 22.3
    ...    |  ...  | ...  | ... | ...
31-dec-2099|  29.3 | 30.1 | ... | 28.4
---------- | ----  | ---- | --- | ---

