CDFt.Gamma <- function(ObsRp, DataGp, DataGf, npas = 100, dev = 2,
                    ini.sh.O=NA, ini.sc.O=NA,
                    ini.sh.Gp=NA, ini.sc.Gp=NA,
                    ini.sh.Gf=NA, ini.sc.Gf=NA){
# The model is a Gamma distribution
# => Data are assumed to be >0




  #########################################
  ### If same min

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
    mR=mean(ObsRp)
    vR=var(ObsRp)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.O
  }

  if(is.na(ini.sc.O)){
    mR=mean(ObsRp)
    vR=var(ObsRp)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.O
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=ObsRp),lower=c(1e-6,1e-6),upper=c(10,10)))
  scO = 1/(as.numeric(coef(est.gamma[[1]])[(length(ObsRp)+1)]))
  shO = as.numeric(coef(est.gamma[[1]])[(length(ObsRp)+2)])
  #shO; scO



  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.Gp)){
    mR=mean(DataGp2)
    vR=var(DataGp2)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.Gp
  }

  if(is.na(ini.sc.Gp)){
    mR=mean(DataGp2)
    vR=var(DataGp2)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.Gp
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGp2),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGp2 = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGp2)+1)]))
  shGp2 = as.numeric(coef(est.gamma[[1]])[(length(DataGp2)+2)])
  #shGp2; scGp2



  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.Gf)){
    mR=mean(DataGf2)
    vR=var(DataGf2)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.Gf
  }

  if(is.na(ini.sc.Gf)){
    mR=mean(DataGf2)
    vR=var(DataGf2)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.Gf
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGf2),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGf2 = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGf2)+1)]))
  shGf2 = as.numeric(coef(est.gamma[[1]])[(length(DataGf2)+2)])
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

  



######################################################################################
### Quantile-matching based on the new large-scale CDF and downscaled local-scale CDF.


  qntl = FGf(DataGf2)
  xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')

  ### xx = FRfm1(FRp(FGPm1(DataGf2))) ??????
  ### No, cannot have FRfm1



#######################################################################################

  ###############################################
  # NEED TO ESTIMATE SHAPE AND SCALE FOR DataGp and DataGf

  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.Gp)){
    mR=mean(DataGp)
    vR=var(DataGp)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.Gp
  }

  if(is.na(ini.sc.Gp)){
    mR=mean(DataGp)
    vR=var(DataGp)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.Gp
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGp),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGp = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGp)+1)]))
  shGp = as.numeric(coef(est.gamma[[1]])[(length(DataGp)+2)])
  #shGp; scGp


  ##############
  # Initialization by method of the moments if needed
  if(is.na(ini.sh.Gf)){
    mR=mean(DataGf)
    vR=var(DataGf)
    ini.g.R=(mR^2)/vR # lambda = alpha.si = shape
  }
  else{
    ini.g.R = ini.sh.Gf
  }

  if(is.na(ini.sc.Gf)){
    mR=mean(DataGf)
    vR=var(DataGf)
    ini.l.R=mR/vR     # gamma = beta.si = rate
    ###ini.s.R=1/ini.l.R # sigma = 1/gamma = scale
  }
  else{
    ini.l.R = 1/ini.sc.Gf
  }

  est.gamma=list(mle(minuslog=MinusLogLikGamma, start=list(lambda=ini.l.R,gam=ini.g.R),method="L-BFGS-B",fixed=list(X=DataGf),lower=c(1e-6,1e-6),upper=c(10,10)))
  scGf = 1/(as.numeric(coef(est.gamma[[1]])[(length(DataGf)+1)]))
  shGf = as.numeric(coef(est.gamma[[1]])[(length(DataGf)+2)])
  #shGf; scGf

  ###############################################



  FRp = cdfGamma(shO,scO) # FGp=ecdf(DataGp)
  FGp = cdfGamma(shGp,scGp) # FGp=ecdf(DataGp)
  FGf = cdfGamma(shGf,scGf) # FGf=ecdf(DataGf)
  
  
  FRP=FRp(x)
  FGP=FGp(x)
  FGF=FGf(x)



  #RETURN ALSO FRf ??



  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=xx$y))

}

