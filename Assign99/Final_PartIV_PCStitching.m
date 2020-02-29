function [mergedCloud] = Final_PartIV_PCStitching(CloudsOld, PV, verbose)

    % Clear out the point-clouds that did not pass the SFM
    Clouds = cell(1);
    idx       = 1;
    for i=1:size(CloudsOld,1)
        if (~isequal(CloudsOld{i}, []) == 1)
            Clouds{idx} = CloudsOld{i};
            idx            = idx + 1;
        end
    end
    Clouds = Clouds';

    % Initialize the merged (aligned) cloud with the main view, in the first point set.
    mergedCloud                  = zeros(3, size(PV,2));
    mergedCloud(:, Clouds{1}{3}) = Clouds{1}{2};  
    mergedInds                   = Clouds{1}{3}; 

    % Stitch each 3D point set to the main view using procrustes
    numClouds = size(Clouds,1);
    for i = 2:numClouds

        % [Get the points that are in the merged cloud] and the [new cloud] by using "intersect" over indexes
        [sharedInds, ~, iClouds] = intersect(mergedInds, Clouds{i}{3});
        sharedPoints             = mergedCloud(:,sharedInds);
        if (verbose == 1)
            fprintf('\n\n[4. 3D Stitch][i=%d] sharedInds : %d --> mergedInds : %d and Clouds{i}{3} : %d', i, size(sharedInds,2), size(mergedInds,2), size(Clouds{i}{3},2));
        end
        
        % A certain number of shared points to do procrustes analysis.
        if size(sharedPoints, 2) < 15
           continue
        end

        % Find optimal transformation between shared points using procrustes
        [~, ~, T] = procrustes(sharedPoints', Clouds{i}{2}(:,iClouds')'); 
        % [d, Z, T] = procrustes(sharedPoints', Clouds{i}{2}(:,iClouds')'); 
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

        if (i >= 3)
            meh=1;
        end
    end

    if (1)
        figure;
        scatter3(mergedCloud(1,:)', mergedCloud(2,:)', mergedCloud(3,:)', 20, [1 0 0], 'filled');
        axis([-500 500 -500 500 -500 500]);
        view(-90,-90);
        xlabel('x'); ylabel('y');zlabel('z');
    end
end