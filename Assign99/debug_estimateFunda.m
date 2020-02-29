%% Part 0 - Final Assignment
clc
clear all
close all
cd (fileparts(matlab.desktop.editor.getActiveFilename))
% tmp = load('Data/castle/funda_data/estimateFunda_castle_round1.mat');
tmp = load('Data/teddy/funda_data/thresh50_variableIter/estimateFunda_teddy_round1.mat');
%%
[F, inliers] = help_estimateFundamentalMatrix(tmp.match1, tmp.match2, 50, 1);
X1 = tmp.coord1(1:2,tmp.match(1,:));


X2 = tmp.coord2(1:2,tmp.match(2,:));
debug_ransac(tmp.name1, tmp.name2, F, inliers, tmp.directory, X1, X2, tmp.match);


%%
[FMat,  inliersIndex]= estimateFundamentalMatrix(tmp.match1', tmp.match2', ...
    'Method','RANSAC', ...
    'DistanceThreshold',200);
% [FMat,  inliersIndex]= estimateFundamentalMatrix(tmp.match1', tmp.match2');
fprintf('\n [MATLAB] inliersIndex = %d', size(inliersIndex,1));

X1 = tmp.coord1(1:2,tmp.match(1,:));
X2 = tmp.coord2(1:2,tmp.match(2,:));
debug_ransac(tmp.name1, tmp.name2, FMat, inliersIndex', tmp.directory, X1, X2, tmp.match);

%%
match1 = [tmp.match1;ones(1,size(tmp.match1,2))]; % [3,N]
match2 = [tmp.match2;ones(1,size(tmp.match2,2))];
    
inliers_mat = help_computeInliers(FMat,match1,match2,50);
inliers_me  = help_computeInliers(F   ,match1,match2,50);

fprintf('\n [Matlab] Inliers : %d / %d (%.2f perc)', size(inliers_mat,2), size(tmp.match1,2), size(inliers_mat,2) / size(tmp.match1,2));
fprintf('\n [Me] Inliers : %d / %d (%.2f perc)', size(inliers_me,2), size(tmp.match1,2), size(inliers_me,2) / size(tmp.match1,2));