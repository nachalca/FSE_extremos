library(RNetCDF)

f <- "datos/pr_day_CESM2_ssp245_r4i1p1f1_gn_20150101-20501231_v20200528.nc"
nc <- open.nc(f)

# esto da info sobre el archivo (4 dimensiones, 7 variables)
file.inq.nc(nc)

att.get.nc(nc)
dim.inq.nc(nc, )
var.get.nc(nc)
