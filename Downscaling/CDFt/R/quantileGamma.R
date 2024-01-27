quantileGamma = function(sh, sc){
  return(
    quantile = function(q){
      return(qgamma(q, shape=sh, scale=sc))
    }
  )
}

