Non.neg.values1D = function(Tab1d){

  n=length(Tab1d)

  c0=0
  for(i in 1:n){
    if(!is.na(Tab1d[i]) && Tab1d[i]>0){
      c0=c0+1
    }
  }

  TabNon0 = array(NaN,dim=c0)
  c=0
  for(i in 1:n){
    if(!is.na(Tab1d[i]) && Tab1d[i]>0){
      c=c+1
      TabNon0[c]=Tab1d[i]
    }
  }

  return(TabNon0)

}
