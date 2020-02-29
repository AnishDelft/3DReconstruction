% Function [Xout, T] = normalize( X )
% Normalize all the points in each image
% Input
%     -X: a matriX with 2D inhomogeneous X in each column. %% --> [2,N]
% Output: 
%     -Xout: a matriX with (2+1)D homogeneous X in each column;
%     -matrix T: normalization matrix

function [Xout, T] = help_normalize( X ) % X = [2,N]

    % Compute Xmean: normalize all X in each image to have 0-mean
    Xmean =  [mean(X(1,:)) mean(X(2,:))];

    % Compute d: scale all X so that the average distance to the mean is sqrt(2).
    % Check the lab file for details.
    d = (1/size(X,2)) * sum(sqrt((X(1,:) - Xmean(1)).^2 + (X(2,:) - Xmean(2)).^2));
    
    % Compose matrix T
    T = [sqrt(2)/d      0     -Xmean(1)*(sqrt(2)/d) ; 
            0      sqrt(2)/d  -Xmean(2)*(sqrt(2)/d) ;
            0           0               1
    ];
    try
        % Compute Xout using X^ = TX with one extra dimension (We are using homogenous coordinates)
        Xout = T * [X; ones(1,size(X,2))];
    catch
        fprintf('\n [Err] Size of X : %d %d', size(X));
        fprintf('\n [Err] Size of T : %d %d', size(T));
        fprintf('\n [Err] Size of [X; ones(1,size(X,2))] : %d %d', size([X; ones(1,size(X,2))]));
        return
    end
    
    

end
