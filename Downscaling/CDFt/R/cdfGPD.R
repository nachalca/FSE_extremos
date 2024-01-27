cdfGPD = function(mu,xi,sc){
  return(
    cdf = function(x){
      return(pgpd.mk(x, xi=xi, mu=mu, sc=sc))
    }
  )
}
