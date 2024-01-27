CDFt.Gaussian <- function(ObsRp, DataGp, DataGf, npas = 100, dev = 2){

  mO = mean(ObsRp)
  mGp= mean(DataGp)
  DataGp2 = DataGp + (mO-mGp)
  DataGf2 = DataGf + (mO-mGp)

  mGp2 = mO
  mGf2 = mean(DataGf2)



  ectO = sqrt(var(ObsRp))
  ectGp2 = sqrt(var(DataGp2))
  ectGf2 = sqrt(var(DataGf2))
  

  FRp = cdfGaussian(mO,ectO)     # FRp=ecdf(ObsRp)
  FGp = cdfGaussian(mGp2,ectGp2) # FGp=ecdf(DataGp2)
  FGf = cdfGaussian(mGf2,ectGf2) # FGf=ecdf(DataGf2)

  a=abs(mean(DataGf)-mean(DataGp))
  m=min(ObsRp, DataGp, DataGf)-dev*a
  M=max(ObsRp, DataGp, DataGf)+dev*a


  x=seq(m,M,,npas)


  FGF=FGf(x)
  FGP=FGp(x)
  FRP=FRp(x)


  FGPm1 = quantileGaussian(mGp2,ectGp2)
  FGPm1.FGF=FGPm1(FGF)
  # FGPm1.FGF=quantile(DataGp2,probs=FGF)


  FRF=FRp(FGPm1.FGF)





######################################################################################
### Quantile-matching based on the new large-scale CDF and downscaled local-scale CDF.



  qntl = FGf(DataGf2)
  xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')

  ### xx = FRfm1(FRp(FGPm1(DataGf2))) ??????
  ### No, cannot have FRfm1


#######################################################################################

  mGf= mean(DataGf)
  ectGp = sqrt(var(DataGp))
  ectGf = sqrt(var(DataGf))

  FGp = cdfGaussian(mGp,ectGp) # FGp=ecdf(DataGp)
  FGf = cdfGaussian(mGf,ectGf) # FGf=ecdf(DataGf)
  
  
  FGP=FGp(x)
  FGF=FGf(x)

  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=xx$y))

}


