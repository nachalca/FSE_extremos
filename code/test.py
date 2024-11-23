from XgboostCustomDownscaler import XgboostCustomDownscaler


xgb = XgboostCustomDownscaler()
p = xgb.predict(data = "data/to_be_downscaled/pr/cesm2-ssp3_7_0.csv", model = "/home/tancre/dev/UTE/FSE_extremos/models/pr/xgboost_custom.pkl")
print(p)