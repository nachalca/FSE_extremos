quantileGaussian = function(m, ect){
  return(
    quantile = function(q){
      return(qnorm(q, mean=m, sd=ect))
    }
  )
}

