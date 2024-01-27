pgpd.mk <- function(q, xi, mu, sc){ 

  q[q<mu] <- mu

  if(xi==0){#Gumbel
     return(1-exp(-(q-mu)))
  }else{
     return(1 - (1 + (xi * (q - mu))/sc)^(-1/xi))
  }
}
