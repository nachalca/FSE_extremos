CDFt.Gamma.Dirac <- function(ObsRp, DataGp, DataGf, npas = 100, dev = 2,
                    ini.sh.O=NA, ini.sc.O=NA,
                    ini.sh.Gp=NA, ini.sc.Gp=NA,
                    ini.sh.Gf=NA, ini.sc.Gf=NA,
                    ini.sh.GpC=NA, ini.sc.GpC=NA,
                    ini.sh.GfC=NA, ini.sc.GfC=NA){
# The model is a mixture of Dirac (in 0) and a Gamma distribution
# Gamma and Dirac are estimated separately

######### To be developed:  CDF-t on the Gamma, separately from the transformation of p0, and then group them ???? #############

  # Separate 0 and non 0 values

  ObsRpNo0 = Non.neg.values1D(ObsRp)
  DataGpNo0 = Non.neg.values1D(DataGp)
  DataGfNo0 = Non.neg.values1D(DataGf)

  p0Obs = (1-(length(ObsRpNo0)/length(ObsRp)))
  p0Gp = 1-(length(DataGpNo0)/length(DataGp))
  p0Gf = 1-(length(DataGfNo0)/length(DataGf))
  p0Rf = p0Gf * p0Obs / p0Gp


  #########################################
  ### If centering

  mO = mean(ObsRpNo0)
  mGp= mean(DataGpNo0)
  DataGp2No0 = DataGpNo0 + (mO-mGp)
  DataGf2No0 = DataGfNo0 + (mO-mGp)

  DataGp2w0 = DataGp
  for(i in 1:(length(DataGp))){
    if(!is.na(DataGp[i]) && DataGp[i]>0)
      DataGp2w0[i] = DataGp[i] + (mO-mGp)
  }
  DataGf2w0 = DataGf
  for(i in 1:(length(DataGf))){
    if(!is.na(DataGf[i]) && DataGf[i]>0)
      DataGf2w0[i] = DataGf[i] + (mO-mGp)
  }
  #########################################
  ### If NO centering
###  DataGf2No0 = DataGfNo0
###  DataGp2No0 = DataGpNo0
###  DataGp2w0 = DataGp
  #########################################


  #####################################################
  # NEED TO ESTIMATE THE shape AND scale PARAMETERS OF THE GAMMA DENSITY

  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.O)){
    mR=mean(ObsRpNo0)
    vR=var(ObsRpNo0)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.O
  }

  if(is.na(ini.sc.O)){
    mR=mean(ObsRpNo0)
    vR=var(ObsRpNo0)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.O
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=ObsRpNo0),lower=c(1e-6,1e-6),upper=c(10,10)))
###  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=1,gam=1),method="L-BFGS-B",fixed=list(X=ObsRpNo0),lower=c(1e-6,1e-6),upper=c(10,10)))
  scO = 1/(as.numeric(coef(est.gamma[[1]])[(length(ObsRpNo0)+1)]))
  shO = as.numeric(coef(est.gamma[[1]])[(length(ObsRpNo0)+2)])
  #shO; scO




  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.GpC)){
    mR=mean(DataGp2No0)
    vR=var(DataGp2No0)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.GpC
  }

  if(is.na(ini.sc.GpC)){
    mR=mean(DataGp2No0)
    vR=var(DataGp2No0)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.GpC
  }


  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGp2No0),lower=c(1e-6,1e-6),upper=c(10,10)))
###  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=1,gam=1),method="L-BFGS-B",fixed=list(X=DataGp2No0),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGp2 = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGp2No0)+1)]))
  shGp2 = as.numeric(coef(est.gamma[[1]])[(length(DataGp2No0)+2)])
  #shGp2; scGp2



  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.GfC)){
    mR=mean(DataGf2No0)
    vR=var(DataGf2No0)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.GfC
  }

  if(is.na(ini.sc.Gf)){
    mR=mean(DataGf2No0)
    vR=var(DataGf2No0)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.GfC
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGf2No0),lower=c(1e-6,1e-6),upper=c(10,10)))
###  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=1,gam=1),method="L-BFGS-B",fixed=list(X=DataGf2No0),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGf2 = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGf2No0)+1)]))
  shGf2 = as.numeric(coef(est.gamma[[1]])[(length(DataGf2No0)+2)])
  #shGf2; scGf2

  #####################################################
  

  FRp = cdfGamma(shO,scO)     # FRp=ecdf(ObsRp)
  FGp = cdfGamma(shGp2,scGp2)  # FGp=ecdf(DataGp2)
  FGf = cdfGamma(shGf2,scGf2)  # FGf=ecdf(DataGf2)

  a=abs(mean(DataGf,na.rm=TRUE)-mean(DataGp,na.rm=TRUE))
  m=min(ObsRp, DataGp, DataGf,na.rm=TRUE)-dev*a
  M=max(ObsRp, DataGp, DataGf,na.rm=TRUE)+dev*a


  #x=seq(m,M,,npas)
  x=seq(max(0,m),M,,npas)

  FGF=FGf(x)
  FGP=FGp(x)
  FRP=FRp(x)

  FGPm1 = quantileGamma(shGp2,scGp2)
  FGPm1.FGF=FGPm1(FGF)
  ### FGPm1.FGF=quantile(DataGp2,probs=FGF)
  FRF=FRp(FGPm1.FGF)

  
  ### Transformation of the FRF values to take p0Rf into account

  #for(i in 1:(length(x))){
  #  if(x[i]<0)
  #    FRF[i]=0
  #  else{
  #    FRF[i] = p0Rf + (FRF[i]*(1-p0Rf))
  #  }
  #}

  ### equivalent to
  FRF[which(x>=0)] = p0Rf + (FRF[which(x>=0)]*(1-p0Rf))
  


######################################################################################
### Quantile-matching based on the new large-scale CDF and downscaled local-scale CDF.


#  FGf = cdfGammaDirac(shGf2,scGf2,p0Gf)
#  qntl = FGf(DataGf2w0)
#  xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')
#  xx$y[which(xx$y<0)]=0

  FGf = cdfGammaDirac(shGf2,scGf2,p0Gf)

  NaNs.indices = which(is.na(DataGf2w0))
  No.NaNs.indices = which(!is.na(DataGf2w0))

  qntl = array(NaN, dim=length(DataGf2w0))
  qntl[No.NaNs.indices] = FGf(DataGf2w0[No.NaNs.indices])

  xx = array(NaN, dim=length(DataGf2w0))
  xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')
  xx$y[which(xx$y<0)]=0


#######################################################################################

  ###############################################
  # NEED TO ESTIMATE SHAPE AND SCALE FOR DataGp and DataGf

  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.Gp)){
    mR=mean(DataGpNo0)
    vR=var(DataGpNo0)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.Gp
  }

  if(is.na(ini.sc.Gp)){
    mR=mean(DataGpNo0)
    vR=var(DataGpNo0)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.Gp
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGpNo0),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGp = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGpNo0)+1)]))
  shGp = as.numeric(coef(est.gamma[[1]])[(length(DataGpNo0)+2)])
  #shGp; scGp


  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.Gf)){
    mR=mean(DataGfNo0)
    vR=var(DataGfNo0)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.Gf
  }

  if(is.na(ini.sc.Gf)){
    mR=mean(DataGfNo0)
    vR=var(DataGfNo0)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.Gf
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGfNo0),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGf = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGfNo0)+1)]))
  shGf = as.numeric(coef(est.gamma[[1]])[(length(DataGfNo0)+2)])
  #shGf; scGf

  ###############################################



  FRp = cdfGammaDirac(shO,scO,p0Obs) # FGp=ecdf(DataGp)
  FGp = cdfGammaDirac(shGp,scGp,p0Gp) # FGp=ecdf(DataGp)
  FGf = cdfGammaDirac(shGf,scGf,p0Gf) # FGf=ecdf(DataGf)
  
  
  FRP=FRp(x)
  FGP=FGp(x)
  FGF=FGf(x)



  #RETURN ALSO FRf ??



  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=xx$y,p0Rf=p0Rf))

}

