%  Apply normalized 8-point RANSAC algorithm to find best matches
% Input:
%     -directory: where to load images
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)

function [C, D, Matches] = Final_PartI_Ransacmatch(directory, threshold, part1_name, save_bool, verbose)
    Files=dir(strcat(directory, '*.png'));
    n = length(Files);
    
    if (n == 0)
        fprintf('\n  --> [Err] We have 0 files in the directory %s', strcat(directory, '*.png'));
    end
    
    % Initialize coordinates C and descriptors D
    C ={};
    D ={};
    % Load all features (coordinates and descriptors of interest points)
    % As an example, we concatenate the haraff and hesaff sift features
    % You can also use features extracted from your own Harris function.
    fprintf('\n [1.1 Matching] Step1 - Load descriptors');
    for i=1:n
        [coord_haraff,desc_haraff,~,~] = loadFeatures(strcat(directory, '/',Files(i).name, '.haraff.sift'));
        [coord_hesaff,desc_hesaff,~,~] = loadFeatures(strcat(directory, '/',Files(i).name, '.hesaff.sift'));
        
        coord = [coord_haraff coord_hesaff];
        desc  = [desc_haraff desc_hesaff];
        
        C{i} = coord(1:2, :);
        D{i} = desc;
    end

    % Initialize Matches (between each two consecutive pairs)
    Matches={};

    fprintf('\n [1.2 Matching] Step2 - Match Features')
    for i=1:n
        tic;
        if (i == n)
            next = 1;
        else
            next = i+1;
        end
        
        coord1 = C{i};
        desc1  = D{i};
        
        coord2 = C{next};
        desc2  = D{next};
        
        % Find matches according to extracted descriptors using vl_ubcmatch
        [match, ~] = vl_ubcmatch(desc1, desc2); % indices - [2,N_matches]
        
        % Obatain X,Y coordinates of matches points
        match1 = coord1(1:2,match(1,:));
        match2 = coord2(1:2,match(2,:));
        
        % Find inliers using normalized 8-point RANSAC algorithm
        [~, inliers] = help_estimateFundamentalMatrix(match1,match2,threshold,0);
        if (verbose == 1)
            fprintf('\n [1.3 Matching] %d) Found %d / %d inliers (%.2f perc)(t:%.2f sec):', i, size(inliers,2), size(match1,2), size(inliers,2)/size(match1,2), round(toc));
        end
        
        Matches{i} = match(:,inliers);
        
        if (save_bool == 1)
            name1    = Files(i).name;
            name2    = Files(next).name;
            filename = sprintf('Data/%s/funda_data/estimateFunda_%s_round%d', part1_name, part1_name, i);
            save(filename, 'match', 'match1', 'match2', 'coord1', 'coord2', 'directory', 'name1', 'name2');
        end
        
    end

end
