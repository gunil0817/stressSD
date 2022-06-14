
#data generation
rm(list=ls())
setwd('/home/jhlee4991/Github/project_stressSD/bayesian_modeling/')

# dat2 = read.csv("newDesign.csv", header = T)
PATH_DATA = '/home/jhlee4991/Github/project_stressSD/bayesian_modeling/data/'
PATH_FIG = '~/Github/project_stressSD/bayesian_modeling/figures'

tmp_data <- list.files(PATH_DATA, pattern = "*.txt")
dat2 <- read.table(paste0(PATH_DATA, tmp_data[1]), head = T, sep = "\t")
# df_behav$totalFairseq <- gsub(1, "targetSame", df_behav$totalFairseq)
# df_behav$totalFairseq <- gsub(0, "targetMore", df_behav$totalFairseq)


library(rstan)
library(biomod2)

source("utils/M16_simulator.R")
options(mc.cores = parallel::detectCores())

#setting true values for parameters
{ 
  numTrial = 120 #144
  #K = seq(0.01,0.2,0.02) #discounting rate
  K = c(0.03, 0.09, 0.15)
  #TAU = c(0.05, 0.1, 0.3, 0.5, 1, 1.5)
  #TAU = c(.05, 0.3, 0.5, .7, 1)
  TAU = c(2) # tau values are pinpointed to see the dyanmics of K and beta
  BETA = seq(0.15,1.45,0.15)
  ETA = c(0.1, 0.6)
  #BETA = seq(0.1,0.7,0.05)
  nrep = 1                   # number of repetition for now
  nump = length(K)*length(TAU)*length(BETA)*length(ETA) # num synthethic subject
}

#synthetic subject task conditions
{
  amount_self      = array(0, c(nump,numTrial))
  amount_other     = array(0, c(nump,numTrial))
  amount_default   = array(0, c(nump,numTrial))
  social_distance  = array(0, c(nump,numTrial))
  split            = array(0, c(nump,numTrial))
  subjID = array((1:nump), c(nump,numTrial))
  inequality       = array(0, c(nump, numTrial))
} 

print(nump)
#assigning conditions //
for (i in 1:nump){
  tmpData = subset(dat2, subjID == 1) #use the first subject data for conditions 
  AO = tmpData$amount_other
  SD = tmpData$social_distance
  AS = tmpData$amount_self
  AD = tmpData$amount_default
  
  amount_self[i, 1:numTrial] = AS
  amount_other[i, 1:numTrial] =AO
  amount_default[i, 1:numTrial] =  AD
  social_distance[i, 1:numTrial] = SD
}

{
  print(sort(unique(amount_self[1,])))
  print(unique(amount_other[1,]))
  print(unique(amount_default[1,]))
}
#can get one of the three : fake_chocies, SVs, and probabilities. 
#Basically, we can generate fake data across different values of K, tau, beta, eta.
#put those values in the stan to see if we get the values we set when we generated the data. 


#fakedata input dataList
fdList <- list(
  N               = nump,
  subjID          = subjID,
  amount_self     = amount_self,
  amount_other    = amount_other,
  amount_default  = amount_default,
  social_distance = social_distance,
  inequality      = amount_other - amount_default
)

params = array(0, c(nump,4))
counts = 1
for (k in 1:length(K)){
  for (beta in 1:length(BETA)) {
    for (tau in 1:length(TAU)) {
      for (eta in 1:length(ETA)) {
        #generate the fakek data for 10 subjects at given parameters.
        split[counts,] = M16_simulator(dataList = fdList, 
                                          k = K[k], beta = BETA[beta], 
                                          tau = TAU[tau], eta = ETA[eta], nrep = 1)
        params[counts, 1] = K[k]
        params[counts, 2] = BETA[beta]
        params[counts, 3] = TAU[tau]
        params[counts, 4] = ETA[eta]
        counts = counts + 1
      }
        
    }
  }
}


print(rowSums(split)) #This summates # of prosocial decisions
print(params)


Tsubj = rep(numTrial,nump)
dataList <- list(
  N = nump,
  T = numTrial,
  Tsubj           = Tsubj,
  social_distance = social_distance,
  amount_self     = amount_self,
  amount_other    = amount_other,
  amount_default  = amount_default,
  split           = split,
  inequality      = amount_other - amount_default
)

{
  #initialization
  library("loo")
  library("hBayesDM")
  library("bayesplot")
  options(mc.cores = parallel::detectCores())
  rstan_options(auto_write = TRUE)
  
  source("utils/HDIofMCMC.R") 
  source("utils/dataPreprocessing.R")
}



#model Fitting
M16 = stan("models/M16.stan", data= dataList, pars = c("k", 'beta', "tau", "eta", 
                                                             "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 6000, warmup = 2000, chains = 4, cores = 80, control = list(adapt_delta = 0.98))
parameters <- rstan::extract(M16)

# Group-level means plot
pars_group = c("mu_beta", "mu_k", "mu_tau")
color_scheme_set(scheme = "blue")
mcmc_trace(M16, pars = pars_group)
fn = sprintf('%s/traceplots-group-level-means.png', PATH_FIG)
png(fn, width = 300, height = 250, units = "mm", res = 300)

# Indi-level 
pars_ind = c("k", "beta", "tau")
model_name = "M16"

for (par in pars_ind) {
  fn = sprintf('%s/traceplots-%s-%s.png', PATH_FIG, model_name, par)
  png(fn, width = 360, height = 240, units = "mm", res = 300)
  print(traceplot(M16, pars = par))
  dev.off()  
  print(sprintf('Traceplot saved: %s-%s', model_name, par))
}
print(traceplot(M16, pars = pars_ind[8]))



dfPre = data.frame(params[,1], params[,2], params[,4], colMeans(parameters$k), colMeans(parameters$beta), colMeans(parameters$eta))
names(dfPre) = c('true_k', 'true_beta', 'true_eta', 'pred_k', 'pred_beta', 'pred_eta')


library(ggpubr)
ggscatter(dfPre, x = "true_beta", y = "pred_beta", add = "reg.line", 
          conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson", xlab="true_beta", ylab = "pred beta") + theme(text=element_text(size=28))


ggscatter(dfPre, x = "true_k", y = "pred_k", add = "reg.line", 
          conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson", xlab="true_k", ylab = "pred_k") + theme(text=element_text(size=28))

ggscatter(dfPre, x = "true_eta", y = "pred_eta", add = "reg.line", 
          conf.int = TRUE, cor.coef = TRUE, cor.method = "pearson", xlab="true_eta", ylab = "pred_eta") + theme(text=element_text(size=28))



#summary of the model
#simulM = summary(M14, pars=c("k","tau", "beta", "eta"), probs = c(0.1, 0.9))$summary
#write.csv(simulM, 'simulSum_M12_beta.csv')

#for some reason, parameter orders need to be reversed. 
#revparams = rev(params[,1])
#plot(fd_m14, ci_level = 0.05, pars = "k") + geom_point(x = revparams, y = seq(1,nump,1), colour = 'red', size = 2)


#revparams = rev(params[,2])
#plot(fd_m14, ci_level = 0.05, pars = "beta") + geom_point(x = params[,2], y = seq(1,nump,1), colour = 'red', size = 2)
#fd_m6 = stan("models/M6_modified.stan", data = dataList, pars = c("k", "tau", "log_lik","mu_tau", "mu_k"),
#             iter = 10000, warmup=4000, chains=4, cores= 16, control = list(adapt_delta = 0.97))

