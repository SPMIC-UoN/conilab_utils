%%%%% Create tract by WM matrix for connectivity blueprint
function blueprint(StudyFolder, sub_list, ds, threshold)
%blueprint( '/home//mydtifit',...
% ...'/home//mydtifit/Diffusion/all_subjects.txt', 2, 0.05 )
StudyFolder='/home//mydtifit';
subID=329440;
ds=3;
threshold=0.00;
%% Set paths and prepare environment and data
addpath /usr/local/fsl/etc/matlab
addpath /home//mydtifit/scripts/Matrix2
DiffStudyFolder=[StudyFolder '/Diffusion'];

% change subject list path to .txt output of completed subjects by mymatx2
sub_list=load(sub_list);

% Define tracts
tracts={'ar_l', 'atr_l', 'cgc_l', 'cgh_l', 'cst_l', 'fma','ifo_l','ilf_l', 'ml_l', 'ptr_l', 'slf_l', 'str_l', 'unc_l', 'slf1_l','slf2_l','slf3_l',...
    'ar_r', 'atr_r', 'cgc_r', 'cgh_r', 'cst_r', 'fmi','ifo_r','ilf_r', 'mcp','ml_r', 'ptr_r','slf_r', 'str_r', 'unc_r','slf1_r','slf2_r','slf3_r'};

% Loop through all subjects
for s=1:size(sub_list,1)
    
    subID=sub_list(s);
    %%
    resultsFolder=[DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/blueprint'];
    cmd=(['if [ ! -d "' resultsFolder '" ]; then mkdir ' resultsFolder ...
        '; else rm ' resultsFolder ' -r; mkdir ' resultsFolder '; fi']);
    unix(cmd);
    
    side='LH';
    disp(['Processing LH of ' num2str(subID) '...'])
    try
        bpTractLoop(StudyFolder, subID, ds, threshold, side, tracts);
        disp('Completed LH')
    catch
        disp('LH failed')
        fail{s,1}=subID;
        fail{s,2}='LH';
    end
    
    side='RH';
    disp(['Processing RH of ' num2str(subID) '...'])
    try
        bpTractLoop(StudyFolder, subID, ds, threshold, side, tracts);
        disp('Completed RH')
    catch
        disp('RH failed')
        fail{s,1}=subID;
        fail{s,3}='RH';
    end
%%
end
% Save failed runs to .mat
if exist('fail', 'var')
    failPath=fullfile(StudyFolder, 'bp_failed.mat');
    save(failPath, 'fail');
end

disp('Finished.')