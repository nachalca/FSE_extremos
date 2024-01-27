quantileBeta = function(sh1, sh2){
  return(
    quantile = function(p){
      return(qbeta(p, shape1=sh1, shape2=sh2))
    }
  )
}
