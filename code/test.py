from CNNDownscaler import CNNDownscaler


cnn = CNNDownscaler()
p = cnn.predict(data = "data/to_be_downscaled/clt/cesm2_ssp2_4_5.csv", model = "models/clt/cnn.pkl")
print(p)