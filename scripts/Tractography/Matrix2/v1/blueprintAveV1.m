%%%%% Average fdt_matrices for all subjects and create a cifti
%%%%% Written by Shaun Warrington (05/2018)
function blueprintAve(StudyFolder, sub_list, ds, dt, threshold)
%% Set paths and prepare environment and data

%%%%%%%% Command lines for running from linux terminal %%%%%%%%%%%%%%%%%%%
% matlab_call='matlab -r -nodesktop -nojvm -nosplash "cd('"'"'/data/Q1200/scripts/Matrix2'"'"'); blueprintAve('"'"'/data/Q1200'"'"','"'"'/mydtifit/Diffusion/all_subjects.txt'"'"', 3, {'"'"'00'"'"'}, 0)"'
% $matlab_call
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
StudyFolder='/data/Q1200';
sub_list='/data/Q1200/Diffusion/all_subjects';
ds=3;
dt={'00'};
threshold=0;

%%
addpath /usr/local/fsl/etc/matlab
addpath /data/Q1200/scripts/Matrix2
addpath /Tools/gifti-1.6
addpath /Tools/Washington-University-cifti-matlab-f3aa924
addpath /Tools/ciftiHCP
DiffStudyFolder=[StudyFolder '/Diffusion'];
StrucStudyFolder=[StudyFolder '/Structural'];
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
clear i tline fID line
%%
resultsFolder=[DiffStudyFolder '/blueprint_averaging'];
cmd=(['if [ ! -d "' resultsFolder '" ]; then mkdir ' resultsFolder...
    '; else rm ' resultsFolder ' -r; mkdir ' resultsFolder '; fi']);
unix(cmd);

sub_list=load(sub_list); 
outliers=[168139 917255 101309 138534 144933 186141 200008 205725 206828 910443];
[sub_list,indV]=setdiff(sub_list,outliers);

%% Loop through all subjects
% Read the bpMat file (LH and RH) and zero-fill so that 32k
count=0;
for s=1:size(sub_list,1)
    subID=sub_list(s);
    bpPath=[DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/blueprint/'...
        num2str(ds) 'mmbpMat' num2str(dt{1}) 'LR32k.mat'];
    disp(['Loading ' num2str(subID) ' data'])
    % Load bpMat files
    try
        bpMat=load(bpPath);
        bpMat=bpMat.bpLR; bpMat=bpMat';
        bpAll(:,:,s-count)=bpMat;
    catch
        disp([num2str(subID) ' failed']);
        count=count+1;
    end
end
%% Average bpMat
noSubs=size(bpAll,3);
disp(['Loaded data for ' num2str(noSubs) ' subjects'])
disp('Averaging...')

% must use nanmean here otherwise results in erroneous surfaces
for i=1:size(tracts,2)
    meanbp(i,:)=mean(bpAll(i,:,:),3);
end
meanbp=meanbp';
meanbp(meanbp<threshold)=0;
%% Create the CIFTI file
% the tracts are the "time series"
% Common L/R descriptors - use existent CIFTI as template
cPath='Tools/template.dtseries.nii';
cifti=ft_read_cifti(cPath);

bpCii=cifti;
bpCii.time=linspace(1,size(tracts,2),size(tracts,2));
bpCii.hdr.dim(6)=size(meanbp,1);
bpCii.dtseries=meanbp;
%ciftiPath=fullfile(resultsFolder, ['average' num2str(noSubs) '_bpTracts']);

ciftiPath=fullfile(resultsFolder, ['other_average' num2str(noSubs) '_bpTracts']);

ft_write_cifti(ciftiPath, bpCii, 'parameter', 'dtseries');

% Save workbench scene file for viewing
%save_scene(ciftiPath, resultsFolder)
end