from XgboostDownscaler import XgboostDownscaler


xgb = XgboostDownscaler()
p = xgb.predict(data = "data/to_be_downscaled/clt/cesm2_ssp2_4_5.csv", model = "models/clt/xgboost.pkl")
print(p)