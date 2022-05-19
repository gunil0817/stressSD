

datapreprocessing = function(dat) {
  
  T        = table(dat$subjID)    # number of trials per subject (=120)
  Tsubj    = as.integer(T)
  allSubj  = unique(dat$subjID) # all subject IDs (1:14)
  N        = length(allSubj) # number of all subjects (14)
  maxTrials= max(Tsubj)

  
  other_incent   = dat$amount_other
  self_incent    = dat$amount_self
  self_default   = dat$amount_default
  amount_inequal = other_incent - self_default
  SD             = dat$social_distance
  SDLike         = dat$SD_likeRaw
  split          = dat$choice
  subjID         = dat$subjID
  
  
  #reshaping the input vectors into input matrix of T,N
  dim(self_default) <- c(maxTrials, N)
  amount_default    = t(self_default)
  
  dim(other_incent) <- c(maxTrials,N)
  amount_other      = t(other_incent) 
  
  dim(self_incent)  <- c(maxTrials,N)
  amount_self       = t(self_incent)
  
  dim(SD)           <- c(maxTrials,N)
  social_distance   = t(SD)
  
  dim(split)        <- c(maxTrials,N)
  split             = t(split)
  
  dim(subjID)       <- c(maxTrials,N)
  subjID            = t(subjID)
  
  dim(SDLike)       <- c(maxTrials,N)
  SDLike            = t(SDLike)
  
  dim(amount_inequal) <- c(maxTrials,N)
  inequality        = t(amount_inequal)
  
  dataList <- list(
    N = N,
    T = max(Tsubj),
    Tsubj           = Tsubj,
    subjID          = subjID, 
    social_distance = social_distance,
    amount_self     = amount_self,
    amount_other    = amount_other,
    amount_default  = amount_default,
    SDLike          = SDLike,
    inequality      = inequality,
    split           = split
  )
  return (dataList)
}