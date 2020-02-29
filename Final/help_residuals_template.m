% function res = residuals(L)
% Returns a matrix containing the residuals computed for every camera view.
% 
% INPUT
%   - L: the matrix L that will be minimized for: Ai L Ai' - Id = 0
%
% OUTPUT
%   - diff: a matrix (n x 4) containing the residuals for the n cameras

function diff = help_residuals_template(L, project_name)

    % Load the saved transformation matrix
    M = load(strcat('Data/', project_name, 'SFM_M_', project_name, '.mat'));
    M = M.M;

    % Pre-allocate the residuals matrix
    diff = zeros(size(M,1)/2,4); % [101,4]

    % Compute the residuals
    for i = 1:size(M, 1)/2 % Loop over the cameras

        % Define the x and y projections: 
        Ai = M(i*2-1 : i*2, : ); 

        % Definite the function to be minimized: Ai L Ai' - Id = 0
        diff_i = Ai*L*Ai' - eye(2); % [2,2]

        diff(i,:) = diff_i(:);      % [4,1]
    end
