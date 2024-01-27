cdfGaussian = function(m,ect){
  return(
    cdf = function(x){
      return(pnorm(x,mean=m,sd=ect))
    }
  )
}

