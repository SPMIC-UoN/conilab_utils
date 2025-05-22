%%%%% Create tract by WM matrix for connectivity blueprint
%%%%% Shell script which calls loop script
%%%%% Written by Shaun Warrington (05/2018)
function blueprintLinux_atlas(StudyFolder, sub_list, ds, dt, threshold)
% StudyFolder='/mydtifit';
% subID=100307;
% ds = 3;
% dt = {'00'};
% threshold = 0;
%sub_list='mydtifit/test100';

StudyFolder='/data/Q1200';
ds = 3;
dt = {'00'};
threshold = 0.001;
sub_list='/data/Q1200/Diffusion/all_subjects';

%%%%%%%% Command lines for running from linux terminal %%%%%%%%%%%%%%%%%%%
% matlab_call='matlab -r -nodesktop -nojvm -nosplash "cd('"'"'/data/Q1200/scripts/Matrix2'"'"'); blueprintLinux('"'"'/data/Q1200'"'"','"'"'/mydtifit/Diffusion/all_subjects.txt'"'"', 3, {'"'"'00'"'"'}, 0)"'
% $matlab_call
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set paths and prepare environment and data
addpath /usr/local/fsl/etc/matlab
addpath /data/Q1200/scripts/Matrix2/atlas_blueprinting
DiffStudyFolder=[StudyFolder '/Diffusion'];
failPath=[DiffStudyFolder '/failedBP_atlas.txt'];
compPath=[DiffStudyFolder '/compBP_atlas.txt'];
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
tracts([13 14 40 41])=[];

sub_list=load(sub_list);
%% Loop through all subjects
parfor s=1:size(sub_list,1)
    
    subID=sub_list(s);
    
    resultsFolder=[DiffStudyFolder '/' num2str(subID) '/MNINonLinear/Results/blueprint_atlas'];
    cmd=(['if [ ! -d "' resultsFolder '" ]; then mkdir ' resultsFolder '; else rm '...
        resultsFolder ' -r; mkdir ' resultsFolder '; fi']);
    unix(cmd);
    
    % Process the left hemisphere
    side='LH';
    disp('     ')
    disp(['Processing LH of ' num2str(subID) '...'])
    disp('     ')
    try
        bpTractLoopLinux_atlas(StudyFolder, subID, ds, dt, threshold, side, tracts);
        disp('Completed LH')
        comp=[num2str(subID) ' LH'];
        unix(['echo "' comp '" >> ' compPath]);
    catch
        disp('LH failed')
        fail=[num2str(subID) ' LH'];
        unix(['echo "' fail '" >> ' failPath]);
    end
    
    % Process the right hemisphere
    side='RH';
    disp('     ')
    disp(['Processing RH of ' num2str(subID) '...'])
    disp('     ')
    try
        bpTractLoopLinux_atlas(StudyFolder, subID, ds, dt, threshold, side, tracts);
        comp=[num2str(subID) ' RH'];
        unix(['echo "' comp '" >> ' compPath]);
    catch
        disp('RH failed')
        fail=[num2str(subID) ' RH'];
        unix(['echo "' fail '" >> ' failPath]);
    end
    disp('     ')
    disp(['Finished processing ' num2str(subID)])
    disp('.')
    disp('..')
    disp('...')
end
disp('Finished!')



%% RMSE between atlas/ind blueprints
StudyFolder='/data/Q1200';
sub_list=load('/data/Q1200/Diffusion/all_subjects');
addpath /Tools/Washington-University-cifti-matlab-f3aa924

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

count=0;
for i=1:length(sub_list)
    disp(num2str(sub_list(i)))
    try
        indBP=ft_read_cifti([StudyFolder '/Diffusion/' num2str(sub_list(i)) '/MNINonLinear/Results/blueprint/bpTracts.dtseries.nii']);
        atlasBP=ft_read_cifti([StudyFolder '/Diffusion/' num2str(sub_list(i)) '/MNINonLinear/Results/blueprint_atlas/bpTracts.dtseries.nii']);
        indBP=indBP.dtseries; atlasBP=atlasBP.dtseries;
        indBP(:,38)=[]; atlasBP(:,38)=[];
        rmse(i-count,:)=sqrt((sum(power((atlasBP-indBP),2))/length(atlasBP)));
        perc(i-count,:)=nanmean((atlasBP-indBP)./(0.5*(atlasBP+indBP)),1)*100;
        for k=1:size(indBP,2)
            [p(i-count,k),h,stats]=ranksum(atlasBP(:,k),indBP(:,k));
            d(i-count,k)=stats.zval/sqrt(size(indBP,1));
            Nrmse(i-count,k)=rmse(i-count,k)/(mean(atlasBP(atlasBP(:,k)~=0)));
        end
    catch
        count=count+1;
    end
end
save('blueprint_comparison1.mat', 'p', 'rmse', 'Nrmse', 'd', 'sub_list', 'tracts')


%%
load('blueprint_comparison1.mat')


% boxplot
for k=1:41
    g(size(d,1),k)=string(tracts(k));
end
figure; hold on
boxplot(d(:),g(:)) % too big

% mean RMSE
mRMSE=mean(rmse,1);
stdRMSE=std(rmse,0,1);

errorbar(mRMSE,stdRMSE); ylabel('Mean RMSE (+/- std)'); xlabel('Tract number')


% mean RMSE
Nrmse(isinf(Nrmse))=0;
mNRMSE=mean(Nrmse,1);
stdNRMSE=std(Nrmse,0,1);

errorbar(mNRMSE,stdNRMSE); ylabel('Mean NRMSE (+/- std)'); xlabel('Tract number')


% mean perc
mperc=mean(perc,1);
stdperc=std(perc,0,1);

figure; errorbar(mperc,stdperc); ylabel('Mean Percentage Difference (+/- std)'); xlabel('Tract number')
[h,p,ci,stats] = ttest(perc)

% absolute mean perc
for k=1:41
    mAperc(1,k)=meanabs(perc(:,k));
end
stdperc=mad(perc,0,1);
Aperc=abs(perc);
figure; errorbar(mAperc,stdperc); ylabel('Mean Percentage Difference (+/- std)'); xlabel('Tract number')
[h,p,ci,stats] = ttest(Aperc)





