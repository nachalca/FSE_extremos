library(RNetCDF)
library(lubridate)
library(ggplot2)
library(here)

f <- "datos/pr_day_CESM2_historical_r1i1p1f1_gn_20000101-20141231_v20190401.nc"
f <- "datos/tas_day_EC-Earth3-CC_historical_r1i1p1f1_gr_20000101-20141231_v20210113.nc"

nc <- open.nc(f)

# esto da info sobre el archivo (4 dimensiones, 7 variables)
file.inq.nc(nc)
print.nc(nc)

var.get.nc(nc, c('lat') )
var.get.nc(nc, c('lon') )  - 360

att.get.nc(nc, 'time', 'units')
att.get.nc(nc, 'lat', 'units')
# ------------------
# Obtener serie promedio en todos los sitios para cada dia

dd <- read.nc(nc)
att.get.nc(nc, 'tas', 'units')

my_origin <- 
  att.get.nc(nc, 'time', 'units') |> 
  gsub('days since ', '', x=_) |> 
  as_datetime()

dt <- data.frame( 
   pr = apply(dd$pr, 3, mean), 
   time = my_origin +  days(dd$time)
 )

#pr = ts( apply(dd$pr, 3, mean), frequency = 365, start = c(2000,  1) )
#plot(pr)
t2m_simu = ts(apply(dd$tas, 3, mean) - 273.15, 
              frequency = 365, start = c(2000,  1) )
plot(t2m_simu)


## Datos reanalisis

fr <- "Archivos_reanalisisERA5_realesINUMET/Reanalisis/Datos_t2m_horario_2000a2010_uy.nc" 

ncr <- open.nc(fr)
print.nc(ncr)

att.get.nc(ncr, 't2m', 'units')

sc  <- att.get.nc(ncr, 't2m', 'scale_factor')
off <- att.get.nc(ncr, 't2m', 'add_offset')


my_originr <- 
  att.get.nc(ncr, 'time', 'units') |> 
  gsub('hours since ', '', x=_) |> 
  as_datetime()

ddr <- read.nc(ncr)

#my_origin +  hours(ddr$time[1])

ddrt <- data.frame( 
   t2m = (apply(ddr$t2m, 3, mean)*sc + off) -273.15, 
   time = my_originr +  hours(ddr$time)
)

plot(ddrt$time, ddrt$t2m, type='l')

# -------------------------------------------
# Relacionar datos horarios con datos diarios







