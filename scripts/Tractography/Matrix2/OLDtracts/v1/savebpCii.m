function savebpCii(bpPath, subID, StrucStudyFolder, dim, ds)
addpath /usr/local/fsl/etc/matlab
addpath /home//Tools/gifti-1.6/
addpath /home//Tools/Washington-University-cifti-matlab-f3aa924
addpath /home//Tools/ciftiHCP

rsFolder=fileparts(bpPath);

tracts={'ar_l', 'atr_l', 'cgc_l', 'cgh_l', 'cst_l', 'fma','ifo_l','ilf_l', 'ptr_l', 'slf_l', 'str_l', 'unc_l', 'slf1_l','slf2_l','slf3_l',...
    'ar_r', 'atr_r', 'cgc_r', 'cgh_r', 'cst_r', 'fmi','ifo_r','ilf_r', 'ptr_r','slf_r', 'str_r', 'unc_r','slf1_r','slf2_r','slf3_r'};
% Seperate tracts to L/R (for cifti saving)

disp('Loading blueprint connectivity map and surface/mask GIFTI files')
% CHANGE NUMBER HERE TO MATCH DISTANCE THRESHOLD
bpMatL=load([rsFolder '/' num2str(ds) 'mmbpMat3LH.mat']);
bpMatR=load([rsFolder '/' num2str(ds) 'mmbpMat3RH.mat']);
bpMatL=bpMatL.bpMat;
bpMatL=bpMatL';
bpMatR=bpMatR.bpMat;
bpMatR=bpMatR';
fsAvpath=fullfile(StrucStudyFolder, num2str(subID), ['MNINonLinear/fsaverage_LR32k/' num2str(subID)]);
maskL=gifti([fsAvpath '.L.atlasroi.32k_fs_LR.shape.gii']);
maskL=maskL.cdata;
maskR=gifti([fsAvpath '.R.atlasroi.32k_fs_LR.shape.gii']);
maskR=maskR.cdata;

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

disp('Preparing CIFTI files...')

% the tracts are the "time series"
%% Common L/R descriptors - use existent CIFTI as template
cPath='/home//Tools/template.dtseries.nii';
cifti=ft_read_cifti(cPath);

bpCii=cifti;
bpCii.time=linspace(1,size(tracts,2),size(tracts,2));
bpCii.hdr.dim(6)=size(bpLR,1);
bpCii.dtseries=bpLR;

ciftiPath=fullfile(rsFolder, 'bpTracts');
ft_write_cifti(ciftiPath, bpCii, 'parameter', 'dtseries');

view_command=['/usr/local/workbench/bin_rh_linux64/wb_view ' fsAvpath ...
    '.L.inflated.32k_fs_LR.surf.gii ' fsAvpath '.R.inflated.32k_fs_LR.surf.gii ' ciftiPath '.dtseries.nii &'];
unix(['echo "' view_command '" >> ' rsFolder '/view.sh']);
unix(['chmod 777 ' rsFolder '/view.sh']);

end