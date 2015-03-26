function plotCol(asObj, pos)

% get selected image from asObj
currImg = squeeze(asObj.getSelectedImages(false));

% assure that its a single 2D image
si = size(currImg);
if numel(si) ~= 2 || si(1) == 1
    fprintf('Only single two-dimensional images or single column vectors are currently supported by plotCol\n');
    if isvalid(asObj)
        asObj.cursor.togglePlotRowAndCol(false)
    end
    return
end

% figure;
cPlot(currImg(:,pos(2)));

% create plot title
title(['Col ', num2str(pos(2))]);

% create plot figure title
set(gcf,'name',['Col-Plot: ',asObj.getFigureTitle()]);
end
