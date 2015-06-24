function asMarkPixel(asObjsOrPos, pos)

if isa(asObjsOrPos,'arrShow');
    if nargin < 2
        error('asMarkPixel:missingArgument','Need position vector');
    end
    aso = asObjsOrPos;
else
    % assume the first input argument to be the position vector
    pos = asObjsOrPos;
    global asObjs %#ok<TLEV>
    aso = asObjs;
end

for i = 1 : length(aso)
    aso(i).markers.add(pos);
end


end