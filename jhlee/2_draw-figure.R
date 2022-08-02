library(rstan)
library(bayesplot)
library(latex2exp)
library(ggplot2)
library(tidyverse)

source("~/Github/project_stressSD/bayesian_modeling/utils/M16_simulator.R")
setwd("~/Github/project_stressSD/jhlee")

# FOLDER_ROOT = '/home/jhlee4991/Github/project_stressSD/' # FOLDER_EXP
# FOLDER_MODEL = sprintf('%sbayesian_modeling/', FOLDER_ROOT)
# FOLDER_STAN = sprintf('%smodels/', FOLDER_MODEL)
# FOLDER_OUTPUT = sprintf('%sstan-output/', FOLDER_MODEL)
PATH_MODEL_OUTPUT = '/data2/project_SD/model-output/'
PATH_STAN_OUTPUT = '/data2/project_SD/stan-output/'
PATH_FIGURES = './figures'

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

# Density figure
# FIGURE 2A #
# mu_k # 
# TODO: add 95% HDI
df_param %>% 
  ggplot(aes(x = mu_k)) + 
  # coord_cartesian(xlim = c(0, 0.4)) + 
  geom_histogram(binwidth = 0.001, 
                 color="black", fill="gray") +
  geom_vline(aes(xintercept = mean(mu_k)),
             color="black", linetype="dashed", 
             size=1) + 
  geom_density(alpha = 0.5, adjust = 5) + 
  # scale_fill_viridis(discrete = TRUE) + 
  xlab(TeX("$\\k$ (Social discounting rate)"))+
  theme_bw() +
  theme(legend.position = 'none',
        legend.title = element_blank(),
        # axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line = element_line(colour = "black"),
        panel.border = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.spacing = unit(1, 'pt'),
        strip.background = element_blank())

# FIGURE 2B #
# mu_beta # 
df_param %>% 
  ggplot(aes(x = mu_beta)) + 
  # coord_cartesian(xlim = c(0, 0.4)) + 
  geom_histogram(binwidth = 0.01, 
                 color="black", fill="gray") +
  geom_vline(aes(xintercept = mean(mu_beta)),
             color="black", linetype="dashed", 
             size=1) + 
  geom_density(alpha = 0.5, adjust = 5) + 
  # scale_fill_viridis(discrete = TRUE) + 
  xlab(TeX("$\\beta$ (Reward sensitivity)"))+
  theme_bw() +
  theme(legend.position = 'none',
        legend.title = element_blank(),
        # axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line = element_line(colour = "black"),
        panel.border = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.spacing = unit(1, 'pt'),
        strip.background = element_blank())

# FIGURE 2A #
# mu_tau # 
gg_tau <- df_param %>% 
  ggplot(aes(x = mu_tau)) + 
  coord_cartesian(xlim = c(0.3, 0.8)) + 
  geom_histogram(binwidth = 0.003, 
                 color="black", fill="gray") +
  geom_vline(aes(xintercept = mean(mu_tau)),
             color="black", linetype="dashed", 
             size=1) + 
  geom_density(alpha = 0.5, adjust = 5) + 
  # scale_fill_viridis(discrete = TRUE) + 
  xlab(TeX("$\\tau$ (Inverse temperature)"))+
  theme_bw() +
  theme(legend.position = 'none',
        legend.title = element_blank(),
        # axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line = element_line(colour = "black"),
        panel.border = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        panel.spacing = unit(1, 'pt'),
        strip.background = element_blank())

# Save the figure -------------------------------------
ggsave2(file.path(PATH_FIGURES, sprintf('%s_simulated_tau.png', NAME_MODEL)), gg_tau,
        dpi = 300, width = 12, height = 9)