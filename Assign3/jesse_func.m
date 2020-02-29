function [] = jesse_func(matches, frames1, frames2)
    inliersBest = 0;
    threshold = 10;

    for n = 1:500

        perm = randperm(length(matches));
        P    = 3;  % 3 matches needed for 6 unknowns
        seed = perm(1:P);

        matchesUsed = matches(:, seed);

        % Build matrix A from P matches
        A = [[frames1(1,matchesUsed(1,1)) frames1(2,matchesUsed(1,1)) 0 0 1 0];
             [0 0 frames1(1,matchesUsed(1,1)) frames1(2,matchesUsed(1,1)) 0 1];
             [frames1(1,matchesUsed(1,2)) frames1(2,matchesUsed(1,2)) 0 0 1 0];
             [0 0 frames1(1,matchesUsed(1,2)) frames1(2,matchesUsed(1,2)) 0 1];
             [frames1(1,matchesUsed(1,3)) frames1(2,matchesUsed(1,3)) 0 0 1 0];
             [0 0 frames1(1,matchesUsed(1,3)) frames1(2,matchesUsed(1,3)) 0 1]];

        b = [frames2(1,matchesUsed(2,1)); 
             frames2(2,matchesUsed(2,1));
             frames2(1,matchesUsed(2,2));
             frames2(2,matchesUsed(2,2));
             frames2(1,matchesUsed(2,3));
             frames2(2,matchesUsed(2,3))];

        x = pinv(A) * b;

        frames2New = frames2;

        % Edit only matches
        for m = 1:length(matches)
            frames2New(1:2,matches(2,m)) = [[x(1) x(2)]; [x(3) x(4)]] * [frames1(1,matches(1,m)); frames1(2,matches(1,m))] + [x(5); x(6)];
        end

        inliers   = length(find(sqrt(sum((frames2New(1:2,:) - frames2(1:2,:)).^2)) < threshold));
        
        fprintf('\n Inliers : %d', inliers);
        disp(inliers)
        if inliers > inliersBest   
            inliersBest = inliers;
            xBest = x;  
        end

    end
end