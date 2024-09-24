library(epwshiftr)

# set directory to store files
options(epwshiftr.dir = tempdir())
options(epwshiftr.verbose = TRUE)

# create a CMIP6 output file index
idx <- init_cmip6_index(
  # only consider ScenarioMIP activity
  activity = "ScenarioMIP",

  # specify dry-bulb temperature and relative humidity
  variable =c("hurs", "pr"),  #NULL,

  # specify report frequent
  frequency = "day",

  # specify experiment name
  experiment = c("ssp585"),

  # specify GCM name
  source = "AWI-CM-1-1-MR", # Germany

  # specify variant,
  variant = "r1i1p1f1",

  # specify years of interest
  years = c(2050, 2060),

  # save to data dictionary
  save = TRUE
)
#> Querying CMIP6 Dataset Information
#> Querying CMIP6 File Information [Attempt 1]
#> Checking if data is complete
#> Data file index saved to '/tmp/RtmpDtbJVc/cmip6_index.csv'

# the index has been automatically saved into directory specified using
# `epwshiftr.dir` option and can be reloaded
#idx <- load_cmip6_index()

str(head(idx))

# get CMIP6 data nodes
#nodes <- get_data_node()

#for(nro in 1:nrow(idx)) {
for(nro in 4:nrow(idx)) {
  system2("wget", idx$file_url[nro], stdout = FALSE)
}



# Summary downloaded file by GCM and variable, use the latest downloaded file if
# multiple matches are detected and save matched information into the index file
sm <- summary_database(".", by = c("source", "variable"), mult = "latest", update = TRUE)
#> 24 NetCDF files found.
#> Data file index updated and saved to '/tmp/RtmpDtbJVc/cmip6_index.csv'

knitr::kable(sm)
