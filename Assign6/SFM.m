function [M,S,p] = SFM(X,Y,project_name) % X = [N_f, N_pts]; Y = [N_f, N_pts]

    %% Step1 - Centering the data
    X1 = X - mean(X, 2);
    Y1 = Y - mean(Y, 2);

    data = [];
    for i=1:size(X1,1)
        X1_row = X1(i,:);
        Y1_row = Y1(i,:);
        data = [data;X1_row;Y1_row];
    end

    %% Step2 - Decomposition
    [U,W,V] = svd(data);        % data = [N_2f, N_pts]

    U3  = U(:,[1 2 3]);         % [N_2f,3]
    W3  = W([1 2 3], [1 2 3]);  % [3,3]
    V3  = V(:, [1 2 3]);        % [N_pts,3]

    %% Step3 - Computing M,S; D = M.S
    M = U3*(W3.^0.5);            % [N_2f, 3] = M = motion matrix
    S = (W3.^0.5)*V3';           % [3, 215] = S = Structure matrix?
    
    if ~(exist('Data', 'dir'))
        mkdir('Data');
    end
    %save('Data/SFM_M', 'M');
    save(strcat("Data/SFM_M_", project_name), 'M');

    %% Step4 - Uniqueness in D = M.S
    p = 1;
    try
        A1    = M(1:2,:);                           % [2,3]
        L0    = pinv(A1' * A1);                     % [3,3]
        opts1 = optimset('display','off');
        L     = lsqnonlin(@residuals_template_teddy, L0, [], [],  opts1); % [3,3] 
        [C,p] = chol(L, 'lower');                   % [3,3]
        M     = M*C;                                % [202,3]
        S     = inv(C)*S;                           % [3,215]
    catch e
       fprintf('\n  --> [Err-SFM] C : %d %d || p:%d', size(C),p);
        % fprintf('\n  --> [Err] Error in SFM Uniquesness')
    end

    %% Step5 - PLot using S
end