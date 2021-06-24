
clear all

list_trt = dir('D:\StressTask\behvData\120TrialVersion\*_BTA*.mat');
baseDir = list_trt(1).folder;
varNames = {'subjID', 'social_distance', 'amount_self', 'amount_other', 'amount_default', 'choice'};
trtData = zeros(120*length(list_trt), 6);
load('D:\StressTask\behvData\n18_parameters.mat')
param = [parameters.k, parameters.tau, parameters.beta];
%for 18 subj
trtSubj = [1 1 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0];

%% group differences
k_trt = parameters.k(trtSubj == 1);
tau_trt = parameters.tau(trtSubj == 1);
beta_trt = parameters.beta(trtSubj == 1);

k_con = parameters.k(trtSubj == 0);
tau_con = parameters.tau(trtSubj == 0);
beta_con = parameters.beta(trtSubj == 0);



for subjs = 1:length(list_trt)
    
    fairseq   = zeros(120,1);
    unfairseq = zeros(120,1);
    
    subjFileName = list_trt(subjs).name;
    load(fullfile(baseDir, subjFileName)); % load subject data
        
    %setting experimentData as data
    data = trialData.gameData;

    %column 1, subj ID
    subjID = ones(size(data,1)*(subjs),1);
    %column 2, social distance
    social_distance = data(:,8);
    
    social_distance(social_distance == 50) = 100;
    social_distance(social_distance == 20) = 50;
    social_distance(social_distance == 10) = 20;
    social_distance(social_distance == 5) = 10;
    social_distance(social_distance == 3) = 5;

    %Column 3 amount_self
    amount_self = data(:,9);

    %Column 4 amount_other
    %Column 5 amount_default
    for counts = 1:length(blockseq)
        if rem(blockseq(counts),2) == 0
            unfairseq(1+(counts-1)*30:counts*30) = 1;
            fairseq(1+(counts-1)*30:counts*30) = 0;
        else
            unfairseq(1+(counts-1)*30:counts*30) = 0;
            fairseq(1+(counts-1)*30:counts*30) = 1;
        end
    end
    amount_default = 20.*fairseq +  10.*unfairseq;
    amount_other = 20.*fairseq +  30.*unfairseq;
    
    %[SV, ACC] = m14_SV(trialData, param(subjs,:),blockseq);
    %SV(:,1) = ev_self, SV(:,2) = ev_other, SV(:,3), pSplit
    
    %setting response
    resp = data(:,7);
    
    %Column 6 choice
    resp(resp == -1) = 0;
    %shifting selfish decision yes to prosocial decision yes. 
    incents = resp;
    split = resp.*-1 +1;
    choice = split;   
    onsetTime = cell(1,12); %defining size of the onsetTime file. 
    
    if subjs > 9
       subjnum = strcat('sub0', num2str(subjs));
    else
       subjnum = strcat('sub00', num2str(subjs));
    end
    
    
    
    valDiff = (amount_default + amount_other) - amount_self;
    valDiffOne = amount_default + amount_self - amount_other;
    valDiffTwo = (amount_other + amount_default - amount_self)./social_distance  - amount_self;
    
    shareValDiff  = valDiff(split   >0);
    incentValDiff = valDiff(incents >0);
    mAS = amount_self - mean(amount_self);
    
    SV_Diff2 = valDiffTwo(split  >0);
    shareOther = amount_other(split>0) + amount_default(split>0);
    
    IV_Diff2 = valDiffTwo(incents>0);
    incentSelf = amount_self(incents>0);
    %fMRI onsetTime
    mrOnset = trialData.time.fMRIStartTime;
    tempTime = (trialData.gameData(:,3:6)-mrOnset)./1000; 
    
    tempDecisionTime = tempTime(:,3);
    shareOnset = tempDecisionTime(split > 0);
    incentOnset = tempDecisionTime(incents > 0);
        
    onsetTime{1} = tempTime(:,1); %fixation
    onsetTime{2} = tempTime(:,2); %name appear
    onsetTime{3} = tempTime(:,3); %incentive appear
    onsetTime{4} = shareOnset;
    onsetTime{5} = incentOnset;
    onsetTime{6} = social_distance - mean(social_distance);
%   onsetTime{7} = shareEVO;
%   onsetTime{8} = shareEVS;
%   onsetTime{9} = selfEVO;
%   onsetTime{10} = selfEVS;
    onsetTime{7} = amount_self - mean(amount_self);
    onsetTime{8} = shareValDiff - mean(shareValDiff);
    onsetTime{9} = incentValDiff - mean(incentValDiff);
    onsetTime{10} = valDiff - mean(valDiff);
    onsetTime{11} = amount_default-mean(amount_default); 
    onsetTime{12} = amount_other-mean(amount_other);
    onsetTime{13} = valDiffTwo - mean(valDiffTwo);
    onsetTime{14} = choice;
    onsetTime{15} = SV_Diff2 - mean(SV_Diff2);
    onsetTime{16} = IV_Diff2 - mean(IV_Diff2);
    onsetTime{17} = incentSelf - mean(incentSelf);
    onsetTime{18} = shareOther - mean(shareOther);
%     onsetTime{17} = SV(:,1)-mean(SV(:,1)); %SV_self
%     onsetTime{18} = SV(:,2)-mean(SV(:,2)); %SV_other
%     onsetTime{19} = SV(:,2)-SV(:,1)-mean(SV(:,2)-SV(:,1)); %SV_other
%     onsetTime{20} = SV(:,3)-mean(SV(:,3)); %SV_psplit
    
    %so, 1 is fix, 2 is name, 3 is incent, 4 is decision 5 is incent to resp.
    
    fileName = strcat('D:\StressTask\onsetFiles','\onsetFile_',subjnum,'.mat');
    save(fileName, 'onsetTime')
end
