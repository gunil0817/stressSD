clear all; clc
%obtain name of behavior data for treatment
%list_trt = dir('D:\StressTask\behvData\GroupedData\treatments\*_BTA*.mat');
list_trt = dir('D:\StressTask\behvData\GroupedData\controls\*_BTA*.mat');
list_trt = dir('D:\StressTask\behvData\120TrialVersion\*_BTA*.mat');


baseDir = list_trt(1).folder;
varNames = {'subjID', 'social_distance', 'amount_self', 'amount_other', 'amount_default', 'choice'};
trtData = zeros(120*length(list_trt), 6);
dataRemoval = zeros(120*(length(list_trt)-2),1);

for subjs = 1:length(list_trt)
    fairseq   = zeros(120,1);
    unfairseq = zeros(120,1);

    subjFileName = list_trt(subjs).name;
    load(fullfile(baseDir, subjFileName)); % load subject data
    
    %assign individual data to the whole group data matrix 
    index = [1+(subjs-1)*120,subjs*120];
    
    %setting experimentData as data
    data = trialData.gameData;
    
    
    %setting response
    resp = data(:,7);
    
    %column 1, subj ID
    trtData(index(1):index(2),1) = ones(length(resp),1)*(subjs);
    subjID(index(1):index(2),1) = ones(length(resp),1)*(subjs)';
    
    %column 2, social distance
    trtData(index(1):index(2),2) = data(:,8);
    social_distance(index(1):index(2),1) = data(:,8);
    

    %Column 3 amount_self
    trtData(index(1):index(2),3) = data(:,9);
    amount_self(index(1):index(2),1) = data(:,9);

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
    amount_default(index(1):index(2),1) = 20.*fairseq +  10.*unfairseq;
    amount_other(index(1):index(2),1) = 20.*fairseq +  30.*unfairseq;

    
    %Column 6 choice
    resp(resp == -1) = 0;
    %shifting selfish decision yes to prosocial decision yes. 
    resp = resp.*-1 +1;
    trtData(index(1):index(2),6) = resp; 
    choice(index(1):index(2),1) = resp;   
end
%transform from to 1 to 100 not 1 to 50
social_distance(social_distance == 50) = 100;
social_distance(social_distance == 20) = 50;
social_distance(social_distance == 10) = 20;
social_distance(social_distance == 5) = 10;
social_distance(social_distance == 3) = 5;

trtTable = table(subjID, social_distance, amount_self, amount_default, amount_other, choice);
writetable(trtTable, 'SD_120_whole.txt', 'Delimiter', '\t');

