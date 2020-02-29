function Gd =gaussianDer(G , sigma)
    X  = ceil(3*sigma);
    Gd = -1*(X.*G)/(sigma^2);
end