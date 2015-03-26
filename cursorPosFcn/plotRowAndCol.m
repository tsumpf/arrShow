function plotRowAndCol(asObj, pos)

% get selected image from asObj
img = squeeze(asObj.getSelectedImages(false));

% assure that its a single 2D image
if isvector(img) || numel(size(img)) ~= 2
    fprintf('Only single two-dimensional images are currently supported by plotRowAndCol\n');
    if isvalid(asObj)
        asObj.cursor.togglePlotRowAndCol(false)
    end
    return
end

mi = asObj.statistics.getMin;
ma = asObj.statistics.getMax;
if ~isreal(mi);
    mi = min([real(mi), imag(mi)]);
    ma = max([real(ma), imag(ma)]);
end
yLimits = [mi, ma];


% if this is the first call...
if isempty(asObj.UserData) ||...
        ~isfield(asObj.UserData,'plotFigHandle') ||...
        ~ishandle(asObj.UserData.plotFigHandle)||...
        ~strcmp(get(asObj.UserData.plotFigHandle,'Tag'),'asPlotFig')
    
    % create plot window
    asObj.UserData.plotFigHandle = figure(...
        'MenuBar','figure',...
        'name',['RowAndCol-Plot: ',asObj.getFigureTitle],...
        'ToolBar','none',...
        'Tag','asPlotFig',...
        'IntegerHandle','off',...
        'CloseRequestFcn',@(src, evnt)closeReqCb(src,asObj));    
    
    % create subplots for row and column  
    asObj.UserData.colPlotHandle = subplot(2,1,1,'parent',asObj.UserData.plotFigHandle);
    asObj.UserData.rowPlotHandle = subplot(2,1,2,'parent',asObj.UserData.plotFigHandle);
end

% subplot axes handle
ah1 = asObj.UserData.colPlotHandle;
ah2 = asObj.UserData.rowPlotHandle;

% create col plot
x = 1 : size(img,2);
cPlot(x, img(pos(1),:)','parent',ah1);
ylim(ah1, yLimits);
xlim(ah1, [1,size(img,2)]);
ylabel(ah1, 'pixel intensity');
xlabel(ah1, 'column');

% create plot title
title(ah1, ['Pixel ( ',num2str(pos(1)),' / ',num2str(pos(2)),' )']);

% create row plot
y = 1 : size(img,1);
cPlot(y, img(:,pos(2)),'parent',ah2);
ylabel(ah2, 'pixel intensity');
xlabel(ah2, 'row');
ylim(ah2, yLimits);
xlim(ah2, [1,size(img,1)]);
end

function closeReqCb(src, asObj)
    if isvalid(asObj)
        asObj.cursor.togglePlotRowAndCol(false)
    end
    delete(src);
end