function imOut = gaussianConv(image_path , sigma_x , sigma_y)
% function [Gx, Gy] = gaussianConv(image_path , sigma_x , sigma_y)
    img = imread(image_path);
    img = img(:,:,1);
    Gx = gaussian_me(sigma_x);
    Gy = gaussian_me(sigma_y);
    
    fprintf('\nKernel Length - X: %d', size(Gx,2));
    fprintf('\nKernel Length - Y: %d', size(Gy,2))
    
    % imOut = conv2(Gx, Gy, img);
    imOut = conv2(Gy', Gx, img);
    %kernel = Gx(:)*Gy(:)';
    %imOut_me = conv2(kernel, img);
    
    % gaussianConv('zebra.png', 1,1);
    
end