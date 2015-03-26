function asMultiDiffMaps(diffObjs, minVal, maxVal)

if ~(isa(diffObjs,'arrShow'))
    error('first argument has to be an array of class arrShow');
end

if nargin < 3
    maxVal = Inf;
    if nargin < 2
        minVal = -Inf;
    end
end


NO = length(diffObjs);

if NO < 2
    error('need at least 2 arrShow objects');
end

refImg = diffObjs(1).getSelectedImages;

% create mask
mask = ones(size(refImg));
for i = 1 : NO
    currImg = diffObjs(i).getSelectedImages ;
    mask(abs(currImg) == 0) = 0;
    mode = 'none';
    switch mode
        case 't2'
            mask(abs(currImg) >400) = 0;
            mask(abs(currImg) < 10 ) = 0;
        case 'r2'
            mask(abs(currImg) <1/400) = 0;
            mask(abs(currImg) > 1/10 ) = 0;
        case 'none'
            mask = ones(size(mask));
    end
end

% limit refimage
refImg(refImg>maxVal)=maxVal;
refImg(refImg<minVal)=minVal;

for i = 1 : NO
    if diffObjs(i) ~= diffObjs(1)
        currImg = diffObjs(i).getSelectedImages ;
        
        % t2 cap all images
        currImg(currImg>maxVal)=maxVal;
        currImg(currImg<minVal)=minVal;
        
        
        n1 =  diffObjs(1).getFigureNumber();
        n2 =  diffObjs(i).getFigureNumber();
        t1 = diffObjs(1).getFigureTitle();
        t2 = diffObjs(i).getFigureTitle();
        tit = ['difference ',t2];
        
        infoTxt = sprintf('Difference map:\nFig.%d (%s) - Fig.%d (%s)\n',...
            n2,t2, n1, t1);
        
        diffImg = currImg - refImg;
        
        
        diffImg = diffImg .* mask;
        
        if(0) % relative difference
            diffImg = diffImg * 100 ./ refImg;
            diffImg(isnan(diffImg)) = 0;
            diffImg(isinf(diffImg)) = 0;
        end
        diffAsObj = as(diffImg, 'title',tit,'info',infoTxt);
        
        % refCW = diffObjs(i).window.getCW;
        % refCW(2) = refCW(2) / 16;
        refCW = [0,20];
        
        refPos = diffObjs(i).getFigureOuterPosition;
        refPos(2) = refPos(2) - refPos(4);
        diffAsObj.setFigureOuterPosition(refPos);
        diffAsObj.complexSelect.setSelection('Re')
        diffAsObj.window.setCW(refCW);
        
    end
end

end