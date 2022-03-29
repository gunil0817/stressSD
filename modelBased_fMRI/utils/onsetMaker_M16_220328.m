%this onest

clear all
list_trt = dir('E:\StressTask\behvData\120TrialVersion\*_BTA*.mat');
baseDir = list_trt(1).folder;
varNames = {'subjID', 'social_distance', 'amount_self', 'amount_other', 'amount_default', 'choice'};
trtData = zeros(120*length(list_trt), 6);
%load('D:\StressTask\behvData\n18_parameters.mat')

%parameters Load
load('E:\StressTask\Round4\behvData\M16_parameters_220328.mat')
param = [M16.k, M16.tau,M16.beta, M16.eta]; %k, tau, beta, eta
%% group differences
for subjs = 1:length(list_trt)
    %initlalization
    fairseq   = zeros(120,1);
    unfairseq = zeros(120,1);
    cf = zeros(120,1); %close friends
    do = zeros(120,1); %distance others
    ac = zeros(120,1); %acquintance
    onsetTime = cell(1,12); %defining size of the onsetTime file. 
    
    if subjs > 9
       subjnum = strcat('sub0', num2str(subjs));
    else
       subjnum = strcat('sub00', num2str(subjs));
    end

    subjFileName = list_trt(subjs).name;
    load(fullfile(baseDir, subjFileName)); % load subject data
        
    %setting experimentData as data
    data = trialData.gameData;
    subjID = ones(size(data,1)*(subjs),1);
    social_distance = data(:,8);
    
    social_distance(social_distance == 50) = 100;
    social_distance(social_distance == 20) = 50;
    social_distance(social_distance == 10) = 20;
    social_distance(social_distance == 5) = 10;
    social_distance(social_distance == 3) = 5;
    
    cf(social_distance == 1 | social_distance == 5) = 1;
    do(social_distance == 50 | social_distance == 100) = 1;
    ac(social_distance == 10 | social_distance == 20) = 1;
    

    [SV, ACC] = expm16_SV(trialData, param(subjs,:),blockseq);
    %SV(:,1) = ev_self, SV(:,2) = ev_other, SV(:,3), pSplit
    ev_self = SV(:,1);
    ev_other = SV(:,2);
    P = SV(:,3);
    

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

    %setting response
    resp = data(:,7);
    %Column 6 choice
    resp(resp == -1) = 0;
    %shifting selfish decision yes to prosocial decision yes. 
    incents = resp;
    split = resp.*-1 +1;
    
    %value computations 
    otherAmount = amount_other./social_distance;
    amountSelf = amount_self - mean(amount_self);
    
    %split it to share vs selfish choices
    valDiffSD = (amount_other)./social_distance  - (amount_self- amount_default);
    SV_DiffSD = valDiffSD(split  >0);
    IV_DiffSD = valDiffSD(incents>0);
    
    %split it to 
    cf_valDiffSD = valDiffSD(cf>0);
    ac_valDiffSD = valDiffSD(ac>0);
    do_valDiffSD = valDiffSD(do>0);
    
    %fairDecision & unfairDecision
    fa_valDiffSD = valDiffSD(fairseq>0);
    uf_valDiffSD = valDiffSD(unfairseq>0);
    
    
    %fMRI onsetTime
    mrOnset = trialData.time.fMRIStartTime;
    tempTime = (trialData.gameData(:,3:6)-mrOnset)./1000; 
    
    %onsetTime : SI
    tempDecisionTime = tempTime(:,3);
    shareOnset = tempDecisionTime(split > 0);
    incentOnset = tempDecisionTime(incents > 0);
    closeOnset = tempDecisionTime(cf > 0);
    acqunOnset = tempDecisionTime(ac > 0);
    distoOnset = tempDecisionTime(do > 0);
    fairOnset = tempDecisionTime(fairseq>0);
    unfaOnset = tempDecisionTime(unfairseq>0);
    
    fairEVO = ev_other(fairseq > 0);
    fairEVS = ev_self(fairseq > 0);
    unfairEVO = ev_other(unfairseq > 0);
    unfairEVS = ev_self(unfairseq > 0);


    fsV = ev_other (fairseq == 1 & split == 1);
    fiV = ev_self (fairseq == 1 & split == 0);
    ufsV = ev_other (fairseq == 0 & split == 1);
    ufiV = ev_self (fairseq == 0 & split == 0);

    %split vs selfish
    shareEVO = ev_other(split>0);
    shareEVS = ev_self(split>0);
    shareP = P(split>0);
    selfEVO = ev_other(incents>0);
    selfEVS = ev_self(incents>0);
    selfP =  P(incents>0);

    chosenVal = ev_other.*split + ev_self.* incents;
    evDiff    = SV(:,2) - SV(:,1);


    %response
    fairResp = split(fairseq>0);
    unfaResp = split(unfairseq>0);

    fairSplit = fairOnset(fairResp>0);
    fairIncent = fairOnset(fairResp==0);
    unfairSplit = unfaOnset(unfaResp>0);
    unfairIncent = unfaOnset(unfaResp==0);
    
    fs = social_distance (fairseq == 1 & split == 1);
    fi = social_distance (fairseq == 1 & split == 0);
    ufs = social_distance (fairseq == 0 & split == 1);
    ufi = social_distance (fairseq == 0 & split == 0);

    fs = fs - mean(fs);
    fi = fi - mean(fi);
    ufs = ufs - mean(ufs);
    ufi = ufi - mean(ufi);
    
    %onsetTime : Motor
    tempMotorTime = tempTime(:,4);
    shareMotorOnset = tempMotorTime(split > 0);
    incentMotorOnset = tempMotorTime(incents > 0);
        
    onsetTime{1} = tempTime(:,1); %fixation
    onsetTime{2} = tempTime(:,2); %name appear
    onsetTime{3} = tempTime(:,3); %incentive appear
    onsetTime{4} = tempTime(:,4); %motor appear
    onsetTime{5} = incentOnset; 
    onsetTime{6} = shareOnset;
    onsetTime{7} = SV(:,1) - mean(SV(:,1));
    onsetTime{8} = SV(:,2) - mean(SV(:,2));
    onsetTime{9} = closeOnset;
    onsetTime{10} = acqunOnset;
    onsetTime{11} = distoOnset;
    onsetTime{12} = cf_valDiffSD;
    onsetTime{13} = ac_valDiffSD;
    onsetTime{14} = do_valDiffSD;
    onsetTime{15} = fairOnset;
    onsetTime{16} = unfaOnset;
    onsetTime{17} = fairSplit;
    onsetTime{18} = fairIncent;
    onsetTime{19} = unfairSplit;
    onsetTime{20} = unfairIncent;
    onsetTime{21} = fs;
    onsetTime{22} = fi;
    onsetTime{23} = ufs;
    onsetTime{24} = ufi;
    onsetTime{25} = fairEVO - mean(fairEVO);
    onsetTime{26} = fairEVS - mean(fairEVS);
    onsetTime{27} = unfairEVO - mean(unfairEVO);
    onsetTime{28} = unfairEVS - mean(unfairEVS);
    onsetTime{29} = fsV - mean(fsV);
    onsetTime{30} = fiV - mean(fiV);
    onsetTime{31} = ufsV - mean(ufsV);
    onsetTime{32} = ufiV - mean(ufiV);
    onsetTime{33} = shareEVO - mean(shareEVO);
    onsetTime{34} = shareEVS - mean(shareEVS);
    onsetTime{35} = selfEVO  - mean(selfEVO);
    onsetTime{36} = selfEVS -  mean(selfEVS);
    onsetTime{37} = chosenVal - mean(chosenVal); 
    onsetTime{38} = evDiff - mean(evDiff);
    onsetTime{39} = social_distance - mean(social_distance);

    %so, 1 is fix, 2 is name, 3 is incent, 4 is decision 5 is incent to resp.
    fileName = strcat('E:\StressTask\Round4\onsetFiles\ParamM16_1','\onsetFile_',subjnum,'.mat');
    save(fileName, 'onsetTime')
end
