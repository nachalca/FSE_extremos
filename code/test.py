from CNNDownscaler import CNNDownscaler
from NaiveDownscaler import NaiveDownscaler

cnn = CNNDownscaler()
parent = "/home/brunotancredi00/FSE_extremos"
p = cnn.explain(data = f"{parent}/data/testing/clt.csv", model = f"{parent}/models/clt/cnn.pkl")

# nv = NaiveDownscaler()
# parent = "/home/brunotancredi00/FSE_extremos"
# p = nv.explain(data = f"{parent}/data/testing/clt.csv", model = f"{parent}/models/clt/naive.pkl")
print(p)