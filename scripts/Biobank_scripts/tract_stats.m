%%%% Script to extract tract stats from all subjects - adapted from Stam
%%%% Also prepare behavioural data
%% Env setup
addpath /Tools/FSLNets
addpath /Tools/palm-alpha110b
addpath /Tools/NearestSymmetricPositiveDefinite
addpath /Tools
addpath /usr/local/fsl/etc/matlab

clear all;  clc;

StudyFolder='/data/UK_Biobank';
Prob_thresh=0.005; %Probability threshold for defining a tract

subject_list=load('/data/UK_Biobank/subjects.txt')'; % List of subjects


%% Read tract names
fID=fopen('/data/Q1200/scripts/fsl_autoPtx_v3/structureList');
tline=fgetl(fID); i=0;
while ischar(tline)
    i=i+1;
    line=strsplit(tline); tracts{i}=line{1}; tline=fgetl(fID);
end
fclose(fID);
tracts(1:7)=[];
% remove unc_l and r
tracts=tracts([1 2 25 26 28 29 34:39]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Extract stats %%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract Volume and Mean Probability of each tract
%Volume for each tract (number of voxels as it is 1mm3 voxels)
%Vol=zeros(length(subject_list),length(tracts));
%Mean Probability of each tract (or multiply by number of voxels to get sum
%of probabilities, i.e. volume weighted by probs
%MeanP=Vol;
unix('mkdir /data/UK_Biobank/CCA');
unix('mkdir /data/UK_Biobank/CCA/tract_stats');
unix('mkdir /data/UK_Biobank/CCA/tract_stats/temp');
x=input('How many parpools? ');
parpool(x);
%%
parfor i=1:length(subject_list)
    SPath=[StudyFolder '/' num2str(subject_list(i)) '/autoPtx/tracts'];
    unix(['mkdir /data/UK_Biobank/CCA/tract_stats/temp/' num2str(subject_list(i))]);
    for j=1:length(tracts)
        [~,t]=unix(['$FSLDIR/bin/fslstats ' SPath '/' tracts{j} '/densityNorm.nii.gz -l ' num2str(Prob_thresh) ' -V -M | awk ''{print $2, $3}''']);
        t=str2num(t);
        Vol=t(1); MeanP=t(2);
        SvPath=['/data/UK_Biobank/CCA/tract_stats/temp/' num2str(subject_list(i)) '/' tracts{j} '_vol_MP.mat'];
        SvStruct=[Vol MeanP];
        parsave(SvPath,SvStruct);
    end
end

% Load in saved vars
for i=1:length(subject_list)
    tempPath=(['/data/UK_Biobank/CCA/tract_stats/temp/' num2str(subject_list(i))]);
    for j=1:length(tracts) 
        tractPath=([tempPath '/' tracts{j} '_vol_MP.mat']);
        load(tractPath);
        Vol(i,j)=SvStruct(1); MeanP(i,j)=SvStruct(2);
    end
end

VolwP=Vol.*MeanP; %Volume of tract weighted by path probabilities (works out like that, because we have 1 mm3 voxels 
                  %and the Volume is the total number of voxels in each
                  %tract). So MeanP*Num of voxels = Sum of Proabilities in
                  %the tract.
save('/data/UK_Biobank/CCA/vol_prob.mat', 'Vol', 'MeanP', 'VolwP');
clear Vol MeanP