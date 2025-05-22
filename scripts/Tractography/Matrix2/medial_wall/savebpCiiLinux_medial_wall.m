%%%%% Function to save blueprint connectivity CIFTI file
%%%%% Written by Shaun Warrington (05/2018)
function savebpCiiLinux_medial_wall(bpPath, subID, StrucStudyFolder, dim, ds, dt, tracts)
%% Preamble
addpath /usr/local/fsl/etc/matlab
addpath /Tools/gifti-1.6/
addpath /data/Q1200/scripts/Matrix2/medial_wall
addpath /Tools/Washington-University-cifti-matlab-f3aa924
rsFolder=fileparts(bpPath);
%%

disp('Getting data...')

% Load the blueprint.mat files and surface GIFTI files
bpMatL=load([rsFolder '/' num2str(ds) 'mmbpMat' num2str(dt{1}) 'LH.mat']);
bpMatR=load([rsFolder '/' num2str(ds) 'mmbpMat' num2str(dt{1}) 'RH.mat']);
bpMatL=bpMatL.bpMat;
bpMatL=bpMatL';
bpMatR=bpMatR.bpMat;
bpMatR=bpMatR';

bpLR=cat(1,bpMatL,bpMatR);
disp('     ')
disp('Saving CIFTI file...')
% Save blueprint to /blueprint folder
svPath=fullfile(rsFolder, [num2str(ds) 'mmbpMat' num2str(dt{1}) 'LR32k.mat']);
save(svPath, 'bpLR');

%% Create the CIFTI file
% the tracts are the "time series"
% Common L/R descriptors - use existent CIFTI as template
cPath='/Tools/template.dtseries.nii';
cifti=ft_read_cifti(cPath);

bpCii=cifti;
bpCii.time=linspace(1,size(tracts,2),size(tracts,2));
bpCii.hdr.dim(6)=size(bpLR,1);
bpCii.dtseries=bpLR;
ciftiPath=fullfile(rsFolder, 'bpTracts');
ft_write_cifti(ciftiPath, bpCii, 'parameter', 'dtseries');

% Save workbench scene file for viewing
save_scene_medial_wall(ciftiPath, rsFolder)

%% Clean up
 clear maskL maskR bpMatL bpMatR bpLaug bpLR 
end