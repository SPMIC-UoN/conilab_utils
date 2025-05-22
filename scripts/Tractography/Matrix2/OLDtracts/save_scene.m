%% Function to create new scene file for wb_view
% Uses previous scene file as template
% Searches through template and changes old data for new 
% For displaying new .dtseries.nii on an individual surface (100206)
function save_scene(ciftiPath, resultsFolder)
[~,ciftiName,~]=fileparts(ciftiPath);

%% Set search critera
bppath1='/home//Tools/wb_scene/average5_bpTracts'; % Replaced by ciftiPath
bpname1='average5_bpTracts'; % Replaced by ciftiName

% Make surface file paths absolute
% Generic
surfname1='Surface: 100206.';
surfname2='Surface: /data/Q1200/Structural/100206/MNINonLinear/fsaverage_LR32k/100206.';
% LH
surfnameL1='[100206.L.inflated.32k_fs_LR.surf.gii]';
surfnameL2='[/data/Q1200/Structural/100206/MNINonLinear/fsaverage_LR32k/100206.L.inflated.32k_fs_LR.surf.gii]';
% RH
surfnameR1='[100206.R.inflated.32k_fs_LR.surf.gii]';
surfnameR2='[/data/Q1200/Structural/100206/MNINonLinear/fsaverage_LR32k/100206.R.inflated.32k_fs_LR.surf.gii]';

%% Read template scene file
[~,newScene]=unix('cat /home//Tools/wb_scene/scene_file.scene');

%% Replace following search critera
newScene=strrep(newScene, bppath1, ciftiPath);
newScene=strrep(newScene, bpname1, ciftiName);
newScene=strrep(newScene, surfname1, surfname2);
newScene=strrep(newScene, surfnameL1, surfnameL2);
newScene=strrep(newScene, surfnameR1, surfnameR2);
scenePath=([resultsFolder '/scene_file']);

%% Save as .txt file and then alter to .scene
sceneFile=fopen([scenePath '.txt'],'w');
fprintf(sceneFile, '%c',newScene);
fclose(sceneFile);
unix(['mv ' scenePath '.txt ' scenePath '.scene']);
end