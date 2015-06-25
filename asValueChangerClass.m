%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)



classdef asValueChangerClass < handle
    
    properties (GetAccess = private, SetAccess = private)
        
        pos = [0 0 .6 1.6]; % standard position
        % [left bottom width height]
        
        % handles
        pph     = 0;     % parent panel handle
        ph      = 0;     % panel handle
        pbh_up  = 0;     % pushbutton handle 'up'
        pbh_down= 0;     % pushbutton handle 'down'
        eth     = 0;     % edit text handle
        pbh_dim = 0;     % pushbutton handle 'dim'
        cmh     = [];    % context menu handle
        flipCmh = 0;     % flip context menu handle
        lockCmh = 0;     % lock context menu handle
        plotTagCmh=0;    % plot dimension context menu handle
        
        userCb   = '';   % user definde Callback
        id       = 0;    % optional user defined id
        kpf      = '';   % user def keyPressFunction
        
        colonDimTag = 0;  % can be 1, 2 or 0 (deaktivated)
        
        colonDim1Callback = [];
        colonDim2Callback = [];
        plotDimCallback   = [];
        
        stdTextColor     = 'black';
        
        tag0Color = 'black'
        tag1Color = 'blue';
        tag2Color = [205/255;0;0];
        plotDimColor = 'white';
        offsetColor = 'yellow';
        
        considerColon = true;
        enabled = true;
        
        str = '1';   % copy of the string in obj.eth
        
        min     = 1;     % string minimum
        max     = 99;    % standard maximum;
        
        inc = 1; % standard increment for the + and - buttons
        
        offset  = 0;     % constant offset which is added to the selected
        % number (this can be useful when sending an image
        % selection number to other windows with the
        % different numbers of frames
        
        data      = [];    % asDataClass object
    end
    properties (GetAccess = public, SetAccess = private)
        colonStr = ':';
    end
    
    methods
        
        function obj = asValueChangerClass(parentPanelHandle, varargin)
            obj.pph = parentPanelHandle;
            
            % evaluate varagin
            if nargin > 1
                for i=1:floor(length(varargin)/2)
                    option=varargin{i*2-1};
                    option_value=varargin{i*2};
                    switch lower(option)
                        case 'position'
                            obj.pos = option_value;
                        case 'min'
                            obj.min = option_value;
                        case 'max'
                            obj.max = option_value;
                        case 'id'
                            obj.id = option_value;
                        case 'callback'
                            obj.userCb = option_value;
                        case 'keypressfcn'
                            obj.kpf = option_value;
                        case 'considercolon'
                            obj.considerColon = option_value;
                        case 'initstring'
                            obj.str = option_value;
                        case 'contextmenu'
                            obj.cmh = option_value;
                        case 'colondim1callback'
                            obj.colonDim1Callback = option_value;
                        case 'colondim2callback'
                            obj.colonDim2Callback = option_value;
                        case 'plotdimcallback'
                            obj.plotDimCallback = option_value;
                        case 'colondimtag'
                            obj.colonDimTag = option_value;
                        case 'dataobject'
                            obj.data = option_value;
                        otherwise
                            warning('asValueChangerClass:unknownOption',...
                                'unknown option [%s]!\n',option);
                    end
                end
            end
            
            
            % assure init string to be within range
            obj.str = obj.validateStr(obj.str);
            
            % panel
            obj.ph       = uipanel(obj.pph,'Units','centimeters',...
                'BorderType','beveledout',...
                'Position',obj.pos);
            
            
            htmlToolTip = ['<html><b>Data selection control:</b><br>',...
                '(Dimension ',num2str(obj.id),')<br><br><table>',...
                '<tr><td><u>Up arrow</u></td><td>: Increase value</td></tr>',...
                '<tr><td><u>Down arrow</u></td>: Decrease value</td></tr>',...
                '<tr><td><u>PageUp</u></td><td>: Set value to 1</td></tr>',...
                '<tr><td><u>PageDown</u></td><td>: Set value to ''end''</td></tr>',...
                '<tr><td><u>Left arrow</u></td><td>: Select left neighbour</td></tr>',...
                '<tr><td><u>Right arrow</u></td><td>: Select right neighbour</td></tr>',...
                '</table><br><i>Hints:<br>',...
                '- Open <b>context menu</b> to perform operations along this dimension<br>',...
                '- Use the <b>mouse wheel</b> to increase or decrease values',...
                '</html>'];
            
            
            % + button
            obj.pbh_up   = uicontrol(obj.ph,'Style','pushbutton','String','+',...
                'Units','normalized',...
                'Position',[0 3/4 1 1/4 ],...
                'tooltip',htmlToolTip,...
                'KeyPressFcn',@(src, evnt)obj.keyPressCb(src, evnt),...
                'Callback', @(src, evnt)obj.up() );
            
            % text edit field
            obj.eth      = uicontrol(obj.ph,'Style','edit','String',obj.str,...
                'Units','normalized',...
                'Position',[0 2/4 1 1/4],...
                'KeyPressFcn',@(src, evnt)obj.keyPressCb(src, evnt),...
                'Callback',@(src,evnt)obj.cb,...
                'String',obj.str,...
                'ForegroundColor',obj.stdTextColor,...
                'TooltipString',obj.str);
            
            % - button
            obj.pbh_down = uicontrol(obj.ph,'Style','pushbutton','String','-',...
                'Units','normalized',...
                'Position',[0 1/4 1 1/4],...
                'tooltip',htmlToolTip,...
                'KeyPressFcn',@(src, evnt)obj.keyPressCb(src, evnt),...
                'Callback', @(src, evnt)obj.down() );
            
            
            
            % colon dimension button
            vCorr = 0;
            htmlToolTip = ['<html><b>Colon dimension quick toggle:</b><br>',...
                '(Dimension ',num2str(obj.id),', size: ',num2str(obj.max),')<br><br><table>',...
                '<tr><td><font color="blue"><u>Left click</font></u></td><td>: Toggle 1st colon dimension</td></tr>',...
                '<tr><td><font color="red"><u>Right click</font></u></td>: Toggle 2nd colon dimension</td></tr>',...
                '<tr><td><font style="BACKGROUND-COLOR: white"><u>Ctrl+click</FONT></u></td>: Set to plot dimension</td></tr></table>',...
                '<br><p style="width:200px; text-align:justify">',...
                '<i>Description:<br>The <b>''colon dimension''</b> toggle can be used to quickly insert a colon (:) into the selection string of the ',...
                'respective dimension. This can be useful e.g. to switch between orientations ',...
                '(coronal, sagittal, transversal).<br>''Colon dimensions'' are also protected against value changes via mouse wheel.<br><br>',...
                'It is possible to manually put additional colons into other dimension, ',...
                'yielding a <br><b>multiframe view</b>.<br><br>The <b>plot dimension</b> tag is used by several sub functions e.g. ',...
                'to create 1D plots along this dimension (v)',...
                '</i></p></html>'];
            fh = get(obj.pph,'Parent'); % get parent figure handle
            obj.pbh_dim  = uicontrol(obj.ph,'Style','pushbutton','String',obj.str,...
                'Units','normalized',...
                'Position',[0 0/4-vCorr 1 1/4],...
                'String',obj.max,...
                'TooltipString',htmlToolTip,...
                'callback',@(src,evnt)colButtonCb,...
                'ButtonDownFcn', @(src,evnt)obj.setColonDimTag(2));
            function colButtonCb()
                modifiers = get(fh,'currentModifier');
                if isempty(modifiers)
                    obj.setColonDimTag(1);
                else
                    if ismember('control',modifiers)
                        obj.plotDimCallback(obj.id);
                    end
                end
            end
            
            
            switch obj.colonDimTag
                case 1
                    set(obj.pbh_dim,'ForegroundColor',obj.tag1Color);
                case 2
                    set(obj.pbh_dim,'ForegroundColor',obj.tag2Color);
            end
            
            
            % context menu
            if ~isempty(obj.cmh)
                obj.cmh = copyobj(obj.cmh,gcf);
                obj.plotTagCmh = uimenu(obj.cmh,'Label','Set as plot dim'   ,...
                    'callback',@(src,evnt)obj.plotDimCallback(obj.id),...
                    'Position',1);
                obj.lockCmh = uimenu(obj.cmh,'Label','Lock'   ,...
                    'callback',@(src,evnt)lockCb(obj),...
                    'Position',2);

                uimenu(obj.cmh,'Label','Set offset'   ,...
                    'callback',@(src,evnt)obj.setOffset(),...
                    'Position',3, 'Separator','on');                
                uimenu(obj.cmh,'Label','Set increment'   ,...
                    'callback',@(src,evnt)obj.setIncrement(),...
                    'Position',4);                

                
                % navigation
                uimenu(obj.cmh,'Label','Set to ''1'' (page up)'   ,...
                    'callback',@(src,evnt)obj.setStr('1',true),...
                    'Position',5,...
                    'Separator','on');
                uimenu(obj.cmh,'Label','Set to ''end'' (page down)'   ,...
                    'callback',@(src,evnt)obj.setStr('end',true),...
                    'Position',6);
                
                
                obj.flipCmh = uimenu(obj.cmh,'Label','Flip subscripts'   ,...
                    'callback',@(src,evnt)obj.flipsubs(),...
                    'Position',7);
                
                % destructive operations
                uimenu(obj.cmh,'Label',['Flip dimension ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.flipDim(obj.id),...
                    'Position',8);
                uimenu(obj.cmh,'Label',['Crop dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.cropDim(obj.id),...
                    'Position',9);
                
                % fft / ifft / fftshift
                uimenu(obj.cmh,'Label',['FFT dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.fftDim(obj.id),...
                    'Position',10,'Separator','on');
                uimenu(obj.cmh,'Label',['iFFT dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.ifftDim(obj.id),...
                    'Position',11);
                uimenu(obj.cmh,'Label',['FFTshift dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.fftshift(obj.id),...
                    'Position',12);
                
                % min, max etc...
                uimenu(obj.cmh,'Label',['Max dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.max(obj.id),...
                    'Position',13,'Separator','on');
                uimenu(obj.cmh,'Label',['Min dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.min(obj.id),...
                    'Position',14);
                uimenu(obj.cmh,'Label',['Sum dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.sum(obj.id),...
                    'Position',15);
                uimenu(obj.cmh,'Label',['Mean dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.mean(obj.id),...
                    'Position',16);
                uimenu(obj.cmh,'Label',['Product dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.prod(obj.id),...
                    'Position',17);
                
                
                % common MRI coil combination methods
                uimenu(obj.cmh,'Label',['Root sum squares dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.sumSqr(obj.id),...
                    'Position',18,'Separator','on');
                uimenu(obj.cmh,'Label',['Coil combine dim ', num2str(obj.id),' (SLOW!,destructive)'] ,...
                    'callback',@(src,evnt)obj.data.coilCombine(obj.id),...
                    'Position',19);
                
                
                set(obj.pbh_up,'uicontextmenu',obj.cmh);
                set(obj.pbh_down,'uicontextmenu',obj.cmh);
                set(obj.eth,'uicontextmenu',obj.cmh);
            end
            
            % lock context menu callback
            function lockCb(obj)
                onOffState = get(obj.lockCmh,'Label');
                switch onOffState
                    case 'Lock'
                        % change context menu entry label to "Unlock"
                        set(obj.lockCmh,'Label','Unlock')
                        
                        % disable value changer
                        obj.enable(false);
                        
                        %...but re-enable the lock button in the context
                        %menu
                        %                         set(obj.cmh,'Visible','on');
                        set(obj.lockCmh,'Visible','on');
                        
                    case 'Unlock'
                        % change context menu entry label to "Lock"
                        set(obj.lockCmh,'Label','Lock')
                        
                        % (re-) enable value changer
                        obj.enable(true);
                        
                    otherwise
                        %nop
                end
            end
            
            
        end
        
        function setIncrement(obj, inc)
            % set the standard increment for the up and down functions
            % (and the + and - buttons)

            % if no increment is give, open input dialog
            if nargin < 2
                inc = mydlg('Enter increment','Increment input dlg',obj.inc);
                if isempty(inc) 
                    return; 
                end
                inc = str2double(inc);
            end
            
            if ~isscalar(inc)
                fprintf('Increment has to be a scalar value\n');
                return;
            end
            
            if inc == 0                
                inc = 1;
                %...since 0 doesn't make much sense                
            end
            
            obj.inc = inc;
            
            if inc == 1
                incStr = '';
            else                
                incStr = num2str(inc);
            end
            set(obj.pbh_up,'String',['+',incStr]);
            set(obj.pbh_down,'String',['-',incStr]);                            
        end
        
        function inc = getIncrement(obj)
            inc = obj.inc;
        end
        
        function up(obj)
            if obj.enabled
                num = obj.str2validNum(get(obj.eth,'String'));
                newNum = num + obj.inc;
                if newNum > obj.max || newNum < obj.min
                    return;
                end
                obj.setStrForce(num2str(newNum));                
                obj.runUserCb;
            end
        end
        
        function down(obj)
            if obj.enabled
                num = obj.str2validNum(get(obj.eth,'String'));
                newNum = num - obj.inc;
                if newNum > obj.max || newNum < obj.min
                    return;
                end                
                obj.setStrForce(num2str(newNum));
                obj.runUserCb;
            end
        end
        
        function setColonDimTag(obj, tag, suppressCallback)
            % colon dimension tag marks value changer dimension as one of the image
            % axis dimensions. A colon dimension does not change it's value on 'up' and 'down' method calls.
            % Valid tags are:
            %   0 : dimension is NOT a colon dimension
            %   1 : dimendion is colon dimension 1
            %   2 : dimendion is colon dimension 2
            
            if obj.enabled
                if nargin < 3
                    suppressCallback = false;
                end
                if obj.colonDimTag == tag
                    if tag ~= 0
                        obj.setColonDimTag(0);
                    end
                else
                    
                    obj.colonDimTag = tag;
                    switch tag
                        case 1
                            obj.setOffset(0, false);  % deactivate possible previous offsets                           
                            set(obj.pbh_dim,'ForegroundColor',obj.tag1Color); % set the text color
                            obj.colonDim1Callback(obj.id);  % tell the asSelection class about the change, so that it can deactivate the previous colon dim. 
                            obj.setStrForce(obj.colonStr);
                        case 2
                            obj.setOffset(0, false);  % deactivate possible previous offsets                           
                            set(obj.pbh_dim,'ForegroundColor',obj.tag2Color); % set the text color
                            obj.colonDim2Callback(obj.id); % tell the asSelection class about the change, so that it can deactivate the previous colon dim. 
                            obj.setStrForce(obj.colonStr);
                        case 0
                            set(obj.pbh_dim,'ForegroundColor',obj.tag0Color);
                            if strcmp(obj.getStr,obj.colonStr)
                                obj.setStrForce(num2str(ceil(obj.max/2)));
                            end
                        otherwise
                            disp('invalid tag number');
                    end
                    
                    if ~suppressCallback
                        obj.runUserCb;
                    end
                end
            end
        end
        
        function setPlotDimTag(obj, value)
            switch value
                case true
                    set(obj.plotTagCmh,'checked','on');
                    %                     set(obj.eth,'ForegroundColor',obj.stdTextColor)
                    set(obj.pbh_dim,'BackgroundColor',obj.plotDimColor)
                case false
                    set(obj.plotTagCmh,'checked','off');
                    %                     set(obj.eth,'ForegroundColor',obj.stdTextColor)
                    set(obj.pbh_dim,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'))
            end
        end
        
        function tag = getPlotDimTag(obj)
            switch(get(obj.plotTagCmh,'checked'))
                case 'on'
                    tag = true;
                case 'off'
                    tag = false;
            end
        end
        
        function id = getId(obj)
            id = obj.id;
        end
        
        function tag = getColonDimTag(obj)
            tag = obj.colonDimTag;
        end
        
        function str = getStr(obj, includeOffset)            
            if nargin < 2
                includeOffset = true;
            end
            
            if obj.offset == 0 || ~includeOffset
                str = obj.str;
            else
                num = str2double(obj.str);
                num = num+obj.offset;
                str = num2str(num);
            end
        end
        
        function setOffset(obj, offs, runUserCb)
            % usage: setOffset(obj, offs, runUserCb)
            % Allows to add a constant offset to the value changer
            % (this can be useful when sending an image
            % selection number to other windows with the
            % different numbers of resolution or FOV)
            
            % run "userCb (meaning updateFig) by default (I should change
            % the naming some day. The term "userCb" was choosen before
            % everything became arrayShow specific anyway)
            if nargin < 3 || isempty(runUserCb)
                runUserCb = true;
            end
            
            % if no offset is give, open input dialog
            if nargin < 2
                offs = mydlg('Enter offset','Offset input dlg',obj.offset);
                if isempty(offs) 
                    return; 
                end
                offs = str2double(offs);
            end                
           
            % if the offset is 0, set background color of the edit text field to default
            if isempty(offs) || offs == 0
                set(obj.eth,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));                
            else
                % else, change the color
                set(obj.eth,'backgroundcolor',obj.offsetColor);                
            end
            
            % adapt the value changer limits
            obj.min = 1 - offs;
            obj.max = str2double(get(obj.pbh_dim,'String')) - offs;                        
            
            % if the dimension is a colon dim and the offset is 0...
            if obj.getColonDimTag > 0 && offs == 0
                % store the new offset in the object properties and just
                % return
                obj.offset = offs;                
                return;
            end
            
            % ...otherwise adapt the selected value to match the same frame
            % considering the offset (if the dim is a colon dim, we just select the first frame)...
            
            % get the current selection string considering the old offset
            origSelStr = obj.getStr(true);                
            
            % add the offset to the value in the string (to keep the
            % actually selected frame constant)
            origSel = str2double(origSelStr);
            if isnan(origSel);
                % if the current selection cannot be transformed into a
                % double, just address the first frame by default
                newSel = 1 - offs;
            else
                newSel = origSel - offs;
            end
            
            % store the new offset in the object properties
            % (this has to be done AFTER the obj.getStr command above,
            % since getStr already consideres the obj.offset property)
            obj.offset = offs;                
           
            % set the new value to the edit text field
            obj.setStr(newSel, runUserCb);            
        end
        
        function offs = getOffset(obj)
            offs = obj.offset;
        end
        
        function setStr(obj, str, runCallback)
            if obj.enabled
                vStr = obj.validateStr(str);
                if obj.getColonDimTag && ~strcmp(vStr,obj.colonStr)
                    obj.setColonDimTag(0,true);
                end
                obj.setStrForce(vStr);
                if nargin > 2 && runCallback == true
                    obj.runUserCb();
                end
            end
        end
        
        function pos = getPos(obj)
            pos = obj.pos;
        end
        
        function ph = getPanelH(obj)
            ph = obj.ph;
        end
        
        function mi = getMin(obj)
            mi = obj.min;
        end
        
        function ma = getMax(obj)
            ma = obj.max;
        end
        
        function flipsubs(obj, suppressCallback)
            if obj.enabled
                if nargin < 2
                    suppressCallback = false;
                end
                flipToggle = ~obj.getFlipToggle;
                if(flipToggle)
                    obj.colonStr = 'end:-1:1';
                    set(obj.flipCmh,'Checked','on');
                else
                    obj.colonStr = ':';
                    set(obj.flipCmh,'Checked','off');
                end
                if obj.colonDimTag > 0
                    obj.setStrForce(obj.colonStr);
                    if ~suppressCallback
                        obj.runUserCb;
                    end
                end
            end
        end
        
        function select(obj)
            if obj.enabled
                % focus the edit text uicontrol
                uicontrol(obj.eth);
            end
        end
        
        function toggle = getFlipToggle(obj)
            toggle = false;
            tstr = get(obj.flipCmh,'Checked');
            if strcmp(tstr,'on')
                toggle = true;
            end
        end
        
        function bool = isSelected(obj)
            bool = false;
            selectedUihandle = get(get(obj.pph,'Parent'),'CurrentObject');
            if selectedUihandle == obj.eth
                bool = true;
            end
        end
        
        function enable(obj, state)
            obj.enabled = state;
            onOff = arrShow.boolToOnOff(state);
            set(obj.pbh_up,'Enable',onOff);
            set(obj.pbh_down,'Enable',onOff);
            set(obj.eth,'Enable',onOff);
            %             set(obj.eth,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
            set(obj.pbh_dim,'Enable',onOff);
            %             set(obj.cmh,'Visible',onOff);
            set(get(obj.cmh,'Children'),'Visible',onOff);
        end
        
        function delete(obj, deletePanel)
            if nargin > 1 && deletePanel == true
                if ishandle(obj.ph)
                    delete(obj.ph);
                end
            end
        end
    end
    
    methods (Access = private)
        
        function setStrForce(obj, str)
            % sets string without validity check
            obj.str = str;
            set(obj.eth,'String',obj.str);
            if obj.offset
                trueValStr = num2str( str2double(obj.str) + obj.offset);
                if obj.offset > 0                    
                    ttstr = [obj.str, ' + ', num2str(obj.offset), ' = ', trueValStr];
                else
                    ttstr = [obj.str, ' - ', num2str(abs(obj.offset)), ' = ', trueValStr];
                end
                set(obj.eth,'TooltipString',ttstr);
            else
                set(obj.eth,'TooltipString',obj.str);
            end
        end
        
        function runUserCb(obj)
            if ~isempty(obj.userCb)
                cb = obj.userCb;
                cb(obj.id);
            end
        end
        
        function vStr = validateStr(obj,str)
            
            % check if the string contains 'cnt' (center)
            cntPos = findstr(str,'cnt');
            if cntPos > 0
                % replace 'cnt' by max/2
                str1 = str(1:cntPos-1);
                str2 = str(cntPos+3:end);
                str = [str1, num2str(floor(obj.max/2)),str2];
            end
            
            % check if the string contains 'end'
            endPos = findstr(str,'end');
            if endPos > 0
                % replace 'end' by max
                str1 = str(1:endPos-1);
                str2 = str(endPos+3:end);
                str = [str1, num2str(obj.max),str2];
            end
            
            
            % check if the string contains '/'
            slPos = findstr(str,'/');
            if slPos > 0
                if obj.offset
                    % offsets are not yet allowed for address ranges
                    fprintf('Deactivating selection offset.\n');
                    obj.setOffset(0,false);
                end

                %take string after the slash as divisor
                divi = -1;
                try
                    divi = str2double(str(slPos + 1 : end));
                catch me
                    fprintf('invalid string format\n');
                end
                
                if divi > 0
                    inBlock = ceil(obj.max / divi);
                    outBlock = floor((obj.max - inBlock) / 2);
                    vStr = [num2str(outBlock + 1),':',num2str(outBlock + inBlock)];
                else
                    vStr = num2str(obj.str2validNum(str));
                end
                return;
            end
            
            
            
            % check if the string contains a colon
            colPos = findstr(str,':');
            
            if isempty(colPos)
                % we have no colon at all...
                vStr = num2str(obj.str2validNum(str));
            else            
                if obj.offset
                    % offsets are not yet allowed for address ranges
                    fprintf('Deactivating selection offset.\n');
                    obj.setOffset(0,false);
                end
                if length(colPos) > 1 % we have more than one colon in the string

                    % no proper check implemented yet... so drop a warning if
                    % this is a colon dimension
                    if obj.colonDimTag > 0
                        warning('asValueChangerClass:validateString',...
                            'multiple colons in selection string might result in wrong interpretation of the cursor position');
                    end
                    vStr = str;


                else    % we have one colon in the string

                    if colPos == 1 && length(str) == colPos(1)
                        % if there's no number in front or behind the colon,
                        %   just return one colon.
                        vStr = ':';

                    else
                        if colPos > 1
                            % devide string in substrings before and after the
                            % colon
                            str1 = str(   1        : colPos - 1);
                            str2 = str( colPos + 1 : end       );

                            num1 = obj.str2validNum(str1);

                            num2 = obj.str2validNum(str2);
                            if num1 < num2
                                vStr = strcat(num2str(num1), ':', num2str(num2));
                            else
                                vStr = num2str(num1);
                            end
                        end
                    end                                    
                end
            end                        
        end
        
        function nr = str2validNum(obj, value)
            % check, if the value is a number
            if isnumeric(value)
                nr = value;
            else
                % try to extract a valid number from string
                nr = str2double(value);
                if isempty(nr) || length(nr) > 1 || isnan(nr)
                    % if the conversion fails, return the object's minimum number
                    nr = obj.min;
                    return
                end
                
            end
            
            % check, if the number is within object's validity range...
            % If not, return the limits respectively
            if nr > obj.max
                nr = obj.max;
            else
                if nr < obj.min;
                    nr = obj.min;
                end
            end
        end
        
        function cb(obj)
            % standard callback for the editText uiobject
            obj.setStrForce(obj.validateStr(get(obj.eth,'String')));
            obj.runUserCb;
        end
        
        function keyPressCb(obj,src, evnt)
            
            switch evnt.Key
                case 'uparrow'
                    obj.up;
                case 'downarrow'
                    obj.down;
                case 'pageup'
                    obj.setStrForce(num2str(obj.min));
                    obj.runUserCb;
                case 'pagedown'
                    obj.setStrForce(num2str(obj.max));
                    obj.runUserCb;
            end
            
            if ~isempty(obj.kpf) % execute user defined keyPressCallback
                fun = obj.kpf;
                fun(src, evnt);
            end
        end
        
    end
    
end