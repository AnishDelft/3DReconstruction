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
        match1 = [match1;ones(1,size(match1,2))];
        match2 = [match2;ones(1,size(match2,2))];

        % Initialize parameters
        bestcount = 0;
        bestinliers = [];
        
        % 
        iterations = 50;

        % Minimum of iterations
        miniter = 50;

        % How many points are needed for the Fundamental matrix?
        P = 8;

        % Start iterations
        i=0;
        while i<iterations

            if (verbose == 1 && mod(i,10) == 0)
                fprintf('\n   [1.3 Matching] -------------- Iter : %d (Best : %.2f perc) --------------', i, size(bestinliers,2)/size(match1,2));
            end

            % Randomly select P points from two sets of matched points.
            % Keep only the first two dimensions: x, y.
            T = size(match1,2);

            perm = randperm(T);
            seed = perm(1:P);

            X_rand1 = match1(1:2, seed);
            X_rand2 = match2(1:2, seed);

            % Normalization
            [X1,T1] = help_normalize(X_rand1);
            [X2,T2] = help_normalize(X_rand2);

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
                [X1,T1] = help_normalize(match1(1:2, inliers));
                [X2,T2] = help_normalize(match2(1:2, inliers));

                % Use inliers to re-estimate F
                A = help_composeA(X1(1:2,:)', X2(1:2,:)');
                if (any(isnan(A(:))))
                    continue
                end
                F = help_computeF(A,T1,T2);

                % Find the final set of inliers
                inliers = help_computeInliers(F,match1,match2,threshold);

                % Note: The number of inliers is assumed to be written as [1 x #good_matches].	
                % if number of inlier > the best so-far, use new F
                if size(inliers,2)>bestcount
                    bestcount   = size(inliers,2);
                    bestF       = F;
                    bestinliers = inliers;
                    if (verbose == 1)
                        fprintf('\n   [1.3 Matching] Total inliers : %d / %d (%.2f perc)', size(bestinliers,2), size(match1,2), size(bestinliers,2)/size(match1,2));
                    end
                end


                % Calculate how many iterations we need by computing:
                % i=log(eps)/log(1-q^p),
                % where p=8 (the number of matches)
                % q= #inliers/#total_pairs (the proportion of inliers over total pairs)
                eps = 0.001;
                q = size(bestinliers,2)/T;

                % Solve for i in the assignment description. 
                iter = log(eps)/log(1-q^P);

                % To prevent special cases, always run at least a couple of times
                iterations = max(miniter, ceil( iter ));
                
                max_limit_iter = 15000;
                
                iterations = min(max_limit_iter, ceil( iter ));

            end
            i = i+1;

        end
        
        fprintf('\n  -->  RANSAC_Iters : %d', i);

    end
    






