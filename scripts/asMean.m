function [sumImg, sumAsObj] = asMean(asObjs, showResultInArrShow)

if nargin < 2
    showResultInArrShow = true;
end
[sumImg, sumAsObj] = asAlgebra(asObjs, 'mean',showResultInArrShow);

end
