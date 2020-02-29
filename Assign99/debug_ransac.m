function debug_ransac(imgname1, imgname2, F, inliers, directory, X1, X2, match)
    
    filename1 = strcat(directory, imgname1);
    filename2 = strcat(directory, imgname2);
    
    % Read images
    % disp('Reading images');
    img1 = im2double(rgb2gray(imread(filename1)));
    img2 = im2double(rgb2gray(imread(filename2)));
    
    % Get X,Y coordinates of matched features
    % X1 = feat1(1:2,match(1,:));
    % X2 = feat2(1:2,match(2,:));


    % Display Fundamental matrix
    %disp('F =');
    %disp(F);

    % Show the images with matched points
    if (1)
        figure(1);
        imshow([img1,img2],'InitialMagnification', 'fit');
        
        if (1)
            random_pts = 50;
            seed       = randi(size(inliers,2),[random_pts,1]);
            inliers_1  = inliers(seed);
            inliers = inliers_1;
            title(sprintf('Images with %d matched points (inliers)', random_pts)); hold on;
        else
            title('Images with matched points (inliers)'); hold on;
        end

        scatter(X1(1,inliers),X1(2,inliers), 'y');
        scatter(size(img1,2)+X2(1,inliers),X2(2,inliers) ,'r');
        line([X1(1,inliers);size(img1,2)+X2(1,inliers)], [X1(2,inliers);X2(2,inliers)], 'Color', 'b');

        % outliers = setdiff(1:size(match,2),inliers);
        % line([X1(1,outliers);size(img1,2)+X2(1,outliers)], [X1(2,outliers);X2(2,outliers)], 'Color', 'r');
    end
    
    if (1)
        figure;
        % Visualize epipolar lines
        subplot(1,2,1);
        imshow(img1,'InitialMagnification', 'fit');
        title('Epipolar line for the yellow point of right image'); hold on;
        subplot(1,2,2);
        imshow(img2,'InitialMagnification', 'fit');
        title('Epipolar line for the yellow point of left image'); hold on;

        % Take random points and visualize
        a  = 1;
        b  = size(match,2);
        rL = floor(a + (b-a).*rand(1,1));
        rR = floor(a + (b-a).*rand(1,1));
        pointL = [X1(:,rL);1];
        pointR = [X2(:,rR);1];

        subplot(1,2,1);
        scatter(pointL(1),pointL(2),15,'y');
        subplot(1,2,2);
        scatter(pointR(1),pointR(2),15,'y');

        % If the obtained line has coordinates (u1, u2, u3) then we can plot it over the image (X,Y) with:
        % Y = -(u1 * X + u3)/u2
        epiR = F * pointL;
        plot(-(epiR(1)*(1:size(img2,2))+epiR(3))./epiR(2), 'r')

        epiL = F' * pointR;
        subplot(1,2,1);
        plot(-(epiL(1)*(1:size(img1,2))+epiL(3))./epiL(2), 'r')
        meh = 1;
    end
    
end
