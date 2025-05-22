clear all; clc
addpath /Tools/Washington-University-cifti-matlab-f3aa924
cii=ft_read_cifti('/data/Q1200/Diffusion/blueprint_atlas_population_perc/ave_blueprint.dtseries.nii');

%% tracts
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
tractsRm=[27 40 41]; 
tracts(tractsRm)
tracts(tractsRm)=[];

%% Prep output
cii.time(tractsRm)=[];
cii.dtseries(:,tractsRm)=[];
cii.hdr.dim(6)=length(tracts);

ft_write_cifti('/data/Q1200/Diffusion/blueprint_atlas_population_perc/ave_blueprint_test', cii, 'parameter', 'dtseries');

