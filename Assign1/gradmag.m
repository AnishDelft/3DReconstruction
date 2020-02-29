function [magnitude , orientation] = gradmag(img , sigma)
    Gx = gaussian_me(sigma);
    Gy = gaussian_me(sigma);
    
    Gdx = gaussianDer(Gx, sigma);
    Gdy = gaussianDer(Gy, sigma);
    
    tempx = conv2([1], Gdx, img, 'same');
    tempy = conv2(Gdy', [1], img, 'same');
    
    magnitude = sqrt(tempx.^2 + tempy.^2);
    orientation = atan(tempx./tempy);
    
    if (0)
        figure(1)
        subplot(1,3,1);
        imshow(img);
        subplot(1,3,2);
        imshow(tempx);
        subplot(1,3,3);
        imshow(tempy);
    end
    
    if (0)
        figure(1)
        subplot(1,3,1);
        imshow(img);
        subplot(1,3,2);
        imshow(magnitude);
        subplot(1,3,3);
        imshow(orientation);
    end
    
    if (1)
        figure(1)
        subplot(1,4,1);
        imshow(img);
        subplot(1,4,2);
        imshow(magnitude);
        subplot(1,4,3);
        imshow(tempx);
        subplot(1,4,4);
        imshow(tempy);
    end
end