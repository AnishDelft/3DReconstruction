% Function [bestF bestinliers] = estimateFundamentalMatrix(match1, match2)
% Estimate the fundamental matrix (F)
%
% Input: 
%           - match1: matched points from the first images
%           - match２: matched points from the second images
% Output: 
%           - bestF: estimated F 
%           - bestinliers: inliers found
          
function [bestF, bestinliers] = help_estimateFundamentalMatrix(match1, match2,...
                                        threshold, verbose)

    % Set in homogenous coordinates
    match1 = [match1;ones(1,size(match1,2))]; % [3,N]
    match2 = [match2;ones(1,size(match2,2))];

    % Initialize parameters
    bestcount = 0;
    bestinliers = [];

    % Initialize RANSAC parameters
    % Total iterations (e.g. 50)
    iterations = 50;

    % Minimum of iterations
    miniter = 5;

    % How many points are needed for the Fundamental matrix?
    p= 8;
    
    % Threshold
    threshold = threshold;

    % Start iterations
    i=0;
    while i<iterations
        if (verbose == 1 && mod(i,10) == 0)
            fprintf('\n -------------- Iter : %d --------------', i);
        end
        
        % Randomly select P points from two sets of matched points
        seed  = randi(size(match1,2),p,1); 
        perm1 = match1(:,seed)';
        perm2 = match2(:,seed)';
        
        % Normalization
        [X1,T1] = help_normalize(perm1(:,1:2)'); % ip = [2,N]
        [X2,T2] = help_normalize(perm2(:,1:2)');
        
        % Compose matrix A, given matched points (X1,X2) from two images
        A = help_composeA(X1(1:2,:)', X2(1:2,:)');
        
        % Compute F given A, T1 and T2    
        F = help_computeF(A,T1,T2);
        
        % Find inliers by computing perpendicular errors between the points 
        % and the epipolar lines in each image
        inliers = help_computeInliers(F,match1,match2,threshold);
        
        % Check if the number of inliers is larger than 8
        % If yes, use those inliners to re-estimate (re-fine) F.    
        if size(inliers,2)>=8
            % Normalize previously found inliers
            [X1,T1] = help_normalize(match1(1:2,inliers)); % ip = [2,N]
            [X2,T2] = help_normalize(match2(1:2,inliers));
            
            % Use inliers to re-estimate F
            A = help_composeA(X1(1:2,:)', X2(1:2,:)');
            F = help_computeF(A,T1,T2);
            
            % Find the final set of inliers
            inliers = help_computeInliers(F,match1,match2,threshold); % [1,N]
            
            % if number of inlier > the best so-far, use new F
            if size(inliers,2)>bestcount
                bestcount   = size(inliers,2);
                bestF       = F;
                bestinliers = inliers;
                % fprintf('\n [Best] Total inliers : %d', size(bestinliers,2));
            end
            
            % Calculate how many iterations we need by computing:
                % i=log(t)/log(1-q^p),
                % where p=8 (the number of matches)
                % q= #inliers/#total_pairs (the proportion of inliers over total pairs)
            q   = size(inliers,2)/size(match1,2);
            eps = 0.001;
            iter   = log(eps) / log(1 - q^p);
            % To prevent special cases, always run at least a couple of times
            iterations = max(miniter, ceil(iter));
            % fprintf('\n Total Iterations : %d \n', iterations);
            % iterations = 100;
        end
        
        i = i+1;
        
    end
    
    if (verbose == 1)
        fprintf('\n -------------- Iter : %d --------------', i);
    end
    
    %fprintf('\n\n =================================================== ')
    %disp(strcat(int2str(iterations), ' iterations used to estimate F'));
    %pause(0.001);
    % fprintf('\n []Total Inliers : %d', size(bestinliers,2))
    % disp(strcat(int2str(size(bestinliers,2)), ' inliers found'));
end





