%% Part 0 - Final Assignment
clc
clear all
close all
cd (fileparts(matlab.desktop.editor.getActiveFilename))

if (0)
    part1_dir      = 'Data/castle/modelCastle_features/modelCastle_features/';
    part1_name     = 'castle';
    part3_imgdir   = 'Data/castle/modelCastle_features/modelCastle_features/';
    part3_img_type = '*.png';
    
    bool_extractFeatures  = 1;
    part1_threshold       = 50;
    
    if (bool_extractFeatures == 1)
        part1_loadMatches     = 1;
        part1_loadMatchesDir  = 'Data/castle/funda_data/';
        part1_saveMatchesDir  = 'Data/castle/Matches/';
        part1_feattype = 'kaze';
        part1_verbose = 0;
        part1_save    = 1;
    else
        part1_loadMatchesDir = 'Data/castle/Matches/';
    end
    
    
else
    part1_dir      = 'Data/teddy/TeddyBearPNG/';
    part1_name     = 'teddy';
    part3_imgdir   = 'Data/teddy/TeddyBearPNG/';
    part3_img_type = '*.png';
    
    bool_extractFeatures  = 1;
    part1_threshold       = 50;
    if (bool_extractFeatures == 1)
        part1_loadMatches     = 0;
        part1_loadMatchesDir  = 'Data/teddy/funda_data/';
        part1_saveMatchesDir  = 'Data/teddy/Matches/';
        part1_feattype = 'kaze';
        part1_verbose = 0;
        part1_save    = 0;
    else
        part1_loadMatchesDir = 'Data/teddy/Matches/';
    end
    
end


%% Part I - Feature point loading and selection of best inliers
fprintf('\n --------------------------------------------------- ');
data_dir = '';
if (bool_extractFeatures == 1)    
    [C, ~, Matches] = Final_PartI_Ransacmatch(part1_dir, part1_threshold, part1_name, part1_loadMatches, part1_loadMatchesDir, part1_save, part1_verbose, part1_feattype);
    save(strcat(part1_saveMatchesDir, sprintf('M_thresh_%d.mat', part1_threshold)), 'Matches');
    save(strcat(part1_saveMatchesDir, sprintf('C_thresh_%d.mat', part1_threshold)), 'C');
else
    if (1)
        tmp     = load(strcat(part1_loadMatchesDir, sprintf('M_thresh_%d.mat', part1_threshold)));
        Matches = tmp.Matches;
        tmp     = load(strcat(part1_loadMatchesDir, sprintf('C_thresh_%d.mat', part1_threshold)));
        C       = tmp.C;
    else
        tmp = load('Data/teddy/Matches/Matches_silvia.mat');
        Matches = tmp.Matches;
        
        tmp = load('Data/teddy/Matches/C_silvia.mat');
        C   = tmp.C;
    end
    
    fprintf('\n [Step-1][Matches] : %d images', size(Matches,2));
end


%% Part II - Chain images using the best matches and creation of point view matrix
PV           = Final_PartII_ChainImages(Matches,0,1);
fprintf('\n --------------------------------------------------- ');
fprintf('\n [Step-2][Chaining] PV = [%d %d] \n', size(PV));

%% Part III - Esitmate the 3D points into a Cloud cell 
Clouds   = Final_PartIII_SFM(PV,C,part1_name, part3_imgdir, part3_img_type, 1, 1);
fprintf('\n --------------------------------------------------- \n');
disp(Clouds);

%% Part IV - Stitch the point cloud
if (0)
    tmp    = load('Data/Clouds_AprilFool.mat');
    Clouds = tmp.Clouds;
end
[mergedCloud] = Final_PartIV_PCStitching(Clouds, PV, 0);
fprintf('\n --------------------------------------------------- ');


%% Part V - Rendering

%% Part 99 - Temp Work

