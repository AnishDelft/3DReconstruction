function [match1, match2] = help_matching(coord1, coord2, descriptor1, descriptor2, threshold_dist)

% Create two arrays containing the points location in both images
    match1 = [];
    match2 = [];
    descriptor1=double(descriptor1);
    descriptor2=double(descriptor2);

    % Loop over the descriptors of the first image
    for index1 = 1:size(descriptor1, 2)
        bestmatch      = [0 0];
        bestDist       = Inf;
        secondBestDist = Inf;

        % Loop over the descriptors of the second image
        for index2 = 1:size(descriptor2, 2)
            desc1 = double(descriptor1(:, index1));
            desc2 = double(descriptor2(:, index2));

            % Normalize the descriptors to unit L2 norm:
            desc1 = desc1/norm(desc1);
            desc2 = desc2/norm(desc2);

            % Compute the Euclidian distance of desc1 and desc2
            dist = pdist([desc1'; desc2']);

            % Threshold the distances
            if secondBestDist > dist
                if bestDist > dist
                    secondBestDist = bestDist;
                    bestDist       = dist;
                    bestmatch      = [index1 index2];
                else % if not smaller than both best and second best dist
                    secondBestDist = dist;
                end
            end
        end

        % Reject matches where the distance ratio is greater than 0.8
        if (bestDist / secondBestDist) < threshold_dist
            pts1 = coord1(:,bestmatch(1));
            pts2 = coord2(:,bestmatch(2));

            % Draw the matched pairs
            match1 = [match1, pts1];
            match2 = [match2, pts2];
        end
    end
    
end
