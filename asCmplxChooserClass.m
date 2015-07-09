%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)

classdef asCmplxChooserClass < handle
    
    properties (GetAccess = private, SetAccess = private)       
        ph                  = 0;            % panel handle
        sendButtonH         = [];

        ddmh                = 0;            % dropdownmenu handle
        
        updFigCb            = '';           
        apply2allCb         = [];           % send to all relatives callback
        cmh                 = struct;       % context menu handle
        
        phaseRepr = 1;  % 1 = show phase in degrees,
                        % 2 = show phase in radiants

        selectionValue = []; % this property is (...should be) always equal 
                             % to "get(obj.ddmh,'Value')" and allows for 
                             % recovering the value even if the according 
                             % UI has been deleted. This can be necessary
                             % when rebuilding an asObj which has been
                             % previously stored by the matlab save command
                        
        enabled    = true;
        
        iscomplex  = true;

    end
    properties (Constant)
        ALL_STATES  = {'Abs','Re','Im','Com','Pha'};
        ALL_STATES_FULL  = {'Magnitude','Real','Imaginary','Complex','Phase'};
        
        REAL_TEXT   = {'Magnitude (m)','Real (r)'};
        CPLX_TEXT   = {'Magnitude (m)','Real (r)','Imaginary (i)','Complex (M)','Phase (p)'};        
    end
    
    properties (GetAccess = public, SetAccess = private)        
        % context menu toggles which can be read from the outside
        sendToggleState = false;
    end
    
    methods
        function obj = asCmplxChooserClass(...
                parentPanel,...
                updFigCb,...
                apply2allCb,...
                sendIcon)
            
            obj.apply2allCb = apply2allCb;
            obj.updFigCb    = updFigCb;                                           
            obj.ph = parentPanel;
            
            % create send button
            obj.sendButtonH = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.85,0,.15,.31],...
                'tooltip','Send selection to relatives',...
                'Callback',@(src,evnt)obj.toggleSend2all(),...
                'CData',sendIcon);
            
            % create dropdown menu
            obj.ddmh = uicontrol('Style','popupmenu','String',obj.CPLX_TEXT,...
                'Units','normalized','pos',[0. -.04 .85 .34],'parent',obj.ph,'HandleVisibility','off',...
                 'Callback',@(src,evnt)obj.stateChangeCb(false));
            
            % select 'complex' per default            
            set(obj.ddmh,'Value',4);
            obj.selectionValue = 4;
             
            % context menu -----------
            obj.cmh.base    = uicontextmenu;
            obj.cmh.send2all = uimenu(obj.cmh.base,'Label','Send selection to relatives' ,...
                'Checked','off',...
                'callback',@(src,evnt)obj.toggleSend2all);            
            obj.cmh.degrees = uimenu(obj.cmh.base,'Label','Represent phase in degrees' ,...
                'Checked','on','Separator','on',...
                'callback',@(src,evnt)obj.togglePhaseRepresentationCb(src));
            obj.cmh.radiants= uimenu(obj.cmh.base,'Label','Represent phase in radiants' ,...
                'Checked','off',...
                'callback',@(src,evnt)obj.togglePhaseRepresentationCb(src));
            
            % assign context menu to the dropdown menu and the parent panel            
            set(obj.ddmh,'uicontextmenu',obj.cmh.base);
            set(obj.ph,'uicontextmenu',obj.cmh.base);                                    
            
        end
        
        
        function sel = getSelection(obj, returnType)
            % get selected complex part
            % return type can be:
            %   1 (default) : a string with the standard abbreviation of
            %                 the complex parts (Abs, Re, Im,...)
            %   2           : a string with the full name of the complex
            %                 part (Magnitude, Real, Imaginary...)
            %   3           : a number corresponding to the part
            %                 (1 = Abs, 2 = Re, 3 = Im, 4 = Com, 5 = Pha)
            if nargin < 2
                returnType = 1;
            end
            if ishandle(obj.ddmh)
                % get selected value from dropdown menu
                v = get(obj.ddmh,'Value');
            else
                % restore selection from this object's property
                v = obj.selectionValue;
            end
            
            switch returnType
                case 1
                    % return the according (abbreviated human readable) state string
                    sel = obj.ALL_STATES{v};                                    
                case 2
                    % return the according (human readable) state string
                    sel = obj.ALL_STATES_FULL{v};                                    
                case 3
                    sel = v;                    
            end
                    
                    
        end        
                
        function togglePhaseRepresentationCb(obj, src)
            if obj.enabled
            switch(src)
                case obj.cmh.degrees
                    obj.setPhaseToDegrees();
                case obj.cmh.radiants
                    obj.setPhaseToRadiants();
            end
            end
        end
        
        function setPhaseToDegrees(obj)
            if obj.enabled
            obj.phaseRepr = 1;
            set(obj.cmh.degrees,'Checked','on');
            set(obj.cmh.radiants,'Checked','off');
            obj.updFigCb();
            end
        end
        
        function setPhaseToRadiants(obj)
            if obj.enabled
            obj.phaseRepr = 2;
            set(obj.cmh.degrees,'Checked','off');
            set(obj.cmh.radiants,'Checked','on');
            obj.updFigCb();
            end
        end
        
        function focus(obj)           
            % enables the uicontrol
            % (this was written to put the focus away from the selection
            % class at initialization of arrShow objects. As a result, key
            % press calbacks can be evaluated without initial mouseclick on
            % the figure window)
            if obj.enabled
                uicontrol(obj.ddmh);
            end
        end
            
        function fun = getFunPointer(obj)
            sel = obj.getSelection;
            switch sel
                case 'Abs'
                    fun = @abs;
                case 'Re'
                    fun = @real;
                case 'Im'
                    fun = @imag;
                case 'Pha'
                    if obj.phaseRepr == 1
                        fun = @myAngle;
                    else
                        fun = @angle;
                    end
                case 'Com'
                    fun = @mynop;
            end
            function y = myAngle(x)
                y = angle(x) * 180 / pi;
            end
            function x = mynop(x)
            end
        end
        
        function ph = getPanelHandle(obj)
            ph = obj.ph;
        end
        
        function setSelection(obj, str, suppressUpdFigCb, sendToRelatives)
            if obj.enabled
                if nargin < 4
                    sendToRelatives = obj.sendToggleState;
                    if nargin < 3
                        suppressUpdFigCb = false;
                    end
                end
            
            switch lower(str)
                case {'magnitude','mag','abs','a','m'}
                    set(obj.ddmh,'Value',1);
                case {'real','re','r'}
                    set(obj.ddmh,'Value',2);
                case {'imaginary','im','ima','imag','i'}
                    if obj.iscomplex
                        set(obj.ddmh,'Value',3);                    
                    end
                case {'complex','cplx','com','c'}
                    if obj.iscomplex                    
                        set(obj.ddmh,'Value',4);                    
                    end
                case {'phase','pha','p'}
                    if obj.iscomplex                    
                        set(obj.ddmh,'Value',5);
                    end
            end
                        
            obj.stateChangeCb(suppressUpdFigCb, sendToRelatives);
            end
        end               
        
        function lockImagAndPhase(obj, suppressCallback)
            if obj.enabled
            if nargin < 2
                suppressCallback = true;
            end
            obj.iscomplex = false;            
            switch obj.getSelection
                case {'Im','Pha','Com'}
                    obj.setSelection('Re', suppressCallback);
            end
            set(obj.ddmh,'String',obj.REAL_TEXT);
            end
        end
        
        function unlockImagAndPhase(obj)   
            if obj.enabled
            obj.iscomplex = true;            
            set(obj.ddmh,'String',obj.CPLX_TEXT);
            end
        end
        
        function toggleSend2all(obj,bool)
            if obj.enabled               
                if nargin > 1
                    set(obj.cmh.send2all,'Checked',arrShow.boolToOnOff(~bool));
                end
                switch get(obj.cmh.send2all,'Checked')
                    case 'off'
                        obj.sendToggleState = true;
                        set(obj.cmh.send2all,'Checked','on');
                        set(obj.sendButtonH,'Value',1);
                        obj.stateChangeCb(true);
                    case 'on'
                        obj.sendToggleState = false;
                        set(obj.cmh.send2all,'Checked','off');
                        set(obj.sendButtonH,'Value',0);
                end
            end
        end
        
        function enable(obj,state)
            obj.enabled = state;
            onOff = arrShow.boolToOnOff(state);
            set(obj.ddmh,'enable',onOff);
            set(obj.sendButtonH,'enable',onOff);
        end

% defining this delete functions didn't seem to bee a good idea. Apparently
% it dometimes happens, that an orphaned object is deleted which then might
% destroy panelhandles which are still in use...
%         function delete(obj)
%             if ishandle(obj.ph)
%                 delete(obj.ph);
%             end
%             clear obj;
%         end
                
    end
    methods (Access = private)
        function stateChangeCb(obj, suppressUpdFigCb, sendToRelatives)        
            if nargin < 3
                sendToRelatives = obj.sendToggleState;
            end
            
            % backup the selection in the local property
            obj.selectionValue = get(obj.ddmh,'Value');
            
            if nargin < 2 || suppressUpdFigCb == false
                % run update figure callback
                obj.updFigCb();
            end

            if sendToRelatives
                sel = obj.getSelection;
                obj.apply2allCb('complexSelect.setSelection', false,  sel, false, false);
            end
            
        end
    end
end
