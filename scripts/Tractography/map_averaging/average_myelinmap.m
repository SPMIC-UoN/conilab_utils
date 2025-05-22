StudyFolder='/data/Q1200';
sub_list=load('/data/Q1200/Diffusion/all_subjects');

addpath /usr/local/fsl/etc/matlab
addpath Tools/gifti-1.6
StrucStudyFolder=[StudyFolder '/Structural'];

%%
resultsFolder=[StrucStudyFolder '/average_myelinmap'];
% cmd=(['if [ ! -d "' resultsFolder '" ]; then mkdir ' resultsFolder...
%     '; else rm ' resultsFolder ' -r; mkdir ' resultsFolder '; fi']);
% unix(cmd);

%% Loop through all subjects
count=0;
for s=1:size(sub_list,1)
    subID=sub_list(s);
    myePath=[StrucStudyFolder '/' num2str(subID) '/MNINonLinear/fsaverage_LR32k/'...
        num2str(subID) '.L.MyelinMap.32k_fs_LR.func.gii'];
    disp(['Loading ' num2str(subID) ' data'])
    % Load bpMat files
    try
        myeMat=gifti(myePath);
        myeMat=myeMat.cdata;
        myeAll(:,s-count)=myeMat;
    catch
        disp([num2str(subID) ' failed']);
        count=count+1;
    end
end
%% Average
noSubs=size(myeAll,2);
disp(['Loaded data for ' num2str(noSubs) ' subjects'])
disp('Averaging...')

% must use nanmean here otherwise results in erroneous surfaces
for i=1:size(myeAll,1)
    meanmye(i,:)=nanmean(myeAll(i,:),2);
end
%% 
gii=gifti('/data/Q1200/Structural/100206/MNINonLinear/fsaverage_LR32k/100206.R.MyelinMap.32k_fs_LR.func.gii');
gii.cdata=meanmye;
giiPath=fullfile(resultsFolder, 'average_myemap_L_onR.func.gii');

save(gii,giiPath);

