%  Apply normalized 8-point RANSAC algorithm to find best matches
% Input:
%     -directory: where to load images
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)

function [C, D, Matches] = Final_PartI_Ransacmatch(directory, threshold, part1_name, part1_loadMatches, part1_loadMatchesDir, save_bool, verbose, part1_feattype)
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

     
    if (part1_loadMatches == 0)
        fprintf('\n [1.1 Matching] Step1 - Load descriptors');
        for i=1:n
            if strcmp(part1_feattype,'silvia')
                [coord_haraff,desc_haraff,~,~] = help_loadFeatures(strcat(directory, '/',Files(i).name, '.haraff.sift'));
                [coord_hesaff,desc_hesaff,~,~] = help_loadFeatures(strcat(directory, '/',Files(i).name, '.hesaff.sift'));

                coord = [coord_haraff coord_hesaff];
                desc  = [desc_haraff desc_hesaff];

                C{i} = coord(1:2, :);
                D{i} = desc;
                
            elseif strcmp(part1_feattype,'kaze')
                fprintf('\n iter %d', i);
                img = rgb2gray(imread(strcat(directory, '/',Files(i).name)));
                
                pts = detectKAZEFeatures(img);
                
                [feat, vpts] = extractFeatures(img, pts);
                
                C{i} = vpts.Location';
                D{i} = feat;
            end
            
        end
    end
    
    save('Data/teddy/tmp', 'C', 'D');
%     tmp = load('Data/teddy/tmp');
%     C = tmp.C;
%     D = tmp.D;
    
    
    % Initialize Matches (between each two consecutive pairs)
    Matches={};

    fprintf('\n [1.2 Matching] Step2 - Match Features')
    for i=1:n
        tic;

        % Find matches according to extracted descriptors using vl_ubcmatch
        if (part1_loadMatches == 0)
            
            if (i == n)
                next = 1;
            else
                next = i+1;
            end
            
            coord1 = C{i};
            desc1  = D{i};

            coord2 = C{next};
            desc2  = D{next};
            
            if strcmp(part1_feattype,'silvia')
                
                [match, ~] = vl_ubcmatch(desc1, desc2); % indices - [2,N_matches]
                % Obtain X,Y coordinates of matches points
                match1 = coord1(1:2,match(1,:));
                match2 = coord2(1:2,match(2,:));
                
            elseif strcmp(part1_feattype,'kaze')
                
                % match  = matchFeatures(desc1, desc2, 'Unique', true,  'Method', 'Approximate');
                match  = matchFeatures(desc1, desc2, 'Unique', false,  'Method', 'Exhaustive');
                match1 = coord1(:,match(:, 1)); % [2,N]
                match2 = coord2(:,match(:, 2));
            end
            
        else
            filename = strcat(part1_loadMatchesDir, sprintf('estimateFunda_%s_round%d.mat', part1_name, i));
            tmp      = load(filename);
            match    = tmp.match;
            match1   = tmp.match1;
            match2   = tmp.match2;
            C{i}     = tmp.coord1;
        end
        
        
        % Find inliers using normalized 8-point RANSAC algorithm
        if (1)
            [F,  inliers] = estimateFundamentalMatrix(match1', match2', 'Method', 'MSAC', 'DistanceThreshold', threshold);
            fprintf('\n [1.3 Matching] %d) Found %d / %d inliers (%.2f perc)(t:%.2f sec):', i, size(find(inliers>0),1), size(match1,2), size(find(inliers>0),1)/size(match1,2), round(toc));
            fprintf('\n');
            disp(F)
        else
        
            [F, inliers] = help_estimateFundamentalMatrix(match1,match2,threshold,verbose); %ip = [2,N]
            fprintf('\n [1.3 Matching] %d) Found %d / %d inliers (%.2f perc)(t:%.2f sec):', i, size(inliers,2), size(match1,2), size(inliers,2)/size(match1,2), round(toc));
            fprintf('\n');
            disp(F)
        end
        
        
        Matches{i} = match(:,inliers);
        
        if (save_bool == 1 && part1_loadMatches == 0)
            name1    = Files(i).name;
            name2    = Files(next).name;
            filename = sprintf('Data/%s/funda_data/estimateFunda_%s_round%d', part1_name, part1_name, i);
            save(filename, 'match', 'match1', 'match2', 'coord1', 'coord2', 'directory', 'name1', 'name2');
        end
        
    end

end
