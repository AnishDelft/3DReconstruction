% function inliers = computeInliers(F,match1,match2,threshold)
% Find inliers by computing perpendicular errors between the points and the epipolar lines in each image
% To be brief, we compute the Sampson distance mentioned in the lab file.
% Input: 
%   -matrix F, matched points from image1 and image 2, and a threshold (e.g. threshold=50)
% Output: 
%   -inliers: indices of inliers
function inliers = help_computeInliers(F,match1,match2,threshold)

    % Calculate Sampson distance for each point
    % Compute numerator and denominator at first
    if (0)
        numer = diag(match2'*F*match1).^2; % diag([3,N]'*[3,3]*[3,N]) = [N,1]

        % denom = (F*match1) % [3,3]*[3,N] = [3,N](1,:) --- take-x --> [1,N] 
        tmp1 = F*match1; % [Note] : Do we have to normalize this?
        tmp2 = F'*match2;
        denom = tmp1(1,:).^2 + tmp1(2,:).^2 + tmp2(1,:).^2 + tmp2(2,:).^2;
        sd    = numer'./denom;
    else
        Fx1   = F*match1;
        Ftx2  = F'*match2;
        num   = sum(match2 .* Fx1,1).^2;
        denum = sum(Fx1(1:2,:).^2,1) + sum(Ftx2(1:2,:).^2,1);
        sd    = num./denum;
        % scost = sqrt(sum(sd));
    end
    
    % Return inliers for which sd is smaller than threshold
    inliers = find(sd<threshold);

end
