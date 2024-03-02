# Stages L2 INFO

We will use this space to communicate about the tasks to be carried out and the progress of the work done during the internship. Please keep this file as clean as possible and keep it up to date.

## List of tasks to be carried out

- [x] Translate everything to English 🏴
- [X] Familiarize yourself with the netCDF format (https://www.unidata.ucar.edu/software/netcdf/)
- What Python modules exist for processing this data? If you need to run tests, feel free to explore the files in the "datos" folder at the root of the GitHub repository.
- [ ] How to visualize the data? The default solution is Panoply (https://www.giss.nasa.gov/tools/panoply/)
  - Use the software to get acquainted (import a data file, produce some graphical representations)
  - Try and/or propose alternatives (e.g., very nice-looking -> https://github.com/blendernc/blendernc)
- [X] Explore the [Climate Data Store](https://cds.climate.copernicus.eu/#!/home) (CDS) API
- [ ] Replicate the downloading of two files from the CDS
- [X] Fusion the two files into on single tabular dataset (as below)
- [ ] Produce a minimal dataset with the target format (this will help Bruno in the downscaling phase)

Current tasks !!
- [ ] Copernicus => CMIP6 climate projections in order to retrieve datasets
- [ ] Build an excel table with the following columns for each dataset retrived from Copernicus : time resolution, variable, experience, model, availability of the model based on previous columns
- [ ] Following columns are needed in the dataframes' table :
\*toy (time of the year) => possible values are expected to be between 0 and 1 ; possible implementation for day i = i-0.5/365
\*dow (day of the week)
\*trend => first row = 1, 2nd = 2, etc.

Side task
- [ ] Visual tool. We need a graphical tool to represent the weather maps. From matrices (like the ones in the nc files) to actual maps. Maybe a different representation by kind of weather variable (e.g. wind should be 2d). Is it possible to construct 3d representations? (Look at raytracing kink of staff)  
- [ ] Slides. Make a short deck of not more than 10 slides presenting the project (context, research question, team, material and methods)

## Description of the long-term objective 

The CDS contains simulated trajectories of different climatological variables (e.g. temperature, precipitation) obtainted by the research consontium CMIP6. The simulation is done over a spatial grid covering the whole planet, and a time grid that may be daily or monthly (depending on the climatological variable). Each research center produce its owns simulations. Different conditions of particles concentration are assumed:
- historical: no more climate change than the already observed
- SSP2
- ...
- SSP8

For each relevant climate variable, we need a data base in a tabular format:

timestamp  | trend |  toy    | exp1 | exp2 | ... | expM
---------- | ----- | ------- | ---- |----- | --- | ---
1-jan-2015 |  1    | 1/365   | 24.3 | 24.1 | ... | 23.9
2-jan-2015 |  2    | 2/365   | 23.4 | 21.7 | ... | 22.3
.......... |  .... | ...     | ...  | ...  | ... | ...  
31-dec-2099|  T    | 365/365 | 29.3 | 30.1 | ... | 28.4
---------- | ----- | ------- | ---- | ---- | --- | ---


