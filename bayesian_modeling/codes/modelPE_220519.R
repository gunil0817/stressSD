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

M17 = stan("finalModels/M17.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                       "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 6000, warmup = 2000, chains = 4, cores = 80, control = list(adapt_delta = 0.982))


M18 = stan("finalModels/M18.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                            "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 8000, warmup = 4000, chains = 4, cores = 80, control = list(adapt_delta = 0.982))

M14 = stan("finalModels/M14.stan", data = datWhole, 
                 pars = c("k", "beta", "tau",
                          "log_lik", 
                          "mu_beta", "mu_k", "mu_tau"),
                 iter = 6000, warmup=2000, chains=4, cores=80, control = list(adapt_delta = 0.98))

M13 = stan("models/M13.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                             "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 10000, warmup = 4000, chains = 4, cores = 80, control = list(adapt_delta = 0.98))

M15 = stan("finalModels/M15.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
                                                            "log_lik", "mu_k", "mu_beta", "mu_eta", "mu_tau"),
           iter = 6000, warmup = 2000, chains = 4, cores = 80, control = list(adapt_delta = 0.98))

M16 = stan("finalModels/M16.stan", data= datWhole, pars = c("k", 'beta', "tau", "eta", 
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

M7 = stan("finalModels/M7.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                                   "mu_k", "mu_tau",  "mu_beta"),
              iter = 6000, warmup = 2000, chains = 4, cores = 40, control = list(adapt_delta = 0.98))

M8 = stan("finalModels/M8.stan", data= datWhole, pars = c("k", "tau", "beta", "log_lik", 
                                                               "mu_k", "mu_tau",  "mu_beta"),
          iter = 6000, warmup = 2000, chains = 4, cores = 100, control = list(adapt_delta = 0.98))

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
              iter = 6000, warmup=2000, chains=4, cores=80, control = list(adapt_delta = 0.97))


parameters <- rstan::extract(M14)
parameters <- rstan::extract(M16)

#summary statistics

sM14 <-  summary(M14, pars=c("k","tau", "beta", "eta"), probs = c(0.1, 0.9))$summary
sM16 <-  summary(M16, pars=c("k","tau", "beta", "eta"), probs = c(0.1, 0.9))$summary
sM18 <-  summary(M18, pars=c("k","tau", "beta", "eta"), probs = c(0.1, 0.9))$summary

#file writing
fName = paste('expm14_summary', Sys.Date(), '.csv')
write.csv(sM14, fName)

fName = paste('expm16_summary', Sys.Date(), '.csv')
rite.csv(eM16, fName)

fName = paste('expm18_summary', Sys.Date(), '.csv')
write.csv(sM18, fName)


#plotting individual traceplot
traceplot(M18, pars = c("k"))
traceplot(M18, pars = c("beta"))
traceplot(M18, pars = c("eta"))

traceplot(M17, pars = c("k"))
traceplot(M17, pars = c("beta"))
traceplot(M17, pars = c("eta"))

traceplot(M16, pars = c("k"))
traceplot(M16, pars = c("beta"))
traceplot(M16, pars = c("eta"))


#model comparison

loo11 = loo_model(M11)
loo10 = loo_model(M10)
loo9 = loo_model(M9)
loo14 = loo_model(M14)
loo12 = loo_model(expdd_m12)
looM = loo_model(defaultM)
loo15 = loo_model(M15)
loo16 = loo_model(M16)
loo17 = loo_model(M17)
loo18 = loo_model(M18)
comp = loo_compare(loo9, loo10, loo11, loo12, loo14, looM, loo18)
comp = loo_compare(loo14, loo15, loo16, loo17, loo18, looM)
comp = loo_compare(looM, loo15, loo17, loo16, loo18)
print(comp, simplify = FALSE)


#model weighting
model_list <- list(M14, defaultM, M18)
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

