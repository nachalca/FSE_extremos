library(rmarkdown)
library(here)

# variables <- c('clt', 'pr', 'rsds', 'sfcWind', 'tas')
variables <- c( 'pr', 'sfcWind', 'tas')

lapply(variables, function(x){
  rmarkdown::render(input="code/model_evaluation_reports_generator/model_evaluation_reduced.Rmd", 
                    output_file = here( paste0("reports/model_evaluation/",x, "_reduced.html")),
                    output_format = "html_document",
                    params = list(variable=x),
                    clean = TRUE) # removes log files
})
