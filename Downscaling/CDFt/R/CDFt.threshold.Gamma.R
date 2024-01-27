CDFt.threshold.Gamma <- function(ObsRp, DataGp, DataGf, thObs = 1,
                    npas = 100, dev = 2,
                    ini.sh.O=NA, ini.sc.O=NA,
                    ini.sh.Gp=NA, ini.sc.Gp=NA,
                    ini.sh.Gf=NA, ini.sc.Gf=NA){


  ### Choice of the large-scale threshold thG with respect to obs threshold thObs
  ### such that Pobs(obs<=thObs)~=Pgcm(GCM<=tG)
  ### <=> to QQ-match
  ### This is done on the DataGp (training) set


  FG = ecdf(DataGp)
  FS = ecdf(ObsRp)
 
  #FS(thObs) is the target value

  closest = order(abs(FG(DataGp)-FS(thObs)))
  closest.1.FG.of.thObs = order(abs(FG(DataGp)-FS(thObs)))[1]
  i=2
  if(FG(DataGp[closest.1.FG.of.thObs]) <= FS(thObs)){
    while(FG(DataGp[closest[i]]) <= FS(thObs)){
      i = i + 1
    }
    closest.2.FG.of.thObs = closest[i]
  }

  if(FG(DataGp[closest.1.FG.of.thObs]) > FS(thObs)){
    while(FG(DataGp[closest[i]]) > FS(thObs)){
      i = i + 1
    }
    closest.2.FG.of.thObs = closest[i]
  }

  closest.FG.of.thObs= c(closest.1.FG.of.thObs, closest.2.FG.of.thObs)
  closest.FG.of.thObs
 
  FG(DataGp[closest.FG.of.thObs])
 
  LM = lm(DataGp[closest.FG.of.thObs]~FG(DataGp[closest.FG.of.thObs]))
  a = LM$coefficients[2]
  b = LM$coefficients[1]

  thG = a*FS(thObs)+b
  
  #FG(thGCM[st]) and FS(thObs) should be appr. =



  #######
  # DS based on CDFt.Gamma


  ObsRp.t = ObsRp[ which(ObsRp>=thObs) ]
  DataGp.t = DataGp[ which(DataGp>=thG) ]
  DataGf.t = DataGf[ which(DataGf>=thG) ]

  C.Gamma = CDFt.Gamma(ObsRp.t, DataGp.t, DataGf.t,npas = npas, dev = dev, ini.sh.O=ini.sh.O, ini.sc.O=ini.sc.O, ini.sh.Gp=ini.sh.Gp, ini.sc.Gp=ini.sc.Gp, ini.sh.Gf=ini.sh.Gf, ini.sc.Gf=ini.sc.Gf)
  ds.pos = pmax(thObs, C.Gamma$DS)


  # Put large-scale data <= thG to 0
  ds.all = array(NaN,dim=length(DataGf))
  ds.all[ which(DataGf<thG) ] = 0
  
  cpt=0
  for(d in 1:(length(ds.all))){
    if(is.na(ds.all[d])){
      cpt = cpt + 1
      ds.all[d] = ds.pos[cpt]
    }
  }

  if(cpt!=(length(ds.pos))){
    cat("-------- WARNING: cpt!=(length(ds.pos)) --------\n")
  }

  


  #####
  # Combine threshold data and CDFt.Gamma results

  return(list(x=C.Gamma$x,FRp=C.Gamma$FRp,FGp=C.Gamma$FGp,FGf=C.Gamma$FGf,FRf=C.Gamma$FRf,DS=ds.all, thObs=thObs, thG=thG))


}



#Obs = rnorm(100,mean=1,sd=1)
#A = rnorm(100,mean=3,sd=1)
#B = rnorm(100,mean=4,sd=1)


#C = CDFt.threshold.Gamma(Obs,A,B,thObs=0.1)



