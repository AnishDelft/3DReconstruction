%% Part 0 - Final Assignment
clc
clear all
close all
cd (fileparts(matlab.desktop.editor.getActiveFilename))

if (1)
    part1_dir      = 'Data/castle/modelCastle_features/modelCastle_features/';
    part1_name     = 'castle';
    part3_imgdir   = 'Data/castle/model_castle/';
    part3_img_type = '*.JPG';
    
    bool_extractFeatures  = 1;
    part1_threshold       = 50;
    part1_loadFeaturesDir = 'Data/castle/castle_data.mat';
else
    part1_dir = 'Data/castle/modelCastle_features/modelCastle_features/';
end


%% Part I - Feature point loading and selection of best inliers
fprintf('\n --------------------------------------------------- ');
data_dir = '';
if (bool_extractFeatures == 1)    
    [C, ~, Matches] = Final_PartI_Ransacmatch(part1_dir, part1_threshold, part1_name, 1, 1);
else
    tmp     = load(part1_loadFeaturesDir);    
    C       = tmp.C;
    Matches = tmp.Matches;
    fprintf('\n [Step-1][Matches] : %d images', size(Matches,2));
end


%% Part II - Chain images using the best matches and creation of point view matrix
PV           = Final_PartII_ChainImages(Matches,0,1);
fprintf('\n --------------------------------------------------- ');
fprintf('\n [Step-2][Chaining] PV = [%d %d] \n', size(PV));

%% Part III - Esitmate the 3D points into a Cloud cell 
Clouds   = Final_PartIII_SFM(PV,C,"project_castle", part3_imgdir, part3_img_type, 1, 0);
fprintf('\n --------------------------------------------------- \n');
disp(Clouds);

%% Part IV - Stitch the point cloud
if (1)
    tmp    = load('Data/Clouds_AprilFool.mat');
    Clouds = tmp.Clouds;
end
[mergedCloud] = Final_PartIV_PCStitching(Clouds, PV, 0);
fprintf('\n --------------------------------------------------- ');


%% Part V - Rendering

%% Part 99 - Temp Work

