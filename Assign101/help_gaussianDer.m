function Gd = help_gaussianDer(G, sigma)
    
    if (0)
        L = ceil(2*sigma);
    else
        L = ceil(3*sigma);
    end
    

    %halfSize = ceil(3 * sigma);
    x = -L:L;

    Gd = -(x./sigma.^2).*G;

end