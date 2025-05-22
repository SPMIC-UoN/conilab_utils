function bpTractLoop(StudyFolder, subID, ds, threshold, side, tracts)
addpath /usr/local/fsl/etc/matlab
stdref='/usr/local/fsl/data/standard/MNI152_T1_2mm_brain_mask';

DiffStudyFolder=[StudyFolder '/Diffusion'];
StrucStudyFolder=[StudyFolder '/Structural'];

% Read in and convert fdt_matrix2
disp('Reading and converting fdt matrix...')
disp('')

% change the number after 'mm to be the distance threshold value
mat2Folder=([DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/Tractography/' num2str(ds) 'mm3/' side]);
fdt=full(spconvert(load([mat2Folder '/fdt_matrix2.dot'])));

% Read in tract file to produce mask
[mask,~,~]=read_avw([mat2Folder '/Mat2_target.nii.gz']);
mask=0*mask;
% Read coord file
coord=load([mat2Folder '/tract_space_coords_for_fdt_matrix2'])+1;
ind=sub2ind(size(mask),coord(:,1),coord(:,2),coord(:,3));
disp('Finished reading fdt matrix')
%% Loop through Ptx tracts
disp('Processing tracts...');
disp('')
PtxFolder=([DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/autoPtx']);
tractMap=cell(1,size(tracts,2));
for i=1:size(tracts,2)
    
    t_in=([PtxFolder '/' tracts{i} '/tracts/tractsNorm']);
    tempFolder=([PtxFolder '/' tracts{i} '/tracts/resampled']);
    t_out=([tempFolder '/tractsNorm_' num2str(ds)]);
    
    % Check if results folder/file exists - delete and create new
    cmd=(['if [ -d "' tempFolder '" ]; then if [ -e "' t_out '.nii.gz" ]; then rm ' ...
        t_out '.nii.gz; fi else mkdir ' tempFolder '; fi']);
    unix(cmd);
    
    % Downsample the tract file
    cmd=(['$FSLDIR/bin/flirt -in ' t_in ' -ref ' stdref ' -out ' t_out ...
        ' -applyisoxfm ' num2str(ds) ' -interp trilinear']);
    unix(cmd);
    
    %Threshold and mask the tract file using the Mat2_target file
    %Threshold here????
    t_mask=([t_in '_' num2str(ds) '_masked']);
%     cmd=(['$FSLDIR/bin/fslmaths ' t_out ' -thr ' num2str(threshold) ' ' t_mask]);
%     unix(cmd);
    cmd=(['$FSLDIR/bin/fslmaths ' t_out ' -mas ' mat2Folder '/Mat2_target ' t_mask]);
    unix(cmd);
    
    % Remove temp folder
    unix(['rm ' tempFolder ' -r']);
    
    % Read in masked tract file
    tractMat=read_avw(t_mask);
    dim=[size(tractMat,1),size(tractMat,2),size(tractMat,3)];
    tractMat=tractMat(:);
    % Loop through tract mat file, linearise and reorder to fdt coords
    tractMat_lin=zeros(size(fdt,2),1);
    for j=1:size(fdt,2)
        tractMat_lin(j)=tractMat(ind(j));
    end
    tractMap{i}=tractMat_lin;
    unix(['rm ' t_mask '.nii.gz']);
    
    disp(['Completed ' num2str(i) ' of ' num2str(size(tracts,2))])
    disp('')
end
disp('Finished processing tracts')
disp('')
disp('Calculating blueprint connectivity map...')
% Convert tract map and multiply by fdt matrix
tractMap=cell2mat(tractMap);
tractMap=tractMap';
bpMat=tractMap*fdt';

disp('Removing ml_l, ml_r and mcp tracts')
% Remove ml (_l [9] and _r [26]) and mcp [25]
bpMat(9,:)=[];
bpMat(25,:)=[];
bpMat(26,:)=[];

% Normalise blueprint connectivity rows
bpMatNorm=zeros(size(bpMat,1),size(bpMat,2));
for k=1:size(bpMat,2)
    tot=sum(bpMat(:,k));
    bpMatNorm(:,k)=bpMat(:,k)./tot;
end
bpMat=bpMatNorm;
% Threshold here? Makes more sense...
bpMat(bpMat<threshold)=0;

disp('Saving...')
% Save blueprint to /blueprint folder --- CHANGE THE NUMBER
bpPath=fullfile(DiffStudyFolder, num2str(subID),'MNINonLinear/Results/blueprint', ...
    [num2str(ds) 'mmbpMat3' side '.mat']);
save(bpPath, 'bpMat');

if side=='RH'
    % Save as CIFTI
    savebpCii(bpPath, subID, StrucStudyFolder, dim, ds);
end
end