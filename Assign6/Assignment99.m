%% 0 - 
clc;
clear all;
cd (fileparts(matlab.desktop.editor.getActiveFilename))

%% 1 - Get Feature Points
if (1)
    threshold = 50;
    [C, D, Matches] = ransac_match('data/TeddyBearPNG/', threshold);
    save('data/Matches_thresh50_iter2.mat', 'Matches');
    save('data/C_thresh50_iter2.mat', 'C');
    save('data/D_thresh50_iter2.mat', 'D');
elseif (1)
    fprintf('\n [1. Feature Points] Loaded Points');
    Matches = load('Matches_thresh50.mat');
    C = load('C_thresh50.mat');
    D = load('D_thresh50.mat');
    
    %Matches = load('Matches_thresh200.mat');
    %C = load('C_thresh200.mat');
    %D = load('D_thresh200.mat');
    
    Matches = Matches.Matches;
    C       = C.C;
    D       = D.D;
else
    meh = 1;
end

%% 2 - Create Chaining
PV        = chainimages(Matches, 1);
if (1)
    figure;
    tmp          = PV;
    tmp(tmp > 0) = 255;
    imagesc(tmp);
    title('PV Matrix');
end

    
%% 3 - SFM
numFrames = size(PV,1);
fprintf('\n [2. Chaining] [Final PV] = [%d %d] \n', size(PV));

frameIds     = (1:numFrames);
numFramesSFM = 3;
Clouds       = cell(numFrames,1);
iArray       = size(frameIds, 2):-1:1;
for i = iArray 
    % 1. Select frames from PC to form a block 
    idxs    = circshift(frameIds, i);
    fprintf('\n\n [3. SFM] Selecting frames : [%d %d %d]', idxs(1:numFramesSFM));
    block = PV(idxs(1:numFramesSFM), :);
    
    % 2. Select columns from the block that do not ... have any zeros
    colInds = find(all(block));
    
    % 3. Check the number of visible points in all views 
    numPoints = size(colInds, 2); 
    fprintf('\n --> numPoints : %d (from : %d, %d, %d)', numPoints, length(find(PV(idxs(1), :)>0)), length(find(PV(idxs(2), :)>0)), length(find(PV(idxs(3), :)>0)));
    if numPoints < 8 
        continue
    end
    
    % 4. Create measurement matrix X

    if (1)
        block      = block(:, colInds); % [3, ~]
        X_3D_local = zeros(2 * numFramesSFM, numPoints);
        % fprintf('\n --> X_3D_local : %d %d \n', size(X_3D_local));
        for f = 1:numFramesSFM
            tmpC     = C{f};
            tmpBlock = block(f,:);
            for p = 1:numPoints
                try
                    idx                      = tmpBlock(1,p);
                    X_3D_local(2 * f - 1, p) = tmpC(1, idx);
                    X_3D_local(2 * f, p)     = tmpC(2,idx);
                catch
                    meh = 1;
                    % fprintf('\n --> [Err] tmpC=[%d %d] || idx : %d', size(tmpC), idx)
                end
            end
        end
        [M,S,p] = SFM(X_3D_local(1:3,:),X_3D_local(3:5,:),'project_teddy'); %S = [3,N]
        fprintf(' \n S : [%d %d] || ColIds : [%d %d]', size(S), size(colInds));
        if (~p)      
            idx           = iArray(i);
            % Clouds{idx}   = cell(1,3);
            Clouds{idx} = {M,S,colInds}; % M = 
            
        end
    end 
end

%% Stitching Points Clouds

% Initialize the merged (aligned) cloud with the main view, in the first point set.
mergedCloud                 = zeros(3, size(PV,2));
mergedCloud(:, Clouds{1}{3}) = Clouds{1}{2};  
mergedInds                  = Clouds{1}{3}; 

% Stitch each 3D point set to the main view using procrustes
numClouds = size(Clouds,1);
for i = 2:numClouds

    % [Get the points that are in the merged cloud] and the [new cloud] by using "intersect" over indexes
    [sharedInds, ~, iClouds] = intersect(mergedInds, Clouds{i}{3});
    fprintf('\n sharedInds : %d --> mergedInds : %d and Clouds{i}{3} : %d', size(sharedInds,2), size(mergedInds,2), size(Clouds{i}{3},2));
    sharedPoints             = mergedCloud(:,sharedInds);

    % A certain number of shared points to do procrustes analysis.
    if size(sharedPoints, 2) < 15
       continue
    end

    % Find optimal transformation between shared points using procrustes
    [d, Z, T] = procrustes(sharedPoints', Clouds{i}{2}(:,iClouds')'); 
    % fprintf('\n Rotations(deg) : %f, %f %f', rad2deg(rotm2eul(T.T)));
    

    % Find the points that are not shared between the merged cloud and the 
    % Clouds{i,:} using "setdiff" over indexes
    [iNew, iCloudsNew] = setdiff(Clouds{i}{3}, mergedInds);
    
    % T.c is a repeated 3D offset, so resample it to have the correct size
    c = T.c(ones(size(iCloudsNew,2),1),:);
    % c = T.c(:,ones(size(iCloudsNew,2),1));

    % Transform the new points using: Z = T.b * T * T.T + T.c.
    % and store them in the merged cloud, and add their indexes to merged set
    mergedCloud(:, iNew)       = T.b * T.T' * Clouds{i}{2}(:,iCloudsNew') + c';
    mergedInds                 = [mergedInds iNew];
end

if (1)
    figure;
    X = mergedCloud(1,:);
    Y = mergedCloud(2,:);
    Z = mergedCloud(3,:);
    scatter3(X', Y', Z', 20, [1 0 0], 'filled');
    axis([-500 500 -500 500 -500 500]);
    view(-90,-90);
    xlabel('x'); ylabel('y');zlabel('z');
    fprintf('Out of %d 3D points we have X:%d, Y:%d, Z:%d non-zero points', ...
        size(mergedCloud,2), size(X(X ~= 0),2), size(Y(Y ~= 0),2), size(Z(Z ~= 0),2));
else
    figure;
    % surf(mergedCloud(1,:)', mergedCloud(2,:)', mergedCloud(3,:)',);
end

% prevIdxs = Clouds{1}{3};
% for i=2:length(Clouds)
%     [commonIdxs, IA, IB] = intersect(prevIdxs, Clouds{i}{3});
%     fprintf('\n IA : [%d %d] || IB : [%d %d]', size(IA), size(IB));
% end


%% 100 - Questions to ask
% 1. How do we get haraff and hesaff features for castle data
% 2. What is the threshold to assume for estimateFundamentalMatrix()
% 3.

%% Tmp
tmp = load('data/estimateFunda_round1');
match1 = tmp.match1;
match2 = tmp.match2;
[F, inliers] = help_estimateFundamentalMatrix(match1,match2,threshold,1);


