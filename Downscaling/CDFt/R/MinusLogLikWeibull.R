MinusLogLikWeibull = function(X, shape, scale){

#  if(scale <= 0){
#    return(1000)
#  }

  n=length(X)
  sumLog=0
  for(i in 1:n){
    d = dweibull(X[i],shape=shape,scale=scale)
    d = max(d,1e-24)
    sumLog=sumLog+log(d)
    #cat(shape, scale, dweibull(X[i],shape=shape,scale=scale),"\n")
    #MIN = min(MIN,dweibull(X[i],shape=shape,scale=scale))
  }
#  cat((-sumLog),"\n")
  if(is.na(sumLog)){
    cat(sumLog,"shape=",shape," scale=",scale,"\n")
  }
  return((-sumLog) )

}

