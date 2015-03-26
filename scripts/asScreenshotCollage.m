function collage = asScreenshotCollage(asObjs)
if nargin < 1
    global asObjs
end

nObjs = numel(asObjs);
allScrShots = cell(nObjs,1);
for i = 1 : nObjs
    currScrShot = asObjs(i).getScreenshot();
    currImg = rgb2gray(currScrShot.cdata);
    allScrShots{i} = currImg;
end
allScrShots = asDataClass.cell2imageMat(allScrShots);

si = size(allScrShots);
collage = reshape(allScrShots,[si(1),si(2)* si(3)]);
end