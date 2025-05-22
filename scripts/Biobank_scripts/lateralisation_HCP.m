%%%% lateralisation

%% Preamble
clear; clc
addpath /usr/local/fsl/etc/matlab

%cohort='Biobank';
cohort='HCP';

StudyFolder=['/mydtifit/scripts/LH_and_RH_comp/kattest/' cohort];

sublist=[StudyFolder '/sub_list'];
sublist=load(sublist);

if strcmp(cohort,'Biobank')
    sublist(190)=[];
end

% set options
thres=0.005;
%meth='MEAN';
meth='MEDIAN';

% % run for slf2_?_kattest2_symm
% % tracts={'slf1_l' 'slf1_r' 'slf2_l' 'slf2_r' 'slf3_l' 'slf3_r'};
% 
% %% Define tracts
% tracts={'MG_ac','MG_unc_l','MG_unc_r','af_l','af_r','ar_l,','ar_r','atr_l',...
%     'atr_r','cbd_l','cbd_r','cbp_l','cbp_r','cbt_l','cbt_r','cing_l',...
%     'cing_r','cst_l','cst_r','fa_l','fa_r','fma','fmi','fx_l','fx_r','ifo_l',...
%     'ifo_r','ilf_l','ilf_r','mcp','mdlf_l','mdlf_r','or_l','or_r',...
%     'slf1_l_kattest2_symm','slf1_r_kattest2_symm','slf2_l_kattest2_symm',...
%     'slf2_r_kattest2_symm','slf3_l_kattest2_symm','slf3_r_kattest2_symm',...
%     'str_l','str_r'};

tracts=importdata([StudyFolder '/lat_tracts_inv'])';
tracts=tracts([3 4 7 8 11:18]);

%% Load data and look for outliers
t=num2str(thres); t=t(3:end);
for i=1:length(tracts)
    temp=load([StudyFolder '/' tracts{i} '_' t]);
    Vol(:,i)=temp(:);
end; clear temp

%% check of NaN and outliers
indRm=[];
for i=1:length(sublist)
    totNaN=sum(sum(isnan(Vol(i,:))));
    if totNaN>0
        i
        totNaN
        indRm=[indRm i];
    end
end
Vol(indRm,:)=[]; sublist(indRm)=[];

% if subject is +/- outMul StDs from mean then outlier
subOL=[]; outMul=3; % the std multiplier
for i=1:length(tracts)
    TM=Vol(:,i);
    subOL=[subOL; find(mean(TM)-(outMul*std(TM))>TM | TM>mean(TM)+(outMul*std(TM)))];
end
subOL=unique(subOL);

Vol(subOL,:)=[]; sublist(subOL)=[];

%%
%% do lat calcs
Indl=find(contains(tracts, '_l'));
Indr=find(contains(tracts, '_r'));
for i=1:size(Vol,1)
    % Run through tracts and calculate lateralisation
    for k=1:size(Indl,2)
        % Calc difference
        latV(i,k)=(Vol(i,Indr(k))-Vol(i,Indl(k)))/(Vol(i,Indr(k))+Vol(i,Indl(k))); % Vol
    end
end

% Calculate the group average lateralisation and Wilcoxon
%%%%%%%%% vol
tractsUsed=tracts(Indl);
if strcmp(meth,'MEAN')
    for k=1:size(Indl,2)
        latAve(k)=nanmean(latV(:,k)); latVar(k)=var(latV(:,k));
        [h(k),p(k)]=ttest(latV(:,k));
    end
elseif strcmp(meth,'MEDIAN')
    for k=1:size(Indl,2)
        latAve(k)=nanmedian(latV(:,k)); latVar(k)=var(latV(:,k));
        [p(k),h(k)]=signrank(latV(:,k));
    end
end

% % Store results a table
resTab=table(tractsUsed', latAve', latVar', p');
resTab.Properties.VariableNames={'Tract', 'Average_lat', 'Variance', 'p_value'};
%writetable(resTab,['/data/Q1200/scripts/Biobank_scripts/' cohort '_' meth '_' t], 'WriteVariableNames', false, 'Delimiter', '\t');
resTab







% 
% 
% %% Plot results
% figure; hold on
% errorbar([1:size(latAve,2)],d,latStd, 'LineStyle', 'None', 'MarkerSize', 1);
% pTxt='plot(';
% for j=1:size(latAve,2)
%     if latAve(j)>=0
%         if h(j)==1
%             pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''*r'','];
%         elseif h(j)==0
%             pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''or'','];
%         end
%     elseif latAve(j)<0
%         if h(j)==1
%             pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''*g'','];
%         elseif h(j)==0
%             pTxt=[pTxt num2str(j) ',' num2str(d(j)) ',''og'','];
%         end
%     end
%     lab{j}=[tractsUsed{j}(1:strfind(tractsUsed{j},'_l')-1) ': ' num2str(j)];
% end
% pTxt=pTxt(1:end-1);
% pTxt=[pTxt ')']; eval(pTxt); ylabel('Lateralisation (+ is right, - is left)'); 
% xlim([0 size(tractsUsed,2)+1]); refline(0,0); xlabel('Tract number - * is significant');
% legend(['Standard Deviation' lab]); title('Tract-by-tract lateralisation using blueprint');
% hold off
% %print(['/mydtifit/scripts/LH_and_RH_comp/lateralisation/lat_figs_blueprint/all'], '-dpng','-r0');
% 
% %%
% clearvars -except Indl Indr tracts sublist tractsUsed; clc
% load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsVol.mat'); vol=resTab;
% load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsVolwP.mat'); volwP=resTab;
% load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsFA.mat'); FA=resTab;
% load('/mydtifit/scripts/LH_and_RH_comp/lateralisation/resultsFAwP.mat'); FAwP=resTab; clear resTab
% 
% %% tractsUsed
% % af=1, mdlf=13, slf1,2,3=16,17,18
% j=18;
% tTab(1,:)=[vol.Average_lat(j) vol.Variance(j) vol.Cohens_d(j) vol.p_value(j)];
% tTab(2,:)=[volwP.Average_lat(j) volwP.Variance(j) volwP.Cohens_d(j) volwP.p_value(j)];
% tTab(3,:)=[FA.Average_lat(j) FA.Variance(j) FA.Cohens_d(j) FA.p_value(j)];
% tTab(4,:)=[FAwP.Average_lat(j) FAwP.Variance(j) FAwP.Cohens_d(j) FAwP.p_value(j)];
% disp('     Lat       Var      Cohens d   p-val'); disp(tTab);