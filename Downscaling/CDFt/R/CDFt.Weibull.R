CDFt.Weibull <- function(ObsRp, DataGp, DataGf, npas = 100, dev = 2,
                ini.sh.O = 1, ini.sc.O = 1,
                ini.sh.Gp = 1, ini.sc.Gp = 1,
                ini.sh.Gf = 1, ini.sc.Gf = 1,
                ini.sh.GpC = 1, ini.sc.GpC = 1,
                ini.sh.GfC = 1, ini.sc.GfC = 1){

#ObsRp = WSS_OBS_Calib[,st]; DataGp=WSS.Calib[,st]; DataGf = WSS.Proj[,st]

  if(min(ObsRp)<=0){
    L0 = length( which(ObsRp<=0) )
    cat(L0," values are <=0 in ObsRp => put to 1e-6\n")
    ObsRp[which(ObsRp<=0)] = 1e-6
  }

  if(min(DataGp)<=0){
    L0 = length( which(DataGp<=0) )
    cat(L0," values are <=0 in DataGp => put to 1e-6\n")
    DataGp[which(DataGp<=0)] = 1e-6
  }

  if(min(DataGf)<=0){
    L0 = length( which(DataGf<=0) )
    cat(L0," values are <=0 in DataGf => put to 1e-6\n")
    DataGf[which(DataGf<=0)] = 1e-6
  }


  mO = min(ObsRp)
  mGp= min(DataGp)

  DataGp2 = DataGp + (mO-mGp)
  DataGf2 = DataGf + (mO-mGp)

  SHIFT = FALSE
  if(min(DataGp2,DataGf2)<=0){
    cat("min(DataGp2,DataGf2)=",(min(ObsRp,DataGp2,DataGf2))," => -",(min(ObsRp,DataGp2,DataGf2)),"+1e-6 to all DataG data\n")
    DataGp2 = DataGp2 - min(ObsRp,DataGp2,DataGf2) + 1e-6
    DataGf2 = DataGf2 - min(ObsRp,DataGp2,DataGf2) + 1e-6
    SHIFT = TRUE
  }

  #####################################################
  # NEED TO ESTIMATE THE shape AND scale PARAMETERS OF THE WEIBULL DENSITY

  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=ini.sh.O,scale=ini.sc.O),method="L-BFGS-B",fixed=list(X=ObsRp),lower=c(1e-6,1e-6),upper=c(25,25)))
###  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=1,scale=1),method="L-BFGS-B",fixed=list(X=ObsRp),lower=c(1e-6,1e-6),upper=c(25,25)))
  shO = as.numeric(coef(est.weibull[[1]])[(length(ObsRp)+1)])
  scO = as.numeric(coef(est.weibull[[1]])[(length(ObsRp)+2)])
  #shO; scO



  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=ini.sh.GpC,scale=ini.sc.GpC),method="L-BFGS-B",fixed=list(X=DataGp2),lower=c(1e-6,1e-6),upper=c(25,25)))
###  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=1,scale=1),method="L-BFGS-B",fixed=list(X=DataGp2),lower=c(1e-6,1e-6),upper=c(25,25)))
  shGp2 = as.numeric(coef(est.weibull[[1]])[(length(DataGp2)+1)])
  scGp2 = as.numeric(coef(est.weibull[[1]])[(length(DataGp2)+2)])
  #shGp2; scGp2



  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=ini.sh.GfC,scale=ini.sc.GfC),method="L-BFGS-B",fixed=list(X=DataGf2),lower=c(1e-6,1e-6),upper=c(25,25)))
###  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=1,scale=1),method="L-BFGS-B",fixed=list(X=DataGf2),lower=c(1e-6,1e-6),upper=c(25,25)))
  shGf2 = as.numeric(coef(est.weibull[[1]])[(length(DataGf2)+1)])
  scGf2 = as.numeric(coef(est.weibull[[1]])[(length(DataGf2)+2)])
  #shGf2; scGf2



#  mGp2 = mO
#  mGf2 = mean(DataGf2)

#  ectO = sqrt(var(ObsRp))
#  ectGp2 = sqrt(var(DataGp2))
#  ectGf2 = sqrt(var(DataGf2))

  #####################################################
  

  FRp = cdfWeibull(shO,scO)     # FRp=ecdf(ObsRp)
  FGp = cdfWeibull(shGp2,scGp2) # FGp=ecdf(DataGp2)
  FGf = cdfWeibull(shGf2,scGf2) # FGf=ecdf(DataGf2)

  a=abs(mean(DataGf)-mean(DataGp))
  m=min(ObsRp, DataGp, DataGf)-dev*a
  M=max(ObsRp, DataGp, DataGf)+dev*a


  x=seq(max(1e-6,m),M,,npas)


  FGF=FGf(x)
  FGP=FGp(x)
  FRP=FRp(x)


  FGPm1 = quantileWeibull(shGp2,scGp2)
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

  ###############################################
  # NEED TO ESTIMATE SHAPE AND SCALE FOR DataGp and DataGf

  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=ini.sh.Gp,scale=ini.sc.Gp),method="L-BFGS-B",fixed=list(X=DataGp),lower=c(1e-6,1e-6),upper=c(25,25)))
###  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=1,scale=1),method="L-BFGS-B",fixed=list(X=DataGp),lower=c(1e-6,1e-6),upper=c(25,25)))
  shGp = as.numeric(coef(est.weibull[[1]])[(length(DataGp)+1)])
  scGp = as.numeric(coef(est.weibull[[1]])[(length(DataGp)+2)])
  #shGp; scGp



  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=ini.sh.Gf,scale=ini.sc.Gf),method="L-BFGS-B",fixed=list(X=DataGf),lower=c(1e-6,1e-6),upper=c(25,25)))
###  est.weibull=list(mle(minuslog=MinusLogLikWeibull, start=list(shape=1,scale=1),method="L-BFGS-B",fixed=list(X=DataGf),lower=c(1e-6,1e-6),upper=c(25,25)))
  shGf = as.numeric(coef(est.weibull[[1]])[(length(DataGf)+1)])
  scGf = as.numeric(coef(est.weibull[[1]])[(length(DataGf)+2)])
  #shGf; scGf


#  mGf= mean(DataGf)
#  ectGp = sqrt(var(DataGp))
#  ectGf = sqrt(var(DataGf))

  ###############################################



  FGp = cdfWeibull(shGp,scGp) # FGp=ecdf(DataGp)
  FGf = cdfWeibull(shGf,scGf) # FGf=ecdf(DataGf)
  
  
  FGP=FGp(x)
  FGF=FGf(x)

  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=xx$y))

}


