%%%%% Create tract by WM matrix for connectivity blueprint
%%%%% Shell script which calls loop script
function blueprintLinux(StudyFolder, sub_list, ds, dt, threshold)
% StudyFolder='/home//mydtifit'
% subID=100206
% ds = downsampling = resolution of the downsampled Mat2_target (2mm?)
% dt = distance threshold (2mm?)
% threshold = image/noise threshold (values < threshold = 0)

%% Set paths and prepare environment and data
addpath /usr/local/fsl/etc/matlab
addpath /data/Q1200/scripts/Matrix2
DiffStudyFolder=[StudyFolder '/Diffusion'];
failPath=[DiffStudyFolder '/failedBP.txt'];
% Define tracts
tracts={'ar_l', 'atr_l', 'cgc_l', 'cgh_l', 'cst_l', 'fma','ifo_l','ilf_l', 'ml_l', 'ptr_l', 'slf_l', 'str_l', 'unc_l', 'slf1_l','slf2_l','slf3_l',...
    'ar_r', 'atr_r', 'cgc_r', 'cgh_r', 'cst_r', 'fmi','ifo_r','ilf_r', 'mcp','ml_r', 'ptr_r','slf_r', 'str_r', 'unc_r','slf1_r','slf2_r','slf3_r'};

sub_list=load(sub_list);
% Loop through all subjects
for s=1:size(sub_list,1)
    
    subID=sub_list(s);
    
    resultsFolder=[DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/blueprint'];
    cmd=(['if [ ! -d "' resultsFolder '" ]; then mkdir ' resultsFolder '; else rm ' resultsFolder ' -r; mkdir ' resultsFolder '; fi']);
    unix(cmd);
    
    %% Process the left hemisphere
    side='LH';
    unix(['echo "Processing LH of ' num2str(subID) '..."']);
    try
        bpTractLoopLinux(StudyFolder, subID, ds, dt, threshold, side, tracts);
        unix('echo "Completed LH"');
    catch
        unix('echo "LH failed"');
        fail=[num2str(subID) ' LH'];
        unix(['echo "' fail '" >> ' failPath]);
    end
    
    %% Process the right hemisphere
    side='RH';
    unix(['echo "Processing RH of ' num2str(subID) '..."']);
    try
        bpTractLoopLinux(StudyFolder, subID, ds, dt, threshold, side, tracts);
    catch
        unix('echo "RH failed"');
        fail=[num2str(subID) ' RH'];
        unix(['echo "' fail '" >> ' failPath]);
    end
    unix(['echo "Finished processing' num2str(subID) '"']);
end
exit