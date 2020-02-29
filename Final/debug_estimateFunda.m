%% Part 0 - Final Assignment
% clc
% clear all
% close all
cd (fileparts(matlab.desktop.editor.getActiveFilename))
 %tmp = load('Data/castle/funda_data/estimateFunda_castle_round3.mat');
 tmp = load('Data/teddy/part1_data/part1_matches_teddy_harris_round3.mat');
threshold = 50;

%%
[F, inliers] = help_estimateFundamentalMatrix(tmp.match1, tmp.match2, threshold, 1);
X1 = tmp.coord1(1:2,tmp.match(1,:));
X2 = tmp.coord2(1:2,tmp.match(2,:));

debug_ransac(tmp.name1, tmp.name2, F, inliers, tmp.part1_inputDir, X1, X2, tmp.match);

fprintf('\n [ME] inliers = %d', size(inliers,2));

%%
[FMat,  inliersIndex]= estimateFundamentalMatrix(tmp.match1', tmp.match2', ...
    'Method','RANSAC', ...
    'NumTrials',2000, ...
    'DistanceThreshold',threshold);
% [FMat,  inliersIndex]= estimateFundamentalMatrix(tmp.match1', tmp.match2');
fprintf('\n [MATLAB] inliersIndex = %d', size(inliersIndex,1));

X1 = tmp.coord1(1:2,tmp.match(1,:));
X2 = tmp.coord2(1:2,tmp.match(2,:));
% debug_ransac(tmp.name1, tmp.name2, FMat, inliersIndex', tmp.directory, X1, X2, tmp.match);
debug_ransac(tmp.name1, tmp.name2, FMat, inliersIndex', 'data/teddy/TeddyBearPNG/', X1, X2, tmp.match);

%%
match1 = [tmp.match1;ones(1,size(tmp.match1,2))]; % [3,N]
match2 = [tmp.match2;ones(1,size(tmp.match2,2))];

inliers_mat = help_computeInliers(FMat,match1,match2,threshold);
inliers_me  = help_computeInliers(F   ,match1,match2,threshold);

fprintf('\n [Matlab] Inliers : %d / %d (%.2f perc)', size(inliers_mat,2), size(tmp.match1,2), size(inliers_mat,2) / size(tmp.match1,2));
fprintf('\n [Me] Inliers : %d / %d (%.2f perc)', size(inliers_me,2), size(tmp.match1,2), size(inliers_me,2) / size(tmp.match1,2));