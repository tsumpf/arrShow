function [sumImg, sumAsObj] = asAlgebra(asObjs, operation, showResultInArrShow)
% Usage: [sumImg, sumAsObj] = asAlgebra(asObjs, operation, showResultInArrShow)
% Performs algebraic operations on the data of the given arrayShow
% objects. 
% The operation is performed on the full data array in case the data
% dimensions are equal. Otherwise, the operation is only performed on the
% currently selected image of all as objects.
%
% showResultInArrShow: if true (default) the result is automatically shown
%                      in a new arrayShow window
%
% Currently implemented operations are:
%   sum/plus, diff/minus, mean, min and max
%

switch lower(operation)
    case {'sum', 'plus'}
        op = @plus;
    case {'minus', 'diff'}
        op = @minus;        
    case {'times', '.*'}
        op = @times;
    case {'rdivide', './'}
        op = @rdivide;
    case 'mean'
        % Treat the mean as as sum first.
        % the division by the number of objects is considered lated
        op = @plus;
    case 'min'
        op = @min;
    case 'max'
        op = @max;
        
    otherwise
        error('asAlgebra:unknownOperation','Operation %s is not sopported yet',operation);
end                       
    
if nargin < 3
    showResultInArrShow = true;
end

% check input arguments
if ~(isa(asObjs,'arrShow'))
    error('first argument has to be an array of class arrShow');
end

NO = length(asObjs);

if NO < 2
    error('need at least 2 arrShow objects');
end


% get data dimensions
allSi = size(asObjs(1).getAllImages(true));
imgSi = asObjs(1).statistics.getDimensions();

% get selected complex data part
cplxPart = asObjs(1).complexSelect.getSelection(2);

% check if the data dimensions and the selected complex part are equal in all asObjs
allDimsAreEqual      = true; % be positive
allCplxPartsAreEqual = true;
for i = 2 : NO
        
    % check if the data dimensions are equal in all asObjs    
    currAllSi = size(asObjs(i).getAllImages(true));
    currImgSi = asObjs(i).statistics.getDimensions();        
    if numel(currAllSi) ~= numel(allSi) || any(currAllSi ~= allSi)
        allDimsAreEqual = false;
        
        % check if at least the dims of the selected images are equal
        if numel(currImgSi) ~= numel(imgSi) || any(currImgSi ~= imgSi)
            fprintf('Cannot sum images with unequal dimensions\n');
            return;
        end        
    end
    
    % check if the selected parts are equal
    if ~strcmp(cplxPart, asObjs(i).complexSelect.getSelection(2))
        allCplxPartsAreEqual = false;
        warning('Different complex parts are selected in the arrayShow objects');
    end
        
end

% assigne a getimg function which either returns all images, if all
% dimensions are equal, or returns only the selected image otherwise...
if allDimsAreEqual
    getimg = @(i)asObjs(i).getAllImages(false);
else
    getimg = @(i)asObjs(i).getSelectedImages(false);
end

% start creating a sumImage
sumImg = getimg(1);

% create an infotext wich is to contain all the summed figure titles
if showResultInArrShow
    
    % if the an equal complmex part is selected in all arrayShow objects,
    % include the complex part to the description
    if allCplxPartsAreEqual
        funName = [cplxPart, ' ', operation];
    end
    
    % create a title
    tit = ['Image ',funName];
    
    % create an info text which contains the names of all summed asObjs
    infoTxt = sprintf('%s of:\nFig.%d: %s',...
        funName,...
        asObjs(1).getFigureNumber(),...
        asObjs(1).getFigureTitle());
end

% again loop over all asObjs and do the actual data summation
for i = 2 : NO
    % the summation
    sumImg = op(sumImg, getimg(i));
    
    if showResultInArrShow
        infoTxt = sprintf('%s\nFig.%d: %s',...
            infoTxt,...
            asObjs(i).getFigureNumber(),...
            asObjs(i).getFigureTitle());
    end
end

if strcmp(operation, 'mean')
    sumImg = sumImg / NO;
end

% create a new asObj
if showResultInArrShow
    refPos = asObjs(i).getFigureOuterPosition;
    refPos(2) = refPos(2) - refPos(4);
    sumAsObj = as(sumImg, 'title',tit,'info',infoTxt);
    sumAsObj.setFigureOuterPosition(refPos);
    
    % don't flood the workspace with data
    if nargout == 0
        clear sumImg        
    end
end

end
