function asMarkPixel(asObj, pos)

ah = asObj.getCurrentAxesHandle;

if isvector(pos)
    nPos = 1;
    pos = pos(:);
else
    nPos= size(pos,2);
end

for i = 1 : nPos
    P = pos(:,i);
%     rect = rectangle('Parent',ah,'Position',[P(1)-.5, P(2)-.5, 1,1],'Curvature',[0,0],...
%         'HitTest','off','EdgeColor','red');
    impoint(ah,P(2),P(1));
end

end