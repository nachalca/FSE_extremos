MinusLogLikGamma <- function(X,lambda,gam){

# gam = shape parameter
# lambda = rate (=1/beta with beta = scale parameter)

  #cat(lambda,gam," ")
  n=length(X)
  sum=0
  sumLog=0
  for(i in 1:n){
    #cat(i,"")
    sum=sum+(X[i])
    #cat(sum,"")
    sumLog=sumLog+log(X[i])
    #cat(sumLog,"")
  }
  #cat((-n * gam * log(lambda)) + (n * log(gamma(gam))) - ((gam-1) * sumLog) + (lambda * sum),"   ")
  return( (-n * gam * log(lambda)) + (n * log(gamma(gam))) - ((gam-1) * sumLog) + (lambda * sum) )
}

