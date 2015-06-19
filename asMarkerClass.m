classdef asMarkerClass < handle
    % The class manages and draws "pixel markers", i.e. it marks specific
    % pixel positions in different slices. Its main intention is to
    % highlight critical image regions which may contain automatically
    % detected image reconstruction errors etc. It can also be used to
    % highlight general pixels of interest. The markers are automatically
    % redrawn if the selected image changes.
    %
    % Pixel markers can be added for either all slices (by calling the .set
    % or .add method with a matrix of pixel positions) or for individual
    % slices (by calling the .set or .add method with a cell array of
    % matrices of pixel positions, or by calling the .setInCurrentFrames
    % method)
    %
    
    properties (Access = private)
        pos = [];   % marker positions
        axesHandles = [];
        
        ignoredDimensions = []; % dimensions where the position cell vector is 1
        markerHandles = {};     % (its probably actually marker "objects" since matlab 2014b)
        selection = [];         % the asSelectionCass (used to determine selected frames)
        color = 'yellow';       % ...not used yet
        
        uiMenuHandle = []; % context menu handle
    end
    
    methods (Access = public)
        
        function obj = asMarkerClass(selection, markerPositions, uiMenuBase)
            % constructor
            
            obj.selection = selection;
            if nargin > 1 && ~isempty(markerPositions)
                obj.pos = obj.parsePos(markerPositions);
            end
            
            % populate ui menu
            obj.uiMenuHandle.base = uiMenuBase;
            obj.uiMenuHandle.showMarker = uimenu(uiMenuBase,'Label','Show' ,...
                'callback',@(src,evnt)obj.toggleVisibility(),...
                'checked','on');
            uimenu(uiMenuBase,'Label','Add global' ,...
                'callback',@(src,evnt)obj.add(),'separator','on');            
            uimenu(uiMenuBase,'Label','Add to current frames' ,...
                'callback',@(src,evnt)obj.addToCurrentFrames());                        
            uimenu(uiMenuBase,'Label','Clear' ,...
                'callback',@(src,evnt)obj.clear(),'separator','on');
            
        end
        
        function updateAxesHandles(obj, axesHandles)
            obj.axesHandles = axesHandles;
            obj.draw();
        end
        
        function add(obj, pos)
            % adds markers at positions pos.
            % pos can be either a matrix of positions for all frames or a
            % cell array of matrices with positions for individual frames.
            % The cell array must have the same number of dimensions as 
            % the arrayShow data array. The dimensions sizes must be either
            % equal or 1. Dimensions of size 1 are ment to be used for
            % image or colon dimensions. 
            % 
            % E.g.: for a stack of images or an image matrix of 
            % 256 x 256 x 20 x 15 pixels, a cell array of size 
            % 1 x 1 x 20 x 1 can be used to hold pixel markers that are
            % equal for the 4th dimension and different for the 3rd
            % dimension.
            
            % if no position vector is given, open input dialog            
            if nargin < 2 || isempty(pos)
                pos = asMarkerClass.getPosFromUi();
                if isempty(pos)
                    return;
                end
            end
                
            pos = obj.parsePos(pos);
            
            if iscell(obj.pos)
                if iscell(pos)
                    % if the new and the present positions are cell vectors
                    % of the same size: just combine them
                    if length(pos) ~= length(obj.pos)
                        error('lalala');
                    end
                    for i = 1 : length(pos)
                        obj.pos{i} = [obj.pos{i}, pos{i}];
                    end
                else
                    % if the present positions are cells and the new are
                    % not, add the new positions to all frames
                    for i = 1 : length(obj.pos)
                        obj.pos{i} = [obj.pos{i}, pos];
                    end
                end
            else
                % ..the present positions are not cells
                if iscell(pos)
                    for i = 1 : length(pos)
                        pos{i} = [obj.pos, pos{i}];
                    end
                    obj.pos = pos;
                else
                    obj.pos = [obj.pos, pos];
                end
            end
            obj.draw();
        end
        
        function bool = getVisibility(obj)
            bool = arrShow.onOffToBool(get(obj.uiMenuHandle.showMarker,'checked'));
        end
        
        function toggleVisibility(obj)
            bool = obj.getVisibility;
            obj.setVisibility(~bool);
        end
        
        function setVisibility(obj, toggle)
            set(obj.uiMenuHandle.showMarker,'checked', arrShow.boolToOnOff(toggle));
            if toggle
                obj.draw();
            else
                obj.deleteMarkers();
            end
        end
        
        function pos = get(obj)
            % get pixel marer positions
            pos = obj.pos;
        end
        
        function addToCurrentFrames(obj, newPos)
            
            % if no position vector is given, open input dialog
            if nargin < 2 || isempty(newPos)
                newPos = asMarkerClass.getPosFromUi();
                if isempty(newPos)
                    return;
                end
            end

            % assure that obj.pos is initialized as a cell array
            if ~iscell(obj.pos) || isempty(obj.pos)
                obj.initPosCellArray();           
            end

            % get the current positions in the current frames
            currPos = obj.getInCurrentFrames();
            
            % assure that the new positions are in a legal format
            expectedNumel = length(currPos);
            newPos = obj.parsePos(newPos, expectedNumel);
            
            
            if iscell(newPos)
                if length(currPos) ~= length(newPos)
                    disp('Length of the position cell vector has to match the number of selected frames');
                    return;
                end
                % add the new positions to all selected frames
                for i = 1 : length(currPos)
                    currPos{i} = [currPos{i}, newPos{i}];
                end
            else
                % add the the same new positions to all selected frames
                for i = 1 : length(currPos)
                    currPos{i} = [currPos{i}, newPos];
                end
            end
            
            
            % set the new positions
            obj.setInCurrentFrames(currPos, false);
            
        end
        
        function setInCurrentFrames(obj, newPos, parsePos)
            if nargin < 3 || isempty(parsePos)
                parsePos = true;
            end
            
            % assure that obj.pos is initialized as a cell array
            if ~iscell(obj.pos) || isempty(obj.pos)
                obj.initPosCellArray();           
            end                                   
            
            % get number of selected frames
            if parsePos
                expectedNumel = numel(obj.getInCurrentFrames());
                newPos = obj.parsePos(newPos, expectedNumel);
            end
            if ~iscell(newPos)
                newPos = {newPos};
            end            
            
            % get the subscripts for the selected frames
            S.subs = obj.selection.getValueAsCell(false);
            S.type = '()';            
            
            % set selection in the ignored dimensions to 1
            S.subs(obj.ignoredDimensions) = repmat({1},[1,length(obj.ignoredDimensions)]);
                                    
            % update the marker positions for the selected frames
            obj.pos = subsasgn(obj.pos,S,newPos);
            
            % "re-draw"
            obj.deleteMarkers()
            obj.draw();
            
        end
        
        function pos = getInCurrentFrames(obj)
            if iscell(obj.pos)
                % get selected frames
                S.subs = obj.selection.getValueAsCell(false);
                S.type = '()';
                
                % set selection in the ignored dimensions to 1
                S.subs(obj.ignoredDimensions) = repmat({1},[1,length(obj.ignoredDimensions)]);
                
                % get the marker positions for the selected frames
                pos = squeeze(subsref(obj.pos,S));
            else
                pos = obj.pos;
            end
        end
        
        function markerHandle = getMarkerHandles(obj)
            markerHandle = obj.markerHandles;
        end
        
        function set(obj, pos)
            if nargin < 2
                pos = [];
            end
            
            % parse and store positions in the object properties
            obj.pos = obj.parsePos(pos);
            
            % delete previous markers
            obj.deleteMarkers();
            
            % draw new markers
            obj.draw();
        end
        
        function clear(obj)
            % permanently removes all marker objects and positions
            obj.deleteMarkers();
            obj.pos = [];
        end
        
        function draw(obj)
            
            if isempty(obj.pos) || obj.getVisibility == false
                return;
            end
            
            if iscell(obj.pos)
                % get the marker positions for the selected frames
                selPos = obj.getInCurrentFrames();
                
                if length(selPos) ~= length(obj.axesHandles)
                    disp('Cannot show markers for the current dimensions');
                else
                    % loop over all axes and create the markers
                    nAxes = length(obj.axesHandles);
                    obj.markerHandles = cell(nAxes,1);
                    for i = 1 : nAxes
                        obj.markerHandles{i} = obj.drawAtAxes(obj.axesHandles(i), selPos{i});
                    end
                end
                
            else
                % we have positions for a single frame. Apply it on all
                % axes...
                
                nAxes = length(obj.axesHandles);
                obj.markerHandles = cell(nAxes);
                % ...loop over availables axes
                for i = 1 : nAxes
                    ah = obj.axesHandles(i);
                    obj.markerHandles{i} = obj.drawAtAxes(ah, obj.pos);
                end
            end
        end
    
        function setColor(obj, col)
            if nargin < 2 || isempty(col)
                % if no color is given, use the color from the object
                % properties
                col = obj.color;
            elseif strcmp(col,obj.color)
                % if the given color already equals the color in the
                % object properties, we probably don't need update anything
                % and we can just return
                return;
            end
                                
            try
                % instead of parsing the col input variable for validity,
                % just use a try/catch on the marker's setColor method...
                % FIXME: this 'pseudo parsing' won't work if setColor is
                % called before any actual markers are present :-/
                for i = 1 : length(obj.markerHandles)
                    cellfun(@(h)setColor(h,col),obj.markerHandles{i});
                end
                obj.color = col;                
            catch ME
                if strcmp(ME.identifier, 'MATLAB:datatypes:RGBAColor:ParseError')
                    fprintf('Invalid color: %s\n',col);
                else
                    rethrow(ME);
                end
            end            
        end
        
    
    end        
    %     methods (Access = protected)
    %     end
    methods (Access = private)
        
        function initPosCellArray(obj)
            % try to initialize a position cell array assuming the colon
            % dimensions as "image dimensions" and all other dimensions as
            % frames
            
            
            if iscell(obj.pos) && ~isempty(obj.pos)
                error('obj.pos already seems to be initialized');
            end                                   
            
            % get the data size
            dataDims = obj.selection.getDimensions;
            
            % ignore the colon dimension by default
            obj.ignoredDimensions = obj.selection.getColonDims;
            dataDims(obj.ignoredDimensions) = 1;
            
            if isempty(obj.pos)
                obj.pos = cell(dataDims);
            else
                % duplicate the position to all cell entries
                tmpBackup = obj.pos;
                obj.pos = cell(dataDims);
                [obj.pos{:}] = deal(tmpBackup);
            end
        end
        
        function markerHandles = drawAtAxes(obj, ah, pos)
            nMarkersPerAxes = size(pos,2);
            markerHandles = cell(nMarkersPerAxes,1);
            for i = 1 : nMarkersPerAxes
                P = pos(:,i);
                %                 markerHandles{i} = impoint(ah,P(2),P(1),'color',obj.color);
                markerHandles{i} = impoint(ah,P(2),P(1));
                markerHandles{i}.setColor(obj.color);
            end
        end
        
        function deleteMarkers(obj)
            for i = 1 : length(obj.markerHandles)
                cellfun(@delete,obj.markerHandles{i});
            end
            obj.markerHandles = {};
        end
        
        function pos = parsePos(obj, pos, expectedNumel)
            % checks if the position vector matches the expected format. If
            % pos is a cell array and expectedNumel is empty, the array is
            % checked to match the data dimension. If expectedNumel is
            % given, the pos array is just checkt for the correct number of
            % elements.
            %
            % If pos is a cell vector, its length is checked against the
            % size of the different data dimensions and reshaped to fit the
            % first match. E.g. If the data dimensions are 128x128x20x30
            % and size(pos) = 20x1 or 1x20, pos is reshaped to 1x1x20x1.
            
            if iscell(pos)
                if nargin > 2 && ~isempty(expectedNumel)
                    if numel(pos) ~= expectedNumel
                        error('Number of elements in the new position vector are not valid');
                    end
                else
                
                    % check the size of the cell array
                    dataDims = obj.selection.getDimensions;
                    siPos = size(pos);
                    lPos = length(siPos);
                    lDat = length(dataDims);

                    if lPos < lDat
                        % ok, the dimensions of the data and the position cell
                        % array are not equal. Check, if pos is a vector
                        % and can be matched with any of the data
                        % dimensions
                        if isvector(pos)
                            matchingDims = find(dataDims == numel(pos));
                            if isempty(matchingDims)
                                error('Marker position vector has invalid dimensions');
                            end
                            
                            % define a new position matrix size with the
                            % elements put into the first matching dim
                            siPos = ones(1,lDat);
                            siPos(matchingDims(1)) = numel(pos);
                            pos = reshape(pos,siPos);
                        else
                            % pos is neither a vector nor does it have the
                            % same number of dimensions as the data dims.
                            % Try to padd all non given trailing dims with
                            % 1 to get equal siPos und dataDims vector size
                            siPos = [siPos, ones(1,lDat - lPos)];
                        end
                    end

                    % define all dimensions with size == 1 as
                    % "ignoredDimensions"
                    obj.ignoredDimensions = find(siPos == 1);

                    % check for unequal dimensions
                    unequalDims = find(siPos ~= dataDims);

                    % check, if the cell entries in the unequal dimensions
                    % are 1
                    if length(unequalDims) > length(obj.ignoredDimensions)||...
                        any(unequalDims ~= obj.ignoredDimensions)
                        error('Marker position vector has invalid dimensions');                        
                    end
                end
                
                % assure that all antries are column vectors
                for i = 1 : length(pos)
                    if isrow(pos{i})
                        pos{i} = pos{i}';
                    end
                end
            else
                if isrow(pos)
                    pos = pos';
                end
            end
        end
    end
    
    methods(Static)
        function pos = getPosFromUi()
            initVal = '0,0';
            pos = mydlg('Enter selection string','Selection input dlg',initVal);
            if isempty(pos)
                return;
            end
            
            try
                pos = str2num(pos);                 %#ok<ST2NM>
            catch 
                pos = [];
                fprintf('Invalid position vector\n');
            end
        end
                    
    end
end