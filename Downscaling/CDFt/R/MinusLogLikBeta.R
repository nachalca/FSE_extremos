MinusLogLikBeta = function(X, sh1, sh2){
  S=0
  for(i in 1:(length(X))){
    S = S-log(dbeta(X[i],sh1,sh2))
  }
  return(S)
}
