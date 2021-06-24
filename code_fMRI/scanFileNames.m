function [scanFileLists] = scanFileNames(scanFileName)
%obtain the input of the smoothing and find the number of scans in the
%smoothing. returns the cell-array of 4d-images for the analysis

% datadir = 'C:\Users\kkim\Desktop\ToolBox Archive\Masks\masks\neurosynth200.nii';
if ischar(scanFileName)
    [p,n,e] = spm_fileparts(scanFileName);
    V = spm_vol(fullfile(p,[n e]));
end

[p,n,e] = spm_fileparts(V(1).fname);
% 
% if nargin < 2
%     if isempty(p), p = pwd; end
%     odir = p;
% end

scanFileLists = cell(numel(V),1);
for i=1:numel(V)
    scanFileLists{i} =strcat(scanFileName,',', num2str(i));
end
 
end

