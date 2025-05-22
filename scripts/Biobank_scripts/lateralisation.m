%%%% Playing with LH vs RH
%%%% Comparing left-right blueprint tracts
%%%% Should use raw autoPtx tracts?

%% Preamble
clear; clc
addpath /usr/local/fsl/etc/matlab
sublist='/data/UK_Biobank/subjects.txt';
StudyFolder='/data/UK_Biobank';

sublist=load(sublist);

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
tracts(1:7)=[]; tracts=tracts([1 2 25 26 28 29 34:39]);
clear tline fID i line

%% Load in tract stats from dMRI CCA - Vol, MeanP
for i=1:length(tracts)
    Vol(:,i)=load([StudyFolder '/tract_stats/' tracts{i}]);
end

Indl=find(contains(tracts, '_l'));
Indr=find(contains(tracts, '_r'));
for i=1:size(sublist,2)
    % Run through tracts and calculate lateralisation
    for k=1:size(Indl,2)
        % Calc difference
        latV(i,k)=(Vol(i,Indr(k))-Vol(i,Indl(k)))/(Vol(i,Indr(k))+Vol(i,Indl(k))); % Vol
    end
end

%% Calculate the group average lateralisation and Wilcoxon
%%%%%%%%% vol
tractsUsed=tracts(Indl);
for k=1:size(Indl,2)
    latAve(k)=nanmean(latV(:,k)); latStd(k)=nanstd(latV(:,k));
    [p(k),h(k),stats]=signrank(latV(:,k)); latVar(k)=var(latV(:,k));
    zVal(k)=stats.zval; d(k)=zVal(k)/sqrt(size(sublist,2));    
end
% Store results a table
resTab=table(tractsUsed', latAve', latStd', latVar', p', h', zVal', d');
resTab.Properties.VariableNames={'Tract', 'Average_lat', 'Std', 'Variance', 'p_value', 'h', 'Z_value', 'Cohens_d'};
save('/data/UK_Biobank/lateralisation.mat','resTab');






%% Plot results
figure; hold on
errorbar([1:size(latAve,2)],d,latStd, 'LineStyle', 'None', 'MarkerSize', 1);
pTxt='plot(';
for j=1:size(latAve,2)
    if latAve(j)>=0
        if h(j)==1
            pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''*r'','];
        elseif h(j)==0
            pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''or'','];
        end
    elseif latAve(j)<0
        if h(j)==1
            pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''*g'','];
        elseif h(j)==0
            pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''og'','];
        end
    end
    lab{j}=[tractsUsed{j}(1:strfind(tractsUsed{j},'_l')-1) ': ' num2str(j)];
end
pTxt=pTxt(1:end-1);
pTxt=[pTxt ')']; eval(pTxt); ylabel('Lateralisation (+ is right, - is left)'); 
xlim([0 size(tractsUsed,2)+1]); refline(0,0); xlabel('Tract number - * is significant');
legend(['Standard Deviation' lab]); title('Tract-by-tract lateralisation using blueprint');
hold off
%print(['/mydtifit/scripts/LH_and_RH_comp/lateralisation/lat_figs_blueprint/all'], '-dpng','-r0');

%%
clearvars -except Indl Indr tracts sublist tractsUsed; clc
load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsVol.mat'); vol=resTab;
load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsVolwP.mat'); volwP=resTab;
load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsFA.mat'); FA=resTab;
load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsFAwP.mat'); FAwP=resTab; clear resTab

%% tractsUsed
% af=1, mdlf=13, slf1,2,3=16,17,18
j=18;
tTab(1,:)=[vol.Average_lat(j) vol.Variance(j) vol.Cohens_d(j) vol.p_value(j)];
tTab(2,:)=[volwP.Average_lat(j) volwP.Variance(j) volwP.Cohens_d(j) volwP.p_value(j)];
tTab(3,:)=[FA.Average_lat(j) FA.Variance(j) FA.Cohens_d(j) FA.p_value(j)];
tTab(4,:)=[FAwP.Average_lat(j) FAwP.Variance(j) FAwP.Cohens_d(j) FAwP.p_value(j)];
disp('     Lat       Var      Cohens d   p-val'); disp(tTab);