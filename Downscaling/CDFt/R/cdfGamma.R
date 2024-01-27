cdfGamma = function(sh,sc){
  return(
    cdf = function(x){
      return(pgamma(x,shape=sh, scale=sc))
    }
  )
}
