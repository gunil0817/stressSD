library(rstan)
library(ggbump)
library(ggplot2)
library(viridis)
library(tidyverse)
source("~/Github/project_stressSD/bayesian_modeling/utils/M15_simulator_figure.R")
source("~/Github/project_stressSD/bayesian_modeling/utils/M16_simulator_figure.R")
source("~/Github/project_stressSD/bayesian_modeling/utils/M17_simulator_figure.R")
source("~/Github/project_stressSD/bayesian_modeling/utils/M18_simulator_figure.R")

# GLOBAL Variables -------------------------------------
FOLDER_ROOT = '/home/jhlee4991/Github/project_stressSD/' # FOLDER_EXP
FOLDER_MODEL = sprintf('%sbayesian_modeling/', FOLDER_ROOT)
FILE_DATA = sprintf("%sdata/SD_120_whole_n41_fairSeq.txt", FOLDER_MODEL)
NAME_MODEL = "M18"

# Read data -------------------------------------
data_behav <- read.table(FILE_DATA, sep = '\t', header = T)

# setting true values for parameters
{ 
  numTrial = 120 #144
  K = seq(0.01,0.2,0.02) #discounting rate
  # K = 0.1
  #TAU = c(0.05, 0.1, 0.3, 0.5, 1, 1.5)
  #TAU = c(.05, 0.3, 0.5, .7, 1)
  TAU = c(2) # tau values are pinpointed to see the dyanmics of K and beta
  # BETA = seq(0.15,1.45,0.15)
  BETA = 0.25
  # ETA = c(0.1, 0.6)
  ETA = 0
  #BETA = seq(0.1,0.7,0.05)
  nrep = 1                   # number of repetition for now
  nump = length(K)
  # length(K)*length(TAU)*length(BETA)*length(ETA) # num synthethic subject
}
# synthetic subject task conditions
{
  amount_self      = array(0, c(nump,numTrial))
  amount_other     = array(0, c(nump,numTrial))
  amount_default   = array(0, c(nump,numTrial))
  social_distance  = array(0, c(nump,numTrial))
  split            = array(0, c(nump,numTrial))
  subjID           = array((1:nump), c(nump,numTrial))
  inequality       = array(0, c(nump, numTrial))
  ### 
  EVO              = array(0, c(nump,numTrial))
  EVS              = array(0, c(nump,numTrial))
  psplit           = array(0, c(nump,numTrial))
  SVnet            = array(0, c(nump,numTrial))
} 

# assigning conditions //
for (i in 1:nump){
  tmpData = subset(data_behav, subjID == 1) # use the first subject data for conditions. 
  AO = tmpData$amount_other
  SD = tmpData$social_distance
  AS = tmpData$amount_self
  AD = tmpData$amount_default
  
  amount_self[i, 1:numTrial] = AS
  amount_other[i, 1:numTrial] = AO
  amount_default[i, 1:numTrial] =  AD
  social_distance[i, 1:numTrial] = SD
}

# fakedata input dataList
fdList <- list(
  N               = nump,
  subjID          = subjID,
  amount_self     = amount_self,
  amount_other    = amount_other,
  amount_default  = amount_default,
  social_distance = social_distance,
  inequality      = amount_other - amount_default
)

params = array(0, c(nump, 4))
counts = 1
for (k in 1:length(K)){
  for (beta in 1:length(BETA)) {
    for (tau in 1:length(TAU)) {
      for (eta in 1:length(ETA)) {
        # generate the fake data for 10 subjects at given parameters.
        SVnet[counts,] = M18_simulator_SVnet(dataList = fdList,
                                           k = K[k],
                                           beta = BETA[beta],
                                           tau = TAU[tau],
                                           eta = ETA[eta],
                                           nrep = 1)
        psplit[counts,] = M18_simulator_psplit(dataList = fdList,
                                         k = K[k],
                                         beta = BETA[beta],
                                         tau = TAU[tau],
                                         eta = ETA[eta],
                                         nrep = 1)
        params[counts, 1] = K[k]
        params[counts, 2] = BETA[beta]
        params[counts, 3] = TAU[tau]
        params[counts, 4] = ETA[eta]
        counts = counts + 1
      }
    }
  }
}

df_params <- as_tibble(params)
colnames(df_params) <- c("k", "beta", "tau", "eta")

# Social distance df 
df_social_distance <- as.data.frame(t(fdList$social_distance))
names(df_social_distance) <- gsub("V", "", names(df_social_distance))
df_social_distance <- df_social_distance %>% 
  gather(key = "subjID", value = "social_distance")

# sigmoid function 
sigmoid <- function(tau, x){
  y = 1/(1+exp(-tau*(x)))
}

# plot
# FIGURE 2A 
# for beta 
tau = 0.1
gg_beta <- cbind(df_social_distance,
      as.data.frame.table(t(SVnet)) %>% 
        mutate(SVnet = Freq) %>% 
        select(SVnet),
      as.data.frame.table(psplit) %>% 
        mutate(psplit = Freq) %>% 
        select(psplit)) %>% 
  group_by(subjID) %>% 
  summarise(
    x = social_distance,
    y = sigmoid(tau, SVnet)
    # y = psplit
  ) %>% 
  group_by(subjID, x) %>% 
  summarise(
    y = mean(y)
  ) %>% 
  ggplot(aes(x = x, y = y, color = subjID)) + 
  geom_point() + 
  geom_line() + 
  coord_cartesian(ylim = c(0, 1.0)) + 
  scale_color_viridis(discrete = TRUE, 
                      name = TeX("$\\beta$")) +
  geom_smooth(method = "nls", 
              formula = y ~ 1/(1 + exp(-tau * x)), 
              method.args = list(start = list(tau, x = social_distance)),
              se = TRUE) + 
  xlab("Social distance") + 
  ylab("Probability split") + 
  theme_bw()+
  theme(legend.position = 'none',
        legend.title = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line = element_line(colour = "black"),
        panel.border = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.spacing = unit(1, 'pt'),
        strip.background = element_blank())

# Save the figure -------------------------------------
ggsave2(file.path(PATH_FIGURES, sprintf('%s_simulated_beta_change.png', NAME_MODEL)), gg_beta,
        dpi = 300, width = 9, height = 9)

