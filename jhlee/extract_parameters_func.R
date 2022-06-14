# Load library
library(tidyverse)
library(rstan)

# This function is to extract parameter & regressors from model fit 
t_max <- 201

####### Read data #######
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

####### Function #######
# Par6 model 
extract_param_par6 <- function(pars_par6, data, save_dir){
  # Get information from data
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
  
  ## Parameters
  mu_a1 = mean(pars_par6$mu_a1)
  mu_a2 = mean(pars_par6$mu_a2)
  mu_beta1 = mean(pars_par6$mu_beta1)
  mu_beta2 = mean(pars_par6$mu_beta2)
  mu_pi = mean(pars_par6$mu_pi)
  mu_w = mean(pars_par6$mu_w)
  #mu_lambda = mean(pars_par7$mu_lambda)
  
  a1 <- c()
  a2 <- c()
  beta1 <- c()
  beta2 <- c()
  pi <- c()
  w <- c()
  #lambda <- c()
  
  for (i in 1:n_subj){
    a1[i] <- mean(pars_par6$a1[, i])
    a2[i] <- mean(pars_par6$a2[, i])
    beta1[i] <- mean(pars_par6$beta1[, i])
    beta2[i] <- mean(pars_par6$beta2[, i])
    pi[i] <- mean(pars_par6$pi[, i])
    w[i] <- mean(pars_par6$w[, i])
    #lambda[i] <- mean(pars_par7$lambda[, i])
  }
  
  ## Model regressors
  v_mb_1c <- array( -999, c(n_subj, t_max))
  v_mb_1nc <- array( -999, c(n_subj, t_max))
  v_mf_1c <- array( -999, c(n_subj, t_max))
  v_mf_1nc <- array( -999, c(n_subj, t_max))
  v_hybrid_1c <- array( -999, c(n_subj, t_max))
  v_hybrid_1nc <- array( -999, c(n_subj, t_max))
  
  v_mf_2c <- array( -999, c(n_subj, t_max))
  v_mf_2nc <- array( -999, c(n_subj, t_max))
  
  pe_1 <- array( -999, c(n_subj, t_max))
  pe_1_mb <- array( -999, c(n_subj, t_max))
  pe_2 <- array( -999, c(n_subj, t_max))
  
  pe_1_diff <- array( -999, c(n_subj, t_max))
  pe_2_diff <- array( -999, c(n_subj, t_max))
  
  p_1 <- array( -999, c(n_subj, t_max))
  p_1_diff <- array( -999, c(n_subj, t_max))
  
  for(i in 1:n_subj) {
    for(t in 1:t_subjs[i]){
      # v_mb_1c[i,trial_number[i, t]] = mean(pars_par6$v_mb_1c[,i,t])
      # v_mb_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mb_1nc[,i,t])
      # v_mf_1c[i,trial_number[i, t]] = mean(pars_par6$v_mf_1c[,i,t])
      # v_mf_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_1nc[,i,t])
      # v_hybrid_1c[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1c[,i,t])
      # v_hybrid_1nc[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1nc[,i,t])
      # 
      # v_mf_2c[i,trial_number[i, t]] = mean(pars_par6$v_mf_2c[,i,t])
      # v_mf_2nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_2nc[,i,t])
      
      pe_1[i,trial_number[i, t]] = mean(pars_par6$pe_1[,i,t])
      pe_1_mb[i,trial_number[i, t]] = mean(pars_par6$pe_1_mb[,i,t])
      pe_2[i,trial_number[i, t]] = mean(pars_par6$pe_2[,i,t])
      pe_1_diff[i,trial_number[i, t]] = mean(pars_par6$pe_1_diff[,i,t])
      pe_2_diff[i,trial_number[i, t]] = mean(pars_par6$pe_2_diff[,i,t])
      p_1[i,trial_number[i, t]] = mean(pars_par6$p_1[,i,t])
      p_1_diff[i,trial_number[i, t]] = mean(pars_par6$p_1_diff[,i,t])
    }
  }
  
  subjectID <- unique(data$subjID)
  
  for(i in 1:length(subjectID)) {
    # state value 
    # df_state_value = cbind(v_mb_1c[i,], v_mb_1nc[i,], v_mf_1c[i,], v_mf_1nc[i,], v_hybrid_1c[i,], v_hybrid_1nc[i,],
    #                        v_mf_2c[i,], v_mf_2nc[i,])
    # colnames(df_state_value) <- c("v_mb_1c", "v_mb_1nc", "v_mf_1c", "v_mf_1nc", "v_hybrid_1c", "v_hybrid_1nc",
    #                               "v_mf_2c", "v_mf_2nc")
    # df <- data.frame(df_state_value)
    # write_tsv(df, path = paste0(save_dir, "/state_value/sub-", subjectID[i], ".txt"))
    
    # prediction error 
    df_pe = cbind(pe_1[i,], pe_1_mb[i,], pe_2[i,], pe_1_diff[i,], pe_2_diff[i,], p_1[i,], p_1_diff[i,])
    colnames(df_pe) <- c("pe_1", "pe_1_mb", "pe_2", "pe_1_diff", "pe_2_diff", "p_1", "p_1_diff")
    df <- data.frame(df_pe)
    write_tsv(df, path = paste0(save_dir, "/prediction_error/sub-", subjectID[i], ".txt"))
  }
  
  ind_par_group <- cbind(subjectID, a1, a2, beta1, beta2, pi, w)   
  return(ind_par_group)
}



# SW model 
extract_param_par7_SW <- function(pars_par6, data, save_dir){
  # Get information from data
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
  
  ## Parameters
  mu_a1 = mean(pars_par6$mu_a1)
  mu_a2 = mean(pars_par6$mu_a2)
  mu_beta1 = mean(pars_par6$mu_beta1)
  mu_beta2 = mean(pars_par6$mu_beta2)
  mu_pi = mean(pars_par6$mu_pi)
  mu_wm = mean(pars_par6$mu_wm)
  mu_wp = mean(pars_par6$mu_wp)
  
  
  a1 <- c()
  a2 <- c()
  beta1 <- c()
  beta2 <- c()
  pi <- c()
  wm <- c()
  wp <- c()
  
  
  for (i in 1:n_subj){
    a1[i] <- mean(pars_par6$a1[, i])
    a2[i] <- mean(pars_par6$a2[, i])
    beta1[i] <- mean(pars_par6$beta1[, i])
    beta2[i] <- mean(pars_par6$beta2[, i])
    pi[i] <- mean(pars_par6$pi[, i])
    wm[i] <- mean(pars_par6$wm[, i])
    wp[i] <- mean(pars_par6$wp[, i])
  }
  
  ## Model regressors
  # v_mb_1c <- array( -999, c(n_subj, t_max))
  # v_mb_1nc <- array( -999, c(n_subj, t_max))
  # v_mf_1c <- array( -999, c(n_subj, t_max))
  # v_mf_1nc <- array( -999, c(n_subj, t_max))
  # v_hybrid_1c <- array( -999, c(n_subj, t_max))
  # v_hybrid_1nc <- array( -999, c(n_subj, t_max))
  # 
  # v_mf_2c <- array( -999, c(n_subj, t_max))
  # v_mf_2nc <- array( -999, c(n_subj, t_max))
  
  pe_1 <- array( -999, c(n_subj, t_max))
  pe_1_mb <- array( -999, c(n_subj, t_max))
  pe_2 <- array( -999, c(n_subj, t_max))
  
  pe_1_diff <- array( -999, c(n_subj, t_max))
  pe_2_diff <- array( -999, c(n_subj, t_max))
  
  p_1 <- array( -999, c(n_subj, t_max))
  p_1_diff <- array( -999, c(n_subj, t_max))
  
  for(i in 1:n_subj) {
    for(t in 1:t_subjs[i]){
      # v_mb_1c[i,trial_number[i, t]] = mean(pars_par6$v_mb_1c[,i,t])
      # v_mb_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mb_1nc[,i,t])
      # v_mf_1c[i,trial_number[i, t]] = mean(pars_par6$v_mf_1c[,i,t])
      # v_mf_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_1nc[,i,t])
      # v_hybrid_1c[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1c[,i,t])
      # v_hybrid_1nc[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1nc[,i,t])
      # 
      # v_mf_2c[i,trial_number[i, t]] = mean(pars_par6$v_mf_2c[,i,t])
      # v_mf_2nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_2nc[,i,t])
      
      pe_1[i,trial_number[i, t]] = mean(pars_par6$pe_1[,i,t])
      pe_1_mb[i,trial_number[i, t]] = mean(pars_par6$pe_1_mb[,i,t])
      pe_2[i,trial_number[i, t]] = mean(pars_par6$pe_2[,i,t])
      pe_1_diff[i,trial_number[i, t]] = mean(pars_par6$pe_1_diff[,i,t])
      pe_2_diff[i,trial_number[i, t]] = mean(pars_par6$pe_2_diff[,i,t])
      p_1[i,trial_number[i, t]] = mean(pars_par6$p_1[,i,t])
      p_1_diff[i,trial_number[i, t]] = mean(pars_par6$p_1_diff[,i,t])
    }
  }
  
  subjectID <- unique(data$subjID)
  
  for(i in 1:length(subjectID)) {
    # state value 
    # df_state_value = cbind(v_mb_1c[i,], v_mb_1nc[i,], v_mf_1c[i,], v_mf_1nc[i,], v_hybrid_1c[i,], v_hybrid_1nc[i,],
    #                        v_mf_2c[i,], v_mf_2nc[i,])
    # colnames(df_state_value) <- c("v_mb_1c", "v_mb_1nc", "v_mf_1c", "v_mf_1nc", "v_hybrid_1c", "v_hybrid_1nc",
    #                               "v_mf_2c", "v_mf_2nc")
    # df <- data.frame(df_state_value)
    # write_tsv(df, path = paste0(save_dir, "/state_value/sub-", subjectID[i], ".txt"))
    
    # prediction error 
    df_pe = cbind(pe_1[i,], pe_1_mb[i,], pe_2[i,], pe_1_diff[i,], pe_2_diff[i,], p_1[i,], p_1_diff[i,])
    colnames(df_pe) <- c("pe_1", "pe_1_mb", "pe_2", "pe_1_diff", "pe_2_diff", "p_1", "p_1_diff")
    df <- data.frame(df_pe)
    write_tsv(df, path = paste0(save_dir, "/prediction_error/sub-", subjectID[i], ".txt"))
  }
  
  ind_par_group <- cbind(subjectID, a1, a2, beta1, beta2, pi, wm, wp)   
  return(ind_par_group)
}



# SW_alp model 
extract_param_SW_alp <- function(pars_par6, data, save_dir){
  # Get information from data
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
  
  ## Parameters
  mu_a1_pos = mean(pars_par6$mu_a1_pos)
  mu_a1_neg = mean(pars_par6$mu_a1_neg)
  mu_a2_pos = mean(pars_par6$mu_a2_pos)
  mu_a2_neg = mean(pars_par6$mu_a2_neg)
  mu_beta1 = mean(pars_par6$mu_beta1)
  mu_beta2 = mean(pars_par6$mu_beta2)
  mu_pi = mean(pars_par6$mu_pi)
  mu_wm = mean(pars_par6$mu_wm)
  mu_wp = mean(pars_par6$mu_wp)
  
  
  a1_pos <- c()
  a1_neg <- c()
  a2_pos <- c()
  a2_neg <- c()
  beta1 <- c()
  beta2 <- c()
  pi <- c()
  wm <- c()
  wp <- c()
  
  
  for (i in 1:n_subj){
    a1_pos[i] <- mean(pars_par6$a1_pos[, i])
    a1_neg[i] <- mean(pars_par6$a1_neg[, i])
    a2_pos[i] <- mean(pars_par6$a2_pos[, i])
    a2_neg[i] <- mean(pars_par6$a2_neg[, i])
    beta1[i] <- mean(pars_par6$beta1[, i])
    beta2[i] <- mean(pars_par6$beta2[, i])
    pi[i] <- mean(pars_par6$pi[, i])
    wm[i] <- mean(pars_par6$wm[, i])
    wp[i] <- mean(pars_par6$wp[, i])
  }
  
  ## Model regressors
  # v_mb_1c <- array( -999, c(n_subj, t_max))
  # v_mb_1nc <- array( -999, c(n_subj, t_max))
  # v_mf_1c <- array( -999, c(n_subj, t_max))
  # v_mf_1nc <- array( -999, c(n_subj, t_max))
  # v_hybrid_1c <- array( -999, c(n_subj, t_max))
  # v_hybrid_1nc <- array( -999, c(n_subj, t_max))
  # 
  # v_mf_2c <- array( -999, c(n_subj, t_max))
  # v_mf_2nc <- array( -999, c(n_subj, t_max))
  
  pe_1 <- array( -999, c(n_subj, t_max))
  pe_1_mb <- array( -999, c(n_subj, t_max))
  pe_2 <- array( -999, c(n_subj, t_max))
  
  pe_1_diff <- array( -999, c(n_subj, t_max))
  pe_2_diff <- array( -999, c(n_subj, t_max))
  
  p_1 <- array( -999, c(n_subj, t_max))
  p_1_diff <- array( -999, c(n_subj, t_max))
  
  for(i in 1:n_subj) {
    for(t in 1:t_subjs[i]){
      # v_mb_1c[i,trial_number[i, t]] = mean(pars_par6$v_mb_1c[,i,t])
      # v_mb_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mb_1nc[,i,t])
      # v_mf_1c[i,trial_number[i, t]] = mean(pars_par6$v_mf_1c[,i,t])
      # v_mf_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_1nc[,i,t])
      # v_hybrid_1c[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1c[,i,t])
      # v_hybrid_1nc[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1nc[,i,t])
      # 
      # v_mf_2c[i,trial_number[i, t]] = mean(pars_par6$v_mf_2c[,i,t])
      # v_mf_2nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_2nc[,i,t])
      
      pe_1[i,trial_number[i, t]] = mean(pars_par6$pe_1[,i,t])
      pe_1_mb[i,trial_number[i, t]] = mean(pars_par6$pe_1_mb[,i,t])
      pe_2[i,trial_number[i, t]] = mean(pars_par6$pe_2[,i,t])
      pe_1_diff[i,trial_number[i, t]] = mean(pars_par6$pe_1_diff[,i,t])
      pe_2_diff[i,trial_number[i, t]] = mean(pars_par6$pe_2_diff[,i,t])
      p_1[i,trial_number[i, t]] = mean(pars_par6$p_1[,i,t])
      p_1_diff[i,trial_number[i, t]] = mean(pars_par6$p_1_diff[,i,t])
    }
  }
  
  subjectID <- unique(data$subjID)
  
  for(i in 1:length(subjectID)) {
    # state value 
    # df_state_value = cbind(v_mb_1c[i,], v_mb_1nc[i,], v_mf_1c[i,], v_mf_1nc[i,], v_hybrid_1c[i,], v_hybrid_1nc[i,],
    #                        v_mf_2c[i,], v_mf_2nc[i,])
    # colnames(df_state_value) <- c("v_mb_1c", "v_mb_1nc", "v_mf_1c", "v_mf_1nc", "v_hybrid_1c", "v_hybrid_1nc",
    #                               "v_mf_2c", "v_mf_2nc")
    # df <- data.frame(df_state_value)
    # write_tsv(df, path = paste0(save_dir, "/state_value/sub-", subjectID[i], ".txt"))
    
    # prediction error 
    df_pe = cbind(pe_1[i,], pe_1_mb[i,], pe_2[i,], pe_1_diff[i,], pe_2_diff[i,], p_1[i,], p_1_diff[i,])
    colnames(df_pe) <- c("pe_1", "pe_1_mb", "pe_2", "pe_1_diff", "pe_2_diff", "p_1", "p_1_diff")
    df <- data.frame(df_pe)
    write_tsv(df, path = paste0(save_dir, "/prediction_error/sub-", subjectID[i], ".txt"))
  }
  
  ind_par_group <- cbind(subjectID, a1_pos, a1_neg, a2_pos, a2_neg, beta1, beta2, pi, wm, wp)   
  return(ind_par_group)
}


# SW_alp_par7 model 
extract_param_SW_alp_par7 <- function(pars_par6, data, save_dir){
  # Get information from data
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
  
  ## Parameters
  mu_a_pos = mean(pars_par6$mu_a_pos)
  mu_a_neg = mean(pars_par6$mu_a_neg)
  mu_beta1 = mean(pars_par6$mu_beta1)
  mu_beta2 = mean(pars_par6$mu_beta2)
  mu_pi = mean(pars_par6$mu_pi)
  mu_wm = mean(pars_par6$mu_wm)
  mu_wp = mean(pars_par6$mu_wp)
  
  
  a_pos <- c()
  a_neg <- c()
  beta1 <- c()
  beta2 <- c()
  pi <- c()
  wm <- c()
  wp <- c()
  
  
  for (i in 1:n_subj){
    a_pos[i] <- mean(pars_par6$a_pos[, i])
    a_neg[i] <- mean(pars_par6$a_neg[, i])
    beta1[i] <- mean(pars_par6$beta1[, i])
    beta2[i] <- mean(pars_par6$beta2[, i])
    pi[i] <- mean(pars_par6$pi[, i])
    wm[i] <- mean(pars_par6$wm[, i])
    wp[i] <- mean(pars_par6$wp[, i])
  }
  
  ## Model regressors
  # v_mb_1c <- array( -999, c(n_subj, t_max))
  # v_mb_1nc <- array( -999, c(n_subj, t_max))
  # v_mf_1c <- array( -999, c(n_subj, t_max))
  # v_mf_1nc <- array( -999, c(n_subj, t_max))
  # v_hybrid_1c <- array( -999, c(n_subj, t_max))
  # v_hybrid_1nc <- array( -999, c(n_subj, t_max))
  # 
  # v_mf_2c <- array( -999, c(n_subj, t_max))
  # v_mf_2nc <- array( -999, c(n_subj, t_max))
  
  pe_1 <- array( -999, c(n_subj, t_max))
  pe_1_mb <- array( -999, c(n_subj, t_max))
  pe_2 <- array( -999, c(n_subj, t_max))
  
  pe_1_diff <- array( -999, c(n_subj, t_max))
  pe_2_diff <- array( -999, c(n_subj, t_max))
  
  p_1 <- array( -999, c(n_subj, t_max))
  p_1_diff <- array( -999, c(n_subj, t_max))
  
  for(i in 1:n_subj) {
    for(t in 1:t_subjs[i]){
      # v_mb_1c[i,trial_number[i, t]] = mean(pars_par6$v_mb_1c[,i,t])
      # v_mb_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mb_1nc[,i,t])
      # v_mf_1c[i,trial_number[i, t]] = mean(pars_par6$v_mf_1c[,i,t])
      # v_mf_1nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_1nc[,i,t])
      # v_hybrid_1c[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1c[,i,t])
      # v_hybrid_1nc[i,trial_number[i, t]] = mean(pars_par6$v_hybrid_1nc[,i,t])
      # 
      # v_mf_2c[i,trial_number[i, t]] = mean(pars_par6$v_mf_2c[,i,t])
      # v_mf_2nc[i,trial_number[i, t]] = mean(pars_par6$v_mf_2nc[,i,t])
      
      pe_1[i,trial_number[i, t]] = mean(pars_par6$pe_1[,i,t])
      pe_1_mb[i,trial_number[i, t]] = mean(pars_par6$pe_1_mb[,i,t])
      pe_2[i,trial_number[i, t]] = mean(pars_par6$pe_2[,i,t])
      pe_1_diff[i,trial_number[i, t]] = mean(pars_par6$pe_1_diff[,i,t])
      pe_2_diff[i,trial_number[i, t]] = mean(pars_par6$pe_2_diff[,i,t])
      p_1[i,trial_number[i, t]] = mean(pars_par6$p_1[,i,t])
      p_1_diff[i,trial_number[i, t]] = mean(pars_par6$p_1_diff[,i,t])
    }
  }
  
  subjectID <- unique(data$subjID)
  
  for(i in 1:length(subjectID)) {
    # state value 
    # df_state_value = cbind(v_mb_1c[i,], v_mb_1nc[i,], v_mf_1c[i,], v_mf_1nc[i,], v_hybrid_1c[i,], v_hybrid_1nc[i,],
    #                        v_mf_2c[i,], v_mf_2nc[i,])
    # colnames(df_state_value) <- c("v_mb_1c", "v_mb_1nc", "v_mf_1c", "v_mf_1nc", "v_hybrid_1c", "v_hybrid_1nc",
    #                               "v_mf_2c", "v_mf_2nc")
    # df <- data.frame(df_state_value)
    # write_tsv(df, path = paste0(save_dir, "/state_value/sub-", subjectID[i], ".txt"))
    
    # prediction error 
    df_pe = cbind(pe_1[i,], pe_1_mb[i,], pe_2[i,], pe_1_diff[i,], pe_2_diff[i,], p_1[i,], p_1_diff[i,])
    colnames(df_pe) <- c("pe_1", "pe_1_mb", "pe_2", "pe_1_diff", "pe_2_diff", "p_1", "p_1_diff")
    df <- data.frame(df_pe)
    write_tsv(df, path = paste0(save_dir, "/prediction_error/sub-", subjectID[i], ".txt"))
  }
  
  ind_par_group <- cbind(subjectID, a_pos, a_neg, beta1, beta2, pi, wm, wp)   
  return(ind_par_group)
}


############################################
# Get R hat 
get_Rhat <- function(fit, model_pars){
  # fit: model fit outcomes (rstan) 
  # model_pars: model parameters you want to check the R hat 
  
  s <- rstan::summary(fit)
  
  ss <- s$summary
  ss <- data.frame(ss)
  
  # model_pars <- fit@model_pars
  # tmp_idx <- which(model_pars == 'log_lik')
  # model_pars <- model_pars[1:tmp_idx-1]
  
  df_rhat <- data.frame()
  for (m in 1:length(model_pars)){
    rhat_sum <- ss %>% 
      dplyr::filter(str_detect(row.names(ss), paste0('^',model_pars[m]))) %>% 
      dplyr::select(Rhat)
      
    df_rhat <- rbind(df_rhat, rhat_sum)
  }
  
  exceed <- ss %>% filter(Rhat > 1.05) %>% dplyr::select(n_eff, Rhat)
  if (nrow(exceed) > 0){
    print('rhat > 1.05')
    print(exceed)
  } else {
    print('all rhat values =< 1.05')
  }
  
  return(df_rhat)
}

