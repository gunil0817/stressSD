clear all;

cd C:\Users\kkim\Documents\MATLAB\behv_data\placebo
cd C:\Users\kkim\Documents\MATLAB\behv_data\treatment

list_placebo = dir(':\Users\kkim\Documents\MATLAB\behv_data\placebo');
list_treatment = dir('C:\Users\kkim\Documents\MATLAB\behv_data\treatment')
dataPlacebo = list_placebo.name;
datatreatment = list_treatment.name;
totalFreqTar = zeros(6,6);


totalCol = [];
respT = [];
incentiveT = [];
socialDistsT = [];
subjsT = [];
for subjs = 3:length(list_placebo)
    
    load(list_placebo(subjs).name)

    data = trialData.gameData;
    socialDists = data(:,8);
    incentive = data(:,9);
    resp = data(:,7);
    resp(resp == -1) = 0;
    freqTar = zeros(6,6);
    
    respT = [respT; resp];
    socialDistsT = [socialDistsT; socialDists];
    incentiveT = [incentiveT; incentive];
    subjsT = [subjsT ; ones(144,1)*(subjs-2)];

    for i = 1:length(resp)
        switch socialDists(i)
            case 1
                switch incentive(i) 
                    case 1500
                        freqTar(1,1) = freqTar(1,1) + resp(i);
                    case 2500       
                        freqTar(2,1) = freqTar(2,1) + resp(i);
                    case 3500
                        freqTar(3,1) = freqTar(3,1) + resp(i);
                    case 4500
                        freqTar(4,1) = freqTar(4,1) + resp(i);
                    case 5500
                        freqTar(5,1) = freqTar(5,1) + resp(i);
                    case 6500
                        freqTar(6,1) = freqTar(6,1) + resp(i);
                 end

            case 3
                switch incentive(i) 
                    case 1500
                        freqTar(1,2) = freqTar(1,2) + resp(i);
                    case 2500       
                        freqTar(2,2) = freqTar(2,2) + resp(i);
                    case 3500
                        freqTar(3,2) = freqTar(3,2) + resp(i);
                    case 4500
                        freqTar(4,2) = freqTar(4,2) + resp(i);
                    case 5500
                        freqTar(5,2) = freqTar(5,2) + resp(i);
                    case 6500
                        freqTar(6,2) = freqTar(6,2) + resp(i);
                end

            case 5
                switch incentive(i) 
                    case 1500
                        freqTar(1,3) = freqTar(1,3) + resp(i);
                    case 2500       
                        freqTar(2,3) = freqTar(2,3) + resp(i);
                    case 3500
                        freqTar(3,3) = freqTar(3,3) + resp(i);
                    case 4500
                        freqTar(4,3) = freqTar(4,3) + resp(i);
                    case 5500
                        freqTar(5,3) = freqTar(5,3) + resp(i);
                    case 6500
                        freqTar(6,3) = freqTar(6,3) + resp(i);
                end

            case 10
                switch incentive(i) 
                    case 1500
                        freqTar(1,4) = freqTar(1,4) + resp(i);
                    case 2500       
                        freqTar(2,4) = freqTar(2,4) + resp(i);
                    case 3500
                        freqTar(3,4) = freqTar(3,4) + resp(i);
                    case 4500
                        freqTar(4,4) = freqTar(4,4) + resp(i);
                    case 5500
                        freqTar(5,4) = freqTar(5,4) + resp(i);
                    case 6500
                        freqTar(6,4) = freqTar(6,4) + resp(i);
                end

            case 20
                switch incentive(i) 
                    case 1500
                        freqTar(1,5) = freqTar(1,5) + resp(i);
                    case 2500       
                        freqTar(2,5) = freqTar(2,5) + resp(i);
                    case 3500
                        freqTar(3,5) = freqTar(3,5) + resp(i);
                    case 4500
                        freqTar(4,5) = freqTar(4,5) + resp(i);
                    case 5500
                        freqTar(5,5) = freqTar(5,5) + resp(i);
                    case 6500
                        freqTar(6,5) = freqTar(6,5) + resp(i);
                end

            case 50 
                switch incentive(i) 
                    case 1500
                        freqTar(1,6) = freqTar(1,6) + resp(i);
                    case 2500       
                        freqTar(2,6) = freqTar(2,6) + resp(i);
                    case 3500
                        freqTar(3,6)  = freqTar(3,6) + resp(i);
                    case 4500
                        freqTar(4,6) = freqTar(4,6) + resp(i);
                    case 5500
                        freqTar(5,6) = freqTar(5,6) + resp(i);
                    case 6500
                        freqTar(6,6) = freqTar(6,6) + resp(i);
                end

        end
    end
    
    
    totalFreqTar = totalFreqTar + freqTar;
%     figure();
%     labels = {1, 3, 5, 10, 20, 50};
%     set(gca, 'xticklabel', labels);
%     bar(freqTar)
%     title('target X social')
end

socialDistsT = zscore(socialDistsT);
incentiveT = zscore(incentiveT);
TotalResp = table(subjsT, socialDistsT, incentiveT, respT);
%     figure();
%     set(gca, 'xticklabel', labels);
%     bar(totalFreqTar./(length(list)-2))
%     title('total target X social placebo')
    
    
    
%% GLMM
%creating a generalized linear mixed effect Model. 

glme1 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT + (1|subjsT)', ...
    'distribution', 'binomial')
glme2 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT +  (1|socialDistsT)', ...
    'distribution', 'binomial')
glme3 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT + (1|incentiveT)', ...
    'distribution', 'binomial')

glme4 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT + socialDistsT*incentiveT + (1|subjsT)', ...
    'distribution', 'binomial')
glme5 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT + socialDistsT*incentiveT + (1|incentiveT)', ...
    'distribution', 'binomial')
glme6 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT + socialDistsT*incentiveT + (1|socialDistsT)', ...
    'distribution', 'binomial')

glme7 = fitglme(TotalResp, 'respT ~ 1 + socialDistsT + incentiveT + socialDistsT*incentiveT', ...
    'distribution', 'binomial')
