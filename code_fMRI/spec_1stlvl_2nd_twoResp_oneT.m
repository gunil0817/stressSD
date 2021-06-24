%perform one sample T-test. no group separation. 
clear all
%initialization

spm('defaults','FMRI')

%% directory setting
baseDir = 'D:\StressTask';
dirDM = '\twoResp4_n30';
dirOnSetTime = baseDir;
dirScan = dirDM;
analysisType = 'oneTT';

condName = {'social', 'choiceSplit', 'choiceIncent'};
noCon = length(condName);


cd(baseDir);
matlabbatch = cell(1,2);
%location of the task smoothed files
dirScanLoc = dir('**/swau*Task1*.nii');
dirMovLoc = dir('**/rp*Task1*.txt');

%     onsetTime{1} = tempTime(:,1); %fixation
%     onsetTime{2} = tempTime(:,2); %name appear
%     onsetTime{3} = tempTime(:,3); %incentive appear
%     onsetTime{4} = shareOnset;
%     onsetTime{5} = incentOnset;
%     onsetTime{6} = social_distance - mean(social_distance);
%     onsetTime{7} = amount_self - mean(amount_self);
%     onsetTime{8} = shareValDiff;
%     onsetTime{9} = incentValDiff;
%     onsetTime{10} = valDiff - mean(valDiff);
%     onsetTime{11} = amount_default-mean(amount_default); 
%     onsetTime{12} = amount_other-mean(amount_other);
%     onsetTime{13} = valDiffTwo;
%     onsetTime{14} = choice;
%     onsetTime{15} = SV_Diff2;
%     onsetTime{16} = IV_Diff2; 

parametricName = {'mSD','SV_diffSD','IV_diffSD' ,'shareOther', 'selfSelf'};
%contrastName = {'social_mSD','S-I', 'S_SD', 'S_AS', 'I_SD','I_AS','m_SD','m_AS'};
contrastName = {'social_mSD','onsetDiff','SV_diff', 'shareOther', 'selfSelf'};

contrastVector{1} = [0 1];
contrastVector{2} = [0 0 1 0 0 -1 0 ];
contrastVector{3} = [0 0 0 1 0 0 -1 0 0];
contrastVector{4} = [0 0 0 0 1 0 0 0 0];
contrastVector{5} = [0 0 0 0 0 0 0 1];

%contrastVector{6} = [0 0 0 0 0 0 0 1];
%contrastVector{7} = [0 0 0 .5 0 0 .5 0];
%contrastVector{8} = [0 0 0 0 .5 0 0 0.5];
onsetList = dir('D:\StressTask\onsetFiles\*.mat');


%% 2nd_lvl setting
dirGroup = 'D:\StressTask\groupAnalysis';
dirGroupName = strcat(dirDM, '_', analysisType);
numSubj = 1;
%% running 1st lvl

for numSubj = 1:length(onsetList)
    %=================< loading onsetFile %>=====================
    subjFileName = onsetList(numSubj).name;
    load(fullfile(onsetList(1).folder, subjFileName)); % load subject data
    
    %=================< scanFile directory setting %>=====================
     fileName =  fullfile(dirScanLoc(numSubj).folder, dirScanLoc(numSubj).name); 
     scanFiles = scanFileNames(fileName);
    %=================< moveReg directory setting %>=====================
     movRegName = fullfile(dirMovLoc(numSubj).folder, dirMovLoc(numSubj).name);
     
     %generating directory
     folderName =  fullfile(dirMovLoc(numSubj).folder, dirDM);
     if 0==exist(folderName,'dir')
            mkdir(folderName);
     end
   
     spmFileName = fullfile(baseDir, dirDM);
    %spm specification
    matlabbatch{1}.spm.stats.fmri_spec.dir = {folderName};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scanFiles;
    
    %condition Setting
    %onset3 = incent + name / 4 = split / 5 = incent / 6 = mSD / 7 = mAS /
    %8 = split / 9 = incents / 10 = amount_default / 11 = amount_other
    %{'zSD','mSD','mAS','incent','split'};
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'social';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = onsetTime{:,2};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1) = struct('name', parametricName{1}, 'param', onsetTime{6}.*-1, 'poly', 1);
    %matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1) = struct('name', parametricName{2}, 'param', onsetTime{6}, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 0;
    
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = condName{2}; %Share
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = onsetTime{:,4};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod(1) = struct('name', parametricName{2}, 'param', onsetTime{15}, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod(2) = struct('name', parametricName{4}, 'param', onsetTime{18}, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 0;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = condName{3}; %selfish
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = onsetTime{:,5};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod(1) = struct('name', parametricName{3}, 'param', onsetTime{16}, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod(2) = struct('name', parametricName{5}, 'param', onsetTime{17}, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).orth = 0;
   
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {movRegName};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {'D:\StressTask\Masks\aal_nocere.nii'};
    
    dirSPM = fullfile(folderName, 'SPM.mat');
          
    matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(dirSPM);
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    


    fileName = strcat(folderName, '\designMatrix_Estimate_jobs.mat' );
    save( fileName  ,'matlabbatch');
            
      %===< RUN >
      spm_jobman('run',matlabbatch);
end


%% contrast generator 
jobs = cell(1,1);
for numSubj = 1:length(onsetList)
     
      folderName =  fullfile(dirMovLoc(numSubj).folder, dirDM);
      dirSPM = fullfile(folderName, 'SPM.mat');

      %%===< contrast managing >
      for cNo = 1:length(contrastName)
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{cNo}.tcon.name = contrastName{cNo};
            jobs{1}.spm.stats.con.consess{cNo}.tcon.convec = contrastVector{cNo};
            jobs{1}.spm.stats.con.consess{cNo}.tcon.sessrep = 'none';
      end
                                               
      jobs{1}.spm.stats.con.delete = 1;                        
      fileName = fullfile(folderName, '/contrastManager_jobs.mat' );
      save( fileName  ,'jobs');            
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end
 
%% 2nd level
jobs = cell(1,2);   
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} ); 
      cd('D:\StressTask\Task1')
      scanLoc = strcat('**',dirDM,'/con_*',num2str(cNo),'.nii');
      dirConLoc = dir(scanLoc);
      
      %% ===< scan files>
      contrastFile = cell(length(onsetList),1) ;
      for sNo=1:length(onsetList)
          fileName = strcat(dirConLoc(sNo).folder,'\',dirConLoc(sNo).name,',1');
          contrastFile{sNo,1}= fileName;
      end
      
      dirSpec = fullfile(dirGroup,dirGroupName, contrastName{cNo});
      jobs{1}.spm.stats.factorial_design.dir =  cellstr(dirSpec);
            
     %%
      jobs{1}.spm.stats.factorial_design.des.mreg.scans = contrastFile;
      jobs{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
      jobs{1}.spm.stats.factorial_design.des.mreg.incint = 1;
      jobs{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
      jobs{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
      jobs{1}.spm.stats.factorial_design.masking.im = 1;
      jobs{1}.spm.stats.factorial_design.masking.em = {''};
      jobs{1}.spm.stats.factorial_design.globalc.g_omit = 1;
      jobs{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
      jobs{1}.spm.stats.factorial_design.globalm.glonorm = 1;
                  
      %% ===< estimation >      
      dirSPM = strcat(dirSpec, '\SPM.mat' );
      jobs{2}.spm.stats.fmri_est.spmmat(1) = cellstr(dirSPM);
      jobs{2}.spm.stats.fmri_est.method.Classical = 1;
      
      if 0==exist( dirSpec ,'dir')
            mkdir(dirSpec);
      end
      
      fileName = strcat(dirSpec, 'oneSample.mat' );
      save( fileName  ,'jobs');
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end

jobs = cell(1,2);   
%% 2nd level  contrasts
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} );      
      %%===< contrast managing >
     
      
      dirSPM = fullfile(dirGroup,dirGroupName, contrastName{cNo},'SPM.mat');
%           disp( contrastName{cNo} );
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{1}.tcon.name = contrastName{cNo};
            jobs{1}.spm.stats.con.consess{1}.tcon.convec = [1];
            jobs{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            
            negContrastName = strcat(contrastName{cNo},'_neg');
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{2}.tcon.name = negContrastName;
            jobs{1}.spm.stats.con.consess{2}.tcon.convec = [-1];
            jobs{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';            
            jobs{1}.spm.stats.con.delete = 1;             
            fileName = fullfile(dirGroup,dirGroupName, contrastName{cNo} ,'/contrastManager_jobs.mat' );
            save( fileName  ,'jobs');
            
            jobs{2}.spm.stats.results.spmmat = {dirSPM};
            jobs{2}.spm.stats.results.conspec.titlestr = contrastName{cNo};
            jobs{2}.spm.stats.results.conspec.contrasts = Inf;
            jobs{2}.spm.stats.results.conspec.threshdesc = 'none';
            jobs{2}.spm.stats.results.conspec.thresh = 0.001;
            jobs{2}.spm.stats.results.conspec.extent = 20;
            jobs{2}.spm.stats.results.conspec.conjunction = 1;
            jobs{2}.spm.stats.results.conspec.mask.none = 1;
            jobs{2}.spm.stats.results.units = 1;
            jobs{2}.spm.stats.results.export{1}.ps = true;
            jobs{2}.spm.stats.results.export{2}.png = true;
            jobs{2}.spm.stats.results.export{3}.xls = true;
      
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end

