%% SocialDistance Lv
clear all; clc;

filelist = dir('*.mat');
[h,~] = size(filelist);

for j = length(filelist);
    filename = (filelist(j).name);
    load(filelist(j).name);

    data = trialData.gameData;
    socialDists = data(:,8);
    incentive = data(:,9);
    resp = data(:,7);

    selfFreq = zeros(1,6);
    for i = 1:length(resp)
        switch socialDists(i)
            case 1 
                selfFreq(1) = selfFreq(1)+ resp(i)
            case 3
                selfFreq(2) = selfFreq(2)+ resp(i)
            case 5
                selfFreq(3) = selfFreq(3)+ resp(i)
            case 10
                selfFreq(4) = selfFreq(4)+ resp(i)
            case 20
                selfFreq(5) = selfFreq(5)+ resp(i)
            case 50
                selfFreq(6) = selfFreq(6)+ resp(i)
        end
    end
end
labels = {1, 3, 5, 10, 20, 50};
bar(selfFreq)
set(gca, 'xticklabel', labels);


%% regression
% m1 = fitglm([zincent, zscore(socialDists)], resp, 'distribution', 'binomial')


