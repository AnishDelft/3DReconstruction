% function A = composeA(x1, x2)
% Compose matrix A, given matched points (X1,X2) from two images
% Input: 
%   -normalized points: X1 and X2 
% Output: 
%   -matrix A
function A = help_composeA(x1, x2) % x1 = [N,2]
    
    A = [];
    for i=1:size(x1,1)
        % tmp = [x1(i,1)*x2(i,1) x1(i,1)*x2(i,2) x1(i,1) x2(i,2)*x2(i,1) x1(i,2)*x2(i,2) x1(i,2) x2(i,1) x2(i,2) 1];
        tmp = [x1(i,1)*x2(i,1) x1(i,1)*x2(i,2) x1(i,1) x1(i,2)*x2(i,1) x1(i,2)*x2(i,2) x1(i,2) x2(i,1) x2(i,2) 1];
        A = [A; tmp];
    end
   
end
