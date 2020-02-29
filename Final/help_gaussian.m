function G = help_gaussian(sigma)

    if (0)
        L = ceil(2*sigma);
    else
        L = ceil(3*sigma);
    end
    

    if sigma == 0
        G = 0;
    else
        G = 1/(sigma*sqrt(2*pi)) * exp(-(-L:L).^2/(2*sigma^2));
        %(normalization)
        G = G / sum(G);
    end

end