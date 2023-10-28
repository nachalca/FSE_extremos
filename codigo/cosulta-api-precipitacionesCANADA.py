import cdsapi

experimentos =['historical', 'ssp5_8_5']
variables = ['precipitation'] #, 'near_surface_wind_speed', 'near_surface_air_temperature']
modelos = ['ipsl-cm6a-lr']

c = cdsapi.Client()

for var in variables:
  for exp in experimentos:
    for mod in modelos:
      archivo = exp+var+mod+'.zip'
      c.retrieve(
      'projections-cmip6',
    {
     'temporal_resolution': 'daily',
     'experiment': exp,
     'variable': var,
     'model': mod,
     'year': '2023', 
     # 'year': list(range(2000, 2049 + 1)),  
     'month': list(range(1, 12 + 1)),
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
            -30, -60, -35,
            -53,
        ],
        'format': 'zip',
    }
    ,
    archivo)




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





        # 'month': [
        #     '01', '02', '03',
        #     '04', '05', '06',
        #     '07', '08', '09',
        #     '10', '11', '12',
        # ],

