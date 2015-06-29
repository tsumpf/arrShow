%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef asCursorPosClass < handle
    
    properties (Constant)
        CURSOR_STD    = 'arrow';         % shape of mouse cursor in standard mode
        CURSOR_PLOT   = 'fullcrosshair'; % shape of cursor when being in plot mode
        
        POSITV_COLOR  = 'black';         % color for positive values
        NEGATIV_COLOR = [205/255;0;0];   % color for negative values
    end
    
    properties (GetAccess = private, SetAccess = private)
        
        % handles
        fh  = [];    % parent figure handle
        ph  = [];    % parent panel handle
        sph = [];    % sub-panel handle (one sp for: x/y, re, im, ...)
        th  = [];    % text handles
        sbh = [];    % send button handle
        cmh = [];    % contextMenu handles
        mbh = [];    % menu bar handle of the arrShow parent window
        fcmh = [];   % figure contextMenu handles
        icons = [];  % icon class handle
        
        cursorColor= 'blue';        % color of the rectangle wrapping the pixel below the mouse cursor
        
        phaseUnit = 'deg'           % can be either 'deg' or 'rad'
        
        precision = 'auto'
        autoPrecisionLimit = 3;     % Max and minimum order of magnitude to represent values in fixed point notation
                                    % e.g. if the value is
                                    % >10^autoPrecisionLimit or 
                                    % <10^-autoPrecisionLimit the
                                    % values are shown in exponential notation
        
        % callback functions
        apply2allCb               = [];   % send to all relatives callback
        getCurrentAxesHandleCb    = [];
        
        complexMode               = true;
        
        sendCursorOnMovement      = false;
        drawPhaseCircOnMovement   = false;
        plotRowAndColOnMovement   = false;
        plotAlongDimOnMovement    = false;
        callUserCursorPosFunc     = false;
        
        userFcn     = @userCursorPosFcn;
        
        position = [1,1];  % initial cursor position
        
        enabled = true;
        
        asObj = [];
    end
    
    methods (Access = public);
        function obj = asCursorPosClass(...
                parentFigureHandle,...
                parentPanelHandle,...
                figureContextMenuHandle,...
                menuBarHandle,...
                icons,...
                complexMode,...
                apply2allCb,...
                getCurrentAxesHandleCb,...
                asObj)
            
            % assign input variables to local object properties
            obj.fh                      = parentFigureHandle;
            obj.ph                      = parentPanelHandle;
            obj.fcmh                    = figureContextMenuHandle;
            obj.mbh                     = menuBarHandle;
            obj.apply2allCb             = apply2allCb;
            obj.getCurrentAxesHandleCb  = getCurrentAxesHandleCb;
            obj.asObj = asObj;
            obj.icons = icons;
            obj.complexMode = complexMode;
            
            % init context menus
            obj.initContextMenus();
            
            % activate initial standard phaseunit
            obj.setPhaseUnit(obj.phaseUnit);
            
            
            obj.updateLayout();
        end
        
        function setPrecision(obj, precision)
            % precision of the values in the bottom panel
            obj.precision = precision;
        end
        
        function setComplexMode(obj,toggle)
            if toggle ~= obj.complexMode
                obj.complexMode = toggle;
                obj.updateLayout();
            end
        end
        
        function changePrecisionDlg(obj)
            % open a dialog window to change the precision of the values in
            % the bottom panel
            
            newPrec = mydlg('Enter precision string','Change precision',obj.precision);
            if ~isempty(newPrec)
                % test if a valid string was entered
                if ~strcmp(newPrec,'auto')
                    try
                        num2str(2.3,newPrec);
                    catch me
                        if strcmp(me.identifier, 'MATLAB:num2str:fmtInvalid');
                            fprintf('Invalid precision string format\n');
                            newPrec = [];
                            % promt for reenter
                            obj.changePrecisionDlg();
                        else
                            throw(me);
                        end
                    end
                end
            end
            
            if ~isempty(newPrec)
                obj.precision = newPrec;
            end
        end
        
        function setPhaseUnit(obj, unit)
            switch lower(unit)
                case {'deg', 'degrees'}
%                     obj.phaseUnit = 'deg';
                    set(obj.cmh.phaseUnit.deg, 'Checked', 'on');
                    set(obj.cmh.phaseUnit.rad, 'Checked', 'off');
                case {'rad', 'radiants'}
                    obj.phaseUnit = 'rad';
                    set(obj.cmh.phaseUnit.deg, 'Checked', 'off');
                    set(obj.cmh.phaseUnit.rad, 'Checked', 'on');
                otherwise
                    error('asCursorPosClass:togglePhaseUnit','unknown phase unit');
            end
        end
        
        function toggleSend(obj, bool)
            if nargin > 1
                set(obj.fcmh.toggleSendCursor,'Checked',arrShow.boolToOnOff(~bool));
            end
            switch get(obj.fcmh.toggleSendCursor,'Checked')
                case 'off'
                    obj.sendCursorOnMovement = true;
                    set(obj.fcmh.toggleSendCursor,'Checked','on');
                    set(obj.sbh,'Value',1);
                case 'on'
                    obj.sendCursorOnMovement = false;
                    set(obj.fcmh.toggleSendCursor,'Checked','off');
                    set(obj.sbh,'Value',0);
            end
        end
        
        function send(obj)
            pos = obj.position;
            obj.apply2allCb('cursor.setPosition',false,pos);
        end
        
        function pos = getPosition(obj)
            pos = obj.position;
        end
        
        function bool = getPlotAlongDimToggle(obj)
            bool = obj.plotAlongDimOnMovement;
        end
        
        function setColor(obj,color)
            % store color in object properties
            obj.cursorColor = color;
            
            % if cursor rect is present, change color
            ah = obj.getCurrentAxesHandleCb();
            ud = get(ah,'UserData');
            if ~isempty(ud) && isfield(ud,'rect') && ~isempty(ud.rect)
                set(ud.rect,'EdgeColor',obj.cursorColor);
            end
        end
        
        function setPosition(obj, pos, forceUpdate, sendToRelatives)
            
            if nargin < 4
                sendToRelatives = obj.sendCursorOnMovement;
                if nargin < 3
                    forceUpdate = false;
                end
            end
            
            % check, if position really has changed
            if all(obj.position == pos) && ~forceUpdate
                return;
            end
            if any(isnan(pos))
                return;
            end
            
            % get current axes handle
            ah = obj.getCurrentAxesHandleCb();
            
            % get complex image from the axes handle's UserData field
            ud = get(ah,'UserData');
            img = ud.cplxImg;
            
            % limit cursor position to image matrix dimensions
            [dimY, dimX] = size(img);
            if pos(1) > dimY
                pos(1) = dimY;
            end
            if pos(2) > dimX
                pos(2) = dimX;
            end
            
            % get shortcuts to x and y positions
            posY = pos(1);
            posX = pos(2);
            
            if any(obj.position ~= [posY, posX]) || forceUpdate
                
                % update stored position and the bottom panel text
                obj.position = [posY,posX];
                obj.setPosText([posY, posX],img(posY,posX));
                
                % create / modify cursor position rectangle
                if isempty(ud) || ~isfield(ud,'rect') || isempty(ud.rect)
                    if verLessThan('matlab','8.4.0')
                        % create cursor position rectangle
                        ud.rect = rectangle('Parent',ah,'Position',[posX-.5, posY-.5, 1,1],'Curvature',[0,0],...
                            'HitTest','off','EdgeColor',obj.cursorColor);
                    else
                        ud.rect = rectangle('Parent',ah,'Position',[posX-.5, posY-.5, 1,1],'Curvature',[0,0],...
                            'HitTest','on','EdgeColor',obj.cursorColor);
                        % HitTest was 'off' in previous arrShow versions.
                        % However, due to the changed uistack behaviour of
                        % matlab 2014b the SelectedObj property of the main
                        % window when klicking on a rectangle with hitTest =
                        % off is not the image anymore. I currently found no
                        % other choice than to enable the HitTest of the
                        % rectangle and to check for that in the arrShow
                        % buttonDown functions. This, however, can also lead
                        % to problems when trying to drag around ROIs :-(
                        % I might again try to solve this after I get a
                        % confirmation from math work, that this is really
                        % a feature and not a bug in matlab 2014.
                        set(ud.rect,'uicontextmenu',obj.fcmh.base);                    
                        % ...we also need to copy the context menu because of
                        % this HitTest problem :-((                        
                    end
                    set(ah,'UserData',ud);                    
                else
                    set(ud.rect,'Position',[posX-.5, posY-.5, 1,1]);
                end
                
                if obj.drawPhaseCircOnMovement
                    obj.drawPhaseCircle;
                end
                if obj.plotRowAndColOnMovement
                    obj.plotRowAndCol;
                end
                if obj.plotAlongDimOnMovement
                    obj.plotAlongPlotDim;
                end
                if obj.callUserCursorPosFunc
                    obj.userCursorPosFcn();
                end
                
                if sendToRelatives
                    obj.apply2allCb('cursor.setPosition', false, [posY,posX], false);
                end
            end
        end
        
        function disableText(obj)
            if obj.enabled
                childs = get(obj.ph,'Children');
                for i = 1 : length(childs)
                    set(childs(i),'Enable','off');
                end
                obj.enabled = false;
            end
        end
        
        function enableText(obj)
            if ~obj.enabled
                childs = get(obj.ph,'Children');
                for i = 1 : length(childs)
                    set(childs(i),'Enable','on');
                end
                obj.enabled = true;
            end
        end
        
        function setPosText(obj,pos,value)
            
            % text handle
            t_posY   = obj.th(2);
            t_posX   = obj.th(4);
            t_reVal  = obj.th(6);
            t_imVal  = obj.th(8);
            t_absVal = obj.th(10);
            t_phVal  = obj.th(12);
            
            % get real and abs value
            reVal  = real(value);
            absVal = abs(value);
            
            % set position text
            obj.setValue(t_posY  , pos(1), '', '%d');
            obj.setValue(t_posX  , pos(2), '', '%d');
            
            % set real and abs value text
            obj.setValue(t_reVal , reVal , '', obj.precision);
            obj.setValue(t_absVal, absVal, '', obj.precision);
            
            % if value is complex, write imaginary part and phase text
            if isreal(value)
                obj.setValue(t_imVal, '-');
                obj.setValue(t_phVal, '-');
            else
                imVal  = imag(value);
                
                if strcmp(obj.phaseUnit, 'deg')
                    phVal = angle(value)*180/pi;
                    phSym = char(176); % the degree symbol;
                else
                    phVal = angle(value);
                    phSym = 'rad';
                end
                
                obj.setValue(t_phVal , phVal, phSym);
                obj.setValue(t_imVal , imVal);
            end
            
        end
        
        
        function row = getRow(obj)
            pos = obj.getPosition;
            row = pos(1);
        end
        
        function col = getColumn(obj)
            pos = obj.getPosition;
            col = pos(2);
        end
        
        
        % shortcuts to frequently used cursor position functions
        function plotRowAndCol(obj)
            plotRowAndCol(obj.asObj, obj.position);
        end
        function plotRow(obj)
            plotRow(obj.asObj, obj.position);
        end
        function plotColumn(obj)
            plotCol(obj.asObj, obj.position);
        end
        function plotAlongPlotDim(obj)
            plotDim = obj.asObj.selection.getPlotDim;
            if isempty(plotDim)
                fprintf('no plot dimension given\n');
                obj.togglePlotAlongDim(false);
            else
                plotAlongDim(obj.asObj, obj.position, plotDim);
            end
        end
        function drawPhaseCircle(obj)
            drawPhaseCircle(obj.asObj, obj.position);
        end
        
        function userCursorPosFcn(obj)
            userCursorPosFcn(obj.asObj,...
                obj.position,...
                obj.asObj.selection.getPlotDim)
        end
        
        
        
        % toggles for the frequently used cursor position functions
        function togglePlotRowAndCol(obj, bool)
            if nargin > 1
                set(obj.fcmh.plotRowAndCol,'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.fcmh.plotRowAndCol,'Checked')
                case 'off'
                    obj.plotRowAndColOnMovement = true;
                    set(obj.fcmh.plotRowAndCol,'Checked','on');
                    set(obj.fh,'Pointer',obj.CURSOR_PLOT);
                case 'on'
                    obj.plotRowAndColOnMovement = false;
                    set(obj.fcmh.plotRowAndCol,'Checked','off');
                    set(obj.fh,'Pointer',obj.CURSOR_STD);
            end
        end
        
        function togglePlotAlongDim(obj, bool)
            if nargin > 1
                set(obj.fcmh.plotAlongDim,'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.fcmh.plotAlongDim,'Checked')
                case 'off'
                    obj.plotAlongDimOnMovement = true;
                    set(obj.fcmh.plotAlongDim,'Checked','on');
                case 'on'
                    obj.plotAlongDimOnMovement = false;
                    set(obj.fcmh.plotAlongDim,'Checked','off');
            end
        end
        
        function toggleDrawPhaseCircle(obj, bool)
            if nargin > 1
                set(obj.fcmh.drawPhaseCircle,'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.fcmh.drawPhaseCircle,'Checked')
                case 'off'
                    obj.drawPhaseCircOnMovement = true;                
                    set(obj.mbh.phaseCircle, 'Checked','on');                    
                    set(obj.fcmh.drawPhaseCircle,'Checked','on');
                case 'on'
                    obj.drawPhaseCircOnMovement = false;
                    set(obj.fcmh.drawPhaseCircle,'Checked','off');
                    set(obj.mbh.phaseCircle, 'Checked','off');                    
                    ud = get(obj.getCurrentAxesHandleCb(),'UserData');
                    if isfield(ud, 'phaseCirc') && any(ishandle(ud.phaseCirc))
                        delete(ud.phaseCirc);
                    end
            end
        end
        
        function toggleCallUserCursorPosFunc(obj, bool)
            if nargin > 1
                set(obj.fcmh.cursorPosCb(),'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.fcmh.cursorPosCb(),'Checked')
                case 'off'
                    obj.callUserCursorPosFunc = true;
                    set(obj.fcmh.cursorPosCb(),'Checked','on');
                case 'on'
                    obj.callUserCursorPosFunc = false;
                    set(obj.fcmh.cursorPosCb(),'Checked','off');
            end
        end
        
        function updateLayout(obj)
            % backup panel unit settings
            phUnits = get(obj.ph,'Units');
            
            
            % get absolute panel width in cm
            set(obj.ph,'Units','centimeters');
            ppos = get(obj.ph,'position');
            pw  = ppos(3);
            phi = ppos(4);

            % decide, which panels to create (depending on the available
            % space)
            if pw > 10
                % standard mode: create all 5 panel
                createPanel = [1, 1, 1, 1, 1];
                %             [P, R, I, A, P]
            else
                if pw > 6
                    % reduced mode (3 panels)
                    if obj.complexMode;
                        createPanel = [1, 0, 0, 1, 1];
                        %             [P, R, I, A, P]
                    else
                        createPanel = [1, 1, 0, 1, 0];
                        %             [P, R, I, A, P]
                    end
                else
                    if pw > 4
                        % reduced mode (2 panels)
                        if obj.complexMode;
                            createPanel = [1, 0, 0, 1, 0];
                            %             [P, R, I, A, P]
                        else
                            createPanel = [1, 1, 0, 0, 0];
                            %             [P, R, I, A, P]
                        end
                    else                    
                        % single mode (only 1 panel)
                        if obj.complexMode;
                            createPanel = [0, 0, 0, 1, 0];
                            %             [P, R, I, A, P]
                        else
                            createPanel = [0, 1, 0, 0, 0];
                            %             [P, R, I, A, P]
                        end        
                    end
                end
            end
                        
            % width of the send button (centimeters)
            sbw = 0.4015; % send button width
            
            % remaining relative panel width
            rpw = pw - sbw;
            
            % dimensions for the text element blocks in the bottom panel
            np = sum(createPanel); % number of panel
            ps = rpw / np; % panel size
            
            % create sub panel for the text
            if isempty(obj.sph)
                obj.sph = zeros(5,1); % sub-panel handle
            end
            
            l   = 0;           % first panel's left position
            for i = 1:5
                if createPanel(i)
                    if obj.sph(i) == 0
                        obj.sph(i) = uipanel(obj.ph,'Units','centimeters',...
                            'Position',[l, 0, ps, phi],'BorderType','beveledout');
                    else
                        set(obj.sph(i),'position',[l, 0, ps, phi]);
                    end
                    l = l + ps; % (left = left + panel size)
                else
                    if obj.sph(i) ~= 0
                        delete(obj.sph(i));
                        obj.sph(i) = 0;
                    end
                end
            end
            
            
            % create text objects within the panel            
            obj.updateTextLayout();
            
            
            % send cursor button  ..
            pos(3:4) = [sbw, phi];    % width and height of the send button
            pos(1:2) = [rpw,  0 ];  % position of the send button
            
            if isempty(obj.sbh)
                obj.sbh = uicontrol('Style','togglebutton',...
                    'Parent',obj.ph,...
                    'Units','centimeters',...
                    'Position',pos,...
                    'tooltip','Send cursor to relatives',...
                    'Callback',@(src,evnt)obj.toggleSend(),...
                    'CData',obj.icons.send);
            else       
                set(obj.sbh,'position',pos);
            end
            
            % restore panel unit settings
            set(obj.ph,'Units',phUnits);
            
        end
        
        function updateTextLayout(obj)
                        
            % shortcut to the sub-panel handle
            spha = obj.sph;
            
            % get sup-panel width (as all sub panels should have the same
            % size, just use the first valid panel as reference)
            refPanelNumber = find(spha ~=0,1,'first');
            spw = asCursorPosClass.getWidth(spha(refPanelNumber), 'centimeters');
            spw = spw - 0.1; % remove some space for the border
            
            if spw < 2.3
                showIdentifier = false;
            else
                showIdentifier = true;
            end
            
            
            % widths for the Re, Im, Abs, and Ph blocks in centimeters
            id = .7;   % identifier
            va = 2.2;   % values
            
            % widths for the y/x block
            id_xy = .7     ;  % identifier
            va_xy = .8     ;  % values
            ss    = .2     ;  % small space
            
            % left offset
            lo = 0.05;
            
            % parameter table for the text objects            
            if showIdentifier
                %    text     , width   , left                    ,panelHandle, alignment
                t = {'Y/X:'   , id_xy   , lo                      , spha(1), 'left';...
                    ' '       , va_xy   , lo + id_xy              , spha(1), 'right';...
                    '/'       , ss      , lo + id_xy + va_xy      , spha(1), 'center';...
                    ' '       , va_xy+ss, lo + id_xy + va_xy + ss , spha(1), 'right';...
                    'Re :'    , id      , lo                      , spha(2), 'left';...
                    ' '       , va      , lo + id                 , spha(2), 'right';...
                    'Im :'    , id      , lo                      , spha(3), 'left';...
                    ' '       , va      , lo + id                 , spha(3), 'right';...
                    'Abs:'    , id      , lo                      , spha(4), 'left';...
                    ' '       , va      , lo + id                 , spha(4), 'right';...
                    'Pha:'    , id      , lo                      , spha(5), 'left';...
                    ' '       , va      , lo + id                 , spha(5), 'right'};
            else
                %    text     , width   , left                , panelHandle
                t = {''       , 0       , 0                   , spha(1), 'left';...
                    ' '       , va_xy   , lo                  , spha(1), 'right';...
                    '/'       , ss      , lo  + va_xy         , spha(1), 'center';...
                    ' '       , va_xy+ss, lo  + va_xy + ss    , spha(1), 'right';...
                    ''        , 0       , 0                   , spha(2), 'left';...
                    ' '       , va      , lo                  , spha(2), 'right';...
                    ''        , 0       , 0                   , spha(3), 'left';...
                    ' '       , va      , lo                  , spha(3), 'right';...
                    ''        , 0       , 0                   , spha(4), 'left';...
                    ' '       , va      , lo                  , spha(4), 'right';...
                    ''        , 0       , 0                   , spha(5), 'left';...
                    ' '       , va      , lo                  , spha(5), 'right'};
            end
            
            % create text objects
            noFields = length(t);
            if isempty(obj.th)
                obj.th = zeros(noFields,1);
            end
            
            h = .36;     % textfield heigth
            
            for i = 1 : noFields
                currPh= t{i,4}; % panel handle
                
                % if the panel handle is 0, skip this text
                if currPh == 0
                    if obj.th(i) ~= 0
                        % delete(obj.th(i)); % (should already be deleted)
                        obj.th(i) = 0;
                    end
                    continue;
                end
                
                l     = t{i,3}; % left
                w     = t{i,2}; % width
                align = t{i,5}; % alignment
                
                % assure that the current text is not bigger than the panel
                % width
                fullWidth = l + w;
                limitedWidth = min(fullWidth, spw);
                w = limitedWidth - l;
                
                if w > 0
                    % w > 0 means we actually want this text
                    
                    if obj.th(i) == 0
                        % if it doesn't seem to exist, create the text
                        value = t{i,1}; % value
                        obj.th(i) = uicontrol('Style','Text','String',value,'HorizontalAlignment',align,...
                            'Units','centimeters','pos',[l 0 w h],'parent',currPh,'HandleVisibility','on',...
                            'uicontextmenu',obj.cmh.base);
                    else
                        % if the text already exists just update the value
                        set(obj.th(i),'pos',[l 0 w h]);
                    end
                                        
                    
                else
                    % w == 0 means we don't really want this text
                    if obj.th(i) ~= 0
                        % so if it exists already,
                        % delete the text
                        delete(obj.th(i));
                        obj.th(i) = 0;
                    end
                end
                
            end
            
        end                
        
    end
    
    methods (Access = private)
        
        function initContextMenus(obj)
            
            % bottom panel
            obj.cmh.base = uicontextmenu;
            obj.cmh.phaseUnit.base = uimenu(obj.cmh.base,'Label','Phase unit...');
            obj.cmh.phaseUnit.deg  = uimenu(obj.cmh.phaseUnit.base,'Label','Degrees'   ,...
                'callback',@(src,evnt)setPhaseUnit(obj,'deg'));
            obj.cmh.phaseUnit.rad  = uimenu(obj.cmh.phaseUnit.base,'Label','Radiants'   ,...
                'callback',@(src,evnt)setPhaseUnit(obj,'rad'));
            obj.cmh.precision  = uimenu(obj.cmh.base,'Label','Change precision'   ,...
                'callback',@(src,evnt)changePrecisionDlg(obj));
            
            % also assign to the parent panel
            set(obj.ph,'uicontextmenu',obj.cmh.base);
            
            % main figure
            uimenu(obj.fcmh.base,'Label','Plot row (-)' ,...
                'callback',@(src,evnt)obj.plotRow);
            uimenu(obj.fcmh.base,'Label','Plot column (|)' ,...
                'callback',@(src,evnt)obj.plotColumn);
            obj.fcmh.plotRowAndCol = uimenu(obj.fcmh.base,'Label','Plot row and column continuously (+)' ,...
                'callback',@(src,evnt)obj.togglePlotRowAndCol);
            
            uimenu(obj.fcmh.base,'Label','Plot along plotDim (v)' ,...
                'callback',@(src,evnt)obj.plotAlongPlotDim);
            
            obj.fcmh.plotAlongDim = uimenu(obj.fcmh.base,'Label','Plot along plotDim continuously (Shift + v)' ,...
                'callback',@(src,evnt)obj.togglePlotAlongDim);
            
            % marker
            obj.fcmh.marker = uimenu(obj.fcmh.base,'Label','Marker',...
                'Separator','on');
            uimenu(obj.fcmh.marker,'Label','Add to all frames' ,...
                'callback',@(src,evnt)obj.asObj.markers.add(obj.getPosition));
            uimenu(obj.fcmh.marker,'Label','Add to current frames' ,...
                'callback',@(src,evnt)obj.asObj.markers.addToCurrentFrames(obj.getPosition));
            uimenu(obj.fcmh.marker,'Label','Send to all frames' ,...
                'callback',@(src,evnt)obj.apply2allCb('markers.add',true,obj.getPosition),...
                'Separator','on');
            uimenu(obj.fcmh.marker,'Label','Send to current frames' ,...
                'callback',@(src,evnt)obj.apply2allCb('markers.addToCurrentFrames',true,obj.getPosition));

            
            % user cursor position callback
            sub4 = uimenu(obj.fcmh.base,'Label', 'User cursor position Function',...
                'Separator','on');
            obj.fcmh.cursorPosCb = uimenu(sub4,'Label', 'Toggle continuous call(C)',...
                'Callback', @(src, event)obj.toggleCallUserCursorPosFunc(),...
                'Checked','off');
            uimenu(sub4,'Label', 'Call once (c)',...
                'Callback', @(src, event) obj.userCursorPosFcn());
            uimenu(sub4,'Label', 'Edit callback',...
                'Callback', @(src, event)eval(['edit ',func2str(obj.userFcn)]));
            
            % send cursor position
            obj.fcmh.toggleSendCursor = uimenu(obj.fcmh.base,'Label', 'Send cursor (Shift + x)',...
                'Callback', @(src, event)obj.toggleSend(),...
                'Checked',arrShow.boolToOnOff(obj.sendCursorOnMovement),...
                'Separator','off');
                        
            % phase circle
            obj.fcmh.drawPhaseCircle = uimenu(obj.fcmh.base,'Label','Draw phase circle continuously (Shift + p)' ,...
                'callback',@(src,evnt)obj.toggleDrawPhaseCircle);
            
        end
        
        function setValue(obj, handle, value, unit, precision)
            
            % default values
            if nargin < 2 || handle == 0
                return;
            end
            if nargin < 5
                precision = obj.precision;
                if nargin < 4
                    unit = '';
                end
            end
            
            if ischar(value)
                color = 'black';
            else
                if value < 0
                    color = obj.NEGATIV_COLOR;
                else
                    color = obj.POSITV_COLOR;
                end
                if strcmp(precision,'auto')
                    if abs(log(value)/log(10)) > obj.autoPrecisionLimit
                        precision = '%2.2e';
                    else
                        precision = '%2.3f';
                    end
                end
                value = num2str(value, precision);
            end
            set(handle, 'String', [value, ' ', unit], 'ForegroundColor', color);
        end
    end
    
    methods (Static)
        function width = getWidth(handle, units)
            % backup unit settings
            phUnits = get(handle,'Units');
            
            % set panel units to the desired ones
            set(handle,'Units',units);
            
            % get width
            ppos = get(handle,'position');
            width = ppos(3); % width
            
            % restore original units
            set(handle,'Units',phUnits);
        end
        
        
    end
end
