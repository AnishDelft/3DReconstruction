% Function [Xout, T] = normalize( X )
% Normalize all the points in each image
% Input
%     -X: a matriX with 2D inhomogeneous X in each column.
% Output: 
%     -Xout: a matriX with (2+1)D homogeneous X in each column;
%     -matrix T: normalization matrix
function [Xout, T] = normalize_avi( X )

    % Compute Xmean: normalize all X in each image to have 0-mean
    Xmean =  mean(X,2);
    
    Xscaled = X - mean(X,2);

    % Compute d: scale all X so that the average distance to the mean is sqrt(2).
    % Check the lab file for details.
    d = sum(sqrt(Xscaled(1,:).^2 + Xscaled(2,:).^2))./size(X,2);

    % Compose matrix T
    T = [sqrt(2)/d   0      -Xmean(1)*sqrt(2)/d; ...
           0     sqrt(2)/d  -Xmean(2)*sqrt(2)/d; ...
           0         0               1          ];
		
    % Compute Xout using X^ = TX with one extra dimension (We are using homogenous coordinates)
    Xout = T * [X; ones(1,size(X,2))];

end
