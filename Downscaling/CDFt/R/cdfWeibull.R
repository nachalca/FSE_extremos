cdfWeibull = function(sh,sc){
  return(
    cdf = function(x){
      return(pweibull(x,shape=sh, scale=sc))
    }
  )
}
