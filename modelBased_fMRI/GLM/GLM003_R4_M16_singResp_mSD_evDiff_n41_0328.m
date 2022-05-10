clear all
%initialization

spm('defaults','FMRI')
%% directory setting
baseDir = 'E:\StressTask';
dirDM = '\GLM001_R4_M16_singResp_mSD_evDiff_n41_0328'; % directory for 1st lvl glm

%2nd group location
dirGroup = 'E:\StressTask\Round4\2ndResult\'; 
analysisType = 'oneTT\';
dirSingleName =strcat(dirDM,'\', analysisType);
dirGroupName = strcat(dirDM, '_',analysisType); %for MR, different

%change directory
cd(strcat(baseDir,'\Task1'));

%scan Dir
dirScanLoc = dir('**\swau*Task1*.nii'); %directories for task_fMRI.nii
dirMovLoc = dir('**\rp*Task1*.txt'); % directoreis for rp files
onsetList = dir('E:\StressTask\Round4\onsetFiles\ParamM16_1\*.mat');

%location of the task smoothed files
condName = {'social','SI'};
noCon = length(condName);
contrastName = {'mSD', 'EVDiff'};
contrastVector{1} = [0 0  0 1 0];
contrastVector{2} = [0 0  0 0 1];

%setup for 1st level
cd(baseDir);
load('E:\StressTask\Round4\behvData\M16_parameters_220328.mat');
k = M16.k; eta = M16.eta; beta = M16.beta;
param= [k eta beta];
%% running 1st lvl
matlabbatch = cell(1,2);
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
   
    %spm specification
    matlabbatch{1}.spm.stats.fmri_spec.dir = {folderName};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scanFiles;

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'social';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = onsetTime{:,2};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod(1) = struct('name', 'target(SD)', 'param', onsetTime{39}.*-1, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 0;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = condName{2}; %target + incentive
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = onsetTime{:,3};
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
    %matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod(1) = struct('name', 'target(SD)', 'param', onsetTime{6}.*-1, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod(1) = struct('name', 'target(SD)', 'param', onsetTime{39}.*-1, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod(2) = struct('name', 'EVDiff', 'param', onsetTime{38}, 'poly', 1);
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 0;
   
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {movRegName};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {'E:\StressTask\Masks\aal_nocere.nii'};
    
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
 
%% 2nd level - oneTT 
jobs = cell(1,2);   
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} ); 
      cd('E:\StressTask\Task1')
          if cNo > 9
            scanLoc = strcat('**',dirDM,'/con_00',num2str(cNo),'.nii');
          else
            scanLoc = strcat('**',dirDM,'/con_000',num2str(cNo),'.nii');
          end
      dirConLoc = dir(scanLoc);
      
      %% ===< scan files>
      contrastFile = cell(length(onsetList),1) ;
      for sNo=1:length(onsetList)
          fileName = strcat(dirConLoc(sNo).folder,'\',dirConLoc(sNo).name,',1');
          contrastFile{sNo,1}= fileName;
      end
      
      dirSpec = fullfile(dirGroup,dirSingleName, contrastName{cNo});
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
%% 2nd level single contrasts
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} );      
      %%===< contrast managing >
     
      dirSPM = fullfile(dirGroup,dirSingleName, contrastName{cNo},'SPM.mat');
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
            fileName = fullfile(dirGroup,dirSingleName, contrastName{cNo} ,'/contrastManager_jobs.mat' );
            save( fileName  ,'jobs');
            
            jobs{2}.spm.stats.results.spmmat = {dirSPM};
            jobs{2}.spm.stats.results.conspec.titlestr = contrastName{cNo};
            jobs{2}.spm.stats.results.conspec.contrasts = Inf;
            jobs{2}.spm.stats.results.conspec.threshdesc = 'none';
            jobs{2}.spm.stats.results.conspec.thresh = 0.001;
            jobs{2}.spm.stats.results.conspec.extent = 30;
            jobs{2}.spm.stats.results.conspec.conjunction = 1;
            jobs{2}.spm.stats.results.conspec.mask.none = 1;
            jobs{2}.spm.stats.results.units = 1;
            %jobs{2}.spm.stats.results.export{1}.ps = true;
            jobs{2}.spm.stats.results.export{1}.png = true;
            %jobs{2}.spm.stats.results.export{3}.xls = true;
      
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end

%% 2nd_lvl setting
analysisType = 'MR_K';
dirSingleName =strcat(dirDM,'\', analysisType);
jobs = cell(1,2);   
NoC = length(contrastName);

for cNo = 1: NoC
      disp( contrastName{cNo} ); 
      cd('E:\StressTask\Task1')
          if cNo > 9
            scanLoc = strcat('**',dirDM,'/con_00',num2str(cNo),'.nii');
          else
            scanLoc = strcat('**',dirDM,'/con_000',num2str(cNo),'.nii');
          end

      dirConLoc = dir(scanLoc);
      %% ===< scan files>
      contrastFile = cell(length(onsetList),1) ;
      for sNo=1:length(onsetList)
          fileName = strcat(dirConLoc(sNo).folder,'\',dirConLoc(sNo).name,',1');
          contrastFile{sNo,1}= fileName;
      end
      
      dirSpec = fullfile(dirGroup,dirSingleName, contrastName{cNo});
      jobs{1}.spm.stats.factorial_design.dir =  cellstr(dirSpec);
            
      %%
      jobs{1}.spm.stats.factorial_design.des.mreg.scans = contrastFile;
      jobs{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
      jobs{1}.spm.stats.factorial_design.des.mreg.incint = 1;
      jobs{1}.spm.stats.factorial_design.cov(1).c =  k;
      jobs{1}.spm.stats.factorial_design.cov(1).cname = 'K';
      jobs{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(1).iCC = 1;
      jobs{1}.spm.stats.factorial_design.cov(2).c =  beta;
      jobs{1}.spm.stats.factorial_design.cov(2).cname = 'beta';
      jobs{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(2).iCC = 1;
      jobs{1}.spm.stats.factorial_design.cov(3).c =  eta;
      jobs{1}.spm.stats.factorial_design.cov(3).cname = 'eta';
      jobs{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(3).iCC = 1;
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
      
      fileName = strcat(dirSpec, 'multiRegression_word_jobs.mat' );
      save( fileName  ,'jobs');
      
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end


jobs = cell(1,2);   
%% 2nd level single contrasts
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} );      
      %%===< contrast managing >
     
      
      dirSPM = fullfile(dirGroup,dirSingleName, contrastName{cNo},'SPM.mat');
%           disp( contrastName{cNo} );
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{1}.tcon.name = contrastName{cNo};
            jobs{1}.spm.stats.con.consess{1}.tcon.convec = [0 1];
            jobs{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            
            negContrastName = strcat(contrastName{cNo},'_neg');
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{2}.tcon.name = negContrastName;
            jobs{1}.spm.stats.con.consess{2}.tcon.convec = [0 -1];
            jobs{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';            
            jobs{1}.spm.stats.con.delete = 1;             
            fileName = fullfile(dirGroup,dirSingleName, contrastName{cNo} ,'/contrastManager_jobs.mat' );
            save( fileName  ,'jobs');
            
            jobs{2}.spm.stats.results.spmmat = {dirSPM};
            jobs{2}.spm.stats.results.conspec.titlestr = contrastName{cNo};
            jobs{2}.spm.stats.results.conspec.contrasts = Inf;
            jobs{2}.spm.stats.results.conspec.threshdesc = 'none';
            jobs{2}.spm.stats.results.conspec.thresh = 0.001;
            jobs{2}.spm.stats.results.conspec.extent = 25;
            jobs{2}.spm.stats.results.conspec.conjunction = 1;
            jobs{2}.spm.stats.results.conspec.mask.none = 1;
            jobs{2}.spm.stats.results.units = 1;
            jobs{2}.spm.stats.results.export{1}.png = true;
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end

%% 2nd_lvl setting BETA
analysisType = 'MR_BETA';
dirSingleName =strcat(dirDM,'\', analysisType);
%% running 1st lvl
jobs = cell(1,2);   
for cNo = 1: NoC
      disp( contrastName{cNo} ); 
      cd('E:\StressTask\Task1')
          if cNo > 9
            scanLoc = strcat('**',dirDM,'/con_00',num2str(cNo),'.nii');
          else
            scanLoc = strcat('**',dirDM,'/con_000',num2str(cNo),'.nii');
          end


      dirConLoc = dir(scanLoc);
      %% ===< scan files>
      contrastFile = cell(length(onsetList),1) ;
      for sNo=1:length(onsetList)
          fileName = strcat(dirConLoc(sNo).folder,'\',dirConLoc(sNo).name,',1');
          contrastFile{sNo,1}= fileName;
      end
      
      dirSpec = fullfile(dirGroup,dirSingleName, contrastName{cNo});
      jobs{1}.spm.stats.factorial_design.dir =  cellstr(dirSpec);
            
      %%
      jobs{1}.spm.stats.factorial_design.des.mreg.scans = contrastFile;
      jobs{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
      jobs{1}.spm.stats.factorial_design.des.mreg.incint = 1;
      jobs{1}.spm.stats.factorial_design.cov(1).c =  beta;
      jobs{1}.spm.stats.factorial_design.cov(1).cname = 'beta';
      jobs{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(1).iCC = 1;
      jobs{1}.spm.stats.factorial_design.cov(2).c =  k;
      jobs{1}.spm.stats.factorial_design.cov(2).cname = 'K';
      jobs{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(2).iCC = 1;
      jobs{1}.spm.stats.factorial_design.cov(3).c =  eta;
      jobs{1}.spm.stats.factorial_design.cov(3).cname = 'eta';
      jobs{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(3).iCC = 1;
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
      
      fileName = strcat(dirSpec, 'multiRegression_word_jobs.mat' );
      save( fileName  ,'jobs');
      
      %===< RUN >
      spm_jobman('run',jobs);
      
      clearvars jobs
end

jobs = cell(1,2);   
%% 2nd level single contrasts
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} );      
      %%===< contrast managing >
     
      dirSPM = fullfile(dirGroup,dirSingleName, contrastName{cNo},'SPM.mat');
%           disp( contrastName{cNo} );
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{1}.tcon.name = contrastName{cNo};
            jobs{1}.spm.stats.con.consess{1}.tcon.convec = [0 1];
            jobs{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            
            negContrastName = strcat(contrastName{cNo},'_neg');
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{2}.tcon.name = negContrastName;
            jobs{1}.spm.stats.con.consess{2}.tcon.convec = [0 -1];
            jobs{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';            
            jobs{1}.spm.stats.con.delete = 1;             
            fileName = fullfile(dirGroup,dirSingleName, contrastName{cNo} ,'/contrastManager_jobs.mat' );
            save( fileName  ,'jobs');
            
            jobs{2}.spm.stats.results.spmmat = {dirSPM};
            jobs{2}.spm.stats.results.conspec.titlestr = contrastName{cNo};
            jobs{2}.spm.stats.results.conspec.contrasts = Inf;
            jobs{2}.spm.stats.results.conspec.threshdesc = 'none';
            jobs{2}.spm.stats.results.conspec.thresh = 0.001;
            jobs{2}.spm.stats.results.conspec.extent = 25;
            jobs{2}.spm.stats.results.conspec.conjunction = 1;
            jobs{2}.spm.stats.results.conspec.mask.none = 1;
            jobs{2}.spm.stats.results.units = 1;
            jobs{2}.spm.stats.results.export{1}.png = true;
      
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end

%% 2nd_lvl setting ETA
analysisType = 'MR_ETA';
dirSingleName =strcat(dirDM,'\', analysisType);
%% running 1st lvl
jobs = cell(1,2);   
for cNo = 1: NoC
      disp( contrastName{cNo} ); 
      cd('E:\StressTask\Task1')
          if cNo > 9
            scanLoc = strcat('**',dirDM,'/con_00',num2str(cNo),'.nii');
          else
            scanLoc = strcat('**',dirDM,'/con_000',num2str(cNo),'.nii');
          end


      dirConLoc = dir(scanLoc);
      %% ===< scan files>
      contrastFile = cell(length(onsetList),1) ;
      for sNo=1:length(onsetList)
          fileName = strcat(dirConLoc(sNo).folder,'\',dirConLoc(sNo).name,',1');
          contrastFile{sNo,1}= fileName;
      end
      
      dirSpec = fullfile(dirGroup,dirSingleName, contrastName{cNo});
      jobs{1}.spm.stats.factorial_design.dir =  cellstr(dirSpec);
            
      %%
      jobs{1}.spm.stats.factorial_design.des.mreg.scans = contrastFile;
      jobs{1}.spm.stats.factorial_design.des.mreg.mcov = struct('c', {}, 'cname', {}, 'iCC', {});
      jobs{1}.spm.stats.factorial_design.des.mreg.incint = 1;
      jobs{1}.spm.stats.factorial_design.cov(1).c =  eta;
      jobs{1}.spm.stats.factorial_design.cov(1).cname = 'eta';
      jobs{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(1).iCC = 1;
      jobs{1}.spm.stats.factorial_design.cov(2).c =  k;
      jobs{1}.spm.stats.factorial_design.cov(2).cname = 'K';
      jobs{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(2).iCC = 1;
      jobs{1}.spm.stats.factorial_design.cov(3).c =  beta;
      jobs{1}.spm.stats.factorial_design.cov(3).cname = 'beta';
      jobs{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
      jobs{1}.spm.stats.factorial_design.cov(3).iCC = 1;
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
      
      fileName = strcat(dirSpec, 'multiRegression_word_jobs.mat' );
      save( fileName  ,'jobs');
      
      %===< RUN >
      spm_jobman('run',jobs);
      
      clearvars jobs
end

jobs = cell(1,2);   
%% 2nd level single contrasts
for cNo = 1:length(contrastName)
      disp( contrastName{cNo} );      
      %%===< contrast managing >
     
      dirSPM = fullfile(dirGroup,dirSingleName, contrastName{cNo},'SPM.mat');
%           disp( contrastName{cNo} );
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{1}.tcon.name = contrastName{cNo};
            jobs{1}.spm.stats.con.consess{1}.tcon.convec = [0 1];
            jobs{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            
            negContrastName = strcat(contrastName{cNo},'_neg');
            jobs{1}.spm.stats.con.spmmat = cellstr( dirSPM );
            jobs{1}.spm.stats.con.consess{2}.tcon.name = negContrastName;
            jobs{1}.spm.stats.con.consess{2}.tcon.convec = [0 -1];
            jobs{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';            
            jobs{1}.spm.stats.con.delete = 1;             
            fileName = fullfile(dirGroup,dirSingleName, contrastName{cNo} ,'/contrastManager_jobs.mat' );
            save( fileName  ,'jobs');
            
            jobs{2}.spm.stats.results.spmmat = {dirSPM};
            jobs{2}.spm.stats.results.conspec.titlestr = contrastName{cNo};
            jobs{2}.spm.stats.results.conspec.contrasts = Inf;
            jobs{2}.spm.stats.results.conspec.threshdesc = 'none';
            jobs{2}.spm.stats.results.conspec.thresh = 0.001;
            jobs{2}.spm.stats.results.conspec.extent = 30;
            jobs{2}.spm.stats.results.conspec.conjunction = 1;
            jobs{2}.spm.stats.results.conspec.mask.none = 1;
            jobs{2}.spm.stats.results.units = 1;
            jobs{2}.spm.stats.results.export{1}.png = true;
      
      %===< RUN >
      spm_jobman('run',jobs);
      clearvars jobs
end
