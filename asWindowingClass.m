%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef asWindowingClass < handle
    
    properties (GetAccess = private, SetAccess = private)
        
        % handle
        ph       = [];          % panel handle        
        ih    = [];             % image handle
        ah    = [];             % axes handle
                
        cntSliderH   = [];      % slider handle
        widthSliderH = [];      %

        filterButtonH  = [];    % button handle
        sendAbsButtonH = [];    %
        sendRelButtonH = [];    %
        keepAbsButtonH = [];    %
        
        cmh = [];               % context menu handle
        
        cntTextH     = [];      % static-text handle for "C"
        widthTextH   = [];      % ...and "W"
        CWTextH      = [];      % ...and "C/W"
        
        
        % callbacks
        updFigCb      = [];     %
        apply2allCb  = [];      % send to all relatives callback
        getPhaseColormapCb = [];
        

        % data type
        isComplex = false;
        complexRef = [];        
        
        
        % center and width
        usePhaseCW = false; % individual windowing settings are stored and
                            % restored for phase and for
                            % magnitude/real/imag views.
                            
        magniCW   = [0,1];  % these values are set to the current slider
        phaseCW   = [0,360];% values (depending on the usePhaseCW state)        
        
        % data ranges
        magniMin = -0.5;
        magniMax =  0.5;
        phaseMin = -180;
        phaseMax = 180;
        
        % toggle states
        keepRelCW       = false;
        keepAbsCW       = false;
        
        % context menu handles
        keepRelCWctxmH  = [];  % handle to context menu entry for keepRelCw
        keepAbsCWctxmH  = [];
        
        cntLimits   = [0,0];
        widthLimits = [0,0];
        
        rangeCalcMethod = 1;% derive data range from:
                            % 0 = manual 1 = min/max 2 = percentile
                            % (calculate image range from percentile rather
                            % than just from min and max helps to have a
                            % reasonable windowing range for noisy data)
        percentile = 98;
        
        
        isInitialized = false;
        isEnabled = true;
        
    end
    
    properties (Constant, Access = private)
        % minimum width value (if the calculated width falls under that
        % value, the windowing object is automatically disabled)
        MIN_VALID_WIDTH = realmin;

        % initial relative windowing
        INITIAL_REL_CW = [.5, 1];        
        
        % background colors for keepAbsoluteCW and keepRelativeCW
        BG_COLOR_REL = get(0,'defaultuicontrolbackgroundcolor');
        BG_COLOR_ABS = [205/255;0;0];         % dark red
    end
    
    %#ok<*FPARK>
    % Deactivate the warning telling me that I should use textscan instead
    % of strread... I like textscan. I'll change it if I feel like having
    % too much time...
    
    
    properties (GetAccess = public, SetAccess = private)
        sendAbsWindow = false;
        sendRelWindow = false;
    end
    
    methods (Access = public)
        function obj = asWindowingClass(...
                parentPanelHandle,...
                panelPosition,...
                updFigCb,...
                apply2allCb,...
                getPhaseColormapCb,...
                icons)
            
            obj.updFigCb    = updFigCb;
            obj.apply2allCb = apply2allCb;
            obj.getPhaseColormapCb = getPhaseColormapCb;
            
            
            % create parent panel
            obj.ph = uipanel('visible','on','Units','normalized',...
                'Position',panelPosition,'Parent',parentPanelHandle,...
                'Tag','asWindowingPanel');

            % create filter button
            htmlToolTip = ['<html><b>Filter:</b><br><table>',...
                '<tr><td><u>Normal click</u></td><td>: Enable filter (use percentile)</td></tr>',...
                '<tr><td><u>Ctrl+click:</u></td>: Set percentile</td></tr>',...                
                '<tr><td><u>Shift+click:</u></td>: Manual mode</td></tr></table>',...
                '<br><p style="width:180px; text-align:left"><i>',...
                'Description:<br>Without ''filter'', the slider range for the windowing is calculated ',...
                'from the min. and max. of the image. This can be disadvantageous for images ',...
                'with strong outliers. Filter mode uses percentile instead.',...
                '</i></p></html>'];
            obj.filterButtonH = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.4,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip',htmlToolTip,...
                'Callback',@(src,evnt)filtButtonCb(obj),...
                'Value',0,...
                'CData',icons.filter);
            function filtButtonCb(obj)
                fh = get(get(obj.ph,'Parent'),'Parent');                                
                modifiers = get(fh,'currentModifier');
                val = get(obj.filterButtonH,'Value');
                if isempty(modifiers)                
                    switch(val)
                        case 1
                            % set range calc method to percentile
                            obj.setRangeCalcMethod(2);                        
                        case 0
                            % set range calc method to minMax
                            obj.setRangeCalcMethod(1);
                    end                    
                else
                    if ismember('control',modifiers)               
                        set(obj.filterButtonH,'Value',~val); % invert toggle state                         
                        obj.setPercentile(); % alter the percentile
                    else
                        if ismember('shift',modifiers)
                            set(obj.filterButtonH,'Value',~val); % invert toggle state                             
                            obj.overwriteSliderLimits();
                        end
                    end
                end
            end
            
                        
            % create send button
            obj.sendAbsButtonH = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.85,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip','Send absolute window to relatives',...
                'Callback',@(src,evnt)obj.toggleSendAbsWindow,...
                'String','A',...
                'fontweight','bold',...
                'ForegroundColor', obj.BG_COLOR_ABS,...
                'CData',icons.send);
            obj.sendRelButtonH = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.7,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip','Send relative window to relatives',...
                'Callback',@(src,evnt)obj.toggleSendRelWindow,...
                'String','R',...
                'fontweight','bold',...
                'ForegroundColor','blue',...
                'CData',icons.send);
            
            % create button for the window behaviour
            htmlToolTip = ['<html><b>Window behavior when changing frames:</b><br><table>',...
                '<tr><td><font color="red"><b>A</font></b></td><td>: Keep the absolute windowing</td></tr>',...
                '<tr><td><b>R</b></td>: Keep the relative windowing</td></tr></table>',...
                '<br><p style="width:200px; text-align:justify"><i>',...
                'Description: The absolute windowing determines how an image value is mapped to a pixel color. ',...
                'If kept constant, a value of e.g. 1 will always be white. The relative windowing ',...
                'consideres the actual data range. If kept constant, the absolute windowing will be ',...
                'recalculated for every frame such that white always corresponds to e.g. 90% of the data maximum.',...
                '</i></p></html>'];
            obj.keepAbsButtonH = uicontrol('Style','pushbutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.55,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip',htmlToolTip,...
                'Callback',@(src,evnt)absButtonCb(obj),...
                'String','A');
            function absButtonCb(obj)
                switch(get(obj.keepAbsButtonH,'String'))
                    case {'A','-'}
                        % toggle to keepRelativeWindow
                        obj.setKeepRelCW(true);
                    case 'R'
                        % toggle to keepAbsWindow
                        obj.setKeepAbsCW(true);
                end
                % note: disabling both options ('-') has been removed since
                % the behavior can also be achieved by simply keeping the
                % relative initial windowing.
            end
            
            
            % create center and width slider
            hintTxt = ['<br><br><i>Hints:<br>- Use center mouse button + mouse movement for convenient windowing<br>',...
                '- Use double click to reset windowing</i>'];
           
            obj.cntSliderH = uicontrol('Style','slider',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Tag','cntSlider',...
                'tooltip',['<html>Center (inverse brightness)',hintTxt,'</html>'],...
                'Position',[0,.5,1,.24],...
                'Callback',@(src,evnt)obj.sliderCb());
                        
            obj.widthSliderH = uicontrol('Style','slider',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[0,.25,1,.24],...
                'tooltip',['<html>Width (inverse contrast)',hintTxt,'</html>'],...
                'Callback',@(src,evnt)obj.sliderCb());
            
            
            % create static annotation text
            obj.cntTextH = uicontrol('Style','Text',...
                'Parent', obj.ph,...
                'String','C/W',...
                'FontSize',8,...
                'Units','normalized',...
                'tooltip',['<html>Center / width of the window<br>(inverse brightness / inverse contrast)',hintTxt,'</html>'],...
                'HorizontalAlignment','left',...
                'Position',[0,.74,.4,.23]);
            
            % create dynamic text for CW values
            obj.CWTextH = uicontrol('Style','Text',...
                'Parent', obj.ph,...
                'String','',...
                'Units','normalized',...
                'FontSize',8,...
                'tooltip',['<html>Center / width of the window<br>(inverse brightness / inverse contrast)',hintTxt,'</html>'],...
                'HorizontalAlignment','center',...
                'Position',[0.01,0,.98,.2]);
            
            
            % create context menu
            obj.cmh.base = uicontextmenu;
            
            uimenu(obj.cmh.base,'Label','Input center and width',...
                'callback',@(src,evnt)obj.setCW);
            
            uimenu(obj.cmh.base,'Label','Input min and max',...
                'callback',@(src,evnt)obj.setCLim);
            
            uimenu(obj.cmh.base,'Label','Activate immediate slider update',...
                'callback',@(src,evnt)obj.activateImmediateUpdate);
            
            uimenu(obj.cmh.base,'Label','Reset windowing (double click)',...
                'callback',@(src,evnt)obj.resetWindowing);
            % ---
            
            obj.cmh.keepRelCW = uimenu(obj.cmh.base,'Label','Keep relativ windowing',...
                'callback',@(src,evnt)obj.setKeepRelCW,...
                'Checked','off', 'Separator','on');
            obj.cmh.keepAbsCW = uimenu(obj.cmh.base,'Label','Keep absolute windowing',...
                'callback',@(src,evnt)obj.setKeepAbsCW,...
                'Checked','off');
            % ---
            
            uimenu(obj.cmh.base,'Label','Copy absolute windowing (Strg + c)',...
                'callback',@(src,evnt)obj.copyAbsWindow,...
                'Separator','on');
            uimenu(obj.cmh.base,'Label','Paste absolute windowing (Strg + v)',...
                'callback',@(src,evnt)obj.pasteAbsWindow);
            uimenu(obj.cmh.base,'Label','Load absolute windowing from txt (Strg + o)',...
                'callback',@(src,evnt)obj.loadAbsWindow);
            % ---
            
            obj.cmh.sendAbsWindow = uimenu(obj.cmh.base,'Label','Send absolute windowing to all relatives' ,...
                'callback',@(src,evnt)obj.toggleSendAbsWindow,...
                'Separator','on');
            obj.cmh.sendRelWindow = uimenu(obj.cmh.base,'Label','Send relative windowing to all relatives' ,...
                'callback',@(src,evnt)obj.toggleSendRelWindow);
            
            % ---
            obj.cmh.rangeCalcMethod = uimenu(obj.cmh.base,'Label','Derive data range from...',...
                'separator','on');
            % ->
            obj.cmh.rangeCalcManu = uimenu(obj.cmh.rangeCalcMethod,'Label','Manual',...
                'callback',@(src,evnt)obj.setRangeCalcMethod(0));
            obj.cmh.rangeCalcMiMa = uimenu(obj.cmh.rangeCalcMethod,'Label','Min/Max',...
                'callback',@(src,evnt)obj.setRangeCalcMethod(1));
            obj.cmh.rangeCalcPerc = uimenu(obj.cmh.rangeCalcMethod,...
                'Label',[num2str(obj.percentile),'% Percentile'],...
                'callback',@(src,evnt)obj.setRangeCalcMethod(2),...
                'checked','on'); % check percentile by default
            obj.cmh.percentile = uimenu(obj.cmh.rangeCalcMethod,...
                'Label','Change percentile...',...
                'callback',@(src,evnt)obj.setPercentile(),...
                'separator','on');
            % <-
            
            % assign context menu to panel, slider, and text
            set(obj.ph,'uicontextmenu',obj.cmh.base);
            set(obj.cntSliderH,'uicontextmenu',obj.cmh.base);
            set(obj.widthSliderH,'uicontextmenu',obj.cmh.base);
            set(obj.cntTextH,'uicontextmenu',obj.cmh.base);
            set(obj.widthTextH,'uicontextmenu',obj.cmh.base);
            set(obj.CWTextH,'uicontextmenu',obj.cmh.base);
            
        end
        
        function toggleUsePhaseCW(obj,bool)
            % the windowing object stores two different window value sets
            % (center and width). One for phase - and one for 'non phase' 
            % views...
            if obj.isEnabled
                if nargin < 2
                    obj.usePhaseCW = ~obj.usePhaseCW;
                else
                    obj.usePhaseCW = bool;
                end
            end
        end
        
        function linkToImage(obj,ihandle)
            % This is called whenever the image in the arrayShow gui
            % changes (e.g. due to a different selection string or a
            % different complex part)
            % If the image handle differs from the previous one, the slider
            % limits and values are updated according to the new image
            % dynamic range.
            
            if ihandle == obj.ih
                return; % (nothing needs to be done)
            end
            
            obj.ih = ihandle;
            obj.ah = get(ihandle,'Parent');
            
            % if the ihandle is not actually an image, e.g. because quiver
            % has been used to illustrate the image array, diable the
            % windowing functionality
            if ~strcmp(get(ihandle,'Type'),'image')
                obj.disable();
                return;
            end
            
            % if we reached this point, we are dealing with a new image
            % which might have a different dynamic range than the previous
            % one...
            
            % get reference image data
            refImage = get(obj.ih,'CData');
            if size(refImage,3) == 3
                % assume that we are dealing with an rgb array, made from a
                % complex image. So get complex image from the axes
                % UserData
                obj.isComplex = true;
                ud = get(obj.ah,'UserData');
                obj.complexRef = ud.cplxImg;
            else
                obj.isComplex = false;
            end
            
            % Update the data range properties (imageMin, max, etc)
            % according to the choosen rangeCalcMethod
            obj.updateDataRange()
            
            if ~obj.isInitialized
                obj.updateCWtext();
                obj.setKeepRelCW(true);
                obj.isInitialized = true;
            end
        end
        
        function setRangeCalcMethod(obj, method)
            % setRangeCalcMethod(obj, method)
            % Sets how the windowing range is calculated
            % method can be either a nunber or a string:
            %   0 : 'manual'
            %   1 : 'min/max' (default)
            %   2 : 'percentile'
                        
            switch method
                case {0,'manual'} % manual
                    set(obj.cmh.rangeCalcManu,'checked','on');
                    set(obj.cmh.rangeCalcMiMa,'checked','off');
                    set(obj.cmh.rangeCalcPerc,'checked','off');
                    set(obj.filterButtonH,'Value',0);
                    obj.overwriteSliderLimits();
                    obj.rangeCalcMethod = 0;
                    return;
                case {1,'min/max'} % min/max
                    set(obj.cmh.rangeCalcManu,'checked','off');
                    set(obj.cmh.rangeCalcMiMa,'checked','on');
                    set(obj.cmh.rangeCalcPerc,'checked','off');
                    set(obj.filterButtonH,'Value',0);
                    obj.rangeCalcMethod = 1;
                case {2,'percentile'} % percentile
                    set(obj.cmh.rangeCalcManu,'checked','off');
                    set(obj.cmh.rangeCalcMiMa,'checked','off');
                    set(obj.cmh.rangeCalcPerc,'checked','on');
                    set(obj.filterButtonH,'Value',1);
                    obj.rangeCalcMethod = 2;
                otherwise
                    error('asWindowingClass:invalidMethod','Invalid range calc method %d',obj.rangeCalcMethod);
                    
            end
            obj.updateDataRange();
        end
        
        function setPercentile(obj, per)
            if nargin < 2
                per = obj.percentile;
                perStr = mydlg('Enter percentile','Enter percentile',num2str(per));
                if ~isempty(perStr)
                    try
                        per = str2double(perStr);
                    catch err
                        if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                            fprintf('incorrect limits format\n');
                        else
                            rethrow(err);
                        end
                    end
                else
                    return
                end
            end
            
            if per == obj.percentile
                return;
            end
            
            obj.percentile = per;
            set(obj.cmh.rangeCalcPerc,'Label',[num2str(obj.percentile),'% Percentile']);
            if obj.rangeCalcMethod == 2 % percentile
                obj.updateDataRange();
            end
            
        end
        
        function overwriteSliderLimits(obj, mi, ma)
            
            % if not given as an argument, get min and max from input
            % dialog
            if nargin < 3
                [mi, ma] = obj.getMinMaxWidth();
                
                limStr = inputdlg({'min','max'},'Enter min and max values',1,{num2str(mi),num2str(ma)});
                if ~isempty(limStr)
                    try
                        mi = str2double(limStr{1});
                        ma = str2double(limStr{2});
                    catch err
                        if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                            fprintf('incorrect limits format\n');
                        else
                            rethrow(err);
                        end
                    end
                else
                    fprintf('incorrect limits format\n');
                    return
                end
            end
            
            % set the range calc method to 'manual'
            obj.rangeCalcMethod = 0;
            
            % derive width
            wi = ma - mi;
            
            % assure that the width is not too close to zero
            if wi < obj.MIN_VALID_WIDTH
                warning('asWindowingClass:invalidValue','Minimal width is limited to %e',obj.MIN_VALID_WIDTH);
                ma = ma + obj.MIN_VALID_WIDTH;
            end
            
            % get the previous relative CW, in case we want to keep that
            prevRelCW = obj.getRelCW();
            
            % store the new data properties
            obj.setMinMaxWidth(mi, ma);
            
            % update slider limits
            obj.updateSliderLimits(false, prevRelCW);
        end
        
        
        
        function setCLim(obj, CLim, adaptLimits, apply2relatives)
            if obj.isEnabled
                
                % default parameters
                if nargin < 4
                    apply2relatives = obj.sendAbsWindow || obj.sendRelWindow;
                    if nargin < 3
                        adaptLimits = true;
                    end
                end
                
                
                % if not given as an argument, get CLim from input dialog
                if nargin < 2
                    CLim = obj.getCLim;
                    CLimStr = mydlg('Enter window limits','Enter window limits',[num2str(CLim(1)),' , ',num2str(CLim(2))]);
                    if ~isempty(CLimStr)
                        try
                            [CLim(1), CLim(2)] = strread(CLimStr,'%f%f','delimiter',',');  %#ok<*FPARK>
                        catch err
                            if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                                fprintf('incorrect CLim format\n');
                            else
                                rethrow(err);
                            end
                        end
                    end
                end
                
                % derive absolute width and center values
                width  = CLim(2) - CLim(1);
                center = CLim(1) + width/2;
                
                
                obj.setCW([center, width], adaptLimits, apply2relatives);
            end
        end
        
        function CW = getCW(obj)
            % get center and width
            if obj.usePhaseCW
                CW = obj.phaseCW;
            else
                CW = obj.magniCW;
            end
        end
        
        function relCW = getRelCW(obj)
            if obj.isEnabled
                CW = obj.getCW;
                [mi, ~, wi] = obj.getMinMaxWidth;
                
                % get center and width setting, relative to image width
                relCW(1) = double((CW(1) - mi )/ wi);
                relCW(2) = double(CW(2) / wi);
                
            else
                relCW = obj.INITIAL_REL_CW;
            end
        end
        
        function activateImmediateUpdate(obj)
            % dirty way of creating a valueAdjustment- java callback
            % (actually i'd love this to be the default behaviour. However,
            % it seems to leave orphant java classes in the matlab sessions
            % which can become a problem when trying to get rid of old
            % arrayShow instances)
            hJScrollBar = findjobj('depth',19,'nomenu','Class','Slider');
            hJScrollBar(1).AdjustmentValueChangedCallback = @(src, evnt)obj.sliderCb;
            hJScrollBar(2).AdjustmentValueChangedCallback = @(src, evnt)obj.sliderCb; %#ok<NASGU> it is used :)
            clear('hJScrollBar');
        end
        
        function setCW(obj, CW, adaptLimits, apply2relatives)
            if obj.isEnabled
                if nargin < 4
                    apply2relatives = obj.sendAbsWindow || obj.sendRelWindow;
                    if nargin < 3
                        adaptLimits = true;
                    end
                end
                
                % if not given as an argument, get CW from input dialog
                if nargin < 2
                    CW = obj.getCW;
                    CWStr = mydlg('Enter window center and width','Enter window center and width',[num2str(CW(1)),' , ',num2str(CW(2))]);
                    if ~isempty(CWStr)
                        try
                            [CW(1), CW(2)] = strread(CWStr,'%f%f','delimiter',',');
                        catch err
                            if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                                fprintf('incorrect CLim format\n');
                            else
                                rethrow(err);
                            end
                        end
                    end
                end
                
                
                % set center and width
                center = CW(1);
                width  = CW(2);
                
                if adaptLimits
                    % adapt slider limits
                    if center < get(obj.cntSliderH,'Min')
                        set(obj.cntSliderH,'Min',center);
                    else
                        if center > get(obj.cntSliderH,'Max')
                            set(obj.cntSliderH,'Max',center);
                        end
                    end
                    
                    if width < get(obj.widthSliderH,'Min')
                        set(obj.widthSliderH,'Min',width);
                    else
                        if width > get(obj.widthSliderH,'Max')
                            set(obj.widthSliderH,'Max',width);
                        end
                    end
                    
                else
                    % make sure, that values are within valid range
                    center = asWindowingClass.limit(center,get(obj.cntSliderH,'Min'),get(obj.cntSliderH,'Max'));
                    width  = asWindowingClass.limit(width ,get(obj.widthSliderH,'Min'),get(obj.widthSliderH,'Max'));
                end
                
                % set to slider
                set(obj.cntSliderH,'Value',center);
                set(obj.widthSliderH,'Value',width);
                obj.backupSliderValues();
                
                % derive axes limits
                CLim(1)  = center - width/2;
                CLim(2)  = CLim(1) + width;
                                
                if obj.isComplex
                    rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                    set(obj.ih,'CData',rgbImg);
                else
                    % last check, if the width is too small to neglect rounding
                    % errors
                    if CLim(1) - CLim(2) == 0
                        obj.enable(false);
                        return;
                    end
                    
                    % set limits to axes
                    set(obj.ah,'CLim',CLim);
                end
                
                % update CW text
                obj.updateCWtext();
                
                if apply2relatives
                    if obj.sendAbsWindow
                        obj.apply2allCb('window.setCW',false, CW, adaptLimits,false);
                    else if obj.sendRelWindow
                            relCW = obj.getRelCW;
                            obj.apply2allCb('window.setRelCW', false, relCW, adaptLimits, false);
                        end
                    end
                end
            end
        end
        
        function setRelCW(obj, relCW, adaptLimits, apply2relatives)
            if obj.isEnabled
                if nargin < 4
                    apply2relatives = obj.sendRelWindow || obj.sendAbsWindow;
                    if nargin < 3
                        adaptLimits = true;
                    end
                end
                [mi, ~, wi] = obj.getMinMaxWidth;
                CW = relCW * wi;
                CW(1) = CW(1) + mi;
                obj.setCW(CW, adaptLimits, apply2relatives);
                obj.updateCWtext();
            end
        end
        
        
        function copyAbsWindow(obj)
            clipboard('copy',num2str(obj.getCW));
            fprintf('Copied center and width to clipboard\n');
        end
        
        function pasteAbsWindow(obj)
            pastedCW = str2num(clipboard('paste')); %#ok<ST2NM> the data is not expected to be a scalar
            if ~isempty(pastedCW)
                if ~any(size(pastedCW) ~= [1,2])
                    obj.setCW(pastedCW);
                    obj.updFigCb();
                    return
                end
            end
            fprintf('No valid center/width information in clipboard\n');
        end
        
        function loadAbsWindow(obj, file)
            if nargin < 2
                [fname, fpath] = uigetfile('*.txt');
                file = [fpath, fname];
            end
            
            if isempty(file) || isnumeric(file)
                return
            else
                % read file
                fid  = fopen(file,'r');
                str = fread(fid,'char=>char');
                fclose(fid);
                
                % find CW strung
                strIdentifier = 'center/width = [';
                pos = strfind(str',strIdentifier);
                if isempty(pos)
                    fprintf('No valid center/width information in clipboard\n');
                    return;
                else
                    pos = pos + length(strIdentifier);
                    [C, W] = strread(str(pos:end),'%f %f',1);
                    obj.setCW([C,W]);
                end
            end
        end
        
        function CLim = getCLim(obj)
            % get current absolute windowing
            CLim   = get(obj.ah,'CLim');
        end
        
        function ah = getAxesHandle(obj)
            ah = obj.ah;
        end
        
        function ih = getImageHandle(obj)
            ih = obj.ih;
        end
        
        function width = getDataWidth(obj)
            [~,~,width] = obj.getMinMaxWidth();
        end
        
        function resetWindowing(obj, apply2relatives)
            
            if nargin < 2
                apply2relatives = obj.sendAbsWindow || obj.sendRelWindow;
            end
            
            if obj.isEnabled
                [mi, ma, wi] = obj.getMinMaxWidth;
                CLim = [mi,ma];
                if obj.isComplex
                    rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                    set(obj.ih,'CData',rgbImg);
                else
                    set(obj.ah,'CLim',CLim);
                end
                set(obj.cntSliderH,'Value',mi + wi/2);
                set(obj.widthSliderH,'Value',wi);
                obj.backupSliderValues();
                obj.updateCWtext();
                if apply2relatives
                    obj.apply2allCb('window.resetWindowing',false,false);
                end
            end
        end
        
        function setKeepRelCW(obj,bool)
            if nargin < 2
                obj.keepRelCW = ~obj.keepRelCW;
            else
                obj.keepRelCW = bool;
            end
            
            switch obj.keepRelCW
                case true
                    set(obj.cmh.keepRelCW,'Checked','on');
                    set(obj.keepAbsButtonH,'String','R','BackgroundColor',obj.BG_COLOR_REL);
                    
                    set(obj.cmh.keepAbsCW,'Checked','off'); %disable concurring option
                    obj.keepAbsCW = false;
                case false
                    set(obj.cmh.keepRelCW,'Checked','off');
                    if(~obj.keepAbsCW)
                        % if neither option is set, draw a '-' in
                        % pushbutton
                        set(obj.keepAbsButtonH,'String','-',...
                            'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                    end
            end
            
        end
        
        function setKeepAbsCW(obj,bool)
            if nargin < 2
                obj.keepAbsCW = ~obj.keepAbsCW;
            else
                obj.keepAbsCW = bool;
            end
            
            switch obj.keepAbsCW
                case true
                    set(obj.cmh.keepAbsCW,'Checked','on');
                    set(obj.keepAbsButtonH,'String','A','BackgroundColor',obj.BG_COLOR_ABS);
                    
                    set(obj.cmh.keepRelCW,'Checked','off'); %disable concurring option
                    obj.keepRelCW = false;
                case false
                    set(obj.cmh.keepAbsCW,'Checked','off');
                    if(~obj.keepRelCW)
                        % if neither option is set, draw a '-' in
                        % pushbutton
                        set(obj.keepAbsButtonH,'String','-',...
                            'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                    end
            end
            
            
        end
        
        
        function disable(obj)
            % shortcut to obj.enable(false) for backward compatibility
            obj.enable(false);
        end
        
        function enable(obj, state)
            if nargin < 2
                state = 'on';
            end
            if ischar(state)
                % assume state to be an "on" or "off" string
                stateStr = state;
            else
                % assume integer or boolean state and create according "on"
                % or "off" string
                stateStr = arrShow.boolToOnOff(state);
            end
            
            set(obj.cntSliderH,'Enable', stateStr);
            set(obj.widthSliderH,'Enable', stateStr);
            set(obj.cntTextH,'Enable', stateStr);
            set(obj.widthTextH,'Enable', stateStr);
            set(obj.CWTextH,'Enable', stateStr);
            set(obj.sendAbsButtonH,'Enable', stateStr);
            set(obj.sendRelButtonH,'Enable', stateStr);
            set(obj.keepAbsButtonH,'Enable', stateStr);
            
            obj.isEnabled = arrShow.onOffToBool(stateStr);
        end
        
        function bool = getIsEnabled(obj)
            bool = obj.isEnabled;
        end
        
        
        
        % ----
        
        function sendAbsWindowToRelatives(obj)
            obj.apply2allCb('window.setCW',false,obj.getCW(),true,false);
        end
        
        function sendRelWindowToRelatives(obj)
            relCW = obj.getRelCW();
            obj.apply2allCb('window.setRelCW',false,relCW,true,false);
        end
        
        function toggleSendAbsWindow(obj,bool)
            if nargin > 1
                set(obj.cmh.sendAbsWindow,'Checked',arrShow.boolToOnOff(~bool));
            end
            switch get(obj.cmh.sendAbsWindow,'Checked')
                case 'off'
                    obj.sendAbsWindow = true;
                    set(obj.cmh.sendAbsWindow,'Checked','on');
                    set(obj.sendAbsButtonH,'value',1);
                    
                    % assure concurring option is disabled
                    set(obj.cmh.sendRelWindow,'Checked','off');
                    set(obj.sendRelButtonH,'value',0);
                    obj.sendRelWindow = false;
                    
                    obj.sendAbsWindowToRelatives();
                case 'on'
                    obj.sendAbsWindow = false;
                    set(obj.cmh.sendAbsWindow,'Checked','off');
                    set(obj.sendAbsButtonH,'value',0);
            end
        end
        
        function toggleSendRelWindow(obj,bool)
            if nargin > 1
                set(obj.cmh.sendRelWindow,'Checked',arrShow.boolToOnOff(~bool));
            end
            switch get(obj.cmh.sendRelWindow,'Checked')
                case 'off'
                    obj.sendRelWindow = true;
                    set(obj.cmh.sendRelWindow,'Checked','on');
                    set(obj.sendRelButtonH,'value',1);
                    
                    % assure concurring option is disabled
                    set(obj.cmh.sendAbsWindow,'Checked','off');
                    obj.sendAbsWindow = false;
                    set(obj.sendAbsButtonH,'value',0);
                    
                    obj.sendRelWindowToRelatives();
                    
                case 'on'
                    obj.sendRelWindow = false;
                    set(obj.cmh.sendRelWindow,'Checked','off');
                    set(obj.sendRelButtonH,'value',0);
            end
        end
        
        
        % ----
    end
    
    
    
    
    methods (Access = private)
        
        function updateDataRange(obj)
            % Update the data range properties (imageMin, max, etc)
            % according to the choosen rangeCalcMethod
            
            % get the previous relative CW, in case we want to keep that
            prevRelCW = obj.getRelCW();
            
            if obj.rangeCalcMethod > 0
                % get reference image data
                refImage = get(obj.ih,'CData');
                if obj.isComplex
                    refImage = abs(obj.complexRef);
                end
                
                switch obj.rangeCalcMethod
                    case 1 % min / max
                        mi = min(min(refImage));
                        ma = max(max(refImage));
                    case 2 % percentile
                        mi = -asWindowingClass.vecPerc(-refImage(:),obj.percentile);
                        ma = asWindowingClass.vecPerc(refImage(:),obj.percentile);
                        
                    otherwise
                        error('asWindowingClass:invalidMethod','Invalid range calc method %d',obj.rangeCalcMethod);
                end
                
                % store the data range (min and max values) in the object
                % properties
                obj.setMinMaxWidth(mi, ma);
            end
            
            % update the slider limits
            obj.updateSliderLimits(true, prevRelCW);
        end
        
        
        function [mi, ma, wi] = getMinMaxWidth(obj)
            if obj.usePhaseCW
                mi = obj.phaseMin;
                ma = obj.phaseMax;
            else
                mi = obj.magniMin;
                ma = obj.magniMax;
            end
            wi = ma - mi;
        end
        
        function setMinMaxWidth(obj, mi, ma)
            if obj.usePhaseCW
                obj.phaseMax = ma;
                obj.phaseMin = mi;
            else
                obj.magniMax = ma;
                obj.magniMin = mi;
            end
        end
        
        function updateCWtext(obj)
            if obj.isEnabled
                [~,~,w] = obj.getMinMaxWidth();
                if w > 10000
                    % range from 10 000 ... inf
                    format = '%6.1e';
                else
                    if w > 10
                        % range from 10 ... 10 000
                        format = '%6.0f';
                    else
                        if w > 0.1
                            % range from 0.1 ... 10
                            format = '%1.2f';
                        else
                            % range from 0 ... 0.1
                            format = '%3.1e';
                        end
                    end
                end
                CW = obj.getCW;
                CWstr = [num2str(CW(1),format) , ' / ' , num2str(CW(2),format) ];
                set(obj.CWTextH, 'String', CWstr);
            end
        end
        
        
        function sliderCb(obj)
            % get slider values
            currCenter = get(obj.cntSliderH,'Value');
            currWidth  = get(obj.widthSliderH,'Value');
            
            % store
            obj.backupSliderValues;
            
            % derive relative axes limits
            CLim(1)  = currCenter - currWidth/2;
            CLim(2)  = CLim(1) + currWidth;
            
            % set limits to axes
            if obj.isComplex
                rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                set(obj.ih,'CData',rgbImg);
            else
                % set limits to axes
                set(obj.ah,'CLim',CLim);
            end
            
            % update the C/W text
            obj.updateCWtext();
            
            % apply to relatives
            if obj.sendAbsWindow
                obj.apply2allCb('window.setCW',false, [currCenter, currWidth]);
            else if obj.sendRelWindow
                    relCW = obj.getRelCW;
                    obj.apply2allCb('window.setRelCW', false, relCW);
                end
            end
            
            
        end
        
        function deriveSliderLimits(obj)
            % derive standard limits for the slider
            [mi, ma, wi] = obj.getMinMaxWidth;
            
            if mi < 0
                obj.cntLimits(1) = 2 * mi;
            else
                obj.cntLimits(1) = .1 * mi;
            end
            if ma > 0
                obj.cntLimits(2) = 2* ma;
            else
                obj.cntLimits(2) = .1 * ma;
            end
            
            obj.widthLimits(1) = wi/200;
            obj.widthLimits(2) = 4 * wi;
        end
        
        function updateSliderLimits(obj, adaptLimits, relCW)
            % adapt the slider limits and valuesto the (previously
            % calculated) data range. Also the current slider VALUES are
            % recalculated using either previously set absolute values or
            % relative values with respect to the new limits.
            %
            % The second input argument (adaptLimits) determines how to
            % deal with slider values (absCW or relCW) which are outside
            % the range of the slider limits. If adaptLimits is set to
            % true, the slider limits are overwritten to include the value.
            % Otherwise, the value is limited to the slider limits.
            
            if nargin < 3
                relCW = obj.getRelCW();
            end
            if nargin < 2
                adaptLimits = false;
            end
            
            % get the (prevoisly calculated) new data range from the
            % object's property
            [mi, ~, wi] = obj.getMinMaxWidth();
            
            % assure, that the width is not too close to zero
            if wi < obj.MIN_VALID_WIDTH
                obj.disable;
                if obj.isComplex
                    rgbImg = complex2rgb(obj.complexRef,256,[1,1], obj.getPhaseColormapCb());
                    set(obj.ih,'CData',rgbImg);
                end
                return
            end
            
            
            % derive new slider limits
            obj.deriveSliderLimits
                        
            % set values to slider objects
            set(obj.cntSliderH,'Min',obj.cntLimits(1),'Max',obj.cntLimits(2),'Value',mi + wi/2);
            set(obj.widthSliderH,'Min',obj.widthLimits(1), 'Max',obj.widthLimits(2), 'Value',wi);
            
            % if we reached this point, we probalby have reasonable slider
            % values and limits set, so enable the object, if it has been
            % disabled before
            if ~obj.isEnabled
                obj.enable;
            end
            
            % update the CW (center and width) values with respect to the
            % new slider limits
            if obj.keepRelCW
                % set the slider to the previous relative center and width
                % setting
                obj.setRelCW(relCW, adaptLimits); %(this is not allowed, if object was disabled before)
            else
                if obj.keepAbsCW
                    % set the slider to the previous absolute center and
                    % width setting
                    absCW = obj.getCW();                    
                    obj.setCW(absCW, adaptLimits);
                else
                    % no "keep-option" is set, so just use a reasonable
                    % standard setting
                    obj.setCW([mi + wi/2,wi], false);
                end
            end
        end
        
        function backupSliderValues(obj)
            CW = [0,0];
            CW(1) = get(obj.cntSliderH,'Value');
            CW(2) = get(obj.widthSliderH,'Value');
            if obj.usePhaseCW
                obj.phaseCW = CW;
            else
                obj.magniCW = CW;
            end
        end
    end
    
    methods (Static)
        function val = limit(val,min,max)
            if val > max
                val = max;
            else
                if val < min
                    val = min;
                end
            end
        end
        
        function y = vecPerc(x,p)
            % vector percentiles (to avoid the matlab prctile function
            % which requires a statistic toolbox liscense)
            
            % get number of elements in x
            N = numel(x);

            % assure that x is a column vector
            if N ~= size(x,1)                
                warning('asWindowingClass:archChg','can only work on 1D column vectors yet');
                x = x(:);
            end
            
            
            % sort the data
            x = sort(x);
            
            % calculate the percentage rank for each index of the (sorted)
            % x vector
            n = (1:N)'; % (column index)
            pn = 100/N * ( n - 0.5);
            
            % add entries for 0% and 100% to x and pn
            x  = [x(1); x; x(N)];
            pn = [0;   pn;  100];
            
            % derive the interpolated x value for the given percentile
            y = interp1q(pn,x,p);
            
            
        end
    end
end
