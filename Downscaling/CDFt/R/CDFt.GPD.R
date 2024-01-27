CDFt.GPD <- function(ObsRp, DataGp, DataGf, muO=0, muGp=0, muGf=NULL, npas = 100, dev = 2){


  #########################################
  ### Choice of the threshold muGf

  if(is.null(muGf)){
      rateGp <- sum(DataGp>=muGp)/length(DataGp)
      muGf = quantile(DataGf,(1-rateGp))
      ### equivalent to ???
      ### muGf <- sort(DataGf,decreasing=TRUE)[as.integer(length(DataGf)*rateGp)]
  }

  #too few extremes
  if((sum(DataGp>muGp) < 15) || (sum(DataGf>muGf) < 15) || (sum(ObsRp>muO) < 15))
        stop("too few extremes\n")



  #####################################################
  #CENTER so that all thresholds are muO

  DataGf2 <- DataGf + (muO - muGp)
  DataGp2 <- DataGp + (muO - muGp)
  muGf2 <- muGf + (muO - muGp)
  muGp2 <- muO


  #########################################
  ### If centering
###  mO = mean(ObsRp)
###  mGp= mean(DataGp)
###  DataGp2 = DataGp + (mO-mGp)
###  DataGf2 = DataGf + (mO-mGp)
###  muG2 = muG + (mO-mGp)

  #########################################
  ### If NO centering
###  DataGf2 = DataGf
###  DataGp2 = DataGp
###  muG2 = muG
  #########################################


  #####################################################
  # NEED TO ESTIMATE THE shape AND scale PARAMETERS OF THE GPD DENSITY

  est.gpd = gpd(ObsRp, threshold = muO, method = "pwm", information = "observed")
  xiO = as.numeric(est.gpd$par.ests[1])
  scO = as.numeric(est.gpd$par.ests[2])
  # xiO; scO

  est.gpd = gpd(DataGp, threshold = muGp, method = "pwm", information = "observed")
  xiGp = as.numeric(est.gpd$par.ests[1])
  scGp = as.numeric(est.gpd$par.ests[2])
  # xiGp; scGp

  est.gpd = gpd(DataGf, threshold = muGf, method = "pwm", information = "observed")
  xiGf = as.numeric(est.gpd$par.ests[1])
  scGf = as.numeric(est.gpd$par.ests[2])
  # xiGf; scGf


  #####################################################
  

  FRp = cdfGPD(muO, xiO, scO)      # FRp=ecdf(ObsRp)
  FGp = cdfGPD(muGp2, xiGp, scGp)  # FGp=ecdf(DataGp2)
  FGf = cdfGPD(muGf2, xiGf, scGf)  # FGf=ecdf(DataGf2)


##  a=abs(mean(DataGf)-mean(DataGp))
##  m=min(ObsRp, DataGp, DataGf)-dev*a
##  M=max(ObsRp, DataGp, DataGf)+dev*a

  ## OR
  DataGfe <- DataGf[DataGf>muGf]
  DataGpe <- DataGp[DataGp>muGp]
  ObsRpe <- ObsRp[ObsRp>muO]
  a=abs(mean(DataGfe)-mean(DataGpe))
  m=min(ObsRpe, DataGpe, DataGfe)-dev*a
  M=max(ObsRpe, DataGpe, DataGfe)+dev*a


  x=seq(m,M,,npas)

  FGF=ifelse(is.na(pmax(0,FGf(x))),1,pmax(0,FGf(x)))
  FGP=ifelse(is.na(pmax(0,FGp(x))),1,pmax(0,FGp(x)))
  FRP=ifelse(is.na(pmax(0,FRp(x))),1,pmax(0,FRp(x)))
  #FGF=pmax(0,FGf(x))
  #FGP=pmax(0,FGp(x))
  #FRP=pmax(0,FRp(x))

  FGPm1 = quantileGPD(muGp2, xiGp, scGp)
  FGPm1.FGF=FGPm1(FGF)
  ### FGPm1.FGF=quantile(DataGp2,probs=FGF)

  FRF=ifelse(is.na(pmax(0,FRp(FGPm1.FGF))),1,pmax(0,FRp(FGPm1.FGF)))
  ##FRF=pmax(0,FRp(FGPm1.FGF))

  

######################################################################################
### Quantile-matching based on the new large-scale CDF and downscaled local-scale CDF.


  qntl = ifelse(is.na(pmax(0,FGf(DataGf2))),1,pmax(0,FGf(DataGf2)))
  ###qntl = FGf(DataGf2)
  xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')

  ### xx = FRfm1(FRp(FGPm1(DataGf2))) ??????
  ### No, cannot have FRfm1

  qqvals <- xx$y
  muO2 <- muGf2
  qqvals[qqvals<muO2] <- muO2

#######################################################################################

  ###############################################

  FGp = cdfGPD(muGp, xiGp, scGp) # FGp=ecdf(DataGp)
  FGf = cdfGPD(muGf, xiGf, scGf) # FGf=ecdf(DataGf)
  
  FGP=pmax(0,FGp(x))
  FGF=pmax(0,FGf(x))



  #RETURN ALSO FRf ??



  ###return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=pmax(muO,xx$y), muGf=muGf))
  ###return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=pmax(muO,qqvals), muGf=muGf))
  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=qqvals, muGf=muGf))

}


