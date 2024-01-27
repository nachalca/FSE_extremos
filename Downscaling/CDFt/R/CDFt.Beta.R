CDFt.Beta <- function(ObsRp, DataGp, DataGf, npas = 100,
                      sh1.ini = 0.2, sh2.ini = 0.2){


est.beta=list(mle(minuslog=MinusLogLikBeta, start=list(sh1=sh1.ini,sh2=sh2.ini),method="L-BFGS-B",fixed=list(X=ObsRp),lower=c(1e-6,1e-6),upper=c(25,25)))
  sh1.O = as.numeric(coef(est.beta[[1]])[(length(ObsRp)+1)])
  sh2.O = as.numeric(coef(est.beta[[1]])[(length(ObsRp)+2)])
  #sh1.O; sh2.O

est.beta=list(mle(minuslog=MinusLogLikBeta, start=list(sh1=sh1.ini,sh2=sh2.ini),method="L-BFGS-B",fixed=list(X=DataGp),lower=c(1e-6,1e-6),upper=c(25,25)))
  sh1.Gp = as.numeric(coef(est.beta[[1]])[(length(DataGp)+1)])
  sh2.Gp = as.numeric(coef(est.beta[[1]])[(length(DataGp)+2)])
  #sh1.Gp; sh2.Gp

est.beta=list(mle(minuslog=MinusLogLikBeta, start=list(sh1=sh1.ini,sh2=sh2.ini),method="L-BFGS-B",fixed=list(X=DataGf),lower=c(1e-6,1e-6),upper=c(25,25)))
  sh1.Gf = as.numeric(coef(est.beta[[1]])[(length(DataGf)+1)])
  sh2.Gf = as.numeric(coef(est.beta[[1]])[(length(DataGf)+2)])
  #sh1.Gf; sh2.Gf


  FRp = cdfBeta(sh1.O,sh2.O)     # FRp=ecdf(ObsRp)
  FGp = cdfBeta(sh1.Gp,sh2.Gp) # FGp=ecdf(DataGp2)
  FGf = cdfBeta(sh1.Gf,sh2.Gf) # FGf=ecdf(DataGf2)

            #a=abs(mean(DataGf)-mean(DataGp))
  m = 0     #min(ObsRp, DataGp, DataGf)-dev*a
  M = 1     #max(ObsRp, DataGp, DataGf)+dev*a


  x=seq(m,M,,npas)


  FGF=FGf(x)
  FGP=FGp(x)
  FRP=FRp(x)


  FGPm1 = quantileBeta(sh1.Gp,sh2.Gp)
  FGPm1.FGF=FGPm1(FGF)

  FRF=FRp(FGPm1.FGF)


######################################################################################
### Quantile-matching based on the new large-scale CDF and downscaled local-scale CDF.



  qntl = FGf(DataGf)
  xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')

  ### xx = FRfm1(FRp(FGPm1(DataGf2))) ??????
  ### No, cannot have FRfm1


#######################################################################################

  FGP=FGp(x)
  FGF=FGf(x)

  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=xx$y))

}

