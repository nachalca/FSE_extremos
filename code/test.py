from CNNDownscaler import CNNDownscaler


cnn = CNNDownscaler()
parent = "/home/tancre/dev/UTE/FSE_extremos"
p = cnn.predict(data = f"{parent}/data/to_be_downscaled/clt/cesm2-ssp2_4_5.csv", model = f"{parent}/models/clt/cnn.pkl")
print(p)