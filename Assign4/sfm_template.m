% function sfm
% A demo of the SfM (Structure from Motion) that shows the 3D structure of the points in the space. 
% Either from the original given set of points or the tracked points.
% 
% INPUT
%   Set of point correspondences to be read from local file. 
%
% OUTPUT
%   An image showing the 3D points in their estimated 3D world position.
%       - Yellow dots are when using the given list of points.
%       - Pink dots are when using the tracked points from the LKtracker.
%   M: The transformation matrix size of 2nx3. Where n is the number of cameras i.e. images.
%   S: The estimated 3-dimensional locations of the points (3x#points).

function [M,S] = sfm()
    close all

    % Load initial set of points
    X = importdata('./model_house/measurement_matrix.txt');

    [~, noPoints] = size(X);
    % Centering: subtract the centroid of the image points (removes translation)
    X = ...

    % Singular value decomposition
    % Remark: Please pay attention to using V or V'. Please check matlab function: "help svd".
    [... ,... ,... ] = svd(X);

    % The matrix of measurements must have rank 3.
    % Keep only the corresponding top 3 rows/columns from the SVD decompositions.
    U = ... 
    W = ...
    V = ... 

    % Compute M and S: One possible decomposition is M = U W^{1/2} and S = W^{1/2} V'
    M = ... 
    S = ...
    save('M','M')

    % Eliminate the affine ambiguity
    % Orthographic: We need to impose that image axes (a1 and a2) are perpendicular and their scale is 1.
    % (a1: col vector, projection of x; a2: row vector, projection of y;,)
    % We define the starting value for L, L0 as: A1 L0 A1' = Id 
    A1 = M(1:2, :);
    L0 = pinv(A1' * A1);

    % We solve L by iterating through all images and finding L one which minimizes Ai*L*Ai' = Id, for all i.
    % LSQNONLIN solves non-linear least squares problems. Please check the Matlab documentation.
    L = lsqnonlin(@residuals, L0);

    % Recover C from L by Cholesky decomposition.
    C = chol(L,'lower');

    % Update M and S with the corresponding C form: M = MC and S = C^{-1}S. 
    M = ...
    S = ...

    % Plot the obtained 3D coordinates:
    plot3(S(1,:),S(2,:),S(3,:),'.y');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Repeat the same procedure for the Optical Flow tracked points %%%%%%%%%%%
    % Clear variables (U,W,V,M,S,A1,L0) which have been used in first part load tracked points
    load('Xpoints')
    load('Ypoints')
    X2 = zeros(size(X));
    X2(1:2:end,:)= ...
    X2(2:2:end,:)= ....

    % Centering the data
    [~,noPoints] = size(X2);
    X2 = ....

    % Perform the Singular Value Decomposition
    [..., ..., ...] = svd(X2);

    % Impose the rank 3 constraint by keeping the top 3 columns/rows for the obtained matrices.
    U = ...
    W = ...
    V = ...

    % Define the matrices M and S from U, W, and V.
    M = ... 
    S = ...
    save('M','M') 

    % Solve the affine ambiguity 
    A1 = ...
    L0 = ...
    L = lsqnonlin(@residuals,L0);

    % Recover C from L by Cholesky decomposition
    C = chol(L,'lower');

    % Update M and S with the values of C: M = MC, S = C^{-1}S
    M = ...
    S = ...

    % Plot the obtained 3D points as well.
    hold on
    plot3(S(1,:),S(2,:),S(3,:),'.m');

end
