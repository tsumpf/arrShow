function plotRow(asObj, pos)

% get selected image from asObj
currImg = squeeze(asObj.getSelectedImages(false));

% assure that its a single 2D image
si = size(currImg);
if numel(si) ~= 2 || si(2) == 1
    fprintf('Only single two-dimensional images or single row vectors are currently supported by plotRow\n');
    if isvalid(asObj)
        asObj.cursor.togglePlotRowAndCol(false)
    end
    return
end

% figure;
cPlot(currImg(pos(1),:)');

% create plot title
title(['Row ', num2str(pos(1))]);

% create plot figure title
set(gcf,'name',['Row-Plot: ',asObj.getFigureTitle()]);

end
