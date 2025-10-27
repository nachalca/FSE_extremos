# Generate ouptut for model-evaluation reports:

# R packages
library(here)
library(tidyverse)
library(gt)
library(plotly)
library(yaml)
library(extremogram)

# custom functions
source(here('code/metrics.R'))
source(here('code/utils.R'))
conf <- yaml.load_file(here("code/conf.yml"))

# variables: "sfcWind" "tas" "pr" "clt" "rsds"
# output: 'metrics', 'qqplot', 'maximum', 'hourly_dist',
#         'amplitude', 'acf', 'extremogram'

mdeval_report_out(variable = 'tas', output = 'metrics')
mdeval_report_out(variable = 'tas', output = 'extremogram')


mdeval_report_out(variable = 'clt', output = 'metrics')
