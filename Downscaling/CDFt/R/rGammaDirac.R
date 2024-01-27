rGammaDirac = function(n, sh,sc,p0){

  r = array(NaN,dim=n)

  for(i in 1:n){
    u = runif(1)
    if(u<=p0){
      r[i] = 0
    }
    else{
      r[i] = rgamma(1, shape=sh, scale=sc)
    }
  }

  return(r)

}
