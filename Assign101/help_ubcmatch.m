function [match] = help_ubcmatch(coord1, coord2, descriptor1, descriptor2, threshold_dist)
    if (1)
        desc1 = double(descriptor1');
        desc2 = double(descriptor2');
        N = size(desc1, 1);
        M = size(desc2, 1);
        match1 = [];
        match2 = [];

        tmp = [];
        for i = 1:N
            Dist = sqrt(sum(( (desc2 - repmat(desc1(i,:), M, 1)).^2),2)); 
            [minValues, ind] = sortrows( Dist, 1 );
            if minValues(2) && ( (minValues(1)/minValues(2)) <= threshold_dist)
                match1 = [match1 i];
                match2 = [match2 ind(1)];
            end
            % tmp = [tmp minValues(1)/minValues(2)];
        end
        match = [match1;match2];
        % figure; hist(tmp);
        % fprintf('Total matches : %d', size(find(MatchedPairs > 0)))
        
        
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                % Draw the matched pairs
                match1 = [match1, bestmatch(1)];
                match2 = [match2, bestmatch(2)];
            end
        end
        match = [match1; match2];

    end

end
