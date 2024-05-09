library(loadeR)
library(transformeR)
library(visualizeR)
library(downscaleR)
library(climate4R.value)
library(climate4R.UDG)
library(loadeR.2nc)

reanalysis <- loadGridData("../Archivos_reanalisisERA5_realesINUMET/Reanalisis/Datos_t2m_horario_2000a2010_uy.nc",
                  var="t2m")

cmip_6 <- loadGridData("../data/tas_day_CESM2-WACCM_historical_r1i1p1f1_gn_20000101-20141231_v20190227.nc",
                       var="tas") |> interpGrid(getGrid(reanalysis))

grid2nc(cmip_6, "../data/tas_day_CESM2-WACCM_historical_r1i1p1f1_gn_20000101-20141231_v20190227_DOWNSCALED.nc")
