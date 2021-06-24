
% written in Aug. 15th. 2019. 
% Authored by Kun Il Kim. 
% this script obtains individual behavior data from placebo file and
% treatment file and generates plots for data visualization. 


clear all; clc
%obtain name of behavior data for treatment
list_trt = dir('D:\StressTask\behvData\basedOnCort\*_BTA*.mat');
baseDir = list_trt(1).folder;

%obtain name of behavior data for control
%list_pla = dir('C:\Users\kkim\Desktop\Project Archive\SD_SECPT\MIST version\DATA\control');
disp('saving figure in this directory');
figdirectory = 'D:\StressTask\behvData\figures\CORT';

trtSubj = [0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 1 1 1 1];
conSubj = [1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 ];

%For group_level data visualization
totalIncents = zeros(2,6); %first row is for placebo 2nd is for trt
totalsocialDists = zeros(2,6);
PlaTotalFreqTar = zeros(6,6);
TrtTotalFreqTar = zeros(6,6);
%generate subject specific behavior data
behvData = struct();
behvData.trt.fair.incents = zeros(length(list_trt)-2,6);
behvData.trt.unfair.incents = zeros(length(list_trt)-2,6);
behvData.trt.fair.SD = zeros(length(list_trt)-2,6);
behvData.trt.unfair.SD = zeros(length(list_trt)-2,6);
behvData.trt.total.SD = zeros(length(list_trt)-2,6);
behvData.trt.total.incents = zeros(length(list_trt)-2,6);

for subjs = 1:length(list_trt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for treatment
    subjFileName = strcat(baseDir,'\',list_trt(subjs).name);
    load(subjFileName);
    
    %generate decision frequency in the axis of Incents
    trtInc = subjIncentive(trialData, blockseq);
  
    %generate decision frequency in the axis of socialDists
    trtSocial = subjSocialDists_blo(trialData, blockseq);
    
    %generate decision frequency in the axis of socialDists x incents
    trtFreqTar = Inc_Soci_freq(trialData);
     
%     h = figure();
%     %plotting for trt
%     subplot(3,2,1), bar(trtSocial(1,:))
%     hold on
%     plot([0:7], ones(1,8)*10, '--')
%     plot([0:7], ones(1,8)*20, '--g')
%     title('Prosocial Decisions SociDists trt fair')
%     labels = {1, 5, 10, 20, 50, 100};
%     set(gca, 'xticklabel', labels);
%     axis([0 7 0 12])
%     
%     subplot(3,2,2), bar(trtSocial(2,:))
%     hold on
%     plot([0:7], ones(1,8)*10, '--')
%     plot([0:7], ones(1,8)*20, '--g')
%     title('Prosocial Decisions SociDists unfair')
%     labels = {1, 5, 10, 20, 50, 100};
%     set(gca, 'xticklabel', labels);
%     axis([0 7 0 12])
%     
%     subplot(3,2,3), bar((trtSocial(1,:)+trtSocial(2,:))/2)
%     hold on
%     plot([0:7], ones(1,8)*10, '--')
%     plot([0:7], ones(1,8)*20, '--g')
%     title('Prosocial Decisions Social Dist total')
%     labels = {1, 2, 3, 4, 5, 6};
%     %set(gca, 'xticklabel', labels);
%     axis([0.5 6.5 0 12])
%     
%     
%     subplot(3,2,4), bar(trtInc(2,:))
%     hold on
%     plot([0:7], ones(1,8)*2, '--')
%     plot([0:7], ones(1,8)*20, '--g')
%     title('Prosocial Decisions Incent unfair')
%     set(gca, 'xticklabel', labels);
%     labels = {'1', '2', '3', '4', '5'};
% 
%     axis([0.5 5.5 0 12])
%     figName = strcat(figdirectory, '\p3p_subjs_', int2str(subjs), '.png');
%     saveas(h, figName);

    behvData.trt.fair.incents(subjs,:) = trtInc(1,:);
    behvData.trt.unfair.incents(subjs,:) = trtInc(2,:);
    behvData.trt.fair.SD(subjs,:) = trtSocial(1,:);
    behvData.trt.unfair.SD(subjs,:) = trtSocial(2,:);
    behvData.trt.total.SD(subjs,:) = trtSocial(1,:) + trtSocial(2,:);
    behvData.trt.total.incents(subjs,:) = trtInc(1,:) + trtInc(2,:);
end

totalsocialDists = zeros(2,6);
totaltrtSD = zeros(sum(trtSubj),6);
totalconSD = zeros(sum(conSubj),6);

FtrtSD = zeros(sum(trtSubj),6);
UFtrtSD = zeros(sum(trtSubj),6);
FconSD = zeros(sum(conSubj),6);
UFconSD = zeros(sum(conSubj),6);
for nsubj = 1:length(trtSubj)
   
    if trtSubj(nsubj) == 1 %trt
        totalsocialDists(1,:) = totalsocialDists(1,:) + behvData.trt.total.SD(nsubj,:);
        totaltrtSD(sum(trtSubj(1:nsubj)),:) = behvData.trt.total.SD(nsubj,:);
        FtrtSD(sum(trtSubj(1:nsubj)),:) = behvData.trt.fair.SD(nsubj,:);
        UFtrtSD(sum(trtSubj(1:nsubj)),:) =behvData.trt.unfair.SD(nsubj,:);
    else %pla
        totalsocialDists(2,:) = totalsocialDists(2,:) + behvData.trt.total.SD(nsubj,:);
        totalconSD(sum(conSubj(1:nsubj)),:) = behvData.trt.total.SD(nsubj,:);
        FconSD(sum(conSubj(1:nsubj)),:) = behvData.trt.fair.SD(nsubj,:);
        UFconSD(sum(conSubj(1:nsubj)),:) = behvData.trt.unfair.SD(nsubj,:);

    end
end
    


    totalsocialDists(1,:) = totalsocialDists(1,:)./(sum(trtSubj))./20;
    totalsocialDists(2,:) = totalsocialDists(2,:)./(sum(conSubj))./20;
    mu_UFtrtSD = mean(UFtrtSD)./10;
    mu_UFconSD = mean(UFconSD)./10;
    
    mu_FtrtSD = mean(FtrtSD)./10;
    mu_FconSD = mean(FconSD)./10;
    
 h1 = figure()
 xvals_SD = [1 5 10 20 50 100];
 xvals = [1 2 3 4 5 6];
 plot(xvals, totalsocialDists(1,:),'-o','LineWidth',4);
 hold on 
 plot(xvals, totalsocialDists(2,:),'-o','LineWidth',4);
 axis([1 6 0 1])
 title('Split decision freq between groups across SD')
 legend({'trt  (n=13)', 'pla(n=10)'})
 saveas(h1, 'totalSplit_noSTD.png')

 h2=figure()
 xvals_SD = [1 5 10 20 50 100];
 xvals = [1 2 3 4 5 6];
 plot(xvals, mu_UFtrtSD,'-o','LineWidth',4);
 hold on 
 plot(xvals, mu_UFconSD,'-o','LineWidth',4);
 axis([1 6 0 1])
 title('Split freq fair across SD')
 legend({'trt  (n=13)', 'pla(n=10)'})
 saveas(h2,'unfair_noSTD.png')

 
 h3=figure()
 xvals_SD = [1 5 10 20 50 100];
 xvals = [1 2 3 4 5 6];
 plot(xvals, mu_FtrtSD,'-o','LineWidth',4);
 hold on 
 plot(xvals, mu_FconSD,'-o','LineWidth',4);
 axis([1 6 0 1])
 title('Split freq unfair across SD')
 legend({'trt  (n=13)', 'pla(n=10)'})
 saveas(h3, 'uair_noSTD.png')

 
h4 = figure()
hold on
errorbar(xvals, totalsocialDists(1,:), std(totaltrtSD)./20,'-o', 'LineWidth',4);
errorbar(xvals, totalsocialDists(2,:), std(totalconSD)./20,'-o', 'LineWidth',4);
title('socialDist in between Group')
ylabel('% of prosocial decisions')
xlabel('social distance')
axis([1 6 0 1])
legend({'trt (n=12)', 'pla(n=9)'})
 saveas(h4, 'totalSplit_SDE.png')
   

xvals_SD = [1 5 10 20 50 100];
xalim = [0 50 0 1];
%% statistical significance
% for SDs = 1:6
%     
%     [h,p]=ttest2(behvData.trt.fair.SD(SDs,:)./12, behvData.pla.fair.SD(SDs,:)./12, 'Vartype','unequal');
%     fprintf('behavior response of fair at SD - %d p values of %f \n', xvals(SDs), p)
% 
%     
%     [h,p]=ttest2(behvData.trt.unfair.SD(SDs,:)./12, behvData.pla.unfair.SD(SDs,:)./12, 'Vartype','unequal');
%     fprintf('behavior response of unfair at SD - %d p values of %f \n',xvals(SDs), p)
% 
%     
%     [h,p]=ttest2(behvData.trt.total.SD(SDs,:)./24, behvData.pla.total.SD(SDs,:)./24);
%     fprintf('behavior response of total at SD - %d p values of %f \n',xvals(SDs), p)  
% end
xvals = [1 2 3 4 5 6];
%% Group level Plotting
%errorbar(xvals, mean(behvData.pla.total.SD), std(behvData.pla.total.SD),'-o', 'LineWidth',4);
%hold on
%errorbar(xvals, mean(behvData.trt.total.SD), std(behvData.trt.total.SD),'-o', 'LineWidth',4);
h1 = figure()
hold on
errorbar(xvals, mean(behvData.pla.total.SD./24), ste(behvData.pla.total.SD./24),'-o', 'LineWidth',4);
errorbar(xvals, mean(behvData.trt.total.SD./24), std(behvData.trt.total.SD./24),'-o', 'LineWidth',4);
title('socialDist in between Group 2ex')
ylabel('% of prosocial decisions')
xlabel('social distance')
legend({'pla','trt'})
axis(xalim)
figname = strcat(figdirectory,'2_excluded_Group_total.png');
saveas(h1, figname);

xvals = [1 2 3 4 5 6];
h2 = figure()
subplot(1,2,1);
%errorbar(xvals, mean(behvData.pla.fair.SD./12), ste(behvData.pla.fair.SD./12),'-o', 'LineWidth',4)
hold on
errorbar(xvals, mean(behvData.trt.fair.SD./12), std(behvData.trt.fair.SD./12)./sqrt(10),'-o','LineWidth',4)
title('socialDist equal split decisions')
ylabel('% of prosocial decisions')
xlabel('social distance')
legend({'stress'})
axis([1, 6, 0, 1])

subplot(1,2,2);
%errorbar(xvals, mean(behvData.pla.unfair.SD./12), ste(behvData.pla.unfair.SD)./12, '-o', 'LineWidth',4)
hold on
errorbar(xvals, mean(behvData.trt.unfair.SD./12), std(behvData.trt.unfair.SD./12)./sqrt(10),'-o','LineWidth',4)
title('socialDist in unequal split decisions')
ylabel('% of prosocial decisions')
xlabel('social distance')
legend({'stress'})
axis([1, 6, 0, 1])
figname = strcat(figdirectory,'\7ppl_fair_Unfair_total.png');
saveas(h2, figname);

respT = behvData.trt.total.SD./24;
for i = 1:8
    h3 = figure()
    bar(respT(i,:));
    xlabel('social Distance');
    ylabel('% of money sharing');
    axis([0, 7, 0, 1])
    figName3 = strcat( 'subj_',num2str(i),'_behvData.png');
    saveas(h3, figName3) 
end
 
