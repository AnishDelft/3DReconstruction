%% Part 0 - Final Assignment
clc
clear all
close all
cd (fileparts(matlab.desktop.editor.getActiveFilename))

if (0)
    fprintf('\n Project Castle : ');
    part1_inputDir      = 'Data/castle/castleJPG/';
    part1_name     = 'castle';
    part3_imgdir   = 'Data/castle/castleJPG/';
    part3_img_type = '*.png';
    part3_frame    = 1;
    part1_matchThreshold =  0.9;
    part1_inlierThreshold = 40;
    part1_feattype =  'harris'; % [cvteam, 'kaze', 'harris']
    
    bool_extractFeatures  = 0;
    part1_outputDir  = 'Data/castle/part1_data/';
    
    if (bool_extractFeatures == 1)
        part1_loadData     = 0;    
        part1_verbose = 0;
        part1_save    = 1;
        if ~(exist(part1_outputDir , 'dir'))
            mkdir(part1_outputDir);
        end
    end
    
    
else
    fprintf('\n Project Teddy : ');
    part1_inputDir      = 'Data/teddy/TeddyBearPNG/';
    part1_name     = 'teddy';
    part3_imgdir   = 'Data/teddy/TeddyBearPNG/';
    part3_img_type = '*.png';
    part1_feattype = 'harris'; % ['cvteam', 'kaze', 'harris']
    part3_frame    = 1;
    part1_matchThreshold =  0.8;
    part1_inlierThreshold = 50;
    
    
    bool_extractFeatures  = 0;

    if (bool_extractFeatures == 1)
        part1_loadData     = 0;
        part1_outputDir  = 'Data/teddy/part1_data/';
        part1_saveMatchesDir  = 'Data/teddy/Matches/';
        part1_verbose = 0;
        part1_save    = 1;
        if ~(exist(part1_outputDir , 'dir'))
            mkdir(part1_outputDir);
        end
    else
        part1_outputDir  = 'Data/teddy/part1_data/';
    end
    
end

    fprintf('\n Matching Threshold : %0.2f',part1_matchThreshold);
    fprintf('\n RANSAC Threshold : %0.2f',part1_inlierThreshold);


%% Part I - Feature point loading and selection of best inliers
fprintf('\n --------------------------------------------------- ');
data_dir = '';
if (bool_extractFeatures == 1)    
    [C, ~, Matches] = Final_PartI_Ransacmatch(part1_name, part1_inputDir, part1_outputDir, part1_feattype, part1_matchThreshold, part1_inlierThreshold, part1_loadData, part1_save, part1_verbose);
    save(strcat(part1_outputDir, sprintf('M_%s_InTh_%d_MatTh_%0.2d.mat', part1_feattype, part1_inlierThreshold, part1_matchThreshold)), 'Matches');
    save(strcat(part1_outputDir, sprintf('C_%s_InTh_%d_MatTh_%0.2d.mat', part1_feattype, part1_inlierThreshold, part1_matchThreshold)), 'C');
    
else
    if (1)
        tmp     = load(strcat(part1_outputDir, sprintf('M_%s_InTh_%d_MatTh_%0.2d.mat', part1_feattype, part1_inlierThreshold, part1_matchThreshold)));
        Matches = tmp.Matches;
        tmp     = load(strcat(part1_outputDir, sprintf('C_%s_InTh_%d_MatTh_%0.2d.mat', part1_feattype, part1_inlierThreshold, part1_matchThreshold)));
        C       = tmp.C;
    else
        tmp = load('Data/castle/part1_data/M_harris_InTh_50_MatTh_9.00e-01');
        Matches = tmp.Matches;
        
        tmp = load('Data/castle/part1_data/C_harris_InTh_50_MatTh_9.00e-01');
        C   = tmp.C;
    end
    
    fprintf('\n [Step-1][Matches] : %d images', size(Matches,2));
end


%% Part II - Chain images using the best matches and creation of point view matrix
PV           = Final_PartII_ChainImages(Matches,0,1);
fprintf('\n --------------------------------------------------- ');
fprintf('\n [Step-2][Chaining] PV = [%d %d] \n', size(PV));

%% Part III - Esitmate the 3D points into a Cloud cell 
[Clouds, M1, MeanFrame1, Img1]   = Final_PartIII_SFM(PV,C,part1_name, part3_imgdir, part3_img_type, part3_frame, 1, 1);
fprintf('\n --------------------------------------------------- \n');
disp(Clouds);

%% Part IV - Stitch the point cloud
[mergedCloud] = Final_PartIV_PCStitching(Clouds, PV, 0);
fprintf('\n --------------------------------------------------- ');


%% Part V - Rendering
if (~isequal(M1, []))
    Final_PartV_SurfaceRenderer(mergedCloud, M1, MeanFrame1, Img1);
else
    fprintf('\n [Err] Cannot render image - %d as main view (SFM issue)', part3_frame);
end
%% Part 99 - Temp Work

