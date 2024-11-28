from CNNDownscaler import CNNDownscaler
from NaiveDownscaler import NaiveDownscaler
from XgboostDownscaler import XgboostDownscaler

cnn = CNNDownscaler()
parent = "/home/tancre/dev/UTE/FSE_extremos"
p = cnn.explain(data = f"{parent}/data/testing/clt.csv", model = f"{parent}/models/clt/cnn.pkl")

# nv = NaiveDownscaler()
# parent = "/home/tancre/dev/UTE/FSE_extremos"
# p = nv.explain(data = f"{parent}/data/testing/clt.csv", model = f"{parent}/models/clt/naive.pkl")

# xgb = XgboostDownscaler()
# parent = "/home/tancre/dev/UTE/FSE_extremos"
# p = xgb.explain(data = f"{parent}/data/testing/rsds.csv", model = f"{parent}/models/rsds/xgboost.pkl")

print(p)
