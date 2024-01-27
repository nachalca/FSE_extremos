cdfGammaDirac = function(sh,sc,p0){
  return(
    cdf = function(x){

      c = array(NaN,dim=length(x))
      for(i in 1:(length(x))){
        #if(x[i]==0){
        #  c[i] = p0
        #}
        if(x[i]<=0){
          c[i] = 0
        }
        if(x[i]>0){
          c[i] = (pgamma(x[i],shape=sh, scale=sc)*(1-p0)) +p0
        }
      }
      return(c)
    }
  )
}
