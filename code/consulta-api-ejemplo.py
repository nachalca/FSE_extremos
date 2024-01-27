# File: consulta-api-ejemplo.py
# Description: Script de ejemplo para descargar datos CMIP6. 
#              Atencion, hay que crear antes el archivo ~/.cdsapirc
# url: https://cds.climate.copernicus.eu/api/v2
# key: 239751:bf8a3744-3003-4667-a0c0-b368cc759a51
# (clave de Nacho)

# consulta para descargar: precipitacion, diaria, SP5-8.5, AWI-CM11 (germany), 
# del 2050-2060, jan-dec, 1-31
# suregion: north, west, south, east (-30, -58, -35, -52)
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'projections-cmip6',
    {
        'temporal_resolution': 'daily',
        'experiment': 'ssp5_8_5',
        'variable': 'precipitation',
        'model': 'awi_cm_1_1_mr',
        'year': [
            '2050', '2051', '2052',
            '2053', '2054', '2055',
            '2056', '2057', '2058',
            '2059', '2060',
        ],
        'month': [
            '01', '02', '03',
            '04', '05', '06',
            '07', '08', '09',
            '10', '11', '12',
        ],
        'day': [
            '01', '02', '03',
            '04', '05', '06',
            '07', '08', '09',
            '10', '11', '12',
            '13', '14', '15',
            '16', '17', '18',
            '19', '20', '21',
            '22', '23', '24',
            '25', '26', '27',
            '28', '29', '30',
            '31',
        ],
        'area': [
            -30, -58, -35,
            -52,
        ],
        'format': 'zip',
    },
    'download.zip')



# SINGLE DOWNLOAD

# c.retrieve(
#     'projections-cmip6',
#     {
#      'temporal_resolution': 'daily',
#      'experiment': 'ssp5_8_5',
#      'variable': 'precipitation',
#      'model': 'canesm5',
#      'year': '2023', 
#      # 'year': list(range(2000, 2049 + 1)),  
#      'month': list(range(1, 12 + 1)),
#         'day': [
#             '01', '02', '03',
#             '04', '05', '06',
#             '07', '08', '09',
#             '10', '11', '12',
#             '13', '14', '15',
#             '16', '17', '18',
#             '19', '20', '21',
#             '22', '23', '24',
#             '25', '26', '27',
#             '28', '29', '30',
#             '31',
#         ],
#         'area': [
#             -30, -60, -35,
#             -53,
#         ],
#         'format': 'zip',
#     }
#     ,
#     'download.zip')
