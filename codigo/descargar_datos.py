# File: descargar_datos.py
# Descripton: Script para descargar el conjunto de datos relevantes al proyecto.
#             La API devuelve archivos compridos que son descomprimidos generando
#             en la carpeta ../datos un archivo por cada variable X experimento X modelo.
#             Las descargas del experimento 'historical' esta separada ya que las fechas
#             de disponibilidad van hasta 2014 (los otros experimentos son proyectivos hasta 2100).

import cdsapi
import zipfile
from os.path import exists

# Todos los experimentos de todos los modelos salvo 'historical'
experimentos = ['ssp5_8_5']  # SSP245, SSP370 y SSP585 (como en el PNC info ejec)
variables_diarias = ['precipitation', 
                     'near_surface_wind_speed', 
                     'near_surface_air_temperature']
variables_mensuales = ['precipitation', 
                       'near_surface_wind_speed', 
                       'near_surface_air_temperature']
modelos = ["ec_earth3_cc",     # Europe
           "ec_earth3_veg_lr", # Europe
           "cesm2",            # USA
           "cesm2_waccm",      # USA
           "cnrm_cm6_1_hr",    # France
           "mri_esm2_0"]       # Japan  
#           "ukesm1_0_ll"]      # UK
#"cnrm_cm6_1_hr" <- utilizado para tests 


c = cdsapi.Client()

# for var in variables_diarias:
#   for exp in experimentos:
#     for mod in modelos:
#       archivo = exp+var+mod+'.zip'
#       if !exists(archivo):
#         c.retrieve(
#         'projections-cmip6',
#          {
#           'temporal_resolution': 'daily',
#           'experiment': exp,
#           'variable': var,
#           'model': mod,
#           'year': '2023', # 'year': list(range(2000, 2049 + 1)),  
#           'month': list(range(1, 12 + 1)),
#           'day': [str(item).zfill(2) for item in range(1, 31 + 1)], # day tiene que ser string a 2 caracteres
#           'area': [-30, -60, -35, -53], # cordenadas lat lon delimitando Uy mediante una caja
#           'format': 'zip', 
#          }
#         , archivo)
#         with zipfile.ZipFile(archivo, 'r') as zip_ref:
#           zip_ref.extractall("../datos")

# Experimentos 'historical' en todos los modelos


experimentos = ['historical'] 
for var in variables_diarias:
  for exp in experimentos: 
    for mod in modelos:
      archivo = exp+var+mod+'.zip'
      if not exists(archivo):
        c.retrieve(
        'projections-cmip6',
        {
        'temporal_resolution': 'daily',
        'experiment': exp,
        'variable': var,
        'model': mod,
        'year': [str(anho) for anho in range(2000, 2015)],
        'month': [str(mes).zfill(2) for mes in range(1, 12 + 1)],
        'day':   [str(dia).zfill(2) for dia in range(1, 31 + 1)], # day tiene que ser string a 2 caracteres
        'area':  [-30, -60, -35, -53], # cordenadas lat lon delimitando Uy mediante una caja
        'format': 'zip', 
        }
        ,
        archivo)
        with zipfile.ZipFile(archivo, 'r') as zip_ref:
          zip_ref.extractall("../datos")
