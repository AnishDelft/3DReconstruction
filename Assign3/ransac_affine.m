% Ransac implementation to find the affine transformation between two images.
% Input:
%       match1 - set of point from image 1
%       match2 - set of corresponding points from image 2
%       im1    - the first image
%       im2    - the second image
% Output:
%       best_h - the affine affine transformation matrix

% function best_h = ransac_affine(match1, match2, im1, im2, threshold)
function best_h = ransac_affine(match1, match2, im1, im2, verbose)
    % Iterations is automatically changed during runtime based on inlier-count
    % Set min-iterations (e.g. 5 iterations) to circumvent corner-cases
    iterations = 500; 
    miniterations = 5;

    % Threshold: the 10 pixels radius
    threshold = 10;

    % The model needs at least ? point pairs (? equations) to form an affine transformation
    P = 3; %3pts = 6 equations for 6 unknowns in affine transform

    % Start the RANSAC loop
    bestinliers = [];
    best_h      = zeros(6,1);
    
    
    
    i=1;
    while ((i<=iterations) || (i<=miniterations))
        if (mod(i,100) == 0 && verbose == 1)
            fprintf('\n ***************** Iter : %d (Inliers : %d) *****************\n',i, size(bestinliers,2))
        end
        
        % (1) Pick randomly P matches
        seed = randi(size(match1,2),P,1);
        perm1 = match1(:,seed)';
        x0 = perm1(1,1);
        y0 = perm1(1,2);
        x1 = perm1(2,1);
        y1 = perm1(2,2);
        x2 = perm1(3,1);
        y2 = perm1(3,2);
        
        perm2 = match2(:,seed)';
        x0p = perm2(1,1);
        y0p = perm2(1,2);
        x1p = perm2(2,1);
        y1p = perm2(2,2);
        x2p = perm2(3,1);
        y2p = perm2(3,2);

        % (2) Construct matrices A, h, b    
        A = [x0 y0 0  0  1  0 ; 
             0  0  x0 y0 0  1 ; 
             x1 y1 0  0  1  0 ; 
             0  0  x1 y1 0  1 ; 
             x2 y2 0  0  1  0 ;
             0  0  x2 y2 0  1 ];
        B = [x0p; y0p; x1p;  y1p; x2p ; y2p ];
        
        % (3) Fit model h over the matches
        h = pinv(A)*B; % B = Ah
        
        % (4) Transform all points from image1 to their counterpart in image2. Plot these correspondences.
        if (0)
            B_ = A*h;
            figure; imshow([im1 im2]); hold on;
            line([A(1,1), size(im1,2)+B_(1,1)], [A(1,2), B_(2,1)], 'color', 'y')
            line([A(3,1), size(im1,2)+B_(3,1)], [A(3,2), B_(4,1)], 'color', 'y')
            line([A(5,1), size(im1,2)+B_(5,1)], [A(5,2), B_(6,1)], 'color', 'y')
            title('Image 1 and 2 with the original points and their transformed counterparts in image 2');
        end
        
        % (5) Determine inliers using the threshold and save the best model
        h1_m = [h(1) h(2); h(3) h(4)];
        h1_t = [h(5);h(6)];
        inliers   = [];
        if (0)
            B_hat       = h1_m*match1 + h1_t;
            inlier_idxs = find(sqrt(sum((match2 - B_hat).^2)) < threshold);
            inliers     = match1(:,inlier_idxs);
        else
            for j=1:size(match1,2)
                perm1 = match1(:,j)';
                x0    = perm1(1,1);
                y0    = perm1(1,2);
                Atmp  =  [x0 y0 0  0  1  0 ; 
                          0  0  x0 y0 0  1];

                perm2 = match2(:,j)';
                x0p   = perm2(1,1);
                y0p   = perm2(1,2);
                Btmp  = [x0p; y0p];

                B_hat = Atmp*h;
                error = sqrt(sum((Btmp - B_hat).^2)); % euclidean distance
                
                if (error < threshold)
                    inliers = [inliers [x0;y0]];
                end
            end
        end
        
        % (6) Save the best model and redefine the stopping iterations
        if size(inliers,2) > size(bestinliers,2)
            bestinliers = inliers;
            best_h = h;
        end
        
        % (6)
        q    = size(bestinliers, 2) / (size(match1,2));
        % iterations = log(0.001) / log(1 - q^P);
        % fprintf('\nIter : %d ||  q : %f || log(1 - q^P) : %f)', iterations, log(1 - q^P));
        % fprintf('\nIter : %d ||  q : %f, q^P)', iterations, q,q^P);
        
        i = i + 1;
        
    end
    
    fprintf('\n\n [RANSAC] Total Inliers: %d / %d = %f', size(bestinliers, 2), size(match1,2), size(bestinliers, 2) / size(match1,2));
    
    % Final Step to show best inlier points and their mapping from im1 to
    if (0)
        figure(1); imshow([im1 im2]); hold on;
        fprintf('  --> Total Inliers : %d / %d', size(bestinliers,2), size(match1,2));
        for i=1:size(bestinliers,2)
            A     = bestinliers(:, i);
            x0 = A(1);
            y0 = A(2);
            Atmp  =  [x0 y0 0  0  1  0 ; 
                      0  0  x0 y0 0  1];
            B_    = Atmp*best_h;
            x1    = B_(1,1);
            y1    = B_(2,1);
            line([x0, size(im1,2) + x1], [y0, y1], 'color', 'y');
        end
        title('Image 1 and 2 with best inliers');
    end
    
end
