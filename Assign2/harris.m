function [r, c, sigmas] = harris(img, loc, verbose, plot) % loc = [...,[c,r,sigma],...]
    % inputs: 
    % im: double grayscale image
    % loc: list of interest points from the Laplacian approximation
    % outputs:
    % [r,c,sigmas]: The row and column of each point is returned in r and c
    %              and the sigmas 'scale' at which they were found
    
    % Calculate Gaussian Derivatives at derivative-scale. 
    % NOTE: The sigma here is for computing the image derivatives. 
    % It is independent of the window size (Which depends on the Laplacian /DoG responses).

    % Hint: use your previously implemented function in assignment 1 
    % Use a small sigma: 0.6 here
    G  = gaussian(0.6); 
    Gd = gaussianDer(G, 0.6);
    Ix =  conv2(img, Gd , 'same');
    Iy =  conv2(img, Gd', 'same');

    % Allocate an 3-channel image to hold the 3 parameters for each pixel: Ix^2, Iy^2 and IxIy
    init_M = zeros(size(Ix,1), size(Ix,2), 3); %[h,w,3]

    % Calculate M for each pixel: Ix^2, Iy^2, IxIy
    init_M(:,:,1) = Ix.^2;
    init_M(:,:,2) = Iy.^2;
    init_M(:,:,3) = Ix.*Iy;
    
    % Smooth M with a gaussian at the integration scale sigma. ???
    
    
    % Allocate the size of R 
    R = zeros(size(img,1),size(img,2),2); 
    
    k = 0.04;
    
    % Smooth M with a gaussian at the integration scale sigma.
    % Keep only points from the list 'loc' that are coreners. 
    for l = 1 : size(loc,1)
        sigma = loc(l,3); % The sigma at which we found this point	

    	% The response accumulation over a window of size '2k sigma + 1' (Where k is the Gaussian cutoff: it can be 1, 2, 3).
        if ((l>1) && sigma~=loc(l-1,3)) || (l==1)
            M       = imfilter(init_M, fspecial('gaussian', ceil(sigma*2+1), sigma), 'replicate', 'same');
            trace_l = M(:,:,1) + M(:,:,2);
            det_l   = M(:,:,1).*M(:,:,2) - M(:,:,3).*M(:,:,3);
            tmp     = det_l - k*(trace_l.^2);
        end
	
        % Compute the cornerness R at the current location location
        R(loc(l,2), loc(l,1), 1) = tmp(loc(l,2), loc(l,1));

    	% Store current sigma as well
        R(loc(l,2), loc(l,1), 2) = sigma;

    end
    % Display cornersa
    if (plot == 1)
        figure;
        imshow(R(:,:,1),[0,1]);
        title('[No threshold] R matrix of Harris');
    end
    

    % Threshold1 : Set the threshold (max value across rows and columns and 0.x percent of that)
    threshold = max(max(R(:,:,1)))*0.1; % Try also 0.3 to retain less corners
    if (verbose == 1)
        fprintf('[Harris] Max Value : ', threshold/0.1);
    end
    
    % Threshold2 : Find local maxima
    % Dilation will alter every pixel except local maxima in a 3x3 square area.
    % Also checks if R is above threshold
    R(:,:,1) = ((R(:,:,1)>threshold) & ((imdilate(R(:,:,1), strel('square', 3))==R(:,:,1)))) ; 
       
    % Return the coordinates r, c and sigmas
    [r,c]  = find(R);
    sigmas = R(r,c,2);
    
    % Display corners
    if (plot == 1)
        figure;
        imshow(double(im)/255.0, [0,1]); hold on;
        circle(c,r,2*sigmas+1); hold off;
        title('[Thresholded] Responses of Harris');
    end
    
end


function h = circle(in_x, in_y, in_r)
    for i = 1:size(in_x,1)
        x = in_x(i);
        y = in_y(i);
        r = in_r(i);
        
        th = 0:pi/50:2*pi;
        xunit = r * cos(th) + x;
        yunit = r * sin(th) + y;
        h = plot(xunit, yunit);
    end
end
