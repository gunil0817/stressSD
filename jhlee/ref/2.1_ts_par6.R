# Setup
library(rstan)
library(tidyverse)
library(loo)

setwd('/home/minakwon/github_repo/project_ts_fMRI/modeling/')
saveDir <- '/data/project_ts_yonsei/modeling_data/'

# exclude 2 outliers, based on survey response ("sub-10019" "sub-10021")
outlier_file <- file.path('../subject_list/subject_outlier.csv')
outlier_list <- read.csv(outlier_file) %>%
  # filter(reason == 'survey') %>%
  mutate(subjID = str_replace(subjID, 'sub-', '')) %>%
  pull(subjID)

####### Read data #######
data_healthy <- read.table("../behavioral_data/preprocessed/data_healthy.txt", sep = '\t', header = T) %>% filter(!subjID %in% outlier_list)
data_alcohol <- read.table("../behavioral_data/preprocessed/data_alcohol.txt", sep = '\t', header = T) %>% filter(!subjID %in% outlier_list)
data_gaming <- read.table("../behavioral_data/preprocessed/data_gaming.txt", sep = '\t', header = T) %>% filter(!subjID %in% outlier_list)

####### model parameters & estimates ####### 
POI6 <- c("mu_a1", "mu_a2", "mu_beta1", "mu_beta2", "mu_pi", "mu_w",
          "sigma",
          "a1", "a2", "beta1", "beta2", "pi", "w",
          # "v_mb_1c", "v_mb_1nc", "v_mf_1c", "v_mf_1nc",
          # "v_hybrid_1c", "v_hybrid_1nc", "v_mf_2c", "v_mf_2nc",
          "pe_1", "pe_1_mb", "pe_2", "pe_1_diff", "pe_2_diff", "p_1", "p_1_diff",
          "log_lik")

DATA = list(data_healthy, data_alcohol, data_gaming)
GROUP = c('healthy', 'alcohol', 'gaming')
# g = 1
for (g in 1:length(DATA)){
  # Process Data! 
  group = GROUP[g]
  print(group)
  
  data = DATA[[g]]
  
  n_subj = length(unique(data$subjID))
  trials <- data %>% group_by(subjID) %>% summarise(count=n())
  t_max = max(trials$count)
  t_subjs = array(trials$count)
  trans_prob = 0.7
  
  level1_choice <- array( 0, c(n_subj, t_max))
  level2_choice <- array( 0, c(n_subj, t_max))
  reward        <- array( 0, c(n_subj, t_max))
  trial_number <- array( 0, c(n_subj, t_max))
  
  row = 0
  for (i in 1:n_subj) {
    for (t in 1:t_subjs[i]){
      row = row + 1
      
      level1_choice[i, t]  <- data$level1_choice[row]
      level2_choice[i, t]  <- data$level2_choice[row]
      reward[i, t]         <- data$reward[row]
      trial_number[i, t] <- data$trial_number[row]
    }
  }

  data_list <- list(
    N             = n_subj,
    T             = t_max,
    Tsubj         = t_subjs,
    level1_choice = level1_choice,
    level2_choice = level2_choice,
    reward        = reward,
    trans_prob    = trans_prob
  )
  
  options(mc.cores = 4)
  
  # FIT MODEL! 
  m_par6 = stan_model(file = "./ts_par6.stan", model_name = "ts_par6")
  
  fit_par6 <- sampling(m_par6, 
                       data = data_list,
                       pars = POI6,
                       chains = 4,
                       # iter = 20, 
                       # warmup = 5,
                       iter = 4000,
                       warmup = 2000,
                       init = "random",
                       thin = 1,
                       control = list(adapt_delta   = 0.95,
                                      max_treedepth = 10,
                                      stepsize      = 1))
  
  savename <- file.path(saveDir, paste0('fit_par6_', group, '.RData'))
  save(fit_par6, file = savename)
  
}

system("slackbot -d '@minakwon' -m '2_ts_par6.R done!'")
