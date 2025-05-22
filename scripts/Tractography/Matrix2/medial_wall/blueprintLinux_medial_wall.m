%%%%% Create tract by WM matrix for connectivity blueprint
%%%%% Shell script which calls loop script
%%%%% Written by Shaun Warrington (05/2018)
function blueprintLinux_medial_wall(StudyFolder, sub_list, ds, dt, threshold)
% StudyFolder='/mydtifit';
% subID=100307;
% ds = 3;
% dt = {'00'};
% threshold = 0;
sub_list='mydtifit/Diffusion/test_subs';

StudyFolder='/data/Q1200';
ds = 3;
dt = {'00'};
threshold = 0.001;
%sub_list='/data/Q1200/Diffusion/all_subjects';

%%%%%%%% Command lines for running from linux terminal %%%%%%%%%%%%%%%%%%%
% matlab_call='matlab -r -nodesktop -nojvm -nosplash "cd('"'"'/data/Q1200/scripts/Matrix2'"'"'); blueprintLinux('"'"'/data/Q1200'"'"','"'"'/mydtifit/Diffusion/all_subjects.txt'"'"', 3, {'"'"'00'"'"'}, 0)"'
% $matlab_call
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set paths and prepare environment and data
addpath /usr/local/fsl/etc/matlab
addpath /data/Q1200/scripts/Matrix2/medial_wall
DiffStudyFolder=[StudyFolder '/Diffusion'];
% failPath=[DiffStudyFolder '/failedBP_atlas.txt'];
% compPath=[DiffStudyFolder '/compBP_atlas.txt'];
%% Define tracts
fID=fopen('/data/Q1200/scripts/fsl_autoPtx_v3/structureList');
tline=fgetl(fID);
i=0;
while ischar(tline)
    i=i+1;
    line=strsplit(tline);
    tracts{i}=line{1};
    tline=fgetl(fID);
end
fclose(fID);
tracts(1:7)=[];
% Remove unc and cing
%tracts([13 14 40 41])=[];

sub_list=load(sub_list);
%% Loop through all subjects
parfor s=1:size(sub_list,1)
    
    subID=sub_list(s);
    
    resultsFolder=[DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/blueprint_test'];
    cmd=(['if [ ! -d "' resultsFolder '" ]; then mkdir ' resultsFolder '; else rm '...
        resultsFolder ' -r; mkdir ' resultsFolder '; fi']);
    unix(cmd);
    
    % Process the left hemisphere
    side='LH';
    disp('     ')
    disp(['Processing LH of ' num2str(subID) '...'])
    disp('     ')
    try
        bpTractLoopLinux_medial_wall(StudyFolder, subID, ds, dt, threshold, side, tracts);
        disp('Completed LH')
%         comp=[num2str(subID) ' LH'];
%         unix(['echo "' comp '" >> ' compPath]);
    catch
        disp('LH failed')
%         fail=[num2str(subID) ' LH'];
%         unix(['echo "' fail '" >> ' failPath]);
    end
    
    % Process the right hemisphere
    side='RH';
    disp('     ')
    disp(['Processing RH of ' num2str(subID) '...'])
    disp('     ')
    try
        bpTractLoopLinux_medial_wall(StudyFolder, subID, ds, dt, threshold, side, tracts);
%         comp=[num2str(subID) ' RH'];
%         unix(['echo "' comp '" >> ' compPath]);
    catch
        disp('RH failed')
%         fail=[num2str(subID) ' RH'];
%         unix(['echo "' fail '" >> ' failPath]);
    end
    disp('     ')
    disp(['Finished processing ' num2str(subID)])
    disp('.')
    disp('..')
    disp('...')
end
disp('Finished!')