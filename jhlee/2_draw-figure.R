library(rstan)
library(bayesplot)
library(ggplot2)
library(tidyverse)

source("~/Github/project_stressSD/bayesian_modeling/utils/M16_simulator.R")

# FOLDER_ROOT = '/home/jhlee4991/Github/project_stressSD/' # FOLDER_EXP
# FOLDER_MODEL = sprintf('%sbayesian_modeling/', FOLDER_ROOT)
# FOLDER_STAN = sprintf('%smodels/', FOLDER_MODEL)
# FOLDER_OUTPUT = sprintf('%sstan-output/', FOLDER_MODEL)
PATH_MODEL_OUTPUT = '/data2/project_SD/model-output/'
PATH_STAN_OUTPUT = '/data2/project_SD/stan-output/'

NAME_MODEL = "M15"

FILE_MODEL_OUTPUT = sprintf('%sparam_output_%s.RData', PATH_MODEL_OUTPUT, NAME_MODEL)
FILE_OUTPUT = sprintf('%soutput_%s.RData', PATH_STAN_OUTPUT, NAME_MODEL) 
# FILE_DATA = sprintf("%sdata/SD_120_whole_n41_fairSeq.txt", FOLDER_MODEL) # behav

POI = c("mu_k", "mu_beta", "mu_tau", "mu_eta", 
        "k", "beta", "tau", "eta",
        "log_lik")

# Read data
# data <- read.table(FILE_MODEL_OUTPUT, sep = '\t', header = T)
df_param <- readRDS(FILE_MODEL_OUTPUT)
df_param <- data.frame(mu_k = df_param$mu_k,
                       mu_beta = df_param$mu_beta, 
                       mu_tau = df_param$mu_tau) 

df_param %>% 
  select(mu_k) %>% 
  ggplot() + 
  geom_jitter(aes(x=1:nrow(df_param), y=mu_k)) 
