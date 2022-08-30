library(rstan)
library(ggbump)
library(ggplot2)
library(tidyverse)

options(mc.cores =4)

FOLDER_ROOT = '/home/jhlee4991/Github/project_stressSD/' # FOLDER_EXP
FOLDER_MODEL = sprintf('%sbayesian_modeling/', FOLDER_ROOT)
FOLDER_STAN = sprintf('%smodels/', FOLDER_MODEL)
FOLDER_OUTPUT = sprintf('%sstan-output/', FOLDER_MODEL)
MODEL_OUTPUT = sprintf('%smodel-output/', FOLDER_MODEL)

NAME_MODEL = "M18"

FILE_DATA = sprintf("%sdata/SD_120_whole_n41_fairSeq.txt", FOLDER_MODEL)
FILE_MODEL = sprintf('%s%s.stan', FOLDER_STAN, NAME_MODEL)

FILE_OUTPUT = sprintf('%soutput_%s.RData', '/data2/project_SD/stan-output/', NAME_MODEL)
FILE_MODEL_OUTPUT = sprintf('%sparam_output_%s.RData', '/data2/project_SD/model-output/', NAME_MODEL)
# FILE_MODEL_OUTPUT = sprintf('%sparam_output_%s.RData', MODEL_OUTPUT, NAME_MODEL)

POI = c("mu_k", "mu_beta", "mu_tau", "mu_eta", 
        "k", "beta", "tau", "eta",
        "log_lik")

# Read data
data <- read.table(FILE_DATA, sep = '\t', header = T)


# setting true values for parameters
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
  nump = length(unique(data$subjID))
    # length(K)*length(TAU)*length(BETA)*length(ETA) # num synthethic subject
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
  ### 
  EVO              = array(0, c(nump,numTrial))
  EVS              = array(0, c(nump,numTrial))
  psplit           = array(0, c(nump,numTrial))
} 

#assigning conditions //
for (i in 1:nump){
  tmpData = subset(data, subjID == 1) #use the first subject data for conditons. 
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
# fdList <- list(
#   N               = nump,
#   subjID          = subjID,
#   amount_self     = amount_self,
#   amount_other    = amount_other,
#   amount_default  = amount_default,
#   social_distance = social_distance,
#   inequality      = amount_other - amount_default
# )
# 
# params = array(0, c(nump, 4))
# counts = 1
# for (k in 1:length(K)){
#   for (beta in 1:length(BETA)) {
#     for (tau in 1:length(TAU)) {
#       for (eta in 1:length(ETA)) {
#         # generate the fake data for 10 subjects at given parameters.
#         # EVO[counts,] = M16_simulator_SVnet(dataList = fdList,
#         #                                    k = K[k],
#         #                                    beta = BETA[beta],
#         #                                    tau = TAU[tau],
#         #                                    eta = ETA[eta],
#         #                                    nrep = 1)
#         psplit[counts,] = M16_simulator_psplit(dataList = fdList,
#                                          k = K[k],
#                                          beta = BETA[beta],
#                                          tau = TAU[tau],
#                                          eta = ETA[eta],
#                                          nrep = 1)
#         params[counts, 1] = K[k]
#         params[counts, 2] = BETA[beta]
#         params[counts, 3] = TAU[tau]
#         params[counts, 4] = ETA[eta]
#         counts = counts + 1
#       }
#     }
#   }
# }
# 
# df_params <- as_tibble(params)
# colnames(df_params) <- c("k", "beta", "tau", "eta")
# 
# # p(split) = 1/(1+exp(-tau*(EVO-EVS))
# ### plot ### 
# sigmoid <- function(tau, x){
#   y = 1/(1+exp(-tau*(x)))
# }
# dataList %>% 
#   # group_by(as.numeric(unlist(social_distance)), 
#   #          as.numeric(unlist(amount_self)),
#   #          as.numeric(unlist(amount_other))) %>% 
#   summarize(
#     x = df_params$tau,
#     y = sigmoid(x, EVO, EVS)
#   ) %>% 
#   ggplot(aes(x = x, y = y)) + 
#   geom_line()
# 
# ### ref ### 
# f <- function(x, b0,b1,b2,b3) b0*exp(-0.5*((x-b1)/b2)^2) + b3
# 
# df.func <- df %>% 
#   group_by(group, b0, b1, b2, b3) %>% 
#   summarize(
#     x = seq(0, 20, length = 100),
#     y = f(x, b0, b1, b2, b3)
#   ) 
# df.points <- df.func %>% 
#   sample_n(10)
# 
# ggplot(df.func, aes(x = x, y = y, color = group))+ 
#   geom_line() +
#   geom_point(data = df.points)
# ### end of example 
# 
# # simple sigmoid 
# p <- ggplot(data = data.frame(x = c(1, 5, 10, 20, 50, 100)), aes(x))
# p + stat_function(fun = sigmoid, args = c(1, 10), n = 100) 
# # 
# ggplot(test,aes(x=t, y=fold))+ 
#   #to make it obvious I use argument names instead of positional matching
#   geom_point()+
#   geom_smooth(method="nls", 
#               formula=y~1+Vmax*(1-exp(-x/tau)), # this is an nls argument, 
#               #but stat_smooth passes the parameter along
#               start=c(tau=0.2,Vmax=2), # this too
#               se=FALSE) # this is an argument to stat_smooth and 
# # switches off drawing confidence intervals
# # 
# 
# print(rowSums(split)) #This summates # of prosocial decisions
# print(params)

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
df_sigmoid <- as.data.frame(unlist(social_distance),
                            unlist(amount_self),
                            unlist(amount_other),
                            unlist(split))

# model Fitting
output <-  stan(FILE_MODEL, 
           data= dataList, 
           pars = POI,
           iter = 6000, 
           warmup = 2000, 
           init = "random",
           chains = 4, 
           cores = 80, 
           control = list(adapt_delta = 0.98,
                          stepsize = 1))
save(output, file = FILE_OUTPUT)

parameters <- rstan::extract(output)
saveRDS(parameters, file = FILE_MODEL_OUTPUT)

system(sprintf("slackbot -d '@jeunghyunlee' -m 'model fitting complete - %s'", NAME_MODEL))

