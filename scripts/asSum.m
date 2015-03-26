function [sumImg, sumAsObj] = asSum(asObjs, showResultInArrShow)

if nargin < 2
    showResultInArrShow = true;
end
[sumImg, sumAsObj] = asAlgebra(asObjs, 'sum',showResultInArrShow);

end
