function asSetAllTitlesToImageString
global asObjs
for i = 1 : length(asObjs)
    asObjs(i).toggleTitleAsImageText;
end
