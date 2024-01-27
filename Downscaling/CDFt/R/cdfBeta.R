cdfBeta = function(sh1,sh2){
  return(
    cdf = function(x){
      return(pbeta(x,shape1=sh1, shape2=sh2))
    }
  )
}
