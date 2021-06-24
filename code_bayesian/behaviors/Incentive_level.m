%% Incentive Level
clear all; clc;

filelist = dir('*.mat');
[h,~] = size(filelist);

for j = length(filelist);
    filename = (filelist(j).name);
    % 불러올 데이터의 파일 이름을 순차적으로 읽음
    load(filelist(j).name);
    
    data = trialData.gameData;
    socialDists = data(:,8);
    incentive = data(:,9);
    resp = data(:,7);
    selfInc = zeros(1,6);
    
    for i = 1:length(resp)
        switch incentive(i)
            case 1500
                selfInc(1) = selfInc(1) + resp(i)
            case 2500
                selfInc(2) = selfInc(2) + resp(i)
            case 3500
                selfInc(3) = selfInc(3) + resp(i)
            case 4500
                selfInc(4) = selfInc(4) + resp(i)
            case 5500
                selfInc(5) = selfInc(5) + resp(i)
            case 6500
                selfInc(6) = selfInc(6) + resp(i)
        end
    end
end

figure();
labels2 = {1500,2500,3500,4500,5500,6500}
set(gca, 'xticklabel', labels2);

bar(selfInc)
plot(selfInc)


