% Stitch multiple images in sequence
% Can be used as mosaic(im1,im2,im3,...);
% Input:
%       varargin - sequence of images to stitch
% Output:
%       imgout - stitched images
function imgout = mosaic(varargin)

    % Begin with first image
    imtarget = imread(varargin{1});
    if (length(size(imtarget)) == 3)
        imtarget = rgb2gray(imtarget);
    end
    
    fprintf('\n [Orig] Image1 : %d %d', size(imtarget));

    % Find the image corners
    w = size(imtarget,2);
    h = size(imtarget,1);
    corners = [1 1 1; w 1 1; 1 h 1; w h 1]';
    % First image is not transformed
    A        = zeros(3, 3, nargin);
    A(:,:,1) = eye(3);
    accA     = A;

    % For all other images
    for i = 2:nargin
        % Load next image
        imnew = imread(varargin{i});
        if (length(size(imnew)) == 3)
            imnew = rgb2gray(imnew);
        end
        fprintf('\n [Orig] Image%d : %d %d', i, size(imnew));
        
        % Get transformation of this new image to previous image
        [affine_transform, match1, match2] = imageAlign(imtarget, imnew, 0, 0);

        % Define the transformation matrix from 'best_h' (best affine parameters) 	
        A(:,:,i) = affine_transform;
    
        % Combine the affine transformation with all previous matrices
        % to get the transformation to the first image
        accA(:,:,i) = A(:,:,i) * accA(:,:,i-1);
    
        % Add the corners of this image
        w = size(imnew,2);
        h = size(imnew,1);
        corners_tmp = (accA(:,:,i))*[1 1 1; w 1 1; 1 h 1; w h 1]'; % [3,4]
        corners     = [corners corners_tmp];
    end
    
    % Find size of output image
    minx = int16(0);
    maxx = int16(max(corners(1,:)));
    miny = int16(0);
    maxy = int16(max(corners(2,:)));
    
    % Output image
    imgout = zeros(maxy-miny+1, maxx-minx+1, nargin);
    fprintf('\n [Mosaic] Final Image Output Size : (%d %d %d)', size(imgout));
    
    % Output image coordinate system
    xdata = [minx, maxx];
    ydata = [miny, maxy];

    % Transform each image to the coordinate system
    % fprintf('\n ----------------------- ');
    for i=1:nargin
        im = imread(varargin{i});
        if (length(size(im)) == 3)
            im = rgb2gray(im);
        end
        if (1)
            tform   = maketform('affine', inv(accA(:,:,i))');
            newtimg = imtransform(im, tform, 'bicubic', 'XData', double(xdata), 'YData', double(ydata));
            if (0)
                subplot(1,2,i);
                imshow(newtimg);
            end
        else
            tform   = affine2d(accA(:,:,i)');
            newtimg = imwarp(im, tform, 'bicubic');
        end
        fprintf('\n [Mosaic][Warped Im%d] : %d %d', i, size(newtimg));
        imgout(:,:,i) = uint8(newtimg);
    end
    
    
    % Blending methods to combine: nanmedian (stable for longer sequences of images)
    imgout = nanmean(imgout,3);
    
    % Show stitched image
    if (1)
        figure; imshow(uint8(imgout));
    else
        figure(2);
        subplot(1,2,1)
        imshow(uint8(imgout(:,:,1)))
        subplot(1,2,2)
        imshow(uint8(imgout(:,:,2)))
    end
    
    
end
