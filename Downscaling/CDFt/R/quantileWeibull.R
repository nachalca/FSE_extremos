quantileWeibull = function(sh, sc){
  return(
    quantile = function(q){
      return(qweibull(q, shape=sh, scale=sc))
    }
  )
}

