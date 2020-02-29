%% 0 - Get Data
%cd ('~/Work/Netherlands/TUDelft/1_Courses/Sem2/ComputerVision/Assignments-Git/ComputerVision/Assign4')
if (0)
    X = load('Xpoints.mat');
    Y = load('Ypoints.mat');

    X = X.pointsx; % 101 cameras, 215 columns [101,215]
    Y = Y.pointsy;
    
    [M,S] = Assignment4(X,Y);
    figure(); 
    scatter3(S(1,:), S(2,:), S(3,:))
    hold on;
    
else
    tmp = load('measurement_matrix.txt'); % [202, 215]
    X = []; Y = [];    
    for i=1:2:size(tmp,1)-1
        X = [X;tmp(i,:)];
        Y = [Y;tmp(i+1,:)];
    end
    
    [M,S] = SFM(X,Y); %M = [?], S = [3,N]
    scatter3(S(1,:), S(2,:), S(3,:),'r');
    
end

%% Plot in 3D
