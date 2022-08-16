#Genearting Fake data for M14. 
#DataList contains amount_self, amount_other, amount_default, social_distance, and inequality
#For certain values of k, tau, beta, eta , computes the Subjective values of
#split and nonsplit options and estimate the probability. 

#nrep     = number of repetition for simulation.
#ev_self  = subjective value of the non-split option
#ev_other = subjective value of the split option
#SVnet    = net subjective value of two choices.
#pSplit   = probability of choosing to split
#fakeSplit= transformation of the probability of split into 1 or 0. 

#Kun Il Kim edited in 2022. 03. 23. 
# Last edit: JH Lee 2022.06.13.

M18_simulator_SVnet = function(dataList, k, beta, tau, eta, nrep) {
  seed = 2022
  
  amount_self     = dataList$amount_self
  amount_other    = dataList$amount_other
  amount_default  = dataList$amount_default
  social_distance = dataList$social_distance
  inequality      = dataList$inequality # 0 for equal, 20 for TarMore
  numTrial = length(amount_self[1,])
  
  # allocating # trial X nrep
  fakesplit <- array(0, c(nrep, numTrial))
  psplit    <- array(0, c(1, numTrial))
  SVnet     <- array(0, c(1, numTrial))
  
    for (n in 1:nrep){
      for (t in 1:numTrial) {
        ev_self = (amount_self[1,t] - amount_default[1,t]) * beta
        ev_other = (amount_other[1,t]) * exp(-1 * ( k * social_distance[1,t]))  - eta * inequality[1,t]
        SVnet[1, t] =  ev_other - ev_self
        psplit[1, t] = 1 / (1 + exp(-1*tau*SVnet[1,t]))
        psplit[1, t]  = psplit[1,t] * 0.9998 + 0.0001    
        fakesplit[n,t] = rbinom(n=1,size = 1, prob = psplit[1,t])
      }
       #this will give 1 or 0
    }
  
  #print(fakesplit[1,])
  # #return(psplit) #for returning probabilites
  # fakesplit = round(colMeans(fakesplit))
  return(SVnet) 
  #return(SVnet) //returning SVnet for all trials given the composition of parameters. 
}

M18_simulator_psplit = function(dataList, k, beta, tau, eta, nrep) {
  seed = 2022
    amount_self     = dataList$amount_self
    amount_other    = dataList$amount_other
    amount_default  = dataList$amount_default
    social_distance = dataList$social_distance
    inequality      = amount_other - amount_default # 0 for equal, 20 for TarMore
    numTrial = length(amount_self)
    
    # allocating # trial X nrep
    fakesplit <- array(0, c(nrep, numTrial))
    psplit    <- array(0, c(1, numTrial))
    SVnet     <- array(0, c(1, numTrial))

    for (n in 1:nrep){
      for (t in 1:numTrial) {
        ev_self = (amount_self[t] - amount_default[t]) * beta
        ev_other = (amount_other[t]) * exp(-1 * ( k * social_distance[t]))  - eta * inequality[t]
        SVnet[1, t] =  ev_other - ev_self
        psplit[1, t] = 1 / (1 + exp(-1*tau*SVnet[1,t]))
        psplit[1, t]  = psplit[1,t] * 0.9998 + 0.0001    
        fakesplit[n,t] = rbinom(n=1,size = 1, prob = psplit[1,t])
      }
      #this will give 1 or 0
    }

  #print(psplit[1,])
  #print(fakesplit[1,])
  # #return(psplit) #for returning probabilites
  fakesplit = round(colMeans(fakesplit))
  return(fakesplit) 
  #return(SVnet) //returning SVnet for all trials given the composition of parameters. 
}
