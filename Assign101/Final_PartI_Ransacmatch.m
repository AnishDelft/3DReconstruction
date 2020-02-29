%  Apply normalized 8-point RANSAC algorithm to find best matches
% Input:
%     -directory: where to load images
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)

function [C, D, Matches] = Final_PartI_Ransacmatch(part1_name, part1_inputDir, part1_outputDir, part1_feattype, part1_matchThreshold,part1_inlierThreshold, part1_loadData, save_bool, verbose)
    Files=dir(strcat(part1_inputDir, '*.png'));
    n = length(Files);
    imgrange = [1:n];
    
    if (n == 0)
        fprintf('\n  --> [Err] We have 0 files in the directory %s', strcat(part1_inputDir, '*.png'));
    end
    
    % Initialize coordinates C and descriptors D
    C ={};
    D ={};
    
    % Load all features (coordinates and descriptors of interest points)
    % As an example, we concatenate the haraff and hesaff sift features
    % You can also use features extracted from your own Harris function.

     
    if (part1_loadData == 0)
        fprintf('\n [1.1 Matching] Step1 - Load descriptors');
        for i=imgrange
            fprintf('\n [1.1 Matching][%s] -- Image : %d', part1_feattype, i);
            if strcmp(part1_feattype,'cvteam')
                [coord_haraff,desc_haraff,~,~] = help_loadFeatures(strcat(part1_inputDir, '/',Files(i).name, '.haraff.sift'));
                [coord_hesaff,desc_hesaff,~,~] = help_loadFeatures(strcat(part1_inputDir, '/',Files(i).name, '.hesaff.sift'));

                coord = [coord_haraff coord_hesaff];
                desc  = [desc_haraff desc_hesaff];

                C{i} = coord(1:2, :);
                D{i} = desc;
                
            elseif strcmp(part1_feattype,'kaze')
                fprintf('\n iter %d', i);
                img_filename = strcat(part1_inputDir, '/',Files(i).name);
                img = rgb2gray(imread(img_filename));
                
                pts = detectKAZEFeatures(img);
                
                [feat, vpts] = extractFeatures(img, pts);
                
                C{i} = vpts.Location';
                D{i} = feat;
            
            elseif strcmp(part1_feattype, 'harris')
                    threshold_DoG    = 0.01;
                    threshold_harris = 10;
                    img_filename  = strcat(part1_inputDir, '/',Files(i).name);
                    [coord, desc] = help_extractHarrisFeatures(img_filename, threshold_DoG, threshold_harris, 1, 0);
                    C{i} = coord; %[4  , N_pts]
                    D{i} = desc;  %[128, N_pts]
            end
        end
    end    
    
    % Initialize Matches (between each two consecutive pairs)
    Matches={};
    
    fprintf('\n [1.2 Matching] Step2 - Match Features')
    for i=imgrange
        tic;
        fprintf('\n [1.2 Matching][%s] -- Image : %d', part1_feattype, i);
        % Find matches according to extracted descriptors using vl_ubcmatch
        if (part1_loadData == 0)
            
            if (i == n)
                next = 1;
            else
                next = i+1;
            end
            
            coord1 = C{i};
            desc1  = D{i};

            coord2 = C{next};
            desc2  = D{next};
            
            if strcmp(part1_feattype,'cvteam')
                [match, ~] = vl_ubcmatch(desc1, desc2, part1_matchThreshold); % indices - [2,N_matches]
                % Obtain X,Y coordinates of matches points
                match1 = coord1(1:2,match(1,:));
                match2 = coord2(1:2,match(2,:));
                
            elseif strcmp(part1_feattype,'kaze')
                % match  = matchFeatures(desc1, desc2, 'Unique', true,  'Method', 'Approximate');
                match  = matchFeatures(desc1, desc2, 'Unique', false,  'Method', 'Exhaustive');
                match1 = coord1(:,match(:, 1)); % [2,N]
                match2 = coord2(:,match(:, 2));
                
            elseif strcmp(part1_feattype,'harris')
                if(0)
                    [match, ~] = vl_ubcmatch(desc1, desc2, part1_matchThreshold); % indices - [2,N_matches]
                    % Obtain X,Y coordinates of matches points
                    match1 = coord1(1:2,match(1,:));
                    match2 = coord2(1:2,match(2,:));
                else
                    %threshold_dist = 0.9;
                    [match] = help_ubcmatch(coord1, coord2, desc1, desc2, part1_matchThreshold);
                    % Obtain X,Y coordinates of matches points
                    match1 = coord1(1:2,match(1,:));
                    match2 = coord2(1:2,match(2,:));
                    fprintf('\n  --> Size of Matches : %d', size(match,2));
                end
            end
            
        
            
        else
            filename = strcat(part1_outputDir, sprintf('part1_matches_%s_%s_round%d.mat', part1_name, part1_feattype, i));
            tmp      = load(filename);
            match    = tmp.match;
            match1   = tmp.match1;
            match2   = tmp.match2;
            C{i}     = tmp.coord1;
        end
        
        
        % Find inliers using normalized 8-point RANSAC algorithm
        if (0)
            [F,  inliers] = estimateFundamentalMatrix(match1', match2', 'Method', 'MSAC', 'DistanceThreshold', part1_inlierThreshold);
            fprintf('\n  --> Found %d / %d inliers (%.2f perc)(t:%.2f sec):', size(inliers,2), size(match1,2), size(inliers,2)/size(match1,2), round(toc));
            fprintf('\n F : \n');
            disp(F)
        else
        
            [F, inliers] = help_estimateFundamentalMatrix(match1,match2,part1_inlierThreshold,verbose); %ip = [2,N]
            fprintf('\n  --> Found %d / %d inliers (%.2f perc)(t:%.2f sec):', size(inliers,2), size(match1,2), size(inliers,2)/size(match1,2), round(toc));
            fprintf('\n F : \n');
            disp(F)
        end
        
        Matches{i} = match(:,inliers);
        
        if (save_bool == 1 && part1_loadData == 0)
            name1    = Files(i).name;
            name2    = Files(next).name;
            filename = strcat(part1_outputDir, sprintf('part1_matches_%s_%s_round%d', part1_name, part1_feattype, i));
            save(filename, 'match', 'match1', 'match2', 'coord1', 'coord2', 'part1_inputDir', 'name1', 'name2');
           
        end
        
    end

end
