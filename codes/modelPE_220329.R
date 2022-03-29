#social discounting parameter estimates(PE)
#this file reads grouped data and performs PE. 
#authored by Kun Il Kim
#21.07.07, modified from 2020.June bayesian modeling class from Prof. Ahn.


rm(list = ls())  # remove7 all variables
set.seed(08787) # set seed
setwd("C:/Users/compu/Desktop/ToSend")
{
#initialization
library(rstan)
library("loo")
library("hBayesDM")
library("bayesplot")
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

source("utils/HDIofMCMC.R") 
source("utils/loo_model.R") 
source("utils/dataPreprocessing.R")


#DataLoading
dataDir   = 'C:/Users/compu/Desktop/ToSend/data/'
dataLists = dir(dataDir)

fileName  = paste(dataDir,dataLists[1], sep="")
pfsen = paste('loading behavior data : ', fileName)
dataWhole       = read.table(fileName, header = T)


#preprocessing behavior data for PE estimation
datWhole = datapreprocessing(dataWhole)
}

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


#newer models after Mar.09. 2022

#winning model from June. 2020
M14 = stan("models/winModelClass.stan", data = datWhole, 
                 pars = c("k", "beta", "tau",
                          "log_lik", 
                          "mu_beta", "mu_k", "mu_tau"),
                 iter = 8000, warmup=4000, chains=4, cores=80, control = list(adapt_delta = 0.98))

M13 = stan("models/M13.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                             "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 10000, warmup = 4000, chains = 4, cores = 80, control = list(adapt_delta = 0.98))

M15 = stan("models/M15.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                            "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 5000, warmup = 2000, chains = 4, cores = 80, control = list(adapt_delta = 0.98))

M16 = stan("models/M16.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                            "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_
tau"),
           iter = 8000, warmup = 4000, chains = 4, cores = 80, control = list(adapt_delta = 0.982))


#older models
M1 = stan("models/M1.stan", data= datWhole, pars = c("k", "tau", 
                                                            "log_lik", "mu_k", "mu_tau"),
             iter = 10000, warmup = 4000, chains = 4, cores = 40, control = list(adapt_delta = 0.98))

M2 = stan("models/M2.stan", data= datWhole, pars = c("k", "tau", 
                                                          "log_lik", "mu_k", "mu_tau"),
          iter = 10000, warmup = 4000, chains = 4, cores = 40, control = list(adapt_delta = 0.98))

M3 = stan("models/M3.stan", data= datWhole, pars = c("k", "tau",
                                                                "log_lik", "mu_k", "mu_tau"),
              iter = 8000, warmup = 3000, chains = 4, cores = 40, control = list(adapt_delta = 0.95))

M4 = stan("models/M4.stan", data= datWhole, pars = c("k", "tau", "log_lik", "mu_k", "mu_tau"),
              iter = 8000, warmup = 3000, chains = 4, cores = 40, control = list(adapt_delta = 0.95))


M5 = stan("models/M5.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                          "mu_k", "mu_tau",  "mu_beta"),
          iter = 8000, warmup = 3000, chains = 4, cores = 40, control = list(adapt_delta = 0.95))

M6 = stan("models/M6.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                          "mu_k", "mu_tau",  "mu_beta"),
          iter = 8000, warmup = 3000, chains = 4, cores = 40, control = list(adapt_delta = 0.95))

M7 = stan("models/M7.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                                   "mu_k", "mu_tau",  "mu_beta"),
              iter = 8000, warmup = 3000, chains = 4, cores = 40, control = list(adapt_delta = 0.95))

M8 = stan("models/M8.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                               "mu_k", "mu_tau",  "mu_beta"),
          iter = 8000, warmup = 3000, chains = 4, cores = 80, control = list(adapt_delta = 0.95))

M9 = stan("models/M9.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                          "mu_k", "mu_tau",  "mu_beta"),
          iter = 8000, warmup = 3000, chains = 4, cores = 100, control = list(adapt_delta = 0.95))


M10 = stan("models/M10.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                          "mu_k", "mu_tau",  "mu_beta"),
          iter = 8000, warmup = 3000, chains = 4, cores = 100, control = list(adapt_delta = 0.95))


M11 = stan("models/M11.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                            "mu_k", "mu_tau",  "mu_beta"),
           iter = 9000, warmup = 5000, chains = 4, cores = 100, control = list(adapt_delta = 0.98))


M12 = stan("models/M12.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                            "mu_k", "mu_tau",  "mu_beta"),
           iter = 8000, warmup = 3000, chains = 4, cores = 100, control = list(adapt_delta = 0.95))




#default model
defaultM = stan("models/sdd_hyperbolic_M6_default.stan", data = datWhole, 
              pars = c("k", "tau",
                       "log_lik", 
                       "mu_tau", "mu_k"),
              iter = 10000, warmup=4000, chains=4, cores=100, control = list(adapt_delta = 0.97))


parameters <- rstan::extract(M14)
parameters <- rstan::extract(M16)

#summary statistics

sM14 <-  summary(M14, pars=c("k","tau", "beta", "eta"), probs = c(0.1, 0.9))$summary
sM16 <-  summary(M16, pars=c("k","tau", "beta", "eta"), probs = c(0.1, 0.9))$summary

#file writing
fName = paste('expm14_summary', Sys.Date(), '.csv')
write.csv(sM14, fName)

fName = paste('expm16_summary', Sys.Date(), '.csv')
write.csv(eM16, fName)

#plotting individual traceplot
traceplot(M14, pars = c("k"))
traceplot(M14, pars = c("beta"))
traceplot(M14, pars = c("eta"))

traceplot(M16, pars = c("k"))
traceplot(M16, pars = c("beta"))
traceplot(M16, pars = c("eta"))


#model comparison
loo14 = loo_model(M14)
loo16 = loo_model(M16)

comp = loo_compare(loo14, loo16)
print(comp, simplify = FALSE)


#model weighting
model_list <- list( M14, M16)
log_lik_list <- lapply(model_list, extract_log_lik)

r_eff_list <- lapply(model_list, function(x) {
  ll_array <- extract_log_lik(x, merge_chains = FALSE)
  relative_eff(exp(ll_array))
})

#stacking method:

wts1 <- loo_model_weights(log_lik_list, 
                          method = "stacking",
                          r_eff_list = r_eff_list,
                          optim_control = list(reltol=1e-10))
print(wts1)

