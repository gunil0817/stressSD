rm(list = ls())  # remove7 all variables


library(rstan)
library(ggbump)
library(ggplot2)
library(viridis)
library(tidyverse)
library(tidyr)
library(dplyr)
library(latex2exp)
library(pracma)
#source("~/Github/project_stressSD/bayesian_modeling/utils/M18_simulator_figure.R")
source("C:/Users/compu/Documents/GitHub/stressSD/bayesian_modeling/utils/M18_simulator_figure.R")
# GLOBAL Variables -------------------------------------
FOLDER_ROOT = 'C:/Users/compu/Documents/GitHub/stressSD/' # FOLDER_EXP
FOLDER_MODEL = sprintf('%sbayesian_modeling/', FOLDER_ROOT)
PATH_FIGURES = 'C:/Users/compu/Documents/GitHub/stressSD/jhlee/figures'
FILE_DATA = sprintf("%sdata/SD_120_whole_n41_fairSeq.txt", FOLDER_MODEL)
NAME_MODEL = "M18"

# Read data -------------------------------------
data_behav <- read.table(FILE_DATA, sep = '\t', header = T)

# setting true values for parameters
{ 
  numTrial = 500 #144
  #K = seq(0.02,0.25,0.035) #discounting rate
  K = c(0.05) #discounting rate
  # K = 0.1
  #TAU = c(0.05, 0.1, 0.3, 0.5, 1, 1.5)
  #TAU = c(.05, 0.3, 0.5, .7, 1)
  TAU = c(.6) # tau values are pinpointed to see the dyanmics of K and beta
  # BETA = seq(0.15,1.45,0.15)
  BETA = 0.6
  # ETA = c(0.1, 0.6)
  ETA = seq(0,.8,.15)
  #BETA = seq(0.1,0.7,0.05)
  nrep = 1                   # number of repetition for now
  nump = length(ETA)
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

#creating condition-related functions
{
SD1= seq(1,100, 2)
AS = c(19, 25, 31, 37, 43, 19, 25, 31, 37, 43)
AO = c(30, 30, 30, 30, 30, 30, 30, 30, 30, 30)
AD = c(10, 10, 10, 10, 10, 10, 10, 10, 10, 10)
iq = c(20, 20, 20, 20, 20, 20, 20, 20, 20, 20)

rewards = cbind(AS,AO,AD,iq)
rewardsMat = repmat(rewards, 50, 1)
SDMat = repmat(SD1,10,1)
SDvec = as.vector(SDMat)
subID = ones

conMat = cbind(SDvec, rewardsMat)
}



# assigning conditions //

for (i in 1:nump){
  #tmpData = subset(data_behav, subjID == 1) # use the first subject data for conditions. 
  amount_self[i, 1:numTrial] = conMat[,2]
  amount_other[i, 1:numTrial] = conMat[,3]
  amount_default[i, 1:numTrial] =  conMat[,4]
  inequality[i, 1:numTrial] = conMat[,5]
  social_distance[i, 1:numTrial] = conMat[,1]
}


# fakedata input dataList
fdList <- list(
  N               = nump,
  subjID          = subID,
  amount_self     = amount_self,
  amount_other    = amount_other,
  amount_default  = amount_default,
  social_distance = social_distance,
  inequality      = inequality
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
        "psplit[counts,] = M18_simulator_psplit(dataList = fdList,
                                         k = K[k],
                                         beta = BETA[beta],
                                         tau = TAU[tau],
                                         eta = ETA[eta],
                                         nrep = 1)"
        params[counts, 1] = K[k]
        params[counts, 2] = BETA[beta]
        params[counts, 3] = TAU[tau]
        params[counts, 4] = ETA[eta]
        counts = counts + 1
      }
    }
  }
}

{
df_params <- as_tibble(params)
colnames(df_params) <- c("k", "beta", "tau", "eta")

df_social_distance <- as.data.frame(t(fdList$social_distance))
names(df_social_distance) <- gsub("V", "", names(df_social_distance))
df_social_distance <- df_social_distance %>% 
  gather(key = "subjID", value = "social_distance")}





# Social distance df 

#cNames = c('SD')
#df_social_distance <- as.data.frame(fdList$social_distance)
#names(df_social_distance) <- gsub("V", "", cNames)

#df_social_distance <- df_social_distance %>% 
#  gather(key = "subjID", value = "social_distance")

#cNames = c('k_0.01', 'k_0.045', 'k_0.08', 'k_0.115', 'k_0.15','k_0.185', 'k_0.22')
#df_SV = as.data.frame(t(SVnet))
#names(df_SV) <- gsub("V", "", cNames)

# sigmoid function 
sigmoid <- function(tau, x){
  psplit = (1/(1+exp(-tau*(x))))** 0.9998 + 0.0001  
}

# plot
# FIGURE 2A 
# for beta 
tau = 0.6
gg_beta <- cbind(df_social_distance,
      as.data.frame.table(t(SVnet)) %>% 
      mutate(SVnet = Freq) %>% 
        select(SVnet)) %>%
      #as.data.frame.table(psplit) %>% 
       # mutate(psplit = Freq) %>% 
      #  select(psplit)) %>% 
  group_by(subjID) %>% 
  summarise(
    x = social_distance,
    y = sigmoid(tau, SVnet)
    # y = psplit
  ) %>% 
  group_by(subjID,x) %>% 
  summarise(
    y = mean(y)
  ) %>% 

  ggplot(aes(x = x, y = y, color = subjID)) + 
  geom_point(size=2.5) +
  geom_line(size=1.1) + 
  coord_cartesian(ylim = c(0, 1.0)) + 
  scale_color_viridis(discrete = TRUE, 
                      name = TeX("$\\k$")) +
  xlab("Social distance") + 
  ylab("Probability split") + 
  theme_bw()+
  theme(
    text = element_text(size = 28),
      legend.position = 'none',
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
gg_beta


# Save the figure -------------------------------------
ggsave2(file.path(PATH_FIGURES, sprintf('%s_simulated_tarMore2_change.png', NAME_MODEL)), gg_beta,
        dpi = 600, width = 9, height = 9)

