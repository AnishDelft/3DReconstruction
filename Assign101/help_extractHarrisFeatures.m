function [coord, desc] = help_extractHarrisFeatures(img_filename, threshold_DoG, threshold_harris, verbose, plot)
    
    img      = imread(img_filename);
    img_gray = rgb2gray(img);
    
    pts_DoG            = help_DoG(img_gray, threshold_DoG);
    if (verbose == 1)
        fprintf('\n  --> DoG points : %d', size(pts_DoG,1));
    end
    
    [r,c,sigmas] = help_harris(img_gray, pts_DoG, threshold_harris, 0);
    if verbose == 1
        fprintf('\n  --> Total corner points detected : %d', size(r,1));
    end
    if (plot == 1)
        figure; imshow(img); hold on; scatter(c,r,'y');
		figure; imshow(img); hold on; scatter(pts_DoG(:,1),pts_DoG(:,2),'b')
    end
    
    orient         = zeros(size(sigmas));
    [coord, desc]  = vl_sift(single(img_gray), 'frames', [c'; r'; sigmas'; orient']);
    
end