function [Clouds] = Final_PartIII_SFM(PV,C,project_name, img_dir, img_type, verbose, plot)
    Files=dir(strcat(img_dir, img_type));
    numFrames = size(PV,1);
    frameIds     = (1:numFrames);
    numFramesSFM = 3;
    Clouds       = cell(numFrames,1);
    iArray       = size(frameIds, 2):-1:1;
    S_matrix     = cell(numFrames,1);
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
        colors = [];
        if (1)
            block      = block(:, colInds); % [3, ~]
            X_3D_local = zeros(2 * numFramesSFM, numPoints);
            % fprintf('\n --> X_3D_local : %d %d \n', size(X_3D_local));

            images_stack = [];
            for f = 1:numFramesSFM
                frameNum = idxs(f);
                % if (f == 1)
                if (plot == 1)
                    imgname = strcat(img_dir, Files(frameNum).name);
                    img     = imread(imgname);
                    imggray = rgb2gray(img);
                    images_stack = vertcat(images_stack, imggray);
                end
                tmpC     = C{frameNum}; % [2, N_corr_pts]
                % tmpC     = C{f};
                fprintf('\n --> Doing frameId : %d || Correspondences : %d', frameNum, size(tmpC,2));
                tmpBlock = block(f,:);
                for p = 1:numPoints
                    try
                        idx                      = tmpBlock(1,p);
                        tmpXCoord                = tmpC(1, idx);
                        tmpYCoord                = tmpC(2, idx);
                        X_3D_local(2 * f - 1, p) = tmpXCoord;
                        X_3D_local(2 * f, p)     = tmpYCoord;
                        % tmpColor                 = img(round(tmpXCoord), round(tmpYCoord), :);
                        tmpColor                 = img(round(tmpYCoord), round(tmpXCoord), :);
                        colors                   = [colors ; tmpColor(:)'];
                    catch
                        fprintf('\n --> [Err][frameID : %d] tmpC=[%d %d] || idx : %d', frameNum, size(tmpC), idx);
                    end
                end
            end

            SFM_X    = X_3D_local([1 3 5],:); %S = [3,N]
            SFM_Y    = X_3D_local([2 4 6],:); %S = [3,N]
            [M,S,p]  = help_SFM(SFM_X,SFM_Y,project_name); % S = [3,N_3D] shall be centered at origin
            S_matrix{idxs(1)} = S_matrix;
            if (0)
                subplot(1,3,1);
                imshow(images_stack); hold on;
                scatter(SFM_X(1,:), SFM_Y(1,:),'r'); hold on;
                push_down = size(imggray,1);
                scatter(SFM_X(2,:), SFM_Y(2,:) + push_down,'g');
                push_down = push_down + size(imggray,1);
                scatter(SFM_X(3,:), SFM_Y(3,:) + push_down,'b');

                subplot(1,3,2);
                scatter3(S(1,:), S(2,:), S(3,:),10, 'r');view(-90,-90);
                
                subplot(1,3,3);
                S_colors = double(colors(1:size(S,2),:));
                scatter3(S(1,:), S(2,:), S(3,:),10, S_colors./255, 'filled');view(-90,-90); hold on;
                xlabel('x'); ylabel('y');zlabel('z');
                % fprintf(' \n S : [%d %d] || ColIds : [%d %d]', size(S), size(colInds));
            end
            if (~p)      
                idx         = iArray(i);
                S_colors    = double(colors(1:size(S,2),:));
                Clouds{idx} = {M,S,colInds, S_colors'}; % M = 
            else
                fprintf('\n [Err] Error with Cholesky decomposition for frameIds : [%d %d %d]', idxs);
            end
        end 
    end
    fprintf('\n');
    
    
    
end
% daspect([1 1 1]);
%rotate3d;