% (1) Align two images using the Harris corner point detection and the sift match function.
% (2) Use RANSAC to get the affine transformation
% Input:
%       im1 - first image
%       im2 - second image
% Output:
%       affine_transform - the learned transformation between image 1 and image 2
%       match1           - the corner points in image 1
%       match2           - their corresponding matches in image 2

function [affine_transform, match1, match2] = imageAlign(im1, im2, verbose, plot)
    if (verbose == 1)
        fprintf('\n *************** 1. Point Matching ******************* ')
    end
    % ------------------------- 1. SIFT -------------------------
    if (0)
        % Detect interest points using your own Harris implementation (lab 2).
        [r1, c1, sigma1]       = harris(im1, loc1);
        [frames1, descriptor1] = sift(single(im1), r1, c1, sigma1);

        [r2, c2, sigma2]       = harris(im2, loc2);
        [frames2, descriptor2] = sift(single(im2), r2, c2, sigma2);

        % Get the set of possible matches between descriptors from two image.
        matches = null; % Your lab 2 implementation for fining matches
    else
        % Optional: You can compare with your results with the custom sift implementation 
        [feat1, descriptor1] = vl_sift(single(im1));
        [feat2, descriptor2] = vl_sift(single(im2));
        matches = vl_ubcmatch(descriptor1, descriptor2); %matches are 2D pts
        if (verbose == 1)
            fprintf('\n --> Found %d matches \n', size(matches,2));
        end
        % Note: In the final project you will be graded for having your own implementation 
        % for the Harris corner point detection and SIFT feature matching". 
    end

    % ------------------------- 2. RANSAC-------------------------
    % Find affine transformation using your own Ransac function
    match1 = feat1(1:2,matches(1,:)); %[2,947]
    match2 = feat2(1:2,matches(2,:)); %[2,947]
    % best_h = ransac_affine(match1, match2, im1, im2, 6); % [1,6]
    best_h = ransac_affine(match1, match2, im1, im2, verbose); % [1,6]
    % fprintf('\n ------------------------------- \n');
    affine_transform = [best_h(1) best_h(2) best_h(5);
                        best_h(3) best_h(4) best_h(6);
                        0         0         1 ];   
    %disp('Affine Transform : ');
    %disp(affine_transform);
            
    
    % -------------------- 3. IMAGE TRANSFORM WITH H --------------------
    % -------------------- Image1 --> Image2
    if (plot == 1)
        figure(2);
        subplot(2,2,1); imshow(im1); title('Original Image 1');
        subplot(2,2,2); imshow(im2); title('Original Image 2');
        ourPlotting = 0;
        % Define the transformation matrix from 'best_h' (best affine parameters)          
        if (ourPlotting == 1)
            % [Us] First image transformed
            im1_transformed = [];
            for rowid=1:size(im1,1)
                for colid=1:size(im1,2)
                    try
                        im1_int = im1(rowid,colid)';
                        A        =  [rowid colid 1  0     0     0 ; 
                                     0     0     0  rowid colid 1];
                        B_hat = round(A*best_h);
                        im1_transformed(B_hat(1), B_hat(2)) = im1_int;
                    catch
                        disp(im1_int);
                    end
                end
            end
        else
            %tform1 = maketform('affine', affine_transform');
            %im1_transformed = imtransform(im1, tform1, 'bicubic');
            tform1 = affine2d(affine_transform');
            im1_transformed = imwarp(im1, tform1, 'bicubic');
            fprintf('\n Image1 : (%d %d) || Image2 : (%d, %d) \n', size(im1), size(im2));
            %warpedImage = imwarp(im1, affine_transform, 'OutputView', 'panoramaView');
            %disp('warpedImage : ')
            %disp(warpedImage)
            

        end
        
        disp('im1_transformed : ');
        disp(size(im1_transformed))
        subplot(2,2,4); imshow(im1_transformed); 
        title('Image 1 transformed to image 2')

        % % Image2 --> Image1
        if (ourPlotting == 1)
            % best_h_inv = pinv(best_h);
            im2_transformed = [];
            for rowid=1:size(im2,1)
                for colid=1:size(im2,2)
                    try
                        im2_int = im2(rowid,colid)';
                        A        =  [rowid colid 1  0     0     0 ; 
                                     0     0     0  rowid colid 1];
                        B_hat = round(A*affine_transform);
                        im2_transformed(B_hat(1), B_hat(2)) = im2_int;
                    catch
                        a = 1;
                        % disp(B_hat)
                    end
                end
            end
        else
            % tform2 = maketform('affine', inv(affine_transform)');
            % im2_transformed = imtransform(im2, tform2, 'bicubic');
            tform2 = affine2d(inv(affine_transform)');
            % tform2 = affine2d(affine_transform');
            im2_transformed = imwarp(im2, tform2, 'bicubic');
        end
        disp('im2_transformed : ');
        disp(size(im2_transformed));
        subplot(2,2,3); imshow(im2_transformed); title('Image 2 transformed to image 1')
    end
end
