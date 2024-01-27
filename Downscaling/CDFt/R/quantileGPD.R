quantileGPD = function(mu, xi, sc){
  return(
    quantile = function(p){
      return(qgpd(p, xi=xi,mu=mu, beta=sc))
    }
  )
}
