# Fichero: downscaling_eval_acp.R
# Descripcion : Analisis de las metricas de 3 variables (tas, clt, sfcWind) para todos los 
# escenarios con todos los predictores
library(tidyverse)
library(FactoMineR)
glimpse(d_sfcWind)

d_tas <- read.csv("reports/ds_acp/tas.csv") |> 
  mutate(diff_of_means= as.numeric(gsub('%', '', diff_of_means) ) )

rownames(d_tas) <- paste0("tas_", rownames(d_tas))

d_pr <- read.csv('reports/ds_acp/pr.csv') |> 
  mutate(diff_of_means= as.numeric(gsub('%', '', diff_of_means) ) )
rownames(d_pr) <- paste0("pr_", rownames(d_pr))

d_sfcWind <- read.csv("reports/ds_acp/sfcWind.csv") |> 
  mutate(diff_of_means= as.numeric(gsub('%', '', diff_of_means) ) )
rownames(d_sfcWind) <- paste0("sfcWind_", rownames(d_sfcWind))


# clt and rsds are monthly variables #
#d_clt <- read.table("~/Documents/clt_metrics.txt", header = TRUE, row.names = 1)
#rownames(d_clt) <- paste0("clt_", rownames(d_clt))
#d_rsds <- read.table("~/Documents/rsds_metrics.txt", header = TRUE, row.names = 1)
#rownames(d_rsds) <- paste0("rsds_", rownames(d_rsds))


d <- list(tas=d_tas, pr=d_pr, wind=d_sfcWind) |> 
  bind_rows(.id="variable") |> 
  separate(X, into=c('predictor', 'model', 'sce'), sep= '\\.', remove=FALSE  )
rownames(d) <- NULL

#d$var <- strsplit(rownames(d), "_") |> lapply('[', 1) |> unlist()
#centro <- strsplit(rownames(d), "\\.") |> lapply('[', 2) |> unlist() 
# d$expe <- 
#   strsplit(rownames(d), "\\.") |> 
#   lapply(function(v) paste(v[-1], collapse = ".")) |>
#   unlist()
# d$predictor <- strsplit(rownames(d), "\\.") |> 
#   lapply('[', 1) |> 
#   unlist() |> 
#   strsplit("_") |> 
#   lapply('[', 2) |> 
#   unlist()

#PCA(d, quali.sup = 8:11)
#install.packages('Factoshiny')

library(Factoshiny)
PCAshiny(d)





