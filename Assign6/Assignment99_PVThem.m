%% 0 - 
clc;
clear all;
cd (fileparts(matlab.desktop.editor.getActiveFilename))
disp(pwd);

%% 2 - Create Chaining
PV = load('Data/PV.mat');
PV = PV.PV;
numFrames = size(PV,1);
fprintf('\n [2. Chaining] [Final PV] = [%d %d] \n', size(PV));

if (1)
    figure;
    tmp          = PV;
    tmp(tmp > 0) = 255;
    imagesc(tmp);
    title('PV Matrix');
end

C = load('C_thresh50.mat');
C = C.C;

%% 3 - SFM
frameIds     = (1:numFrames);
numFramesSFM = 3;
Clouds       = cell(numFrames,1);
iArray       = size(frameIds, 2):-1:1;
S_matrix     = cell(numFrames,1);

M1           = [];
MeanFrame1   = [];
Img1         = [];

for i = iArray 
    % 1. Select frames from PC to form a block 
    idxs    = circshift(frameIds, i);
    idxs    = idxs(1:numFramesSFM);
    fprintf('\n\n [3. SFM] Selecting frames : [%d %d %d]', idxs);
    block = PV(idxs, :);
    
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
        
        images_stack = [];
        colors = [];
        for f = 1:numFramesSFM
            frameNum = idxs(f);
            if (f == 1)
            % if (1)
                imgname = sprintf('Data/TeddyBearPNG/obj02_%.3d.png', frameNum);
                img     = imread(imgname);
                imggray = rgb2gray(img);
                images_stack = vertcat(images_stack, imggray);
            end
            tmpC     = C{frameNum}; % [2, N_corr_pts]
            % tmpC     = C{f};
            % fprintf('\n --> Doing frameId : %d || Correspondences : %d', frameNum, size(tmpC,2));
            tmpBlock = block(f,:);
            for p = 1:numPoints
                try
                    idx                      = tmpBlock(1,p);
                    tmpXCoord                = tmpC(1, idx);
                    tmpYCoord                = tmpC(2, idx);
                    X_3D_local(2 * f - 1, p) = tmpXCoord;
                    X_3D_local(2 * f, p)     = tmpYCoord;
                    if (f == 1)
                        tmpColor    = img(uint16(tmpXCoord), uint16(tmpYCoord), :);                    
                        colors      = [colors ; tmpColor(:)'];
                    end
                    
                catch
                    fprintf('\n --> [Err][frameID : %d] tmpC=[%d %d] || idx : %d', frameNum, size(tmpC), idx)
                end
            end
        end
        
        SFM_X    = X_3D_local([1 3 5],:); %S = [3,N]
        SFM_Y    = X_3D_local([2 4 6],:); %S = [3,N]
        [M,S,p]  = SFM(SFM_X,SFM_Y,'project_teddy'); % S = [3,N_3D] shall be centered at origin
        S_matrix{idxs(1)} = S_matrix;
        
        
        if (0)
            subplot(1,2,1);
            imshow(images_stack); hold on;
            scatter(SFM_X(1,:), SFM_Y(1,:),'r'); hold on;
            push_down = size(imggray,1);
            scatter(SFM_X(2,:), SFM_Y(2,:) + push_down,'g');
            push_down = push_down + size(imggray,1);
            scatter(SFM_X(3,:), SFM_Y(3,:) + push_down,'b');
            
            subplot(1,2,2);
            if (1)
                scatter3(S(1,:), S(2,:), S(3,:),10, 'r');view(-90,-90);
            else
                surf(S(1,:), S(2,:), S(3,:), colors);
            end
            xlabel('x'); ylabel('y');zlabel('z');
            
            % fprintf(' \n S : [%d %d] || ColIds : [%d %d]', size(S), size(colInds));
        end
        if (~p)      
            idx           = iArray(i);
            Clouds{idx} = {M,S,colInds, colors}; % M = 
        else
            fprintf('\n [Err] Error with Cholesky decomposition for frameIds : [%d %d %d]', idxs);
        end
        
        if i==numFrames && ~p
            M1         = M(1:2,:);
            MeanFrame1 = sum(X_3D_local,2)/numPoints;
            imgname1   = sprintf('Data/TeddyBearPNG/obj02_%.3d.png', 1);
            Img1       = imread(imgname1);
        end
        
    end 
end
fprintf('\n');
%% Stitching Points Clouds

% Initialize the merged (aligned) cloud with the main view, in the first point set.
mergedCloud                  = zeros(3, size(PV,2)); %[3,N]
mergedCloud(:, Clouds{1}{3}) = Clouds{1}{2};  
mergedInds                   = Clouds{1}{3};

mergedCloud_colors                  = zeros(size(PV,2),3);
mergedCloud_colors(Clouds{1}{3},:)  = Clouds{1}{4};

% Stitch each 3D point set to the main view using procrustes
numClouds = size(Clouds,1);
for i = 2:numClouds

    % [Get the points that are in the merged cloud] and the [new cloud] by using "intersect" over indexes
    [sharedInds, ~, iClouds] = intersect(mergedInds, Clouds{i}{3});
    fprintf('\n\n[4. 3D Stitch][i=%d] sharedInds : %d --> mergedInds : %d and Clouds{i}{3} : %d', i, size(sharedInds,2), size(mergedInds,2), size(Clouds{i}{3},2));
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
    %fprintf('\n --> Newer points : %d', size(iNew,2));
    
    % T.c is a repeated 3D offset, so resample it to have the correct size
    c = T.c(ones(size(iCloudsNew,2),1),:);
    % c = T.c(:,ones(size(iCloudsNew,2),1));

    % Transform the new points using: Z = T.b * T * T.T + T.c.
    % and store them in the merged cloud, and add their indexes to merged set
    mergedCloud(:, iNew)       = T.b * T.T' * Clouds{i}{2}(:,iCloudsNew') + c';
    mergedInds                 = [mergedInds iNew];
    mergedCloud_colors(iNew,:) = Clouds{i}{4}(iCloudsNew',:);
    
    if (i >= 3)
        meh = 1;
    end
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
% daspect([1 1 1]);
%rotate3d;

%% Assignment7 - Surface Render
if (1)
    tmp = load('data/Debug');
    mergedCloud = tmp.mergedCloud;
    M1          = tmp.M1;
    MeanFrame1  = tmp.MeanFrame1;
    Img1        = tmp.Img1;
else
    save('Data/Debug','mergedCloud','M1','MeanFrame1','Img1');
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
end

surfaceRender(mergedCloud, M1, MeanFrame1, Img1);

%% using surf function
if (1)
    figure;
    [xi,yi] = meshgrid(min(X):1:max(X), min(Y):1:max(Y));
    zi      = griddata(X,Y,Z,xi,yi);
    surf(xi,yi,zi);
    axis vis3d;
    xlabel('x'); ylabel('y'); zlabel('z');
else
    [xi,yi] = meshgrid(sort((X(X ~= 0))), sort((Y(Y ~= 0))));
    zi      = griddata(X,Y,Z,xi,yi);
    surf(xi,yi,zi, mergedCloud_colors);
    axis vis3d;
    xlabel('x'); ylabel('y'); zlabel('Depth');
end

%% Random Trials
% dt = delaunayTriangulation(mergedCloud');
% tetramesh(dt, 'FaceColor', 'cyan');
% figure;
% subplot(1,2,1);
% scatter3(X', Y', Z', 20, [1 0 0], 'filled');
% axis([-500 500 -500 500 -500 500]);
% view(-90,-90);
% xlabel('x'); ylabel('y');zlabel('z');
% 
% subplot(1,2,2);
% tri = delaunay(X, Y);
% h = trisurf(tri, X, Y, Z);
% axis vis3d
% axis off
% l = light('Position',[-50 -15 29])
% set(gca,'CameraPosition',[208 -50 7687])
% lighting phong
% shading interp
% colorbar EastOutside
% % plot(X,Y,'.');





%% 100 - Questions to ask
% 1. How do we get haraff and hesaff features for castle data
% 2. What is the threshold to assume for estimateFundamentalMatrix()
% 3. 