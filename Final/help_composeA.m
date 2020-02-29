% function A = composeA(x1, x2)
% Compose matrix A, given matched points (X1,X2) from two images
% Input: 
%   -normalized points: X1 and X2 
% Output: 
%   -matrix A
% function A = composeA_avi(x1, x2)
function A = composeA_avi(x2, x1)    
    
    A = [];
    for i=1:size(x1,1)
        % tmp = [x1(i,1)*x2(i,1) x1(i,1)*x2(i,2) x1(i,1) x2(i,2)*x2(i,1) x1(i,2)*x2(i,2) x1(i,2) x2(i,1) x2(i,2) 1];
        tmp = [x1(i,1)*x2(i,1) x1(i,1)*x2(i,2) x1(i,1) x1(i,2)*x2(i,1) x1(i,2)*x2(i,2) x1(i,2) x2(i,1) x2(i,2) 1];
        A = [A; tmp];
    end
   

end
