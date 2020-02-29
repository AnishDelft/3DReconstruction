function [r, c, sigmas] = help_harris(im, loc, threshold, plot)
    % inputs: 
    % im: double grayscale image
    % loc: list of interest points from the Laplacian approximation
    % outputs:
    % [r,c,sigmas]: The row and column of each point is returned in r and c
    %              and the sigmas 'scale' at which they were found
    
    % Calculate Gaussian Derivatives at derivative-scale. 
    % NOTE: The sigma is independent of the window size (which dependes on the Laplacian responses).
    % Hint: use your previously implemented function in assignment 1 
    m_sigma = 0.5;
    G   = help_gaussian(m_sigma);
    G_d = help_gaussianDer(G, m_sigma);
    Ix  =  conv2(im, G_d, 'same');
    Iy  =  conv2(im, G_d', 'same');

    % Allocate an 3-channel image to hold the 3 parameters for each pixel
    init_M = zeros(size(Ix,1), size(Ix,2), 3);

    % Calculate M for each pixel
    init_M(:,:,1) = Ix.*Ix;
    init_M(:,:,2) = Iy.*Iy;
    init_M(:,:,3) = Ix.*Iy;

    % Allocate R 
    R = zeros(size(im,1),size(im,2),2);

    % Smooth M with a gaussian at the integration scale sigma.
    % Keep only points from the list 'loc' that are coreners. 
    for l = 1 : size(loc,1)
        sigma = loc(l,3); % The sigma at which we found this point	
        if ((l>1) && sigma~=loc(l-1,3)) || (l==1)
            M = imfilter(init_M, fspecial('gaussian', ceil(sigma*6+1), sigma), 'replicate', 'same');
        end

        % Compute the cornerness R at the current location location
        trace_l = M(loc(l,2),loc(l,1),1) + M(loc(l,2),loc(l,1),2);
        det_l   = M(loc(l,2),loc(l,1),1).*M(loc(l,2),loc(l,1),2) - M(loc(l,2),loc(l,1),3).^2;
        R(loc(l,2), loc(l,1), 1) = det_l - 0.04.*trace_l.^2;

        % Store current sigma as well
        R(loc(l,2), loc(l,1), 2) = sigma;

    end
    % Display corners
    if (plot)
        figure
        imshow(R(:,:,1),[0,1]);
        tmp = R(:,:,1);
        tmp = tmp(:);
        tmps = sort(tmp, 'descend');
    end
    

    % Set the threshold
    if (0)
        responses = R(:,:,1);
        responses = sort(responses(:),'descend');
        responses = responses(1:ceil(length(responses)*0.1));
        threshold = min(responses);
        % threshold = 0.01*(max(max(R(:,:,1)))); %thresh;
    end
    fprintf('\n  --> Threshold : %.2f', threshold);

    % Find local maxima
    % Dilation will alter every pixel except local maxima in a 3x3 square area.
    % Also checks if R is above threshold
 
    % Non max supression	
    R(:,:,1) = ((R(:,:,1)>threshold) & ((imdilate(R(:,:,1), strel('square', 3))==R(:,:,1)))) ; 
       
    % Return the coordinates and sigmas
    if (1)
        [r,c] = find(R(:,:,1));
        coords = sub2ind(size(R(:,:,1)), r, c);
        sigmas = R(:,:,2);
        sigmas = sigmas(coords);
        % sigmas = R(r,c,2);
    else
        [r, c, sigmas] = find(R);
    end
    
end
