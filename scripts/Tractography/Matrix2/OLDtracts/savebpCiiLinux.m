%%%%% Function to save blueprint connectivity CIFTI file
%%%%% Written by Shaun Warrington (05/2018)
function savebpCiiLinux(bpPath, subID, StrucStudyFolder, dim, ds, dt, tracts)
%% Preamble
addpath /usr/local/fsl/etc/matlab
addpath /home//Tools/gifti-1.6/
addpath /data/Q1200/scripts/
addpath /home//Tools/Washington-University-cifti-matlab-f3aa924
addpath /home//Tools/ciftiHCP
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
fsAvpath=fullfile(StrucStudyFolder, num2str(subID), ['MNINonLinear/fsaverage_LR32k/' num2str(subID)]);
maskL=gifti([fsAvpath '.L.atlasroi.32k_fs_LR.shape.gii']);
maskL=maskL.cdata;
maskR=gifti([fsAvpath '.R.atlasroi.32k_fs_LR.shape.gii']);
maskR=maskR.cdata;

%% Resizing from 29k to 32k
% Loop through the bpMat for each hemisphere and resize to 32k
disp('Converting from 29k to 32k...')
bpLaug=zeros(size(maskL,1), size(bpMatL,2));
k=0;
for i=1:size(maskL,1)
    if maskL(i)==1
        bpLaug(i,:)=bpMatL(i-k,:);
    elseif maskL(i)==0
        bpLaug(i,:)=bpLaug(i,:);
        k=k+1;
    end
end
bpRaug=zeros(size(maskR,1), size(bpMatR,2));
k=0;
for i=1:size(maskR,1)
    if maskR(i)==1
        bpRaug(i,:)=bpMatR(i-k,:);
    elseif maskR(i)==0
        bpRaug(i,:)=bpRaug(i,:);
        k=k+1;
    end
end
bpLR=cat(1,bpLaug,bpRaug);
disp('     ')
disp('Saving CIFTI file...')
% Save blueprint to /blueprint folder
svPath=fullfile(rsFolder, [num2str(ds) 'mmbpMat' num2str(dt{1}) 'LR32k.mat']);
save(svPath, 'bpLR');

%% Create the CIFTI file
% the tracts are the "time series"
% Common L/R descriptors - use existent CIFTI as template
cPath='/home//Tools/template.dtseries.nii';
cifti=ft_read_cifti(cPath);

bpCii=cifti;
bpCii.time=linspace(1,size(tracts,2),size(tracts,2));
bpCii.hdr.dim(6)=size(bpLR,1);
bpCii.dtseries=bpLR;
ciftiPath=fullfile(rsFolder, 'bpTracts');
ft_write_cifti(ciftiPath, bpCii, 'parameter', 'dtseries');

% Save workbench scene file for viewing
save_scene(ciftiPath, rsFolder)

%% Clean up
 clear maskL maskR bpMatL bpMatR bpLaug bpLR bpRaug 
end