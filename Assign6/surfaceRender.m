% function [] = surfaceRender(pointcloud, M, Mean, img)
% project every point on the surface to the main view (camera plane) as 
% reconstructed from sfm, and use the projected coordinates to find 
% RGB (texture) colour of the related points.

% Inputs:
% - pointcloud: reconstructed point clould
% - M: transformation matrix of the main view (camera plane) where all
% - points are projected
% - Mean: Mean values of the main view (this will be used during coordinates (de)normalization) 
% - img: corresponding image of main view
%
% Outputs:
% - None
function [] = surfaceRender(pointcloud, M, Mean, img)

    % (X,Y,Z) of the point cloud = [3,N_pts]
    pointcloud = unique(pointcloud', 'rows')';
    X_orig = pointcloud(1,:);
    Y_orig = pointcloud(2,:);
    Z_orig = pointcloud(3,:);

    % % % Cross product of two vectors (X and Y)
    % % % The cross product a × b is defined as a vector c 
    % % % that is perpendicular (orthogonal) to both a and b, 
    % % % with a direction given by the right-hand rule and a magnitude 
    % % % equal to the area of the parallelogram that the vectors span.
    viewdir = cross(M(1,:), M(2,:)); % M = [2,3]
    viewdir = viewdir/sum(abs(viewdir)); % sum(viewdir)=1
    viewdir = viewdir';
    
    % % Centre point cloud around zero and use dot product to remove points
    % % behind the mean
    m  = [mean(X_orig) ; mean(Y_orig); mean(Z_orig)]; 
    X0 = [X_orig       ; Y_orig      ; Z_orig];
    X1 = repmat(viewdir, 1 , size(X_orig,2));
    Xm = repmat(m      , 1 , size(X_orig,2));

    % Remove the points where the dot product between the mean subtracted points
    % (given by X0 - Xm) and the viewing direction is negative
    tmp        = dot(X1, X0 - m); %[1,5031]
    indices    = find(tmp < 0);   %[1,2300]
    fprintf('\n We have lost %d points from %d points : ', size(indices,2), size(tmp,2));
    X = X_orig; Y = Y_orig;Z = Z_orig;
    X(indices) = [0];
    Y(indices) = [0];
    Z(indices) = [0];
    
    if (1)
        figure;
        subplot(1,2,1);
        scatter3(X_orig,Y_orig,Z_orig, 'r', 'filled');
        axis([-500 500 -500 500 -500 500]);
        view(-90,-90);
        
        subplot(1,2,2);
        scatter3(X,Y,Z, 'b', 'filled');
        axis([-500 500 -500 500 -500 500]);
        view(-90,-90);     
    end
    
    
    % Grid to create surface on using meshgrid.
    % You can define the size of the grid (e.g., -500:500) 
    ti = 1;
    [qx,qy] = meshgrid(min(X):max(X), min(Y):max(Y));

    % Surface generation using TriScatteredInterp
    % You can also use scatteredInterpolant instead.
    % Please check the detailed usage of these functions
    F  = TriScatteredInterp(X', Y', Z');
    qz = F(qx,qy); 
    % Note: qz contains NaNs because some points in Z direction may not defined
    % This will lead to NaNs in the following calculation.
    
    if (1)
        qx = uint16(qx);
        qy = uint16(qy);
        qz = uint16(qz);
    end
    

    % Reshape (qx,qy,qz) = ([m,n], [m,n], [m,n]) 
    % to row vectors for next step
    qxrow = reshape(qx, [1,size(qx,1)*size(qx,2)]);
    qyrow = reshape(qy, [1,size(qy,1)*size(qy,2)]);
    qzrow = reshape(qz, [1,size(qz,1)*size(qz,2)]);

    % Transform to the main view using the corresponding motion 
    % / transformation matrix, M
        meh = 1;
    q_xy = M*[qxrow; qyrow; qzrow]

    % All transformed points are normalized by mean values in advance, we have to move
    % them to the correct positions by adding corresponding mean values of each dimension.
%     q_x = ... 
%     q_y = ... 

    % Remove NaN values in q_x and q_y
    q_x(isnan(q_x))=1;
    q_y(isnan(q_x))=1;
    q_x(isnan(q_y))=1;
    q_y(isnan(q_y))=1;

    figure(2);

    if(size(img,3)==3)
        % Select the corresponding r,g,b image channels
        imgr = img(:,:,1);
        imgg = img(:,:,2);
        imgb = img(:,:,3);

        % Color selection from image according to (q_y, q_x) using sub2ind
%         Cr = sub2ind(size(imgr), qx,qy);
%         Cg = ...
%         Cb = ...
 
        qc(:,:,1) = reshape(Cr,size(qx));
        qc(:,:,2) = reshape(Cg,size(qy));
        qc(:,:,3) = reshape(Cb,size(qz));
    else 
        % If grayscale image, we only have 1 channel
%         C  = img(sub2ind( ... , ..., ...))
%         qc = reshape(C,size(qx));
        colormap gray
    end

    % Display surface
    surf(qx, qy, qz, qc);
     
    % Render parameters
    axis( [-500 500 -500 500 -500 500] );
    daspect([1 1 1]);
    rotate3d;

    shading flat;
end
