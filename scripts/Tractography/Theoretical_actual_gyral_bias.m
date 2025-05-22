addpath matlab/CIFTIMatlabReaderWriter_old
addpath matlab

clear all;
clc;

StudyFolder='/vols/Scratch/HCP/Diffusion/7T+3T/JuneTests';
Subjects={'109123', '158035', '167036', '169343', '770352'};
Method={'Conn3_sum.dscalar.nii'};
Method_name={'3T'};
Res={'1.25'};
Hemis={'L','R'}; Struct={'CORTEX_LEFT','CORTEX_RIGHT'};
ZeroCurvThresh='0.05';

%%
% Compute expected (theoretical) gyral bias 
for s=1:length(Subjects)
    s
    subj=Subjects{s};
    surfDir=[StudyFolder '/' subj '/T1w/fsaverage_LR32k'];
    MNIDir=[StudyFolder '/' subj '/MNINonLinear/fsaverage_LR32k'];
    TractDir=[StudyFolder '/' subj '/MNINonLinear/Results/Tractography'];
    TmpDir=[MNIDir '/temp'];
    unix(['mkdir -p ' TmpDir]);    
    for h=1:length(Hemis)
        unix(['wb_command -surface-vertex-areas ' MNIDir '/' subj '.' Hemis{h} '.white.32k_fs_LR.surf.gii ' TmpDir '/' subj '.' Hemis{h} '.white.32k_fs_LR.func.gii']);
        unix(['wb_command -surface-wedge-volume ' MNIDir '/' subj '.' Hemis{h} '.white.32k_fs_LR.surf.gii ' MNIDir '/' subj '.' Hemis{h} '.pial.32k_fs_LR.surf.gii ' TmpDir '/' subj '.' Hemis{h} '.wedge.32k_fs_LR.func.gii']);
        unix(['wb_command -metric-math "Wedge / WhiteArea" ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii -var Wedge ' TmpDir '/' subj '.' Hemis{h} '.wedge.32k_fs_LR.func.gii -var WhiteArea ' TmpDir '/' subj '.' Hemis{h} '.white.32k_fs_LR.func.gii']);
        unix(['wb_command -metric-mask ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii ' MNIDir '/' subj '.' Hemis{h} '.atlasroi.32k_fs_LR.shape.gii ' MNIDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii ']);
     
        %Find mean around zero curvature
        unix(['wb_command -metric-math "(x>=-' ZeroCurvThresh ')*(x<=' ZeroCurvThresh ')" '  TmpDir '/' subj '.' Hemis{h} '.curvature.32k_fs_LR.shape.gii -var x ' MNIDir '/' subj '.' Hemis{h} '.curvature.32k_fs_LR.shape.gii']);
        unix(['wb_command -metric-mask ' TmpDir '/' subj '.' Hemis{h} '.curvature.32k_fs_LR.shape.gii ' MNIDir '/' subj '.' Hemis{h} '.atlasroi.32k_fs_LR.shape.gii ' TmpDir '/' subj '.' Hemis{h} '.curvature.32k_fs_LR.shape.gii ']);

        A=gifti([TmpDir '/' subj '.' Hemis{h} '.curvature.32k_fs_LR.shape.gii']);
        T=gifti([TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii']);
        M=mean(T.cdata(A.cdata>0));
        %Normalize predicted bias
        unix(['wb_command -metric-math "Var/' num2str(M) '" ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii -var Var ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii']);
        %unix(['wb_command -metric-math "ln(Var/' num2str(M) ')/ln(2)" ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii -var Var ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii']);
        
        unix(['wb_command -metric-mask ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii ' MNIDir '/' subj '.' Hemis{h} '.atlasroi.32k_fs_LR.shape.gii ' TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii ']);
    end; 
    %Create a dsclar with the predicted bias
    unix(['wb_command -cifti-create-dense-scalar ' TractDir '/Predbias.dscalar.nii -left-metric '  MNIDir '/' subj '.L.predbias.32k_fs_LR.func.gii -roi-left ' MNIDir '/' subj '.L.atlasroi.32k_fs_LR.shape.gii -right-metric ' MNIDir '/' subj '.R.predbias.32k_fs_LR.func.gii -roi-right ' MNIDir '/' subj '.R.atlasroi.32k_fs_LR.shape.gii']);
    
    % Quantify actual gyral bias 
    for l=1:length(Method)
        unix(['cp  ' TractDir '/' Method{l} ' ' TmpDir '/' Method{l}]);
        %Log the connectivities first? 
        %unix(['wb_command -cifti-math "log(x)" ' TmpDir '/' Method{l} ' -var x ' TmpDir '/' Method{l}]);
        for h=1:length(Hemis)
            EbiasName=[TmpDir '/' subj '.' Hemis{h} '.estimbias_' Method_name{l} '.32k_fs_LR.func.gii'];
            unix(['wb_command -cifti-separate ' TmpDir '/' Method{l} ' COLUMN -metric ' Struct{h} ' ' EbiasName ]);
            %Find mean around zero curvature
            A=gifti([TmpDir '/' subj '.' Hemis{h} '.curvature.32k_fs_LR.shape.gii']);
            T=gifti(EbiasName);
            M=mean(T.cdata(A.cdata>0));
            %Normalize estimated bias
            unix(['wb_command -metric-math "Var/' num2str(M) '" ' EbiasName ' -var Var ' EbiasName]);
            %unix(['wb_command -metric-math "ln(Var/' num2str(M) ')/ln(2)" ' EbiasName ' -var Var ' EbiasName]);

            unix(['wb_command -metric-mask ' EbiasName ' ' MNIDir '/' subj '.' Hemis{h} '.atlasroi.32k_fs_LR.shape.gii ' EbiasName]);
        end; 
    end
end


%% Now read the results in Matlab
Subjects={'109123', '167036', '169343', '770352'};

ELp5=zeros(length(Method),length(Subjects));
ELp95=zeros(length(Method),length(Subjects));
PLp5=zeros(length(Subjects),1);
PLp95=zeros(length(Subjects),1);
h=1; %Left hemisphere
for s=1:length(Subjects)
    s
    subj=Subjects{s};  
    TmpDir=[StudyFolder '/' subj '/MNINonLinear/fsaverage_LR32k/temp'];
    for n=1:length(Method)
        EbiasName=[TmpDir '/' subj '.' Hemis{h} '.estimbias_' Method_name{n} '.32k_fs_LR.func.gii'];
        T=gifti(EbiasName);
        ELp5(n,s)=prctile(T.cdata(T.cdata>0),5);
        ELp95(n,s)=prctile(T.cdata(T.cdata>0),95);
    end
    TmpDir=[StudyFolder '/' subj '/MNINonLinear/fsaverage_LR32k/temp'];
    PbiasName=[TmpDir '/' subj '.' Hemis{h} '.predbias.32k_fs_LR.func.gii'];
    T=gifti(PbiasName);
    PLp5(s)=prctile(T.cdata(T.cdata>0),5);
    PLp95(s)=prctile(T.cdata(T.cdata>0),95);
end

1./mean(PLp5)
1./mean(ELp5,2)
mean(PLp95)  
mean(ELp95,2)