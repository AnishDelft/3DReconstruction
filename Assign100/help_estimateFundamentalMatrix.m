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
    if(0)
        % Set in homogenous coordinates
        match1 = [match1;ones(1,size(match1,2))]; % [3,N]
        match2 = [match2;ones(1,size(match2,2))];

        % Initialize parameters
        bestcount = 0;
        bestinliers = [];

        % Initialize RANSAC parameters
        % Total iterations (e.g. 50)
        % iterations = 50;
        iterations = 2000;

        % Minimum of iterations
        miniter = 5;

        % How many points are needed for the Fundamental matrix?
        p= 8;

        % Threshold
        threshold = threshold;

        % Start iterations
        i=0;
        inliers = [];
        while i<iterations
            if (verbose == 1 && mod(i,10) == 0)
                fprintf('\n   [1.3 Matching] -------------- Iter : %d (Best : %.2f perc) --------------', i, size(bestinliers,2)/size(match1,2));
            end

            % Randomly select P points from two sets of matched points
            seed  = randi(size(match1,2),[p,1]); % size=[p,1]
            perm1 = match1(:,seed); % size = [3,p]
            perm2 = match2(:,seed);

            % Normalization
            [X1,T1] = help_normalize(perm1(1:2,:)); % ip = [2,N]
            [X2,T2] = help_normalize(perm2(1:2,:)); % [Note] Check mean(X2,2) to debug

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
                    if (verbose == 1)
                        fprintf('\n   [1.3 Matching] Total inliers : %d / %d (%.2f perc)', size(bestinliers,2), size(match1,2), size(bestinliers,2)/size(match1,2));
                    end

                end

                % Calculate how many iterations we need by computing:
                % q=(the proportion of inliers over total pairs)
                q    = size(inliers,2)/size(match1,2); 
                eps  = 0.001;
                iter = log(eps) / log(1 - q^p);
                % iterations = iter;

                % [Note] : q < 0.01 -> iter = -Inf  
                % [Note] : q = 0.6  -> iter = ~272
                % [Note] : q = 0.5  -> iter = ~1177

                % To prevent special cases, always run at least a couple of times
                % iterations = max(miniter, ceil(iter));
                % fprintf('\n Total Iterations : %d || q: %.2f (iter:%d)\n', iterations, q, ceil(iter));
                % iterations = 100;
            end

            i = i+1;

        end

        if (verbose == 1)
            fprintf('\n   [1.3 Matching] -------------- Iter : %d --------------', i);
        end

        %fprintf('\n\n =================================================== ')
        %disp(strcat(int2str(iterations), ' iterations used to estimate F'));
        %pause(0.001);
        % fprintf('\n []Total Inliers : %d', size(bestinliers,2))
        % disp(strcat(int2str(size(bestinliers,2)), ' inliers found'));
    else
        
        % Set in homogenous coordinates
        match1 = [match1;ones(1,size(match1,2))];
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
        P = 8;

        %threshold
    %     threshold = 50;

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
            [X1,T1] = normalize_avi(X_rand1);
            [X2,T2] = normalize_avi(X_rand2);

            % Compose matrix A, given matched points (X1,X2) from two images
            A = composeA_avi(X1(1:2,:)', X2(1:2,:)');

            % Compute F given A, T1 and T2    
            F = computeF_avi(A,T1,T2);

            % Find inliers by computing perpendicular errors between the points 
            % and the epipolar lines in each image
            inliers = computeInliers_avi(F,match1,match2,threshold);

            % Check if the number of inliers is larger than 8
            % If yes, use those inliners to re-estimate (re-fine) F.    
            if size(inliers,2)>=8
                % Normalize previously found inliers
                [X1,T1] = normalize_avi(match1(1:2, inliers));
                [X2,T2] = normalize_avi(match2(1:2, inliers));

                % Use inliers to re-estimate F
                 A = composeA_avi(X1(1:2,:)', X2(1:2,:)');
                F = computeF_avi(A,T1,T2);

                % Find the final set of inliers
                inliers = computeInliers_avi(F,match1,match2,threshold);

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

            end
            i = i+1;

        end
        fprintf('\n   [1.3 Matching] -------------- Iter : %d --------------', i);
    %     disp(strcat(int2str(iterations), ' iterations used to estimate F'));
    %     pause(0.001);
    %     disp(strcat(int2str(size(bestinliers,2)), ' inliers found'));
    end
    
end





