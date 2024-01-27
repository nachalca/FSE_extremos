CDFt <- function(ObsRp, DataGp, DataGf, npas = 100, dev = 2){

  mO = mean(ObsRp, na.rm=TRUE)
  mGp= mean(DataGp, na.rm=TRUE)
  DataGp2 = DataGp + (mO-mGp)
  DataGf2 = DataGf + (mO-mGp)

  FRp=ecdf(ObsRp)
  FGp=ecdf(DataGp2)
  FGf=ecdf(DataGf2)

  a=abs(mean(DataGf, na.rm=TRUE)-mean(DataGp, na.rm=TRUE))
  m=min(ObsRp, DataGp, DataGf, na.rm=TRUE)-dev*a
  M=max(ObsRp, DataGp, DataGf, na.rm=TRUE)+dev*a


  x=seq(m,M,,npas)


  FGF=FGf(x)
  FGP=FGp(x)
  FRP=FRp(x)

  FGPm1.FGF=quantile(DataGp2,probs=FGF, na.rm=TRUE)

  FRF=FRp(FGPm1.FGF)

  ######################################
  # FRf=FRp with shift for x<min(DataGf)

  if(min(ObsRp, na.rm=TRUE)<min(DataGf2, na.rm=TRUE)){

    i=1
    while(x[i]<=quantile(ObsRp,probs=FRF[1],na.rm=TRUE)){
      i=i+1
    }
  
    j=1
    while(x[j]<min(DataGf2, na.rm=TRUE)){
      j=j+1
    }

    k=i
    while(j>0 && k>0){
      FRF[j]=FRP[k]
      j=j-1
      k=k-1
    }

    ##########    

    if(j>0){
      for(k in j:1){
        FRF[k]=0
      }
    }

  }

  ######################################
  # FRf=FRp with shift for x>max(DataGf)


  if(FRF[length(x)]<1){

    i=length(x)
    QQ=quantile(ObsRp,probs=FRF[length(x)], na.rm=TRUE)
    while(x[i]>=QQ){
      i=i-1
    }
    i=i+1

    j=length(x)-1
    while(j>0 && FRF[j]==FRF[length(x)]){
      j=j-1
    }

    if(j==0){
      stop("In CDFt, dev must be higher\n")
    }

    dif=min((length(x)-j),(length(x)-i))
    FRF[j:(j+dif)]=FRP[i:(i+dif)]
    k=j+dif

    if(k<length(x)){
      FRF[k:(length(x))]=1
    }

  }


######################################################################################
### Quantile-matching based on the new large-scale CDF and downscaled local-scale CDF.

NaNs.indices = which(is.na(DataGf2))
No.NaNs.indices = which(!is.na(DataGf2))

qntl = array(NaN, dim=dim(DataGf2))
qntl[No.NaNs.indices] = FGf(DataGf2[No.NaNs.indices])
#qntl[NaNs.indices] = NaN

xx = array(NaN, dim=dim(DataGf2))
xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')

#qntl = FGf(DataGf2)
#xx = approx(FRF,x,qntl,yleft=x[1],yright=x[length(x)],ties='mean')

#######################################################################################
  FGp=ecdf(DataGp)
  FGf=ecdf(DataGf)
  FGP=FGp(x)
  FGF=FGf(x)

  return(list(x=x,FRp=FRP,FGp=FGP,FGf=FGF,FRf=FRF,DS=xx$y))

}
