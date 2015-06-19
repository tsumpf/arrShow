% arrShow Image viewer.
% obj = arrShow(imageArray) displays the image in imageArray in an arrayShow GUI
% and returns an instance of the arrShow class. Most properties of the GUI
% (image contrast, cursor position, ROI ...) can also be created and controlled
% by object methods, e.g. obj.createRoi(roiPos); or obj.window.setCW([center, width]);
%
% Hint: don't call the arrShow constructor directly but use the function
% "as" instead. All arrayShow instances are hereby collected in a global
% workspace array "asObjs" which can be used e.g. for batch tasks.
%
% ------------------------------------------------------------------------
%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef arrShow < handle
    
    properties (Access = public)
        data            = [];               % object containing the data and data operations
        selection       = [];               % asSelectionClass object containing the valueChanger array
        complexSelect   = [];               % cmplxChooser object
        statistics      = [];               % image statistics object
        cursor          = [];               % cursor position object
        infotext        = [];               % info text object
        window          = [];               % image windowing object
        roi             = [];               % region of interest object
        imageText       = [];               % image text object
        markers         = [];               % pixel markers
        
        UserData        = [];               % this is not used within this class
        % and may be set and
        % changed for arbitrary purpose
    end
    
    
    properties (Access = protected)
        
        % debug messeges
        %         msg = @fprintf;                    % use fprintf for debugging
        msg = @nop;                         % use nop as default
        
        % icons
        icons = [];                         % asIcon class
        
        % main figure
        fh              = 0;                % main figure handle
        title           = '';               % main figure title
        figurePosition  = [];               % main figure position
        
        userCallback = [];                  % callback is executed at the end of updFig,
        % e.g. when the selected image or
        % selected complex part has changed
        
        linkedToWorkspaceArray  = false;    % is (automatically) set to true if input array is a variable in workspace
        % (rather than e.g. a variable in the debugger, or the result of an operation
        % as in e.g. "as(a + b)"). If linked to workspace array, this array can be reloaded
        % and updated by clicking the according buttons within the arrShow main window.
        workspaceArrayName      = '';       % name of the input array in workspace (will be set automatically)
        
        arrShowPath = '';                   % root path of the arrShowClass
        cMapStdPath = '';                   % standard path for colormaps
        
        fcmh    = struct;                   % struct of figure context menu handle
        
        fph     = 0;                        % figure panel handle
        bph     = 0;                        % bottom panal handle
        cph     = 0 ;                       % control panel handle
        cpcmh   = struct;                   % control panel context menu handle
        mbh     = struct;                   % menu bar handle
        tbh     = struct;                   % tool bar handle
        
        ih   = [];                          % image handle
        %  (this is an array of N handles, if we display
        %    N images)
        
        fp_height = 0;                      % the figure panel height is usually set to the constant
        % variable FP_MAX_HEIGHT.
        % However, for small screens it
        % might have to be set to a
        % smaller value
        
        postProcFun = [];                   % postprocessing function handle
        

        mouseMovementMode            = 0;  % behaviour on mouse movements:
                                           % 0 : just update the cursorPositionClass
                                           % 1 : mouse windowing mode
                                           % 2 : dragging mode                

        mouseReferencePoint = [];          % reference point for mouse windowing or dragging
        
        buttonUpCbTime = uint64(0);        % Workaround: if a mouse click changes the focus
        % of different uiObjects, apparently the mouseUp callback is sometimes called prior the 
        % mouseDown callback. I guess the reason is, that the up-callback is called more or less
        % directly, whereas the down-callback is called after the
        % window manager has finished all its focus operations... However:
        % The manual check of the callback time is a workaround for simetimes 'jammed'
        % dragging operations.
        
        mouse_wheel_zoom_factor = 1.5;      % default zoom factor per mouse wheel step
        
        processingCallback           = false;
        
        forceComplexRepresentation = true;  % use phase overlay in complex mode even if imaginary part
        % of the frame is zero at every point
        
        relatives     = [];                 % list of other arrShow objects in current environment
        noRelatives   = 0;                  % number of relatives
        useGlobalArray= false;              % if the "useGlobalArray" toggle
        % is set to true, no individual relatives list is populated within this object and
        % a global workspace array "asObjs" is used instead.
        
        sendWdwSize         = false;        % send main figure window size to relatives
        titleAsImageText    = false;        % draw the title as a text within the images
        
        saveInfosAtImageExport      = true; % if true, a description text file is created when exporting images (containing dinensions, norm, i.e.)
        
        
        playAlongDim  = false;  % this is set to true if the play button has been pressed
        framerate = 50;         % Standard framerate for the play function.
        % Note: the framerate setting
        % currently does not consider
        % the execution time of updFig and is thus not precise.
        % The actual framerate can be assumed to
        % be lower.
        
        
        stdColormap     = 'Gray(256)';         % standard colormap
        phaseColormap   = 'martin_phase(256)'; % standard colormap for phase display
        
        stdCmapMightBeModified = false;     % The matlab colormapeditor allows for altering the colormap
        phaCmapMightBeModified = false;     % even after the actual command 'colormapeditor' has already returned.
        % The 'cmapMightBeModified' workaround causes
        % arrayShow to retrieve the potentially modified colormap from the
        % figure handle during updFig.
    end
    
    properties (Constant, GetAccess = private)
        % image export presets
        RESIZE_AXES_FOR_SCREENSHOTS = false;
        
        % panel positions
        CMPLX_SEL_POS  = [5/6, 0, 1/6, 1]; % relative position and size of the complexSelector in the top Panel
        STATISTICS_POS = [4/6, 0, 1/6, 1]; % relative position and size of the statistics in the top Panel
        INFOTEXT_POS   = [2/6, 0, 1/6, 1]; % ...
        WINDOWING_POS  = [3/6, 0, 1/6, 1];
        
        % sizes
        CP_HEIGHT = 2.2;      % fixed height for the controlPanel (in centimeters)
        BP_HEIGHT = .5;       % fixed height for the bottom panel (in centimeters)
        FP_MAX_HEIGHT = 18;   % desired height for the figurePanel (in centimeters)
        % (for small screens, the actual fp_height
        % might be smaller)
        
        % marker colors
        MARKER_COL_PHA = 'white';  % default marker color for phase representations
        MARKER_COL_REAL= 'yellow'; % default marker color for real valued images
    end
    
    properties (Access = private);
        updFigCount = 0;    % counter for updateFig calls for
                            % debugging and speed improvements
        
        processingError = false; % if an error in the data is detected during 
                                 % updFig, the function can be restarted
                                 % with new values and this flag set to
                                 % true. The flag is a quick and dirty workaround 
                                 % to avoid endless loops if an error
                                 % persists in a second updFig call
    end
    
    properties (Constant, GetAccess = public)
        % arrShow version
        VERSION = 0.34;
    end
    
    %#ok<*FPARK>
    % Deactivate the warning telling me that I should use textscan instead
    % of strread... I like strread. I'll change it if I feel like having
    % too much time...
    
    methods (Access = public)
        function obj = arrShow(arr, varargin)
            
            % evaluate varagin
            CW = [];
            userFigurePosition = [];
            selectionOffset = [];
            selectedImageStr = '';
            pixMarkers = [];
            imageTextVal = [];
            initComplexSelect = [];
            infoText = '';
            renderUi = true;
            if nargin > 1
                if length(varargin) ==1
                    obj.title = varargin{1};
                    if strcmp(obj.title,inputname(1))
                        obj.workspaceArrayName = inputname(1);
                        obj.linkedToWorkspaceArray = true;
                    end
                end
                for i = 1 : floor(length(varargin)/2)
                    option       = varargin{i*2-1};
                    option_value = varargin{i*2};
                    
                    switch lower(option)
                        case 'title'
                            obj.title        = option_value;
                        case 'info'
                            infoText         = option_value;
                        case {'imagetext', 'imgtxt'}
                            imageTextVal        = option_value;
                        case {'windowing','window','wdw'}
                            CW = option_value;
                        case 'select'
                            selectedImageStr = option_value;
                        case 'complexselect'
                            initComplexSelect = option_value;
                        case {'colormap', 'stdcolormap'}
                            obj.stdColormap = option_value;
                        case 'phasecolormap'
                            obj.phaseColormap = option_value;
                        case {'position','pos'}
                            userFigurePosition = option_value;
                        case 'inputname'
                            if isempty(obj.title)
                                obj.title = option_value;
                            end
                            if ~isempty(option_value)
                                obj.workspaceArrayName = option_value;
                                obj.linkedToWorkspaceArray = true;
                            end
                        case {'callback','cb'}
                            obj.userCallback =  option_value;
                        case 'useglobalarray'
                            obj.useGlobalArray = option_value;
                        case 'renderui' % this option has been introduced
                            % to initialize an arrShow object without
                            % drawing the actual ui elements. This is
                            % currently used to create temporary object 
                            % copies which are saveable in matlab >= 2014b
                            renderUi = option_value;                            
                        case 'offset' % offset to the asSelection class
                            selectionOffset = option_value;                            
                        case 'markers' % pixel markers
                            pixMarkers = option_value;
                            
                        otherwise
                            error('arrShow:varargin','unknown option [%s]!\n',option);
                    end;
                end;
                clear('option','option_value');
                clear('varargin');
                % If we don't explicitly delete it here,
                % the varargin is stored within the
                % object, wasting memory                
            end
            
            % assure that all support function paths are registered
            arrShow.checkPath();
            
            % initialize the asData object (which also performs some
            % initial data validity tests)
            obj.data = asDataClass(arr, @obj.updFig);
            si       = size(obj.data.dat);            
            
            % store standard paths
            obj.arrShowPath = fileparts(mfilename('fullpath'));
            obj.cMapStdPath = [obj.arrShowPath, filesep, 'customColormaps'];
            iconPath    = [obj.arrShowPath, filesep, 'icons'];
            
            % load icons
            obj.icons = asIconClass.getInstance(iconPath);
            
            % create main figure
            fpos = obj.deriveFigurePos();
            obj.fh     = figure('Units','centimeters',...
                'Resize','on',...  % it's tempting to set this to off during initialization. However, this can cause problems with certain linux window managers
                'Position',fpos,...
                'KeyPressFcn',@(src,evnt)obj.keyPressCb(evnt),...
                'CloseRequestFcn',@(src,evnt)obj.closeReq(src),...
                'WindowButtonMotionFcn',@(src, evnt)obj.mouseMovementCb,...
                'WindowButtonDownFcn',@obj.buttonDownCb,...
                'WindowButtonUpFcn',@(src,evnt)obj.buttonUpCb(src),...
                'WindowScrollWheelFcn',@obj.scollWheelCb,...
                'MenuBar','none',...
                'toolbar','none',...
                'Visible','off',...
                'Tag','arrShowFig',...
                'IntegerHandle','on');
            
            set(obj.fh,'UserData',obj)  % link this object to main figure
            
            % set title
            if ~isempty(obj.title)
                set(obj.fh,'Name',obj.title);
            end
            
            % change figure icon :-)
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jframe=get(obj.fh,'javaframe');
            jIcon=javax.swing.ImageIcon(fullfile(iconPath,'figure.png'));
            jframe.setFigureIcon(jIcon);
            clear jframe jIcon
            
            % init menu- and toolbar
            obj.initMenuBar();
            obj.initToolBar();
            
            % shortcuts to some dimensions
            fphe = obj.fp_height; % figure panel height
            cphe = obj.CP_HEIGHT; % control panel (top panel) height
            bphe = obj.BP_HEIGHT; % bottom panel height
            
            % control panel
            obj.cph  = uipanel(obj.fh,'Units','centimeters',...
                'Position',[0, fphe + bphe, fpos(3), cphe],...
                'Interruptible','off',...
                'BorderType','none',...
                'BusyAction','cancel',...
                'Tag','asControlPanel');
            set(obj.cph,'Units','normalized');
            
            % bottom panel
            obj.bph  = uipanel(obj.fh,'Units','centimeters',...
                'Position',[0, 0, fpos(3), bphe],...
                'Interruptible','off',...
                'BusyAction','cancel' ,...
                'BorderType','none',...
                'Tag','asBottomPanel');
            set(obj.bph,'Units','normalized');
            
            % figure panel
            obj.fph   = uipanel(obj.fh,'Units','centimeters',...
                'Position',[0, bphe,  fpos(3), fphe],...
                'Interruptible','off',...
                'BorderType','beveledin',...
                'BusyAction','cancel',...                
                'Tag','asFigurePanel');
            set(obj.fph,'Units','normalized');            
            
            % image statistics object (min, max, l2 ...)
            obj.statistics = asStatisticsClass(obj.cph, obj.STATISTICS_POS);
            
            % image windowing object (the center and width slider i.e. contrast
            % and brightness)
            obj.window = asWindowingClass(...
                obj.cph,...
                obj.WINDOWING_POS,...
                @obj.updFig,...
                @obj.applyToRelatives,...
                @()obj.getColormap('phase',true),...
                obj.icons);
            
            % info textbox object
            obj.infotext = asInfoTextClass(obj.cph, obj.INFOTEXT_POS);
                        
            % complex part selector (the dropdown menu on the top right of
            % the arrayShow window)
            obj.complexSelect = asCmplxChooserClass(...
                obj.cph,...
                obj.CMPLX_SEL_POS,...
                @obj.updFig,...
                @obj.applyToRelatives,...
                obj.icons.send);
            
            dataIsreal = isreal(obj.data.dat);
            if dataIsreal
                % disable the imag and phase button in the complexSelect
                % object
                obj.complexSelect.lockImagAndPhase;
                
                % select real part per default
                if isempty(initComplexSelect)
                    initComplexSelect = 'Re';
                end
            end
            if ~isempty(initComplexSelect)
                obj.complexSelect.setSelection(initComplexSelect, true);
            end
            
            
            
            % init the figure context menu (first entries are created
            % within the asCursorPosClass)
            obj.fcmh.base = uicontextmenu;
            
            % cursor position object
            obj.cursor = asCursorPosClass(...
                obj.fh,...
                obj.bph,...
                obj.fcmh,...
                obj.icons,...
                ~dataIsreal,...
                @obj.applyToRelatives,...
                @obj.getCurrentAxesHandle,...
                obj);
            
            % valueChanger array (the +/- buttons on the top left of the
            % arrayShow window)
            initStrings = cell(length(si),1);
            initStrings{1} = ':';
            initStrings{2} = ':';
            for i = 3 : length(si)
                initStrings{i} = '1';
            end
            obj.selection = asSelectionClass(obj.cph, si,...
                'figureUpdateCallback',@obj.updFig,...
                'apply2allCb',@obj.applyToRelatives,...
                'InitStrings',initStrings,...
                'dataObject',obj.data,...
                'offsets', selectionOffset,...
                'sendIcon',obj.icons.send);
            obj.data.linkToSelectionClassObject(obj.selection);
            
            
            % init the control panel context menu and create additional
            % entries in the previously created figure context menu...
            obj.initContextMenus(infoText);
            clear('infoText');
            
            
            set(obj.fh,'HandleVisibility','off');
            % ...we don't want other matlab routines to print stuff on our
            % main figure
            
            
            if ~isempty(selectedImageStr)
                obj.selection.setValue(selectedImageStr,true,true,true);
            end
            
            
            % pixel markers
            obj.markers = asMarkerClass(obj.selection, pixMarkers, obj.mbh.markers);
            
            
            % if specific figure position is given, resize the gui
            if ~isempty(userFigurePosition)
                obj.setFigurePosition(userFigurePosition);
                obj.fpResize(true);  % manually call resize function
            end
            
            % find relatives
            if ~obj.useGlobalArray
                obj.refreshRelativesList();
                
                % since this object is not yet in the cloud, add it manually to
                % the list
                obj.relatives   = [obj.relatives,obj];
                obj.noRelatives = obj.noRelatives + 1;
                % (this assures that the send2all function does
                % include this object, if the "includeSelf"-toggle is switched
                % on)
            end
            
            % all gui components should be ready by now, so start
            % updateFigure to find the selected array part and convert it
            % to an image object in the axes region
            if obj.updFigCount == 0 && renderUi
                % for new figures, updFig sometimes seems to be triggered
                % when setting the figure resize function...
                % I haven't figured why and when exactly that happens.
                % However, to speedup the start time, we don't call updFig again in
                % this case.
                obj.updFig;
            end
            
            % apply the initial window (center and width setting), if we
            % got one as a constructor input argument
            if ~isempty(CW)
                obj.window.setCW(CW);
            end
            
            % select proper valueChanger object (VCO)
            if length(si) > 2
                obj.selection.selectVco(3);
            end
            
            % write the imagetext
            if ~isempty(imageTextVal)
                
                % deal with special case of a one-dimensional image
                % text cell array and a 3 dimensional image array
                if iscell(imageTextVal) && isvector(imageTextVal)
                    if length(size(obj.data.dat)) == 3
                        imageTextVal = reshape(imageTextVal,[1,1,length(imageTextVal)]);
                    end
                end
                obj.createImageText(imageTextVal);
                if renderUi
                    obj.updFig
                end
            end
            
            
            if ~renderUi
                return;
            end            
            
            % save figure position in the object property (pixel units) and activate
            % figure resize function
            set(obj.fh,'Visible', 'on');
            drawnow; % apparently it's a good idea to draw the figure before
            % activating the resize callback. Otherwise, the
            % callback is sometimes triggered for no obvious
            % reasons.
            set(obj.fh,'Units', 'pixel',...
                'ResizeFcn',@(src, evnt)obj.fpResize);
            
            obj.figurePosition = get(obj.fh,'Position');
            
            
            % put focus on complexSelector
            % (this was written to put the focus away from the selection
            % class at initialization of arrShow objects. As a result, key
            % press calbacks can be evaluated without initial mouseclick on
            % the figure window. Unfortunately, this command also seems to
            % notably increases the startup time :-/  )
            obj.complexSelect.focus;
            
        end
        
        function reloadWorkspaceArray(obj)
            if obj.linkedToWorkspaceArray
                % try to get the workspace array
                try
                    WA = evalin('base',obj.workspaceArrayName);
                catch err
                    if strcmp(err.identifier,'MATLAB:UndefinedFunction')
                        WA = [];
                    else
                        rethrow(err);
                    end
                end
                if isempty(WA)
                    fprintf('workspace variable ''%s'' seems not to be valid anymore\n',obj.workspaceArrayName);
                else
                    obj.data.overwriteImageArray(WA);
                end
            else
                disp('asObject is not linked to a workspace array');
            end
            
        end
        
        function updateWorkspaceArray(obj)
            if obj.linkedToWorkspaceArray
                assignin('base',obj.workspaceArrayName,obj.data.dat);
            end
        end
        
        function overwriteImageArray(obj, arr)
            obj.data.overwriteImageArray(arr);
        end
        
        function refreshRelativesList(obj)
            if obj.useGlobalArray
                global asObjs %#ok<TLEV>
                asObjs = arrShow.findAllObjects();
                evalin('base','global asObjs');
            else
                obj.relatives   = arrShow.findAllObjects();
                obj.noRelatives = length(obj.relatives);
            end
            
            % if according options are set, send object properties to
            % relatives
            if obj.sendWdwSize
                obj.sendFigureSize();
            end
            
            %             obj.sendColormap(false);
            
            if obj.complexSelect.sendToggleState
                if obj.selection.sendToggleState
                    obj.applyToRelatives('complexSelect.setSelection',false,obj.complexSelect.getSelection(),true);
                else
                    obj.applyToRelatives('complexSelect.setSelection',false,obj.complexSelect.getSelection(),false);
                end
            end
            
            if obj.selection.sendToggleState
                obj.selection.send;
            end
            
            if obj.window.sendAbsWindow
                obj.window.sendAbsWindowToRelatives()
            else
                if obj.window.sendRelWindow
                    obj.window.sendRelWindowToRelatives();
                end
            end
            
            if obj.roiExists()
                if obj.roi.getSendPositionToggle();
                    obj.roi.callSendPositionCallback;
                end
            end
        end
        
        function wipeRelativesList(obj)
            %             obj.relatives   = [];
            %             obj.noRelatives = 0;
            %             fprintf('deleted all relatives from list\n');
            obj.msg('wipe call');
        end
        
        function sendColormap(obj, mapType)
            % mapType can be either
            % current, standard or phase
            if nargin < 2
                mapType = 'current';
            end
            obj.applyToRelatives('setColormap',false,obj.getColormap(mapType),mapType);
        end
        
        
        function sendAll(obj, bool)
            % toggle send all (sendable) settings to the relatives
            if nargin < 2
                bool = true;
            end
            obj.selection.toggleSend(bool);
            obj.window.toggleSendRelWindow(bool);
            obj.window.toggleSendAbsWindow(bool);
            obj.complexSelect.toggleSend2all(bool);
            obj.cursor.toggleSend(bool);
            
            % also send non toggleable options
            if bool
                obj.sendColormap();
                obj.sendZoom();
            end
            
        end
        
        function printCurrentImage(obj)
            % this is a workaround to print an image without the uipanels
            
            % create a help figure without menues
            helpFigure = figure('MenuBar','none',...
                'ToolBar','none');
            colormap(obj.getColormap);
            
            % copy current axes to the help figure
            ah = obj.getCurrentAxesHandle;
            helpAxes = copyobj(ah,helpFigure);
            set(helpAxes,'Units','normalized','position',[0,0,1,1])
            
            % delete cursor rectangle in helpFigure
            rect = findobj(helpFigure,'type','rectangle');
            delete(rect);
            
            % print helpFigure
            ph = printpreview(helpFigure);
            
            % wait until print dialog is closed
            while(ishandle(ph))
                pause(0.1);
            end
            
            % ...and close the help figure
            if ishandle(helpFigure)
                close(helpFigure);
            end
            
        end
        
        function batchExportDimension(obj, dim, filename, createMovie, framerate)
            % export all 2D frames of dimension dim to either bitmap files
            % or an avi file
            
            % create bitmap series by default (rather than a movie file)
            if nargin < 4 ||isempty(createMovie)
                createMovie = false;
            end
            
            % use the image title as filename by default
            if nargin < 3 || isempty(filename)
                filename = obj.title;
                if isempty(filename)
                    disp('Need a figure title to create a filename');
                    return;
                end
            end
            
            % remove special characters from the filename
            filename = arrShow.removeSpecialCharsFromString(filename);
                                   
            % get data dimensions
            dims = obj.selection.getDimensions;
            noDims = length(dims);
            
            % if no export dimension is give, open an input dialog
            if nargin < 2 || isempty(dim)
                dim = mydlg('Enter dimension','Enter dimension for batch export',num2str(noDims));
                dim = str2double(dim);
                if isnan(dim)
                    return
                end
            end
                        
            % check validity of the given export dimension
            if noDims < dim
                disp('invalid dimension number given');
                return;
            end
            
            % if we want to create a movie file, initialize the VideoWriter
            % object
            if createMovie
                vwObj = VideoWriter(filename,'Uncompressed AVI');
                if nargin < 5 || isempty(framerate)
                    framerate = mydlg('Enter framerate','Enter framerate for the movie','30');
                    framerate = str2double(framerate);
                    if isnan(framerate)
                        return
                    end                    
                end
                vwObj.FrameRate = framerate;
                vwObj.open();
            end            

            if createMovie
                % check if we need to crop the frames: .avi-files require that
                % the dimensions be divisible by four. Therefore, in
                % exportCurrentImage, we make sure that they are. Since that
                % function is called quite often and would therefore lead to
                % warning spam, we issue the warning here
                % instead of where we actually do the cropping.
                exportSize = size(get(findobj( ...
                    obj.getCurrentAxesHandle(),'type','image'),'Cdata'));
                rem = [mod(exportSize(1), 4) mod(exportSize(2), 4)];
                if any(rem)
                                        warning('arrShow:writeMovie',['image dimension not divisible by four, ',...
                            'which is required for .avi-export. Cropping image to be divisible by four...']);
                end
            end


            % select the export dimension
            obj.selection.selectVco(dim)
            
            % store the current selection
            origValue = obj.selection.getCurrentVcValue;
            
            % loop through all frames in the export dimension
            obj.selection.setCurrentVcValue(1);
            for i = 1 : dims(dim);
                if createMovie
                    obj.exportCurrentImage(vwObj);
                else
                    obj.exportCurrentImage([filename,'_',num2str(i, '%05.5d'),'.png']);
                end
                obj.selection.increaseCurrentVc;
            end
            
            % reset selection
            obj.selection.setCurrentVcValue(origValue);
            
            % close videoWriter
            if createMovie
                vwObj.close();
            end
            
            disp('Done batchexport.');
        end
        
        function createMovie(obj, dim, framerate)
            % shortcut to batchExportDimension with enabled movie export
            if nargin < 3
                framerate = [];
            end
            if nargin < 2
                dim = [];
            end
            obj.batchExportDimension(dim, [], true, framerate);
        end
        
        function img = getScreenshot(obj, includePanels, includeCursor, scrshotPauseTime)
            % use the matlab getframe routines to capture the current image
            % with all its child-objects.
            warning('arrShow:exportCurrentImage','output image might not have the exact original image''s resolution');
            
            if nargin < 4
                scrshotPauseTime = 0;
                if nargin < 3
                    includeCursor = false;
                    if nargin < 2
                        includePanels = false;
                    end
                end
            end
            
            ah = obj.getCurrentAxesHandle();
            imh = findobj(ah,'type','image');
            img = get(imh,'Cdata');
            
            origUnits = get(ah,'units');
            set(ah,'units','pixel');
            origPos = get(ah,'position');
            
            % show cursor rectangle?
            if ~includeCursor
                ud = get(ah,'UserData');
                if ~isempty(ud) && isfield(ud,'rect') && ~isempty(ud.rect)
                    delete(ud.rect);
                    ud.rect = [];
                    set(ah,'UserData',ud);
                end
            end
            
            if obj.RESIZE_AXES_FOR_SCREENSHOTS
                si = size(img) -1;
                set(ah,'position',[origPos(1:2),si(1:2)]);
            end
            
            % assure that current window is on top of all others
            if scrshotPauseTime
                figure(obj.fh);
                drawnow;
                pause(scrshotPauseTime);
            end
            
            if includePanels
                img = getframe(obj.fh);
            else
                img = getframe(ah);
            end
            
            set(ah,'position',origPos);
            set(ah,'units',origUnits);
        end
        
        function exportCurrentImage(obj, filenameOrVideoWriterObj, screenshot, includePanels, includeCursor, scrshotPauseTime)
            % export data (original image or a screenshot containing
            % arrayShow controls etc.) to either a bitmap file of a
            % videoWriter object.
            %
            % filename can be either a string or a VideoWriter object.
            
            if nargin < 6
                scrshotPauseTime = 0;
                if nargin < 5
                    includeCursor = false;
                    if nargin < 4
                        includePanels = false;
                        if nargin < 3
                            screenshot = false;
                            if nargin < 2
                                filenameOrVideoWriterObj = '';
                            end
                        end
                    end
                end
            end
            
            if isempty(filenameOrVideoWriterObj)
                % generate filename from title
                filenameOrVideoWriterObj = arrShow.removeSpecialCharsFromString(obj.title);
                
                [file,path] = uiputfile({'*.png';'*.bmp'},'Save image as', filenameOrVideoWriterObj);
                if isnumeric(file)
                    return;
                end
                filenameOrVideoWriterObj = strcat(path, file);
                
                if isempty(filenameOrVideoWriterObj)
                    warning('arrShow:exportCurrentImage','image export aborted, no filename given');
                    return;
                end                

                if exist(filenameOrVideoWriterObj,'file');
                    fprintf('Fig. %d: overwriting existing file: %s\n',obj.getFigureNumber, filenameOrVideoWriterObj);
                end                
            end
            
            % define the method to write single frames
            writeVideo = isa(filenameOrVideoWriterObj,'VideoWriter');
            if writeVideo
                vwObj = filenameOrVideoWriterObj;
                writeFrame = @(dat, tmp1, tmp2)vwObj.writeVideo(dat);
            else
                writeFrame = @imwrite;
            end
            
            %img = obj.getSelectedImages();
            ah = obj.getCurrentAxesHandle();
            imh = findobj(ah,'type','image');
            img = get(imh,'Cdata');

            % .avi files need to have dimensions divisible by four
            % so if we write to a movie, we should make sure that this is
            % fulfilled. Therefore, we crop the image here to make sure
            % that its size is divisible by four.
            if writeVideo
                rem = [mod(size(img, 1), 4) mod(size(img, 2), 4)];
                if any(rem)
                    tmpstr = repmat({':'}, 1, ndims(img));
                    for currDim = 1:2
                        r = rem(currDim);
                        switch r
                            case 1
                                % Just leave out the last value
                                tmpstr{currDim} = 1:size(img,currDim)-1;
                            case 2
                                % Leave out first and last
                                tmpstr{currDim} = 2:size(img,currDim)-1;
                            case 3
                                % First and last two
                                tmpstr{currDim} = 2:size(img,currDim)-2;
                        end
                    end
                    % Crop image using the subscript vector
                    img = img(tmpstr{:});
                end
            end

            if screenshot || includePanels
                % use the matlab getframe routines to capture the current image
                % with all its child-objects.
                img = obj.getScreenshot(includePanels, includeCursor, scrshotPauseTime);

                % write image to file
                writeFrame(img.cdata,filenameOrVideoWriterObj);

            else

                if size(img,3) == 3
                    % cdata is already in RGB format, so just write it
                    % to file
                    writeFrame(img,filenameOrVideoWriterObj);
                else
                    % cdata represents intensity values while the
                    % visible representation is windowed and color coded
                    % using the colormap and CLim property of the axes object.
                    % In order to properly save the image we need to
                    % mimic the windowing of the axes object.

                    % get range limitations and center/width values
                    Clim = obj.window.getCLim();
                    CW = obj.window.getCW();

                    % compress image to valid range
                    img(img > Clim(2)) = Clim(2);
                    img(img < Clim(1)) = Clim(1);

                    % scale image according to windowing
                    img = img - Clim(1);
                    img = img / CW(2);

                    % scale image to the range of the current colormap
                    cmap = obj.getColormap('current', true);
                    img = img * ( size(cmap,1) - 1) + 1;

                    % get rgb image
                    rgbImg = ind2rgb(round(img), cmap);
                    
                    % write image to file
                    writeFrame(rgbImg,filenameOrVideoWriterObj);
                    
                end
            end

            % export image infos to a text file
            if obj.saveInfosAtImageExport && ~writeVideo
                [path,name] = fileparts(filenameOrVideoWriterObj);
                obj.exportImageInfos(fullfile(path,[name,'.txt']));
            end
        end
        
        function exportImageInfos(obj, filename, appendToFile)
            if nargin < 3
                appendToFile = false;
                if nargin < 2
                    initName = obj.title;
                    initName(isspace(initName))='_';
                    [file,path] = uiputfile({'*.txt'},'Save image infos in', initName);
                    if isnumeric(file)
                        return;
                    end
                    filename = strcat(path, file);
                end
            end
            
            if ~isempty(filename)
                if appendToFile
                    fid = fopen(filename,'at');
                else
                    fid = fopen(filename,'wt');
                end
                
                % construct output text from title, imageStats and infoText
                CW = obj.window.getCW;
                
                if isempty(CW)
                    CW = [0,0];
                end
                
                % basic informations
                text = {'--Figure title--';...
                    ['''',obj.title,''''];...
                    '';...
                    '--Image dimensions--';...
                    num2str(size(obj.getSelectedImages));...
                    '';...
                    '--Selected image--';...
                    obj.selection.getValue();...
                    '';...
                    '--Image stats--'};
                text = [text; obj.statistics.getImageStatsCellString()];
                
                % windowing
                cmap = obj.getColormap;
                if isnumeric(cmap);
                    cmap = 'custom';
                end
                
                text = [text ; {...
                    '';...
                    '--Image windowing--';...
                    ['center/width = [ ', num2str(CW(1)),' ',num2str(CW(2)),' ]'];...
                    ['colormap     = ',cmap];...
                    ''}];
                
                % roi
                if obj.roiExists()
                    roiPos = obj.roi.getPosition;
                    Nvertex = size(roiPos,1);
                    roiPosText = cell(Nvertex,1);
                    for i = 1 : Nvertex
                        roiPosText{i} = [num2str(roiPos(i,1)),'  ',num2str(roiPos(i,2))];
                    end
                    roiStats = obj.roi.getMeanAndStdString;
                    text = [text ; {'--Roi position--'};...
                        roiPosText;...
                        {'';...
                        '--Roi Stats--';...
                        roiStats;...
                        '';}];
                end
                
                % infotext
                text = [text; {'--InfoText--'};...
                    obj.infotext.getString;...
                    '';];
                
                % date time
                text = [text; {''; '--Export date--'}];
                text = [text; 'date : ', humanize.clock(clock,'date')];
                text = [text; 'time : ', humanize.clock(clock,'time')];
                
                % arrayShow version
                text = [text; {''; '--arrayShow version--'}];
                text = [text; num2str(obj.VERSION)];
                
                
                % write everything to the text file
                for i = 1 : size(text,1);
                    fprintf(fid,'%s\n',text{i});
                end
                
                fclose(fid);
            end
            
        end
        
        function exportColorbar(obj, filename)
            if nargin < 2
                filename = [];
            end
            if isempty(filename)
                % generate filename from title
                filename = arrShow.removeSpecialCharsFromString(obj.title);
                
                [file,path] = uiputfile({'*.eps';'*.png'},'Save colorbar as', filename);
                if isnumeric(file)
                    return;
                end
                filename = strcat(path, file);
            end
            
            if isempty(filename)
                warning('arrShow:exportColorbar','image export aborted, no filename given');
            else
                % determine output format
                [~,~,fileExt] = fileparts(filename);
                if isempty(fileExt)
                    fprintf('No file extension given, using eps\n');
                    fileExt = '.eps';
                    filename = [filename,fileExt];
                end
                switch fileExt
                    case '.eps'
                        % use colored eps (pepsc)
                        graphicFormat = 'epsc';
                    otherwise
                        % try to just use the extension as format name
                        graphicFormat = fileExt(2:end);
                end
                
                % check if file already exists
                if exist(filename,'file');
                    fprintf('Fig. %d: overwriting existing file: %s\n',obj.getFigureNumber(), filename);
                end
                
                % get colorbar handle
                ch = colorbar('peer',obj.getCurrentAxesHandle);
                
                % create a help figure without menues
                helpFigure = figure('MenuBar','none',...
                    'ToolBar','none');
                set(helpFigure,'Units','pixel','position',[800,300,50,300])
                colormap(obj.getColormap('current',true));
                
                % copy current axes to the help figure
                helpAxes = copyobj(ch,helpFigure);
                set(helpAxes,'Units','normalized','position',[0.3,0.1,.05,0.8])
                
                set(helpAxes,'fontsize',14)
                
                % write image to file
                try
                    print(helpFigure,filename,['-d',graphicFormat]);
                catch ME
                    if strcmp(ME, 'MATLAB:print:InvalidDeviceOption')
                        fprintf('Unsupported output format %s\n',graphicFormat);
                    else
                        rethrow(ME);
                    end
                end
                
                % close help window
                delete(helpFigure);
                
                % update figure to possibly remove the colorbar from the main
                % window
                obj.updFig;
            end
            
        end
        
        function bool = isInitialized(obj)
            bool = false([1,length(obj)]); % be pessimistic
            
            for i = 1 : length(obj)
                % check, if the object's figure handle is a valid figure handle
                % in this workspace
                if isvalid(obj) && ishandle(obj(i).fh)
                    type = '';
                    
                    try %#ok<TRYNC> dont want to check for unexpected errors in this single line
                        type = get(obj(i).fh,'Type');
                    end
                    
                    if strcmp(type, 'figure')
                        % check if this object is the same als the object
                        % linked to the figure
                        linkedObject = get(obj(i).fh,'UserData');
                        if obj(i).eq(linkedObject)
                            bool(i) = true;
                        end
                    end
                end
            end
        end
        
        function arr = getAllImages(obj, returnAsComplex)
            if nargin < 2
                returnAsComplex = true;
            end
            arr = obj.data.dat;
            
            if ~returnAsComplex
                % ... get function pointer (to abs(), real(), phase(0...) from complexChooser
                fun = obj.complexSelect.getFunPointer();
                
                arr = fun(arr);
            end
        end
        
        function arr = getSelectedImages(obj, returnAsComplex)
            
            if nargin < 2
                returnAsComplex = false;
            end
            
            % ---- ugly but yet best working way to do the indexing
            sel = obj.selection.getValue;
            cmdStr = ['arr = obj.data.dat(',sel,');'];
            eval(cmdStr);
            
            
            %             % ---- i actually thought that this is the proper way to do indexing.
            %             % Unfortunately this doesn't seem to work with strings like
            %             % 'end:-1:1'
            %
            %             % create a subscript structure for subsref
            %             S.type = '()';                           % ...we're always dealing with a standard matrix
            %             S.subs = obj.selection.getValueAsCell(false); % get selected image subscripts
            %
            %             % get the selected images
            %             arr = subsref(obj.data.dat,S);
            %
            %
            %
            %             % ---- another way to do the same stuff, but with the same
            %             % limitations
            %
            %             % get selected image subscripts
            %             idx = obj.selection.getValueAsCell(false);
            %
            %             % get the selected images
            %             arr = obj.data.dat(idx{:});
            
            if ~returnAsComplex
                % ... get function pointer (to abs(), real(), phase(0...) from complexChooser
                fun = obj.complexSelect.getFunPointer();
                
                arr = fun(arr); %#ok<NODEF> arr is defined by the eval command which is ugly, i know...
            end
            
        end
        
        
        function dims = getImageDimensions(obj)
            dims = size(obj.data.dat);
        end
        
        function fh  = getFigureHandle(obj)
            fh = obj.fh;
        end

        function n  = getFigureNumber(obj)
            if isnumeric(obj.fh)
                % originally I used "verLessThan('matlab','8.4.0')" here.
                % However, this fails when recreating an object which was
                % stored in a previous matlab version but is opened in a
                % new matlab version :-/
                n = obj.fh;
            else
                if isvalid(obj.fh)
                    n = obj.fh.Number;
                else
                    n = 0;
                end
            end                
        end
        
        function ah  = getCurrentAxesHandle(obj)
            % since the image windowing object nows the lastly selected
            % axes, assume this to be the 'current axes' even if
            % get(fh,'CurrentObject') might already be something else
            ah = obj.window.getAxesHandle();
        end
        
        
        
        
        
        % ----> zoom
        function z = getZoom(obj)
            ah = obj.getCurrentAxesHandle;
            if ishandle(ah)
                yl = ylim(ah);
                xl = xlim(ah);
                z = [yl;xl];
            else
                z = [];
            end
        end
        
        function setZoom(obj, z, resetFirst, centerPoint)
            % usage: setZoom(obj, z, resetFirst, centerPoint)
            % set zoom around a the centerPoint
            %
            % the zoom "z" can be:
            %   - A scalar zoom factor for both dimensions
            %   - A 2-element vector with individual zoom factors for both dimensions
            %   - A 4-element vector containing xlim and ylim.
            %
            % if z has less than 4 elements, 'resetFirst' determines if z is applyed
            % relative to the current zoom level or relative to zero zoom
            %
            % If no centerPoint is given, zoom is performed around the
            % center of the image
            
            if ~obj.isLocked && isnumeric(z)
                
                if nargin < 3
                    resetFirst = false;
                    if nargin < 2
                        obj.msg('Please specify zoom factor');
                    end
                end
                
                % choose the zoom method according to the number of
                % elements in z
                if ~ismember(numel(z),[1,2,4])
                    obj.msg('invalid zoom argument\n');
                    return;
                end
                
                % get axis handle
                ah = obj.getCurrentAxesHandle;
                
                % get image dimensions
                dim = obj.statistics.getDimensions;
                
                if numel(z) == 4
                    % assume z to be a matrix with ylim and xlim
                    if all(size(z) == [2,2])
                        % limit the new FOV to the image size
                        z = min(z, [dim(1),dim(1);dim(2),dim(2)]+0.5);
                        z = max(z,0.5 * ones(2));
                        if any(diff(z,[],2) <0.5)
                            disp('invalid zoom');
                            return;
                        end
                        ylim(ah,z(1,:));
                        xlim(ah,z(2,:));
                        return;
                    end
                else
                    % assume z to contain zoom factors
                    
                    % replicate scalar zoom factor to be 2 dimensional
                    if isscalar(z)
                        z = [z,z];
                    end
                                        
                    if sum(z) == 0 || resetFirst
                        % reset zoom
                        ylim(ah,0.5 + [0,dim(1)]);
                        xlim(ah,0.5 + [0,dim(2)]);
                    end
                    
                    if sum(z) ~= 0
                        % get current FOV
                        xl = get(ah,'XLim');
                        yl = get(ah,'YLim');
                        
                        % width of the current FOV
                        w = [ diff(yl), diff(xl)];
                        
                        % if not given, use the center point of the original image
                        if nargin < 4 || isempty(centerPoint)
                            centerPoint = dim/2;
                        end
                        
                        % zoomed width
                        w = w ./ z;
                        
                        % new FOV
                        left  = centerPoint - w/2;
                        right = centerPoint + w/2;
                        
                        % account for over- and undershoots
                        overshoot  = right - dim;
                        overshoot(overshoot < 0) = 0;
                        left = left - overshoot;
                        
                        undershoot = left;
                        undershoot(undershoot > 0) = 0;
                        right = right - undershoot;
                        
                        newLims = [left;right];
                        
                        % limit the new FOV to the image size
                        newLims = min(newLims, [dim;dim]);
                        newLims = max(newLims,zeros(2));
                        newLims = newLims + 0.5;
                        
                        % set new limits to axes handle
                        set(ah,'XLim',newLims(:,2));
                        set(ah,'YLim',newLims(:,1));
                    end
                end
            end
        end
        
        function cropFromZoom(obj)
            % get colon dimensions
            colDims  = obj.selection.getColonDims();
            if length(colDims) < 2
                fprintf('Need both colon dimensions selected');
                return;
            end
            
            % get data and their dimensions
            A = obj.data.dat;            
            ndims = length(size(A));
            
            % get zoom
            z   = obj.getZoom();
            z(:,1) = ceil(z(:,1));
            z(:,2) = floor(z(:,2));
            
            % create the selection string
            sel = repmat({':'},[ndims,1]);
            sel{colDims(1)} = z(1,1):z(1,2);
            sel{colDims(2)} = z(2,1):z(2,2);
            S.type = '()';
            S.subs = sel;
            
            % select selection from A and write it back to the asDataClass
            A = subsref(A,S);
            obj.data.overwriteImageArray(A);
            
        end
        
        function zf = getMouseWheelZoomFactor(obj)
            zf = obj.mouse_wheel_zoom_factor;
        end
        
        function setMouseWheelZoomFactor(obj, zf)
            obj.mouse_wheel_zoom_factor = zf;
        end
        
        function toggleZoomCursor(obj, bool)
            % toggle interactive zoom mode
            
            % get zoom object
            z = zoom(obj.fh);
            
            % get zoom state
            if nargin < 2
                bool = ~arrShow.onOffToBool(z.Enable);
            end
            
            if bool
                % toggle the zoom button state
                set(obj.tbh.zoom,'State','on');
                
                % enable zoom
                z.Enable = 'on';
            else
                % toggle the zoom button state
                set(obj.tbh.zoom,'State','off');
                
                % disable zoom
                z.Enable = 'off';
            end
        end
        
        function sendZoom(obj)
            % send zoom to relatives
            z = obj.getZoom;
            obj.applyToRelatives('setZoom',false,z);
        end
        
        function copyZoom(obj)
            % copy zoom to clipboard
            clipboard('copy',obj.getZoom);
            fprintf('Copied zoom to clipboard\n');
            
        end
        
        function pasteZoom(obj)
            % paste zoom from clipboard
            z = str2num(clipboard('paste')); %#ok<*ST2NM> I'm using str2num because the value usually isnt scalar
            if ~isempty(z)
                if all(size(z) == [2,2])
                    obj.setZoom(z)
                    return
                end
            end
            fprintf('No valid zoom information in clipboard\n');
        end
        
        % <---- zoom
        
        function shiftImage(obj, shft)  
            % assure that shift is a column vector with two elements
            if numel(shft) == 2                
                if 2 ~= size(shft,1)
                    shft = shft(:);
                end
                
                % get image dimensions
                dim = obj.statistics.getDimensions;
                
                % get the current FOV
                FOV = obj.getZoom();
                
                % derive the target FOV
                newFov = FOV + repmat(shft,[1,2]);
                
                % assure that the new FOV is within the image dims
                if newFov(1,1) < 0.5 || newFov(1,2) > dim(1)
                    newFov(1,:) = FOV(1,:);
                end
                if newFov(2,1) < 0.5 || newFov(2,2) > dim(2)
                    newFov(2,:) = FOV(2,:);
                end                                    
                
                % assure that the target is within the image limits
                obj.setZoom(newFov);
            end
        end
        
        function enableControls(obj, bool)
            if nargin < 2
                bool = true;
            end
            obj.selection.enable(bool);
            obj.window.enable(bool);
            obj.complexSelect.enable(bool);
            state = arrShow.boolToOnOff(~bool);
            set(obj.tbh.lock,'state',state);
            set(obj.mbh.lockCntrls,'Checked',state);
        end
        
        function lockControls(obj, bool)
            % more intuitive name for obj.enableControls(false)
            if nargin < 2
                bool = true;
            end
            obj.enableControls(~bool);
        end
        
        function bool = isLocked(obj)
            bool = arrShow.onOffToBool(get(obj.tbh.lock,'state'));
        end
        
        function obj = rebuildObject(obj, varargin)
            
            for i = 1 : length(obj)
                
                pars = {'title',          obj(i).getFigureTitle,...
                    'info',           obj(i).infotext.getString,...
                    'window',         obj(i).window.getCW(),...
                    'select',         obj(i).selection.getValue,...
                    'complexselect',  obj(i).complexSelect.getSelection,...
                    'stdcolormap',    obj(i).getColormap('standard'),...
                    'phasecolormap',  obj(i).getColormap('phase'),...
                    'position',       obj(i).getFigurePosition,...
                    'useglobalarray', obj(i).useGlobalArray};
                pars = [pars, varargin]; %#ok<AGROW>
                obj(i) = arrShow(obj(i).getAllImages, pars{:});
                
                if ~isempty(obj(i).UserData)
                    obj(i).UserData = obj(i).UserData;
                end
                
            end
        end
        
        function setColormap(obj, mapName, mapType, suppressUpdFig)
            % mapType can be 'current, standard or phase'
            
            if obj.isLocked
                return
            end
            if nargin < 4
                suppressUpdFig = false;
            end
            if nargin < 3
                mapType = 'current';
            end
            if nargin < 2 || isempty(mapName)
                
                % this is a workaround... in previous versions, arrShow
                % could only handle standard colormaps. Therefore
                % obj.getColormap always returned a string. However, with the
                % possibility to load custom maps, the map name might not
                % be defined. In this case, obj.getColormap now returns the actual RGB
                % "lookup table". In future versions, lookup tables and map
                % names will be separated more carefully.
                cMap = obj.getColormap();
                if ~ischar(cMap)
                    cMap = 'gray(256)';
                end
                
                % prompt for a colormap name
                mapName = inputdlg('','Colormap name',1,{cMap});
                if isempty(mapName)
                    return;
                else
                    mapName = mapName{1};
                end
                
                % check if the given name exists as a file
                % (which is still no proof that its an actual colormap.
                % However, it catches at least the most common input
                % errors)
                if ~exist(mapName,'file')
                    fprintf('Warning: a colormap with the name ''%s'' does not seem to exist\n',mapName);
                    return
                end                
                                
            end
            
            mapType = lower(mapType);
            
            for i = 1 : length(obj)
                switch mapType
                    case 'current'
                        if strcmp(obj.complexSelect.getSelection,'Pha')
                            obj(i).phaseColormap = mapName;
                        else
                            obj(i).stdColormap = mapName;
                        end
                    case 'standard'
                        obj(i).stdColormap = mapName;
                    case 'phase'
                        obj(i).phaseColormap = mapName;
                end
                if ~suppressUpdFig
                    obj(i).updFig();
                end
            end
        end
        
        function cMap = getColormap(obj, mapType, convertToMatrix)
            % mapType can be 'current, standard or phase'
            
            if nargin < 3
                convertToMatrix = false;
                if nargin < 2
                    mapType = 'current';
                end
            end
            
            % account for the fact that the cMap might has been altered
            % by the matlab colormapeditor in the meantime
            if (obj.stdCmapMightBeModified ||...
                    obj.phaCmapMightBeModified) &&...
                    obj.isInitialized()
                
                % retrieve the colormap from the figure
                cMap = colormap(obj.fh);
                
                % store the cMap to this object's properties
                if obj.phaCmapMightBeModified
                    obj.setColormap(cMap, 'phase', true);
                else
                    obj.setColormap(cMap, 'standard', true);
                end
            end
            
            
            switch lower(mapType)
                case 'current'
                    if strcmp(obj.complexSelect.getSelection,'Pha')
                        cMap = obj.phaseColormap;
                    else
                        cMap = obj.stdColormap;
                    end
                case 'standard'
                    cMap = obj.stdColormap;
                case 'phase'
                    cMap = obj.phaseColormap;
            end
            
            if convertToMatrix && ischar(cMap)
                ah = obj.getCurrentAxesHandle;
                cMap   = colormap(ah(1),cMap);
            end
            
        end
        
        function setPostprocessingFunction(obj,fun)
            if nargin < 2 || isempty(fun)
                obj.postProcFun = [];
                obj.updFig();
            else
                if isa(fun,'function_handle')
                    obj.postProcFun = fun;
                    obj.updFig();
                else
                    disp('invalid argument');
                end
            end
        end
        
        function setForceComplexRepresentation(obj, bool)
            obj.forceComplexRepresentation = bool;
        end
        
        function storeColormap(obj, file)
            % save colormap in a file
            if nargin < 2
                [fname, fpath] = uiputfile('.mat','store custom colormap',obj.cMapStdPath);
                file = [fpath, fname];
            end
            if ~isempty(file) && ~isa(file,'double')
                cm = colormap(obj.fh); %#ok<NASGU> the value is used in the save command
                save(file,'cm');
            end
        end
        
        function loadColormap(obj, file)
            % load colormap from file
            if nargin < 2
                [fname, fpath] = uigetfile('.mat','load custom colormap',obj.cMapStdPath);
                if isnumeric(fname)
                    return;
                end
                file = [fpath, fname];
            end
            if ~isempty(file)
                cm = load(file,'cm');
                if isfield(cm,'cm');
                    obj.setColormap(cm.cm);
                end
            end
        end
        
        function showTrueImageSize(obj)
            truesize(obj.fh);
        end
        
        
        % ---->  figure properties
        function pos = getFigurePosition(obj)
            if obj.isInitialized()
                obj.storeFigurePosition
            end
            pos = obj.figurePosition;
        end
        
        function setFigurePosition(obj,pos)
            if obj.isInitialized()
                originalUnits = get(obj.fh,'Units');
                set(obj.fh,'Units','pixels');
                set(obj.fh,'Position',pos);
                set(obj.fh,'Units',originalUnits);
                
                % (the actual resize function 'obj.fpResize' is executed as
                % a callback from the figure object)
            end
            obj.figurePosition = pos;
        end
        
        function pos = getFigureOuterPosition(obj)
            originalUnits = get(obj.fh,'Units');
            set(obj.fh,'Units','pixels');
            pos = get(obj.fh,'Outerposition');
            set(obj.fh,'Units',originalUnits);
        end
        
        function setFigureOuterPosition(obj,pos)
            originalUnits = get(obj.fh,'Units');
            set(obj.fh,'Units','pixels');
            set(obj.fh,'Outerposition',pos);
            obj.figurePosition = get(obj.fh,'Position');
            set(obj.fh,'Units',originalUnits);
        end
        
        function storeFigurePosition(obj)
            % unfortunately there is no "positionChangeCallback" option in
            % matlab figures. So the obj.figurePosition property might not
            % be up to date after moving the window around. This method is
            % a workaround to manually store the current figure position
            % e.g. before saving the object to a file
            if obj.isInitialized
                originalUnits = get(obj.fh,'Units');
                set(obj.fh,'Units','pixels');
                obj.figurePosition = get(obj.fh,'Position');
                set(obj.fh,'Units',originalUnits);
            end
        end
        
        function resetFigurePosition(obj)
            fpos = obj.deriveFigurePos();
            originalUnits = get(obj.fh,'Units');
            set(obj.fh,'Units','centimeters');
            set(obj.fh,'Position',fpos);
            
            
            % save position in pixels to object
            set(obj.fh,'Units','pixels');
            obj.figurePosition = get(obj.fh,'Position');
            
            % restore original units
            set(obj.fh,'Units',originalUnits);
            
        end
        
        function siz = getFigureSize(obj)
            pos = obj.getFigurePosition;
            siz = pos(3:end);
        end
        
        function setFigureSize(obj,siz)
            obj.storeFigurePosition
            pos = obj.getFigurePosition;
            if isscalar(siz)
                siz = siz * pos(3:4);
            end
            pos(2) = pos(2) + pos(4) - siz(2);
            pos(3:4) = siz;
            obj.setFigurePosition(pos);
        end
        
        function copyFigureSize(obj)
            % copy figure size to clipboard
            clipboard('copy',obj.getFigureSize);
            fprintf('Copied figure size to clipboard\n');
            
        end
        
        function pasteFigureSize(obj)
            % paste figure size from clipboard
            siz = str2num(clipboard('paste'));
            if ~isempty(siz)
                if all(size(siz) == [1,2])
                    obj.setFigureSize(siz)
                    return
                end
            end
            fprintf('No valid zoom information in clipboard\n');
        end
        
        function sendFigureSize(obj)
            siz = obj.getFigureSize;
            obj.applyToRelatives('setFigureSize',false,siz)
        end
        
        function toggleSendFigureSize(obj, bool)
            if nargin > 1
                set(obj.mbh.sendFigSize,'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.mbh.sendFigSize,'Checked')
                case 'off'
                    obj.sendWdwSize = true;
                    %                     set(obj.cpcmh.sendFigSize,'Checked','on');
                    set(obj.mbh.sendFigSize,'Checked','on');
                    
                    obj.sendFigureSize();
                    
                case 'on'
                    obj.sendWdwSize = false;
                    %                     set(obj.cpcmh.sendFigSize,'Checked','off');
                    set(obj.mbh.sendFigSize,'Checked','off');
            end
        end
        
        function setFigureTitle(obj,title)
            if nargin < 2
                previousTitle = get(obj.fh,'Name');
                title = mydlg('Enter title','Change figure title',previousTitle, [500 500 500 90]);
                if isempty(title)
                    title = previousTitle;
                end
            end
            obj.title = title;
            set(obj.fh,'Name',title);
            if obj.titleAsImageText
                obj.imageText.setString(title);
            end
        end
        
        function title = getFigureTitle(obj)
            %             title = get(obj.fh,'Name');
            title = obj.title;
        end
        
        function putFigureOnTop(obj)
            figure(obj.fh);
        end
        
        function minimizeFigure(obj)
            figureName = ['Figure ',num2str(obj.getFigureNumber())];
            if verLessThan('matlab','8.4.0')
                showwindow(figureName,'minimize');
            else
                warning('Sorry, showwindow does not seem to be working with this Matlab version. This needs to be fixed some day...');
            end
        end
        % ---->  figure properties
        
        
        
        function ah = getAxesHandle(obj)
            ah = obj.window.getAxesHandle();
        end
        
        
        
        
        function out = applyToRelatives(obj, funName, includeSelf, varargin)
            if obj.useGlobalArray
                global asObjs; %#ok<TLEV> yeah, I know that global might be inefficient but yet I like this to be globally accessible
                obj.relatives = asObjs;
                obj.noRelatives = length(obj.relatives);
            end
            
            % don't include this object by default
            if nargin < 3
                includeSelf = false;
            end
            
            % create command string for 'eval'
            cmd = ['obj.relatives(o).',funName,'(varargin{:})'];
            
            % preallocate output cell vector
            if nargout > 0
                out = cell(obj.noRelatives,1);
            end

            o = 1;
            while o <= obj.noRelatives
                if isvalid(obj.relatives(o))
                    if includeSelf || obj.relatives(o) ~= obj
                        if nargout == 1
                            out{o} = eval(cmd);
                        else
                            eval(cmd);
                        end
                    end
                    o = o + 1;
                else
                    obj.relatives(o) = '';
                    obj.noRelatives = obj.noRelatives - 1;
                end
            end
            
            % delete possible empty entry in the output vector if
            % includeSelf == false
            if nargout > 0 && ~includeSelf
                out(cellfun(@isempty,out)) = [];
            end
        end
        
        function saveObject(obj, filename)
            if nargin < 2 || isempty(filename)
                % generate filename from title
                filename = arrShow.removeSpecialCharsFromString(obj.title);
                
                [file,path] = uiputfile({'*.mat'},'Save asObjects as', filename);
                if isnumeric(file)
                    return;
                end
                filename = strcat(path, file);
            else
                file = filename;
            end
            
            
            if isempty(filename)
                warning('arrShow:saveObject','object saving aborted, no filename given');
            else
                
                % choose a variable name for the asObjects, which is the filename
                % without the tailing '.mat'
                storeVarName = textscan(file,'%s %s','delimiter','.');
                storeVarName = storeVarName{1}{1};
                               
                
                if verLessThan('matlab','8.4.0')
                    cpObj = obj;
    
                    % remove possible links to relatives and store objects position
                    cpObj.wipeRelativesList;
                    cpObj.storeFigurePosition;                                    
                else
                    % apparently, since matlab 2014b, saving objects containing
                    % graphic elements was sustantially changed. As a consequence
                    % the normal save commant now tries to recursively store all
                    % graphic objects. As almost all arrayShow subclasses 
                    % are linked to graphic elements, it is
                    % rather complicated to get rit of them prior saving. As a
                    % workaround, I currently just create a copy of the object
                    % and then delete the main figure graphic object (which
                    % automatically also deletes all parent graphics). The
                    % object can then be saved as in previous matlab versions.
                    % This sux a bit in terms of performance, but seems 
                    % to work for now.                
                    cpObj = obj.rebuildObject('renderUI',false);
                    delete(cpObj.getFigureHandle);
                end
                                
                % copy objects to a variable named like the file
                eval([storeVarName, ' = cpObj;']); % I didn't find a more elegant solution yet, since
                % "assignin('caller',...)" doesn't seem to work. If anyone
                % knows a better solution, let me know :)
                                                                
                % ...write the variable to harddisk
                fprintf('saving data...   ');
                tic;
                save(filename,storeVarName, '-v7.3');
                fprintf('done in %s.\n',humanize.seconds(toc));
                
                clear(storeVarName);
            end
        end
        
        function stop(obj)
            obj.pausePlay
        end
        
        function pausePlay(obj)
            % deactivates the "play mode"
            
            % Replace pause button by a play button
            obj.setupPlayButton
            
            % set playAlong dim to false
            obj.playAlongDim = false;
        end
        
        function setFramerate(obj, framerate)
            if nargin < 2
                frStr = mydlg('Please enter framerate','Please enter framerate',num2str(obj.framerate));
                framerate = str2double(frStr);
            end
            if isscalar(framerate) && isfinite(framerate) && framerate > 0
                obj.framerate = framerate;
            end
        end
        
        function framerate = getFramerate(obj)
            framerate = obj.framerate;
        end
        
        function play(obj, framerate, autoRepeat)
            % automatically increase the selected value in the plot dimension
            % with a given framerate. This yields kind of a movie
            % mode.
            % If autoRepeat is set to true, the function always starts over
            % at the beginning until the pause button is pressed (or
            % obj.pausePlay is called).
            % Otherwise, the playback ends at the last frame in the plot
            % dimension.
            
            % check input arguments
            if nargin < 3
                autoRepeat = false;
            end
            if nargin < 2 || isempty(framerate)
                % if a framerate is given, update the according object
                % property
                framerate = obj.framerate;
            else
                % else just use the objects standard setting
                obj.framerate = framerate;
            end
            
            
            % set playAlong dim to true
            obj.playAlongDim = true;
            
            % Replace play button by a pause button
            set(obj.tbh.play,'Tag','Annotation.pause',...
                'TooltipString', 'Pause',...
                'ClickedCallback', @(src, evnt)obj.stop,...
                'CData',obj.icons.pause);
            
            % get the plot dimension
            plotDim = obj.selection.getPlotDim();
            
            if ~isempty(plotDim)
                % select plotDim valueChanger
                obj.selection.selectVco(plotDim);
                
                % get the data dimension
                dims = obj.selection.getDimensions();
                
                % get the number of the current and the last frame in the
                % plot dimension
                currFrame = str2double(obj.selection.getCurrentVcValue);
                lastFrame = dims(1, plotDim);
                
                % automatically rewind, if we are at the end of the
                % dimension
                if currFrame == lastFrame
                    obj.selection.setCurrentVcValue(1)
                    currFrame = 1;
                end
                
                % loop
                i = currFrame;
                while i <= lastFrame

                    % avoid an error when someone closes the asObj during
                    % play mode
                    if ~isvalid(obj)
                        return;
                    end
                    
                    % check if someone hit the pause button
                    if ~obj.playAlongDim
                        break;
                    end
                    
                    if i == lastFrame
                        if autoRepeat
                            obj.selection.setCurrentVcValue(1)
                            i = 1;
                        else
                            break;
                        end
                    else
                        obj.selection.increaseCurrentVc();
                        i = i + 1;                        
                    end                     
                    pause(1/framerate);
                end
            end
            
            obj.pausePlay();
            
        end               
        
        function createWorkspaceObject(obj)
            assignin('base','asObj',obj)
            disp('handle object was created in workspace variable ''asObj''');
        end
        
        
        function close(obj)
            N = length(obj);
            ms = obj(1).msg;
            ms('destroying %d objects with handles: ',N);
            for i = 1 : N
                if obj(i).isInitialized
                    ms('%f ',obj(i).fh);
                    obj(i).closeReq(obj(i).fh);
                    %                     delete(obj.fh);
                end
            end
            ms('\n');
        end
        
        function about(obj)
            fp = obj.getFigurePosition;
            w = 320;
            h = 150;
            l = fp(1) + 20;
            b = fp(2) + fp(4) - h;
            fPos =  [l, b, w, h];
            mf = mfilename('fullpath');
            d = dir([mf,'.m']);
            str = char('arrayShow',...
                ['Version: ',num2str(obj.VERSION)],...
                'Last modified:',...
                d.date,...
                '',...
                'Written by Tilman Johannes Sumpf (tsumpf@gwdg.de)',...
                'Copyright (c) 2009-2013 Biomedizinische NMR Forschungs GmbH',...
                'http://www.biomednmr.mpg.de');
            
            afh = figure( 'MenuBar','none',...
                'ToolBar','none',...
                'NumberTitle','off',...
                'Position',fPos,...
                'Name','About arrayShow');
            
            uicontrol('Style','text',...
                'Parent',afh,...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Max',2,...
                'HorizontalAlignment','left',...
                'Visible','on',...
                'String', str);
            
            
        end
        
        function bool = roiExists(obj)
            bool = ~isempty(obj.roi) && isvalid(obj.roi);
        end
        
        function createRoi(obj, roiPos)
            % Function either creates a new ROI or updates the position of
            % an old ROI, if present.
            
            % check if vector plot is enabled
            if obj.getUseQuiverToggle
                disp('ROIs are not yet supported in vector-plot mode');
                return;
            end
            
            % declare the roi position vector, if it's not given as an
            % input argument
            if nargin < 2
                roiPos = [];
            end
            
            % check if a previous ROI exists
            if obj.roiExists()
                if isempty(roiPos)
                    % if we don't have a defined roiPos, we probably want
                    % to create an all new ROI. So delete the old one
                    delete(obj.roi);
                    
                else
                    % we have a roi position vector, so just update the
                    % already existing ROI
                    obj.roi.setPosition(roiPos);                                        
                end
            else            
                % We don't have an old ROI and
                % really want to create a new one

                % check if we have the necessary liscense
                [TF, errmsg] = license('checkout','Image_Toolbox');
                if TF == 0
                    fprintf('We need the image toolbox to create a ROI :-/\n\n');
                    disp(errmsg);
                    return;
                end

                % prohibit change of selection during ROI creation (this would
                % mess up everything)
                obj.selection.enable(false);
                obj.data.enableDestructiveFunctions(false);
                obj.complexSelect.enable(false);

                % create the roi
                obj.roi = asRoiClass(obj.getCurrentAxesHandle,roiPos,...
                    @obj.roiCallback);

                % and re-enable the disabled controls
                obj.selection.enable(true);
                obj.complexSelect.enable(true);
                obj.data.enableDestructiveFunctions(true);
            end
            
            % check, if the plotAlongDim functionality is activated. 
            % This function can also plot roi values along dim which might have
            % changed.
            if obj.cursor.getPlotAlongDimToggle
                obj.cursor.plotAlongPlotDim();
            end
        end
        
        function copyRoi(obj)
            if obj.roiExists()
                obj.roi.copyPosition();
            end
        end
        
        function pasteRoi(obj)
            posStr = clipboard('paste');
            roiPos = str2num(posStr);
            if ~isempty(roiPos)
                obj.createRoi(roiPos);
            end
        end
        
        function deleteRoi(obj)
            if obj.roiExists()
                obj.roi.delete();
            end
        end
        
        function createImageText(obj, str)
            if nargin < 2
                str = [];
            end
            if isempty(obj.imageText) || ~isvalid(obj.imageText)
                obj.imageText = asImageTextClass(obj.getCurrentAxesHandle,str);
            else
                if iscell(str)
                    % compare if the size of str and the array data fits
                    obj.imageText.storeCellArray(str);
                else
                    obj.imageText.setString(str);
                end
            end
            obj.updFig;
        end
        
        function toggleTitleAsImageText(obj)
            switch get(obj.mbh.titleAsImageText,'Checked')
                case 'off'
                    obj.titleAsImageText = true;
                    obj.createImageText(obj.title);
                    set(obj.mbh.titleAsImageText,'Checked','on');
                case 'on'
                    obj.titleAsImageText = false;
                    set(obj.mbh.titleAsImageText,'Checked','off');
                    if isvalid(obj.imageText)
                        cellSel=obj.selection.getValueAsCell;                        % get the selection string
                        for j=1:1:length(cellSel)
                            if cellSel{j} ==  ':'
                                cellSel{j}=num2str(1);
                            else
                                cellSel{j}=cellSel{j};
                            end
                        end
                        obj.imageText.updateAxesHandle(obj.getCurrentAxesHandle);
                        obj.imageText.setString('', cellSel);
                    end
                    obj.updFig;
            end
        end
        
        function toggleAspectRatio(obj)
            switch get(obj.mbh.aspectRatio,'Checked')
                case 'off'
                    set(obj.mbh.aspectRatio,'Checked','on');
                case 'on'
                    set(obj.mbh.aspectRatio,'Checked','off');
            end
            obj.updFig();
        end
        
        
        function toggleTrueSize(obj)
            switch get(obj.mbh.trueSize,'Checked')
                case 'off'
                    set(obj.mbh.trueSize,'Checked','on');
                case 'on'
                    set(obj.mbh.trueSize,'Checked','off');
            end
            obj.updFig();
        end
        
        function bool = getTrueSizeToggle(obj)
            switch get(obj.mbh.trueSize,'Checked')
                case 'off'
                    bool = false;
                case 'on'
                    bool = true;
            end
        end
        
        function toggleUseQuiver(obj)
            switch get(obj.mbh.quiver,'Checked')
                case 'off'
                    set(obj.mbh.quiver,'Checked','on');
                case 'on'
                    set(obj.mbh.quiver,'Checked','off');
            end
            obj.updFig();
        end
        
        function toggeShowVectorPlot(obj)
            %... just an alias to useQuiver
            obj.toggleUseQuiver();
        end
        
        function bool = getUseQuiverToggle(obj)
            bool = arrShow.onOffToBool(get(obj.mbh.quiver,'Checked'));
        end
        
        function toggleTextboxVisibility(obj)
            switch get(obj.cpcmh.infoText,'Checked')
                case 'on'
                    obj.infotext.setVisible('off');
                    set(obj.cpcmh.infoText,'Checked','off');
                    set(obj.mbh.infoText,'Checked','off');
                case 'off'
                    obj.infotext.setVisible('on');
                    set(obj.cpcmh.infoText,'Checked','on');
                    set(obj.mbh.infoText,'Checked','on');
            end
        end
        
        function showColorbar(obj, bool)
            if nargin < 2
                bool = true;
            end
            if bool
                % enable colorbar
                sel = obj.complexSelect.getSelection();
                if strcmp(sel,'Com')
                    set(obj.tbh.colorbar,'State','off');
                    disp('colorbar not yet available in complex mode');
                else
                    set(obj.tbh.colorbar,'State','on');
                    colorbar('peer',obj.getCurrentAxesHandle);
                end
            else
                % disable colorbar
                set(obj.tbh.colorbar,'State','off');
                colorbar('peer',obj.getCurrentAxesHandle,'off');
                obj.updFig();
            end
        end

        function setUserCallback(obj, ucb_function)
			obj.userCallback = ucb_function;
		end
        
        function setUserCb(obj, cb_function)
            obj.userCallback = cb_function;
		end
		function cb = getUserCallback(obj)
			cb = obj.userCallback;
		end
       
        
    end %(public methods)
    
    methods (Access = private)
        function setupPlayButton(obj)
            % create multi function play and pause buttons
            % (because the button can be dynamically replaced by a pause            
            % button, its creation routines are put in this dedicated
            % function.)
            
            htmlToolTip = ['<html><b>Play along plot dimension:</b><br><table>',...
                '<tr><td><u>Normal click</u></td><td>: Play until the last frame is reached</td></tr>',...
                '<tr><td><u>Ctrl+click</u></td>: Play continuously (auto repeat)</td></tr>',...
                '<tr><td><u>Shift+click</u></td>: Set framerate</td></tr></table></html>'];
            
            if ~isfield(obj.tbh,'play')
                obj.tbh.play = uipushtool('Parent',obj.tbh.base,'Tag','Annotation.play',...
                    'Separator','on');
            end
            
            set(obj.tbh.play,'TooltipString', htmlToolTip,...
                'ClickedCallback', @(src, evnt)playButtonCb(),...
                'CData',obj.icons.play);
            
            function playButtonCb()
                modifiers = get(obj.fh,'currentModifier');
                if isempty(modifiers)
                    obj.play([],false);
                else
                    if ismember('control',modifiers)
                        obj.play([],true);
                    else
                        if ismember('shift',modifiers)
                            obj.setFramerate();
                        end
                    end
                end
            end
        end
        
        function [bool, imageHandle] = isImageSelected(obj)
            % in previous arrShow versions, it was sufficient to just
            % check, if get(obj.fh,'CurrentObject') returns an image
            % handle. However, since 2014b clilcking on the moving rectangle in the
            % image seems influence the currentObject property, even if the
            % HitTest of the rectangle is set to 'off'.  I currently found no
            % better option than to enable the HitTest of the
            % rectangle and to check for that in this function :-(
            % this does not yet work for phase circles :-((
            
            selectedUiObj = get(obj.fh,'CurrentObject');
            imageHandle = [];
            bool = false;
            
            % check, if the image is selected (these lines were sufficient
            % in matlab versions prior 2014b)            
            if strcmp(get(selectedUiObj,'Type'), 'image');
                bool = true;
                imageHandle = selectedUiObj;
            elseif(strcmp(get(selectedUiObj,'Type'), 'rectangle'));
                % ...and here comes the ugly part:
                % try to get the selected image from the childs of the
                % parent of the rectangle...
                axesHandle = get(selectedUiObj,'Parent');
                axesChilds = get(axesHandle,'Children');
                if verLessThan('matlab','8.4.0')
                    for i = 1 : length(axesChilds)
                        if strcmp(get(axesChilds(i),'Type'),'image')
                            imageHandle = axesChilds(i);
                            bool = true;
                            break;
                        end
                    end
                else
                    imgInds = find(arrayfun(@(x)isa(x,'matlab.graphics.primitive.Image'),axesChilds));
                    if isempty(imgInds)
                        % also try to find a quiver object, in case
                        % vectorPlot is enabled...
                        imgInds = find(arrayfun(@(x)isa(x,'matlab.graphics.chart.primitive.Quiver'),axesChilds));
                    end
                    imageHandle = axesChilds(imgInds(1));                 
                    bool = true;
                end                                
            end
        end
        
        function fpos = deriveFigurePos(obj)
            
            % some dimension shortcuts
            cpH = obj.CP_HEIGHT; % control (top) panel height
            bpH = obj.BP_HEIGHT; % bottom panel height
            mH = 3;              % estimated height of menubar + toolbar in cm
            
            % screen size in centimeters
            originalUnits = get(0,'Units');
            set(0,'Units','centimeters');
            scrS = get(0,'ScreenSize');
            set(0,'Units',originalUnits);
            
            % derive the possible figure panel height (in centimeters)
            possible_fH = scrS(4) - cpH - bpH - mH;
            if possible_fH < obj.FP_MAX_HEIGHT
                warning('arrShow:dimensionError',...
                    'screen size seems to small for the desired arrayShow standard figure dimensions');
                fpH = possible_fH;
            else
                fpH = obj.FP_MAX_HEIGHT;
            end
            if fpH < 8
                error('arrShow:dimensionError','Screen size seems to small for arrayShow');
            end
            
            fH = cpH+fpH+bpH;   % figure height
            
            % set the bottom left position of the main window to 1/4 of
            % the horizontal screen size
            left = 1/4 * scrS(3);
            
            bot = scrS(4) - fH - mH;
            fpos = [left, bot, fpH, fH ];
            
            obj.fp_height = fpH;
        end
        
        function initMenuBar(obj)
            % create menubar -------------
            
            
            % file menu
            mb_file = uimenu(obj.fh,'Label','File');
            
            % Data to Workspace
            mb_copy2Ws = uimenu(mb_file,'Label','Copy current image to workspace',...
                'Separator','off');
            if isreal(obj.data.dat)
                set(mb_copy2Ws,'callback',@(src,evnt)obj.copyImg2Ws(true,false));
            else
                uimenu(mb_copy2Ws,'Label','Selected complex part' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,false));
                uimenu(mb_copy2Ws,'Label','Complex array' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,true));
            end
            uimenu(mb_file,'Label','Copy ALL images to workspace',...
                'callback',@(src,evnt)obj.copyImg2Ws(false,true),...
                'Separator','off');
            uimenu(mb_file,'Label','Create Workspace Obj' ,...
                'callback',@(src,evnt)obj.createWorkspaceObject,...
                'Separator','off');
            uimenu(mb_file,'Label','Clone asObj' ,...
                'callback',@(src,evnt)clone);
            uimenu(mb_file,'Label','Save asObj' ,...
                'callback',@(src,evnt)obj.saveObject());
            
            function clone
                obj.storeFigurePosition;
                as(obj)
            end
            
            % save image
            mb_subExport = uimenu(mb_file,'Label','Export current image to file...',...
                'Separator','on');
            uimenu(mb_subExport,'Label','Original data (Ctrl + e)',...
                'callback',@(src,evnt)obj.exportCurrentImage('',false,false));
            mb_sub_screenshot = uimenu(mb_subExport,'Label','Frame screenshot');            
            uimenu(mb_sub_screenshot,'Label','Include ROI',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,false,false));            
            uimenu(mb_sub_screenshot,'Label','Include ROI and cursor',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,false,true));
            uimenu(mb_sub_screenshot,'Label','Include ROI and panels',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,true,false));
            
            uimenu(mb_file,'Label','Batch export dimension...'   ,...
                'callback',@(src,evnt)obj.batchExportDimension);

            uimenu(mb_file,'Label','Create movie from dimension...'   ,...
                'callback',@(src,evnt)obj.createMovie);
            
            uimenu(mb_file,'Label','Export image informations to txt file'   ,...
                'callback',@(src,evnt)obj.exportImageInfos);
            
            uimenu(mb_file,'Label','Export colorbar'   ,...
                'callback',@(src,evnt)obj.exportColorbar);
            
            uimenu(mb_file,'Label','Print current image',...
                'callback',@(src,evnt)obj.printCurrentImage);
            
            uimenu(mb_file,'Label','Close','Callback',@(src, evnt)obj.close,...
                'Separator','on');
            
            
            
            
            
            %Operations menu
            mb_operations = uimenu(obj.fh,'Label','Operations');
            uimenu(mb_operations,'Label','Rot90'   ,...
                'callback',@(src, evnt)obj.data.rot90(1));
            uimenu(mb_operations,'Label','Rot-90'   ,...
                'callback',@(src, evnt)obj.data.rot90(-1));
            uimenu(mb_operations,'Label','Crop around center'   ,...
                'callback',@(src, evnt)obj.data.crop);
            uimenu(mb_operations,'Label','Crop from zoom'   ,...
                'callback',@(src, evnt)obj.cropFromZoom());
            

            uimenu(mb_operations,'Label','Conjugate (conj)'   ,...
                'callback',@(src, evnt)obj.data.conj(),...
                'Separator','on');
            uimenu(mb_operations,'Label','Negate (uminus)'   ,...
                'callback',@(src, evnt)obj.data.uminus());

            
            uimenu(mb_operations,'Label','FFT all images (Shift + f)'   ,...
                'callback',@(src,evnt)obj.data.fft2All,...
                'Separator','on');
            uimenu(mb_operations,'Label','iFFT all images (Shift + d)'   ,...
                'callback',@(src,evnt)obj.data.ifft2All);
            uimenu(mb_operations,'Label','FFTshift2 all images (Ctrl + Shift + f)'   ,...
                'callback',@(src,evnt)obj.data.fftshift2All);
            
            uimenu(mb_operations,'Label','Squeeze'   ,...
                'callback',@(src,evnt)obj.data.squeeze(),...
                'Separator','on');
            uimenu(mb_operations,'Label','Permute'   ,...
                'callback',@(src,evnt)obj.data.permute());
            uimenu(mb_operations,'Label','Reshape'   ,...
                'callback',@(src,evnt)obj.data.reshape());            
            mb_coldivi = uimenu(mb_operations,'Label','Set colon dim divisor',...
                'Separator','on');
            arrShow.populateColonDimDivisorSubmenu(obj,mb_coldivi);
            uimenu(mb_operations,'Label','Set destructive selection string (Shift + s)'   ,...
                'callback',@(src,evnt)obj.data.setDestructiveSelectionString());
            
            
            % tools
            mb_tools = uimenu(obj.fh,'Label','Tools');
            % ROI
            mb_roi = uimenu(mb_tools,'Label','ROI');
            uimenu(mb_roi,'Label','Draw'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.createRoi);
            uimenu(mb_roi,'Label','Copy'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.copyRoi);
            uimenu(mb_roi,'Label','Paste'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.pasteRoi);
            uimenu(mb_roi,'Label','Delete'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.deleteRoi);
            
            uimenu(mb_tools,'Label','Surface plot' ,...
                'callback',@(src,evnt)createSurfacePlot,...
                'Separator','on');
            function createSurfacePlot()
                imgs = obj.getSelectedImages(false);
                if ~isreal(imgs)
                    fprintf('Surface plot doesn''t work on complex data yet.\n');
                    return
                end
                if length(size(squeeze(imgs)))>2
                    fprintf('Surface plot currently works on single images.\n');
                    return
                end
                if isa(imgs,'single');                    
                    imgs = double(imgs);
                    fprintf('Surface plot don''t work with single precision images. Converting to double...\n');
                    %...this holds true at least for matlab R2013a
                end
                
                % always create a new figure to not destroy e.g. previous
                % surface plots
                figure;
                surf(imgs)
            end
            uimenu(mb_tools,'Label','Impixelregion (Shift + z)'   ,...
                'Separator','off', 'callback',@(src,evnt)impixelregion(obj.fh));
            
            
            
            
            
            
            % relatives
            mb_relatives = uimenu(obj.fh,'Label','Relatives');
            % shortcut to allObjs commands
            uimenu(mb_relatives,'Label','Lineup (l)' ,'callback',@(src,evnt)asLineup);
            uimenu(mb_relatives,'Label','Lineup top left (Ctrl + l)' ,'callback',@(src,evnt)asLineup([],[],[],1,1));
            uimenu(mb_relatives,'Label','Show title within image (Shift + t)' ,'callback',@(src,evnt)asSetAllTitlesToImageString);
            uimenu(mb_relatives,'Label','Browse (b)' ,'callback',@(src,evnt)ab);
            uimenu(mb_relatives,'Label','Close (Shift + ESC)' ,'callback',@(src,evnt)asCloseAll);
            
            uimenu(mb_relatives,'Label','Refresh list of relatives (F5)' ,...
                'callback',@(src,evnt)obj.refreshRelativesList(),...
                'Separator', 'on');
            
            
            
            
            % view --
            mb_view = uimenu(obj.fh,'Label','View');            
            
            % markers
            obj.mbh.markers = uimenu(mb_view,'Label','Markers' );                        
            
            % aspect ratio etc...
            obj.mbh.aspectRatio = uimenu(mb_view,'Label','Keep aspect ratio' ,...
                'callback',@(src,evnt)obj.toggleAspectRatio(),...
                'Checked','on','Separator','on');
            obj.mbh.trueSize = uimenu(mb_view,'Label','Keep true size' ,...
                'callback',@(src,evnt)obj.toggleTrueSize(),...
                'Checked','off');
            obj.mbh.quiver = uimenu(mb_view,'Label','Show vector plot' ,...
                'callback',@(src,evnt)obj.toggleUseQuiver(),...
                'Checked','off');            
            
            % zoom
            cmh_zoom = uimenu(mb_view,'Label','Set zoom' ,...
                'Separator','on');
            uimenu(cmh_zoom,'Label','Reset (Ctrl + 1)' ,...
                'callback',@(src,evnt)obj.setZoom(0));
            uimenu(cmh_zoom,'Label','2 (Ctrl + 2)' ,...
                'callback',@(src,evnt)obj.setZoom(2,true));
            uimenu(cmh_zoom,'Label','3 (Ctrl + 3)' ,...
                'callback',@(src,evnt)obj.setZoom(3,true));
            uimenu(cmh_zoom,'Label','4 (Ctrl + 4)' ,...
                'callback',@(src,evnt)obj.setZoom(4,true));
            
            uimenu(mb_view,'Label','Copy zoom (Ctrl + Shift + c)' ,...
                'callback',@(src,evnt)obj.copyZoom);
            uimenu(mb_view,'Label','Paste zoom (Ctrl + Shift + v)' ,...
                'callback',@(src,evnt)obj.pasteZoom);
            uimenu(mb_view,'Label','Send zoom' ,...
                'callback',@(src,evnt)obj.sendZoom);
            
            
            % colormaps
            cmh_stdCmap = uimenu(mb_view,'Label'  ,'Colormap',...
                'Separator','on');
            obj.populateColormapMenu(cmh_stdCmap, @(map)obj.setColormap(map,'standard'));
            cmh_phaCmap = uimenu(mb_view,'Label'  ,'Phase colormap',...
                'Separator','off');
            obj.populateColormapMenu(cmh_phaCmap, @(map)obj.setColormap(map,'phase'));
            % add send entries
            uimenu(cmh_stdCmap,'Label','Send','callback',@(src,evnt)obj.sendColormap('standard'),'Position',1);
            uimenu(cmh_phaCmap,'Label','Send','callback',@(src,evnt)obj.sendColormap('phase'),'Position',1);
            
            
            uimenu(mb_view,'Label','Create image text' ,...
                'callback',@(src,evnt)obj.createImageText(mydlg),...
                'Separator', 'on');
            
            
            % Figure
            mb_figure = uimenu(obj.fh,'Label','Figure');
            obj.mbh.lockCntrls = uimenu(mb_figure,'Label','Lock controls (`)'   ,...
                'callback',@(src,evnt)obj.lockControls(~arrShow.onOffToBool(get(obj.mbh.lockCntrls,'Checked'))));
	    uimenu(mb_figure, 'Label', 'Delete userCallback', ...
		'callback', @(src,evnt)obj.setUserCallback([]));
            uimenu(mb_figure,'Label','Change title (t)'   ,...
                'callback',@(src,evnt)obj.setFigureTitle,...
                'Separator','on');
            obj.mbh.titleAsImageText = uimenu(mb_figure,'Label','Show title within image (Ctrl + t)'   ,...
                'callback',@(src,evnt)obj.toggleTitleAsImageText);
            
            obj.mbh.infoText = uimenu(mb_figure,'Label','Show Info Textbox'   ,...
                'checked','off',...
                'callback',@(src,evnt)toggleTextboxVisibility(obj));
            
            uimenu(mb_figure,'Label','Half size (Alt + F2)'   ,...
                'callback',@(src,evnt)obj.setFigureSize([341 444]),...
                'Separator','on');
            uimenu(mb_figure,'Label','Reset figure size (Alt + F1)'   ,...
                'callback',@(src,evnt)obj.resetFigurePosition,...
                'Separator','off');
            
            uimenu(mb_figure,'Label','Copy figure size'   ,...
                'callback',@(src,evnt)obj.copyFigureSize());
            
            uimenu(mb_figure,'Label','Paste figure size'   ,...
                'callback',@(src,evnt)obj.pasteFigureSize());
            
            obj.mbh.sendFigSize = uimenu(mb_figure,'Label','Send figure size'   ,...
                'callback',@(src,evnt)obj.toggleSendFigureSize());
            
            % Info
            mb_info = uimenu(obj.fh,'Label','Info');
            uimenu(mb_info,'Label','About'   ,...
                'callback',@(src,evnt)obj.about);
            
        end
        
        function initToolBar(obj)
            
            % create toolbar
            toolBar = uitoolbar(obj.fh);
            obj.tbh.base = toolBar;
            
            % multi function colorbar button
            htmlToolTip = ['<html><b>Colorbar:</b><br><table>',...
                '<tr><td><u>Normal click</u></td><td>: Show colorbar</td></tr>',...
                '<tr><td><u>Ctrl+click:</u></td>: Send current colormap</td></tr></table>',...
                '</html>'];
            obj.tbh.colorbar = uitoggletool('Parent',toolBar,'Tag','Annotation.myInsertColorbar',...
                'TooltipString', htmlToolTip,...
                'ClickedCallback', @(src,evnt)colorbarCb(obj),...
                'CData',obj.icons.colorbar);
            function colorbarCb(obj)
                modifiers = get(obj.fh,'currentModifier');
                if isempty(modifiers)
                    switch(get(obj.tbh.colorbar,'State'))
                        case 'on'
                            obj.showColorbar(true);
                        case 'off'
                            obj.showColorbar(false);
                    end
                else
                    if ismember('control',modifiers)
                        obj.sendColormap();
                        set(obj.tbh.colorbar,'State','off');
                    end
                end
            end
            
            % multi function zoom button
            htmlToolTip = ['<html><b>Zoom:</b><br><table>',...
                '<tr><td><u>Normal click</u></td><td>: Enable interactive zoom (z)</td></tr>',...
                '<tr><td><u>Ctrl+click:</u></td>: Send zoom</td></tr></table>',...
                '<br><p style="width:180px; text-align:left"><i>',...
                'Hint:<br>Zooming is also possible by pressing <br><b>control+mouse wheel</b>',...
                '</i></p></html>'];
            obj.tbh.zoom = uitoggletool('Parent',toolBar,'Tag','loration.ZoomOut',...
                'TooltipString', htmlToolTip,...
                'ClickedCallback', @(src, evnt)zoomButtonCb(),...
                'CData',obj.icons.magnify);
            function zoomButtonCb
                modifiers = get(obj.fh,'currentModifier');
                if isempty(modifiers)
                    putdowntext('zoomin',gcbo);
                else
                    if ismember('control',modifiers)
                        obj.sendZoom();
                        set(obj.tbh.zoom,'State','off');
                    end
                end
            end
            
            
            % add rotate button
            %             defaultColor = get(0,'defaultuicontrolbackgroundcolor');
            uipushtool('Parent',toolBar,'Tag','Annotation.Rot90',...
                'TooltipString', 'Rot90',...
                'ClickedCallback', @(src, evnt)obj.data.rot90(1),...
                'CData',obj.icons.rotLeft,...
                'Separator','on');
            uipushtool('Parent',toolBar,'Tag','Annotation.Rot-90',...
                'TooltipString', 'Rot-90',...
                'ClickedCallback', @(src, evnt)obj.data.rot90(-1),...
                'CData',obj.icons.rotRight,...
                'Separator','off');
            
            % refresh button
            uipushtool('Parent',toolBar,'Tag','Annotation.refreshRelativesList',...
                'TooltipString', 'Refresh list of relatives (F5)',...
                'ClickedCallback', @(src, evnt)obj.refreshRelativesList,...
                'CData',obj.icons.refresh,...
                'Separator','on');
            
            % as browse
            uipushtool('Parent',toolBar,'Tag','Annotation.asBrowse',...
                'TooltipString', 'Browse list of relatives (b)',...
                'ClickedCallback', @(src, evnt)ab,...
                'CData',obj.icons.asBrowse);
            
            % multi function lineup button
            htmlToolTip = ['<html><b>Lineup all open arrayShow windows:</b><br><table>',...
                '<tr><td><u>Normal click:</u></td><td>Open lineup dialog</td></tr>',...
                '<tr><td><u>Shift+click:</u></td>Lineup to the top left arrayShow window</td></tr>',...
                '<tr><td><u>Ctrl+click:</u></td>Lineup to the top left of the screen</td></tr></table></html>'];
            uipushtool('Parent',toolBar,'Tag','Annotation.lineup',...
                'TooltipString', htmlToolTip,...
                'ClickedCallback', @(src, evnt)lineupButtonCb,...
                'CData',obj.icons.lineup);
            function lineupButtonCb
                modifiers = get(obj.fh,'currentModifier');
                if isempty(modifiers)
                    arrShow.openLineupDlg();
                else
                    if ismember('control',modifiers)
                        asLineup([],[],[],1,1);
                    else
                        if ismember('shift',modifiers)
                            asLineup();
                        end
                    end
                end
            end
            
            % multi function send button
            htmlToolTip = ['<html><b>All sendings:</b><br><table>',...
                '<tr><td><u>Normal click</u></td><td>: Deactivate all sendings</td></tr>',...
                '<tr><td><u>Ctrl+click</u></td>: Send all</td></tr></table></html>'];
            uipushtool('Parent',toolBar,'Tag','Annotation.sendNone',...
                'TooltipString', htmlToolTip,...
                'ClickedCallback', @(src, evnt)sendAllCb(),...
                'CData',obj.icons.dontSend);
            function sendAllCb()
                modifiers = get(obj.fh,'currentModifier');
                if isempty(modifiers)
                    obj.sendAll(false)
                else
                    if ismember('control',modifiers)
                        obj.sendAll(true)
                    end
                end
            end
            
            
            
            % lock controls
            obj.tbh.lock = uitoggletool('Parent',toolBar,'Tag','Annotation.lockControls',...
                'TooltipString', 'Lock controls and ignore commands from relatives (`)',...
                'ClickedCallback', @(src,evnt)obj.lockControls(~arrShow.onOffToBool(get(obj.mbh.lockCntrls,'Checked'))),...
                'CData',obj.icons.lock);
            
            % create workspace object or image array
            htmlToolTip = ['<html><b>Assign data to a variable in workspace:</b><br><table>',...
                '<tr><td><u>Normal click</u></td><td>: Create handle to this arrayShow object</td></tr>',...
                '<tr><td><u>Shift+click</u></td>: Copy all images</td></tr>',...
                '<tr><td><u>Ctrl+click</u></td>: Copy current image</td></tr></table></html>'];
            uipushtool('Parent',toolBar,'Tag','Annotation.createWsObj',...
                'TooltipString', htmlToolTip,...
                'ClickedCallback', @(src, evnt)createWsObjButtonCb(),...
                'CData',obj.icons.wsObj,...
                'Separator','on');
            function createWsObjButtonCb()
                modifiers = get(obj.fh,'currentModifier');
                if isempty(modifiers)
                    % create workspace object
                    obj.createWorkspaceObject();
                else
                    if ismember('control',modifiers)
                        % coppy current image to workspace
                        obj.copyImg2Ws(true, true);
                    else
                        if ismember('shift',modifiers)
                            % copy all images to workspace
                            obj.copyImg2Ws(false, true);
                        end
                    end
                end
            end
            
            if obj.linkedToWorkspaceArray
                uipushtool('Parent',toolBar,'Tag','Annotation.reload',...
                    'TooltipString', 'Reload image array from workspace',...
                    'ClickedCallback', @(src, evnt)obj.reloadWorkspaceArray,...
                    'CData',obj.icons.upload,...
                    'Separator','off');
                uipushtool('Parent',toolBar,'Tag','Annotation.put',...
                    'TooltipString', 'Update image array in workspace',...
                    'ClickedCallback', @(src, evnt)obj.updateWorkspaceArray,...
                    'CData',obj.icons.download);
            else
                %                 uipushtool('Parent',toolBar,'Tag','Annotation.put',...
                %                     'TooltipString', 'Copy all images to workspace',...
                %                     'ClickedCallback', @(src,evnt)obj.copyImg2Ws(false,true),...
                %                     'CData',iconRead(fullfile(obj.iconPath,'download.png')),...
                %                     'Separator','on');
            end
            
            % multi function play and pause buttons
            obj.setupPlayButton(); % because the button can be dynamically 
                                    % replaced by a pause            
                                    % button, its creation routines are put 
                                    % in a dedicated function.
        end
        
        function updateDynamicSqueezeButton(obj)
            
            sel = obj.selection.getDimensions;
            
            if any(sel == 1) && length(sel) > 2
                if ~(isfield(obj.tbh,'squeeze') && ishandle(obj.tbh.squeeze))
                    obj.tbh.squeeze = uipushtool('Parent',obj.tbh.base,'Tag','Annotation.squeeze',...
                        'TooltipString', 'Squeeze image array',...
                        'ClickedCallback', @(src, evnt)squeezeCb(obj),...
                        'CData',obj.icons.squeeze);
                end
            end
            function squeezeCb(obj)
                obj.data.squeeze
                delete(obj.tbh.squeeze);
            end
        end
        
        function initContextMenus(obj, infoText)
            % ---------------------------
            % control panel context menu
            % ---------------------------
            obj.cpcmh.base = uicontextmenu;
            obj.cpcmh.infoText = uimenu(obj.cpcmh.base,'Label','Show Info Textbox'   ,...
                'checked','off',...
                'callback',@(src,evnt)toggleTextboxVisibility(obj));
            
            uimenu(obj.cpcmh.base,'Label','Squeeze'   ,...
                'callback',@(src,evnt)obj.data.squeeze(),...
                'Separator','on');
            uimenu(obj.cpcmh.base,'Label','Permute'   ,...
                'callback',@(src,evnt)obj.data.permute());
            uimenu(obj.cpcmh.base,'Label','Reshape'   ,...
                'callback',@(src,evnt)obj.data.reshape());
            
            mb_coldivi = uimenu(obj.cpcmh.base,'Label','Set colon dim divisor',...
                'Separator','on');
            arrShow.populateColonDimDivisorSubmenu(obj,mb_coldivi);
            uimenu(obj.cpcmh.base,'Label','Set selection string (s)'   ,...
                'callback',@(src,evnt)obj.selection.openSetValueDlg());
            uimenu(obj.cpcmh.base,'Label','Set destructive selection string (S)'   ,...
                'callback',@(src,evnt)obj.data.setDestructiveSelectionString());
            
            set(obj.cph,'uicontextmenu',obj.cpcmh.base);
            
            if ~isempty(infoText)
                obj.infotext.setInfotext(infoText);
                obj.infotext.setVisible('on');
                set(obj.cpcmh.infoText,'Checked','on');
                clear('infoText');
            end
            
            
            
            % ---------------------------
            % figure context menu
            % ---------------------------
            
            % ROI
            uimenu(obj.fcmh.base,'Label','Draw ROI'   ,...
                'Separator','on', 'callback',@(src,evnt)obj.createRoi);
            uimenu(obj.fcmh.base,'Label','Paste ROI position'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.pasteRoi);
            
            % colormaps
            cmh_cmap = uimenu(obj.fcmh.base,'Label'  ,'Colormap','Separator','on');
            obj.populateColormapMenu(cmh_cmap, @(map)obj.setColormap(map,'standard'));
            uimenu(cmh_cmap,'Label','Send','callback',@(src,evnt)obj.sendColormap('standard'),'Position',1);
            
            % phase colormap
            cmh_cmapPha = uimenu(obj.fcmh.base,'Label'  ,'Phase colormap');
            obj.populateColormapMenu(cmh_cmapPha, @(map)obj.setColormap(map,'phase'));
            uimenu(cmh_cmapPha,'Label','Send','callback',@(src,evnt)obj.sendColormap('standard'),'Position',1);
            
            
            % FFT / iFFT
            uimenu(obj.fcmh.base,'Label','Show 2D FFT (f)'  ,...
                'callback',@(src,evnt)obj.data.fft2SelectedFrames(),...
                'Separator','on');
            uimenu(obj.fcmh.base,'Label','Show 2D iFFT (d)' ,...
                'callback',@(src,evnt)obj.data.ifft2SelectedFrames());
            
            % selected image to Workspace
            cmh_copy2Ws = uimenu(obj.fcmh.base,'Label','Copy current image to workspace',...
                'Separator','on');
            if isreal(obj.data.dat)
                set(cmh_copy2Ws,'callback',@(src,evnt)obj.copyImg2Ws(true,false));
            else
                uimenu(cmh_copy2Ws,'Label','selected complex part' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,false));
                uimenu(cmh_copy2Ws,'Label','complex array' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,true));
            end
            
            % save image
            sub3 = uimenu(obj.fcmh.base,'Label','Export current image to file...');
            uimenu(sub3,'Label','Original data (Ctrl + e)',...
                'callback',@(src,evnt)obj.exportCurrentImage('',false,false));
            uimenu(sub3,'Label','Frame with roi',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,false));
            uimenu(sub3,'Label','Frame with panels',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,true));
            uimenu(obj.fcmh.base,'Label','Print current image',...
                'callback',@(src,evnt)obj.printCurrentImage);
            
            % image text
            uimenu(obj.fcmh.base,'Label','Create image text' ,...
                'callback',@(src,evnt)obj.createImageText(mydlg),...
                'Separator', 'on');
            
            set(obj.fph,'uicontextmenu',obj.fcmh.base)
            
        end
        
        function populateColormapMenu(obj, menuHandle, cb)
            uimenu(menuHandle,'Label','Edit'         ,'callback',@(src,evnt)colormapEditorCb(obj),'separator','on');
            uimenu(menuHandle,'Label','Load'         ,'callback',@(src,evnt)obj.loadColormap);
            uimenu(menuHandle,'Label','Store'        ,'callback',@(src,evnt)obj.storeColormap);
            
            uimenu(menuHandle,'Label','Gray (g)'     ,'callback',@(src,evnt)cb('gray(256)'), 'Separator', 'on');
            uimenu(menuHandle,'Label','Gray periodic','callback',@(src,evnt)cb('gray_periodic(256)'));
            uimenu(menuHandle,'Label','martin_phase' ,'callback',@(src,evnt)cb('martin_phase(256)'));
            uimenu(menuHandle,'Label','Red/Green periodic','callback',@(src,evnt)cb('redgreen_periodic'));
            uimenu(menuHandle,'Label','Jet (j)'      ,'callback',@(src,evnt)cb('jet(256)'));
            uimenu(menuHandle,'Label','YlGnBu_r (y)'     ,'callback',@(src,evnt)cb('YlGnBu_r'));
            if ~verLessThan('matlab','8.4.0')
                uimenu(menuHandle,'Label','Parula'      ,'callback',@(src,evnt)cb('parula(256)'));
            end
            uimenu(menuHandle,'Label','HSV'          ,'callback' ,@(src,evnt)cb('hsv(256)'));
            uimenu(menuHandle,'Label','Hot'          ,'callback' ,@(src,evnt)cb('hot(256)'));
            uimenu(menuHandle,'Label','Cool'         ,'callback' ,@(src,evnt)cb('cool(256)'));
            uimenu(menuHandle,'Label','Spring'       ,'callback' ,@(src,evnt)cb('spring(256)'));
            uimenu(menuHandle,'Label','Summer'       ,'callback' ,@(src,evnt)cb('summer(256)'));
            uimenu(menuHandle,'Label','Autumn'       ,'callback' ,@(src,evnt)cb('autumn(256)'));
            uimenu(menuHandle,'Label','Winter'       ,'callback' ,@(src,evnt)cb('winter(256)'));
            uimenu(menuHandle,'Label','Bone'         ,'callback' ,@(src,evnt)cb('bone(256)'));
            uimenu(menuHandle,'Label','Copper'       ,'callback' ,@(src,evnt)cb('copper(256)'));
            uimenu(menuHandle,'Label','Pink'         ,'callback' ,@(src,evnt)cb('pink(256)'));
            uimenu(menuHandle,'Label','Lines'        ,'callback' ,@(src,evnt)cb('lines(256)'));
            
            uimenu(menuHandle,'Label','Enter name...','callback',@(src,evnt)cb([]),'separator','on');
        end
        
        function colormapEditorCb(obj)
            % The matlab colormapeditor allows for altering the colormap
            % even after the program returns from the function call
            % 'colormapeditor'. The 'cmapMightBeModified' workaround causes
            % arrayShow to retrieve the potentially modified from the
            % figure handle during updFig.
            if verLessThan('matlab','8.4')
                colormapeditor(obj.fh);
            else
                % why the hell did mathworks remove the option to pass the
                % figure handle to the colormapeditor ?!?
                % ...ok, workaround:
                %
                % enable the handle visibility
                set(obj.fh,'HandleVisibility','on');
                
                % make the arrayShow figure the current one
                figure(obj.fh)
                
                % call the colormapeditor
                colormapeditor;
                
                % disable the handle visibility
                set(obj.fh,'HandleVisibility','off');                                    
            end
            
            if strcmp(obj.complexSelect.getSelection,'Pha')
                obj.phaCmapMightBeModified = true;
            else
                obj.stdCmapMightBeModified = true;
            end
        end
        
    end
    methods (Access = protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end
        
        function closeReq(obj, src)
            obj.msg('executing close request from handle %d\n',src);
            if isfield(obj.infotext, 'closeLargeWindow')
                obj.infotext.closeLargeWindow;
            end
            delete(src);
            delete(obj);
            arrShow.cleanGlobalAsArray
        end
        
        function cpResize(obj)
            % controlPanel resize callback
            % (assures, that the control panel keeps it's height)
            oldUnits = get(obj.cph,'Units');
            
            % set units to centimeters and deactivate resize callback
            set(obj.cph,'Units','Centimeters');
            
            
            pos = get(obj.cph,'Position');
            % pos = [left bot width height]
            
            h = obj.CP_HEIGHT;
            offset = pos(4) - h;
            newBot = pos(2) + offset;
            
            newPos = [pos(1), newBot, pos(3), h];
            
            set(obj.cph,'Position',newPos);
            
            % restore settings
            set(obj.cph,'Units',oldUnits);
            
        end
        
        function bpResize(obj)
            % bottom Panel resize callback
            % (assures, that the position panel keeps it's height)
            oldUnits = get(obj.bph,'Units');
            
            % set units to centimeters and deactivate resize callback
            set(obj.bph,'Units','Centimeters');
            
            pos = get(obj.bph,'Position');
            % pos = [left bot width height]
            
            h = obj.BP_HEIGHT;
            
            newPos = [pos(1), pos(2), pos(3), h];
            
            set(obj.bph,'Position',newPos);
            
            % restore settings
            set(obj.bph,'Units',oldUnits);
            
            % call resize function of the cursor position object
            obj.cursor.updateLayout();
        end
        
        function fpResize(obj, suppressImageRedraw)
            % figurePanel resize callback
            %             set(obj.fh,'ResizeFcn',[]);
            
            if nargin < 2
                suppressImageRedraw = false;
            end
            
            % backup unit settings
            fhUnits = get(obj.fh,'Units');
            fpUnits = get(obj.fph,'Units');
            
            % set units to centimeters
            set(obj.fh,'Units','Centimeters');
            set(obj.fph,'Units','Centimeters');
            
            % get new size of the home figure
            pos = get(obj.fh,'Position');
            % pos = [left bot width height]
            
            % create new position vector for the figurePanel
            newPos = [0, obj.BP_HEIGHT, pos(3), pos(4) - obj.CP_HEIGHT - obj.BP_HEIGHT ];
            set(obj.fph,'Position',newPos);
            
            % save pixel position to object
            set(obj.fh,'Units','pixel');
            obj.figurePosition = get(obj.fh,'Position');
            
            % restore unit settings
            set(obj.fh,'Units',fhUnits);
            set(obj.fph,'Units',fpUnits);
            
            % call resize functions for control- and bottom panel
            obj.cpResize;   % control panel
            obj.bpResize;   % bottom panel
            
            if ~suppressImageRedraw
                obj.updFig;
            end
            
            if obj.sendWdwSize
                obj.sendFigureSize;
            end
            
            %             set(obj.fh,'ResizeFcn',@(src, evnt)obj.fpResize);
        end
        
        function updFig(obj)
            
            % reactivate handle visibility
            set(obj.fh,'HandleVisibility','on');
            
            % if the images are not complex,...
            if isreal(obj.data.dat)
                % disable the imag and phase button in the complexSelect
                % object
                obj.complexSelect.lockImagAndPhase(true);
                
                % allow the cursor object to hide complex informations if
                % the available text space is low
                obj.cursor.setComplexMode(false);
            else
                obj.complexSelect.unlockImagAndPhase;
                obj.cursor.setComplexMode(true);
            end
            
            
            % get the toggle state of 'keep aspect ratio' context menu
            % entry
            switch get(obj.mbh.aspectRatio,'Checked');
                case 'on'
                    aspectRatio = true;
                case 'off'
                    aspectRatio = false;
            end
            
            % check and copy roi object if necessary
            roiPos = [];
            if ~isempty(obj.roi)
                if isvalid(obj.roi)
                    roiPos = obj.roi.getPosition;
                    delete(obj.roi);
                end
            end
            
            % get selected images
            selCplxImgs = squeeze(obj.getSelectedImages(true));
            
            % isolate selected complex part
            fun = obj.complexSelect.getFunPointer();
            selImgs = fun(selCplxImgs);
            
            % force complex representation?
            if obj.forceComplexRepresentation && ...
                    strcmp(obj.complexSelect.getSelection,'Com')
                forceComplex = true;
            else
                forceComplex = false;
            end
            
            % perform postProcessing
            if isempty(obj.postProcFun)
                ppImgs = selImgs;
            else
                try
                    ppImgs = obj.postProcFun(selImgs);
                catch err
                    disp(err);
                    disp(err.message);
                    ppImgs = selImgs;
                    obj.postProcFun = [];
                end
            end
            
            
            % get true size toggle
            trueSize = obj.getTrueSizeToggle();
            
            % get previous zoom level
            prevDim  = obj.statistics.getDimensions();
            prevZoom = obj.getZoom();
            
            
            % get colormap for current complexSelection
            cMap = obj.getColormap;
            
            % reset the modified colormap toggles
            obj.phaCmapMightBeModified = false;
            obj.stdCmapMightBeModified = false;
            
            % use quiver?
            useQuiver = arrShow.onOffToBool(get(obj.mbh.quiver,'Checked'));
            
            % display the images and save image handle
            try
                [allAxes, obj.ih] = imageCollage(...
                    ppImgs,...      % postprocessed images
                    obj.fph,...     % figure panel handle
                    cMap,...        % colormap
                    aspectRatio,...
                    trueSize,...
                    useQuiver,...
                    forceComplex);
            catch ME
                obj.errorHandlerInvalidData(ME);
                return;
            end
            noImgs  = length(obj.ih); % number of currently shown images
            
            % assign the original complex image data to the axes handles
            for i = 1 : noImgs
                ud = get(allAxes(i),'UserData');
                ud.cplxImg = selCplxImgs(:,:,i);
                set(allAxes(i),'UserData',ud);
            end
            
            % assign context menu to all new images
            for i = 1 : noImgs
                set(obj.ih(i),'uicontextmenu',obj.fcmh.base);
            end
            
            % update image stats- and image windowing object
            if strcmp(obj.complexSelect.getSelection,'Pha')
                obj.window.toggleUsePhaseCW(true);
            else
                obj.window.toggleUsePhaseCW(false);
            end            
            for i = length(obj.ih): -1 : 1
                try
                    % to speedup the start time, full initial data inspection is
                    % deactivated since Version 0.33. Due to
                    % this, invalid values will usually remain
                    % undetected until the windowing class
                    % tries to determine the image min and
                    % max. Therefore the error handling is now put to this place                    
                    obj.window.linkToImage(obj.ih(i));
                catch ME
                    obj.errorHandlerInvalidData(ME);
                    return;
                end
            end
            obj.statistics.setImageStats(obj.ih(1));
            
            % apply previous zoom level
            newDim  = obj.statistics.getDimensions();
            if all(newDim == prevDim)
                obj.setZoom(prevZoom);
            end
            
            % draw new roi
            if ~isempty(roiPos)
                obj.createRoi(roiPos)
            end
            
            % update imageText
            if ~isempty(obj.imageText) && isvalid(obj.imageText)
                
                % inform imageText about the potentially new axesHandle
                obj.imageText.updateAxesHandle(obj.getCurrentAxesHandle);
                
                % if the image text is supposed to be the title, just
                % update the the text...
                if obj.titleAsImageText                                
                    obj.imageText.setString(obj.title);
                else
                    % otherwise...
                    
                    % get the image-text cell vector size 
                    imageTextCellSize = obj.imageText.getImageTextCellSizeAsCell; % get the selection string

                    % if this vector is empty, the image text is 
                    % the same for each frame and just needs to be updated
                    if isempty(imageTextCellSize)
                        str = obj.imageText.getString;
                        obj.imageText.setString(str);
                    else                        
                        
                        % otherwise (the image text is a cell vector) we
                        % have to select the correct text for the current
                        % frame...
                        
                        % get the image selection as cell vector of strings
                        cellSel = obj.selection.getValueAsCell(true);

                        % find the 'colon dimensions' (even the ones which
                        % might not be tagged as colonDimensions)
                        colDims = find(strcmp(cellSel,':'));
                        
                        % to create a selection vector for the image text,
                        % replace colons in cellSel by '1'
                        cellSel(colDims) = {'1'};                        
                        
                        % check if the imageTextCellSize matches the image
                        % imageDimension when neglecting colon dimensions
                        imgDims = obj.getImageDimensions;
                        imgDims(colDims) = 1;
                        if all(imgDims == cellfun(@str2num,imageTextCellSize))
                            obj.imageText.setString('', cellSel);                                                        
                        else
                            fprintf(1, 'Warning: The size of the imageText cell vector does not fit to the number of frames.\n');                                                        
                        end

                    end
                                        
                end
            end
            
            % update pixel markers
            obj.markers.updateAxesHandles(allAxes);
            complxSel = obj.complexSelect.getSelection();
            if strcmp(complxSel,'Com') || strcmp(complxSel,'Pha')
                obj.markers.setColor(obj.MARKER_COL_PHA);
            else
                obj.markers.setColor(obj.MARKER_COL_REAL);
            end
            
            % insert colorbar (if the respective button is enabled)
            if strcmp( get(obj.tbh.colorbar,'State'), 'on')
                colorbar('peer',obj.getCurrentAxesHandle);
            end
            
            % update dynamic squeeze button
            obj.updateDynamicSqueezeButton;
            
            
            % prevent main window from becoming target of other graphic
            % outputs
            set(obj.fh,'HandleVisibility','off');
            
            % update cursor position
            obj.cursor.setPosition(obj.cursor.getPosition(),true);
            
            % run user callback function
            if ~isempty(obj.userCallback)
                obj.userCallback(obj);
            end
            
            % increase updFig counter
            obj.updFigCount = obj.updFigCount + 1;
            
        end
        
        function errorHandlerInvalidData(obj, ME)
            if any(strfind(ME.identifier,'ExpectedFinite')) || ~obj.processingError;
                % apparently there are invalid values in the data
                fprintf('DATA CONTAINS INFINITE VALUES.\nFORCING FULL DATA INSPECTION...');

                % try to replace them by zeros in the full data
                obj.data.replaceInvalidDataWithZeros();

                % set the processingError toggle to true
                obj.processingError = true;

                % rerun updFig with the new data
                obj.updFig();

                % if updFig finished successfully this time, reset
                % the error processing flag
                fprintf(' That seems to have worked.\n');
                obj.processingError = false;
            else
                throw(ME);
            end
        end                    
        
        function roiCallback(obj, pos)
            obj.applyToRelatives('createRoi',false,pos);
        end
        
        function keyPressCb(obj,evnt, varargin)
            if ~obj.processingCallback
                obj.processingCallback = true;
                
                % copy the evnt.key property, since it has apparently
                % become read-only in matlab 2014b
                key = evnt.Key;
                
                % if a control key is pressed, alter event.Key string
                if ~isempty(evnt.Modifier)
                    % combine all modifiers to a single string
                    mod = cell2mat(evnt.Modifier);
                    
                    % search the string for keywords 'shift' or 'alt' or
                    % 'control'
                    if any(strfind(mod,'shift'))
                        key = strcat('s',key);
                    end
                    if any(strfind(mod,'alt'))
                        key = strcat('a',key);
                    end
                    if any(strfind(mod,'control'))
                        key = strcat('c',key);
                    end
                    
                end
                
                switch key
                    
                    % image export
                    case 'ce'
                        obj.exportCurrentImage('',false,false);
                        
                        % figure title
                    case 't'
                        obj.setFigureTitle;
                    case 'st'
                        asSetAllTitlesToImageString();
                    case 'ct'
                        obj.toggleTitleAsImageText();
                        
                        % lock controls
                    case 'backquote'
                        obj.enableControls(arrShow.onOffToBool(get(obj.mbh.lockCntrls,'Checked')))
                        
                        % selected image
                    case 's'
                        obj.selection.openSetValueDlg;
                    case 'ss'
                        obj.data.setDestructiveSelectionString()
                        
                        
                        % complex selector
                    case 'm'
                        obj.complexSelect.setSelection('Abs');
                    case 'sm'
                        obj.complexSelect.setSelection('Com');
                        
                    case 'p'
                        obj.complexSelect.setSelection('Pha');
                    case 'sp'
                        obj.cursor.toggleDrawPhaseCircle();
                        
                    case 'r'
                        obj.complexSelect.setSelection('Re');
                    case 'i'
                        obj.complexSelect.setSelection('Im');
                        
                        
                        
                        % FFT
                    case 'f'    %FFT
                        obj.data.fft2SelectedFrames();
                    case 'sf'
                        obj.data.fft2All(); %FFT all
                        
                    case 'd'    %IFFT
                        obj.data.ifft2SelectedFrames();
                    case 'sd'
                        obj.data.ifft2All(); %IFFT all
                        
                    case 'csf'   % fftshift
                        obj.data.fftshift2All;                        
                        
                        
                        
                        % cursor position
                    case 'x'
                        obj.cursor.send;
                    case 'sx'
                        obj.cursor.toggleSend();
                        
                        
                        
                        % plotAlontDim
                    case 'v'
                        obj.cursor.plotAlongPlotDim;
                    case 'sv'
                        obj.cursor.togglePlotAlongDim();
                        
                        % user cursor position function
                    case 'sc'
                        obj.cursor.toggleCallUserCursorPosFunc;
                    case 'c'
                        obj.cursor.userCursorPosFcn;
                        
                        
                        % colormap
                    case 'j'
                        obj.setColormap('Jet(256)');
                    case 'g'
                        obj.setColormap('Gray(256)');
                    case 'h'
                        obj.setColormap('hot(256)');
                    case 'y'
                        obj.setColormap('ylgnbu_r');
                        
                        % windowing
                    case 'cc'
                        obj.window.copyAbsWindow();
                    case 'cv'
                        obj.window.pasteAbsWindow();
                    case 'co'
                        obj.window.loadAbsWindow();
                        
                        
                        % zoom
                    case 'z'
                        obj.toggleZoomCursor();
                    case 'csc'
                        obj.copyZoom();
                    case 'csv'
                        obj.pasteZoom();
                    case 'c1'
                        obj.setZoom(0);
                    case 'c2'
                        obj.setZoom(2,true);
                    case 'c3'
                        obj.setZoom(3,true);
                    case 'c4'
                        obj.setZoom(4,true);
                        
                        
                        
                        % selection
                    case {'uparrow', 'downarrow','leftarrow','rightarrow'}
                        if ~isempty(obj.selection)
                            % make sure, that a valueChangerObject is selected
                            %   ( the keypress will also be captured and evaluated
                            %   by this valueChanger)
                            selObjParent = get(get(obj.fh,'CurrentObject'),'Parent');
                            
                            if(isempty(selObjParent)...
                                    || selObjParent ~= obj.selection.getPanelH)
                                obj.selection.selectVco;
                            end
                            
                        end
                        
                        
                        % selected view range (FOV)
                    case 'a1'
                        obj.selection.setColonDimDivisor(1);
                    case 'a2'
                        obj.selection.setColonDimDivisor(2);
                    case 'a3'
                        obj.selection.setColonDimDivisor(3);
                    case 'a4'
                        obj.selection.setColonDimDivisor(4);
                        
                        
                        
                    case 'sz'    %impixelregion
                        impixelregion(obj.fh);
                        
                        
                        % main window size
                    case 'af1'
                        obj.resetFigurePosition
                    case {'af2','f2'}
                        obj.setFigureSize([341 444]);
                        
                        
                    case {'escape','af4'}   %CLOSE
                        obj.closeReq(obj.fh);
                        return;
                    case 'sescape'
                        asCloseAll;
                        return;
                        
                    case 'f5'   % refresh relatives list
                        obj.refreshRelativesList();
                        
                        
                        
                        
                        % relatives
                    case 'b' % asBrowse
                        ab;
                        
                    case 'l' %lineup
                        asLineup();
                    case 'sl'
                        arrShow.openLineupDlg();
                    case 'cl' % lineup top left
                        asLineup([],[],[],1,1);
                        
                        
                        
                    otherwise
                        switch evnt.Character
                            % position plots
                            case '-'
                                obj.cursor.plotRow();
                            case '|'
                                obj.cursor.plotColumn();
                            case '+'
                                obj.cursor.togglePlotRowAndCol();
                                
                        end
                        
                end
                obj.processingCallback = false;
            end
        end
        
        function scollWheelCb(obj,~,evnt)
            modifiers = get(obj.fh,'currentModifier');
            zoomMode = ismember('control',modifiers);
            if zoomMode
                mousePos  = obj.cursor.getPosition();
            end
            
            switch evnt.VerticalScrollCount
                case -1  %up
                    if zoomMode
                        obj.setZoom(obj.mouse_wheel_zoom_factor,0,mousePos);
                    else
                        if ~isempty(obj.selection)
                            if obj.selection.getCurrentVcColonDimTag == 0
                                obj.selection.increaseCurrentVc();
                            else
                                obj.selection.selectNeighbour(1);
                            end
                        end
                    end
                case 1  % down
                    if zoomMode
                        obj.setZoom(1./obj.mouse_wheel_zoom_factor,0,mousePos);
                    else
                        if ~isempty(obj.selection)
                            if obj.selection.getCurrentVcColonDimTag == 0
                                obj.selection.decreaseCurrentVc();
                            else
                                obj.selection.selectNeighbour(-1);
                            end
                        end
                    end
            end
        end
        
        function buttonDownCb(obj,src,~)            

        if toc(obj.buttonUpCbTime) < 1e-1 && ~strcmp(get(src,'SelectionType'),'open')
            % workaround: check if the previous buttonUp callback
            % is less than 100ms ago (see the description of
            % obj.buttonUpCbTime in the property section for details)
            return;
        end
            if ~ishandle(src)
                % sometimes a button down callback seems to be called
                % after the parent window has already been destroyed.
                % this workaround is to avoid occuring errors due to this
                % not yet fully understood bug...
                return;
            end

            switch get(src,'SelectionType')

                case 'normal' % left button
                    % check if an image is selected
                    [bool, imageHandle] = obj.isImageSelected();
                    
                    if bool && obj.window.getIsEnabled()
                        
                        % check if the current axes has changed
                        currAxes = get(imageHandle,'Parent');
                        lastAxes = obj.window.getAxesHandle();
                        if currAxes ~= lastAxes;
                            % if so:
                            % delete cursor rectangle from last Axes
                            ud = get(lastAxes,'UserData');
                            if ~isempty(ud) && isfield(ud,'rect')
                                delete(ud.rect);
                                ud.rect = [];
                            end
                            set(lastAxes,'UserData',ud);
                            
                            % link the windowing to the current axes
                            obj.window.linkToImage(imageHandle);                        
                            
                            % and update the image statistics
                            obj.statistics.setImageStats(imageHandle);                            
                        else                        
                            % store the current cursor position as
                            % reference Point
                            currentAxes = obj.window.getAxesHandle();
                            obj.mouseReferencePoint = get(currentAxes,'CurrentPoint');
                            
                            % acticate dragging mode
                            obj.mouseMovementMode = 2;
                        end                        
                    end
                    
                case 'extend'  % middle button

                    % check if we did a middle-button click on the image
                    [bool, imageHandle] = obj.isImageSelected();
                    
                    if bool && obj.window.getIsEnabled();
                        
                        % assure that the windowClass is linked to the
                        % clicked image
                        obj.window.linkToImage(imageHandle);
                        
                        % store the current cursor position as
                        % reference Point
                        currentAxes = obj.window.getAxesHandle();
                        obj.mouseReferencePoint = get(currentAxes,'CurrentPoint');
                        
                        % set mouse windowing mode to true
                        obj.mouseMovementMode = 1;
                        
                    end
                    
                case 'alt' % right button
                    switch obj.mouseMovementMode
                        case 1 % mouse windowing is active
                            % reset the image windowing
                            obj.window.resetWindowing();
                            obj.mouseMovementMode = 0;
                            obj.equalizeWindowing();
                        
                        otherwise                            
                            % deactivate dragging mode
                            obj.mouseMovementMode = 0;

                    end
                    
                case 'open' %double click
                    if obj.window.getIsEnabled();                        
                        obj.window.resetWindowing();
                        obj.mouseMovementMode = 0; 
                        obj.equalizeWindowing();
                    end
            end
            
        end
        
        function buttonUpCb(obj,src)
            
            % workaround: store the current time (see the description of
            % obj.buttonUpCbTime in the property section for details)
            obj.buttonUpCbTime = tic;           
            
            % always: deactivate mouse windowing or dragging
            obj.mouseMovementMode = 0;
            
            % for the center mouse button...:
            if strcmp(get(src,'SelectionType'), 'extend')                
                % ...and for multiframe views:
                % update the windowing of all frames
                if  obj.window.getIsEnabled();
                    obj.equalizeWindowing();
                end
            end
        end
        
        function equalizeWindowing(obj)            
            % equalize the windowing of all views in multiframe view
            
            % get number of views (available image handles)
            nh = length(obj.ih);
            
            % if we have more than one view (we are in multiframe mode),
            % update the windowing
            if nh > 1
                % get the currently selected image
                selectedImageH = obj.window.getImageHandle;

                % loop through all available other image objects
                for i = 1 : length(obj.ih)
                    if obj.ih(i) ~= selectedImageH
                        % by linking the windowing object to the image, the
                        % windowing is automatically updated
                        obj.window.linkToImage(obj.ih(i));
                    end
                end
                % finally, reselect the original image
                obj.window.linkToImage(selectedImageH);
            end
        end
        
        function mouseMovementCb(obj)
            
            if ~obj.processingCallback
                obj.processingCallback = true;
                
                if obj.mouseMovementMode == 0
                    % normal mode: just update the cursor position
                    for i = 1 : length(obj.ih)
                        currAxes = get(obj.ih(i),'Parent');
                        position = get(currAxes,'CurrentPoint');

                        if arrShow.mouseInsideAxes(position, currAxes);
                            x = round(position(1,1));
                            y = round(position(1,2));

                            obj.cursor.setPosition([y,x],false);
                            break;
                        end
                    end
                else % (obj.mouseMovementMode ~= 0)
                    % we are either in windowing or dragging mode
                    
                    % get the number of pixels, the cursor has moved
                    currentAxes = obj.window.getAxesHandle();
                    refC   = obj.mouseReferencePoint;
                    currC  = get(currentAxes,'CurrentPoint');
                    
                    % the x/y coordinates are swapped
                    difference(2) =  refC(1,1) - currC(1,1);
                    difference(1) =  refC(1,2) - currC(1,2);

                    
                    if obj.mouseMovementMode == 1 % mouse windowing mode                    
                        % invert x-direction to behave similar to siemens
                        difference(2) = -difference(2);

                        % standardize with image dimensions
                        difference = difference .* [1,4] ./ obj.statistics.getDimensions();

                        % get current center and  width; standardize with image
                        % width
                        CW = obj.window.getCW();
                        imageWidth = obj.window.getDataWidth();
                        CW = CW / imageWidth;

                        % derive and apply new center and width settings
                        CW = (CW + difference) * imageWidth;
                        obj.window.setCW(CW,false);

                        % set current cursor position as new reference
                        obj.mouseReferencePoint = currC;
                        
                    else % dragging mode

                        % shift the image
                        obj.shiftImage(difference);

                        % get the current point in the potentially altered
                        % FOV
                        currC  = get(currentAxes,'CurrentPoint');
                                                
                        % set current cursor position as new reference
                        obj.mouseReferencePoint = currC;
                    end                        
                end
                obj.processingCallback = false;
            end
        end
        
        function copyImg2Ws(obj, onlySelectedImg, returnAsComplex)
            if nargin < 3
                returnAsComplex = true;
                if nargin < 2
                    onlySelectedImg = false;
                end
            end
            
            % create global variable 'currImg'
            global currImg;
            
            % assign current images to currImg
            if onlySelectedImg
                currImg = obj.getSelectedImages(returnAsComplex);
            else
                currImg = obj.data.dat;
            end
            
            % make the global variable visible in workspace
            evalin('base','global currImg');
            if onlySelectedImg
                disp('current image was copied to workspace variable ''currImg''');
            else
                disp('all images were copied to workspace variable ''currImg''');
            end
            disp('size(currImg) =');
            disp(size(currImg));
        end
        
    end
    
    methods (Static)
        
        function As3Obj = convertAs2Obj(As2Obj)
            
            for i = 1 : length(As2Obj)
                
                As3Obj(i) = arrShow(As2Obj(i).getAllImages,...
                    'Title',   As2Obj(i).getFigureTitle,...
                    'info',    As2Obj(i).infotext.getString,...
                    'window',  As2Obj(i).window.getCW(),...
                    'select',  As2Obj(i).selection.getValue,...
                    'colormap',As2Obj(i).getColormap,...
                    'Position',As2Obj(i).getFigurePosition); %#ok<AGROW> dont want to preallocate this vector of objects
                
                if ~isempty(As2Obj(i).UserData)
                    As3Obj(i).UserData = As2Obj(i).UserData; %#ok<AGROW> dont want to preallocate this vector of objects
                end
                
            end
        end
        
        
        function exportAllGlobalArrayImages()
            global asObjs;
            for i = 1 : length(asObjs)
                filename = asObjs(i).title;
                filename(isspace(filename))='_';
                filename = [filename, '.png']; %#ok<AGROW> filename is 
                                               %actually recreated in every
                                               %iteration it seems that the
                                               %editor is wrong here
                asObjs(i).exportCurrentImage(filename);
            end
        end
        
        function newObject = appendToGlobalAsArray(arr, varargin)
            % this static function allows for creating new instances of the arrShow
            % class within a common global workspace array 'asObjs'
            
            arrShow.cleanGlobalAsArray();
            
            global asObjs;
            
            if isa(arr,'arrShow');
                newObj = arr.rebuildObject(varargin{:});
            else
                if  isa(arr,'arrShow2') || isa(arr,'arrShow3')
                    % for backward compatibility
                    newObj = arrShow.convertAs2Obj(arr);
                else
                    
                    if isa(arr,'struct') && isfield(arr,'dat')
                        % arr seems to be an "arrayShow struct"
                        newObj = [];
                        for i = 1 : length(arr)
                            curr = arr(i);
                            dat = curr.('dat');
                            curr = rmfield(curr,'dat');
                            args = asDataClass.struct2varargin(curr);
                            newObj = [newObj, arrShow(dat, args{:})]; %#ok<AGROW>
                        end
                    else                    
                        % default case
                        newObj = arrShow(arr, varargin{:});
                    end
                end
            end
            
            asObjs = [asObjs,newObj];
            
            evalin('base','global asObjs');
            
            if nargout == 1
                newObject = newObj;
            end
        end
        
        function cleanGlobalAsArray()
            % This static function deletes all handles in the 'asObjs' array, which
            % refer to already deleted objects.
            
            global asObjs;
            
            if ~isempty(asObjs)
                asObjs(~isvalid(asObjs)) = [];
            end
            
            invInds = false(length(asObjs),1);
            for i = 1 : length(asObjs)
                if ~ishandle(asObjs(i).getFigureHandle)
                    invInds(i) = true;
                end
            end
            asObjs(invInds == true) = [];
            
            if isempty(asObjs)
                clear global asObjs;
            end
        end
        
        function in = mouseInsideAxes(position, axesHandle)
            X = get(axesHandle,'XLim');
            Y = get(axesHandle,'YLim');
            x = position(1,1);
            y = position(1,2);
            
            if ( x < X(1) || x > X(2) ||...
                    y < Y(1) || y > Y(2) )
                in = false;
            else
                in = true;
            end
        end
        
        function allAsObjs = findAllObjects()
            asFigures = findall(0,'Tag','arrShowFig');
            if isempty(asFigures)
                allAsObjs = [];
            else
                allAsObjs = get(asFigures,'UserData');
                if iscell(allAsObjs)
                    allAsObjs = cat(2,allAsObjs{:});
                end
                allAsObjs = allAsObjs(isvalid(allAsObjs));
            end
        end
        
        function onOff = boolToOnOff(bool)
            switch bool
                case 1
                    onOff = 'on';
                case 0
                    onOff = 'off';
                otherwise
                    error('arrShow:boolToOnOff','input is not a boolean');
            end
        end
        
        function bool = onOffToBool(onOff)
            switch onOff
                case 'on'
                    bool = true;
                case 'off'
                    bool = false;
                otherwise
                    error('arrShow:onOffToBool','input has to be either of the strings ''on'' or ''off''');
            end
        end
        
        
        function str = removeSpecialCharsFromString(str)
            % remove special characters from initname
            str(isspace(str))='_';
            delIdx = false(length(str),1);
            for i = 1 : length(str)
                switch(str(i))
                    case '.'
                        str(i) = ',';
                    case ':'
                        str(i) = ';';
                    case '<'
                        str(i) = '(';
                    case '>'
                        str(i) = ')';
                    case{'|', '/', '\'}
                        str(i) = '_';
                    case{'?','*','''','"'}
                        delIdx(i) = true;
                end
            end
            str = str(~delIdx);
        end
    end
    methods (Static, Access = private)
                
        function populateColonDimDivisorSubmenu(obj,mb_coldivi)
            uimenu(mb_coldivi,'Label','1 (Alt + 1)','callback',@(src,evnt)obj.selection.setColonDimDivisor(1));
            uimenu(mb_coldivi,'Label','2 (Alt + 2)','callback',@(src,evnt)obj.selection.setColonDimDivisor(2));
            uimenu(mb_coldivi,'Label','3 (Alt + 3)','callback',@(src,evnt)obj.selection.setColonDimDivisor(3));
            uimenu(mb_coldivi,'Label','4 (Alt + 4)','callback',@(src,evnt)obj.selection.setColonDimDivisor(4));
        end
        
        function openLineupDlg()
            global asObjs
            suggestion = ['1x',num2str(length(asObjs))];
            newValue = mydlg('Enter ordering','Lineup ordering Dlg',suggestion);
            if ~isempty(newValue)
                [M,N] = strread(newValue,'%d %d',1,'delimiter','x');
                if isempty(M) || isempty(N)
                    warning('lineupDlg:valueCheck','invalid value');
                    return;
                else
                    asLineup(M,N);
                end
            end
        end
        
        function cPlot(y)
            if isreal(y)
                plot(y);
            else
                plot([real(y),imag(y)]);
                %                     legend('real','imag'); % seems to be quite expensive
            end
        end
        
        function checkPath()
            % assure that all support function paths are registered
            
            % we basically have 3 subdirectories which have to be
            % registered to the path. The following lines check for an
            % exemplary function within each of the directories. If the
            % function cannot be found, the dir is added to the path.
            everythingSeemsFine = ...
                exist('drawPhaseCircle','file') &&...
                exist('asCloseAll','file') &&...
                exist('gray_periodic','file') &&...
                exist('complex2rgb','file');
            
            if ~everythingSeemsFine
                % try adding the paths
                fprintf(['Not all paths to the arraySow support functions ',...
                    'seem to be registered.\nTrying to add it ',...
                    'automatically...\nTo avoid this message in future Matlab sessions ',...
                    'call savepath or run the README.m again.\n']);
                basePath = fileparts(mfilename('fullpath'));
                addpath(basePath);
                addpath([basePath,filesep,'supportFunctions']);
                addpath([basePath,filesep,'scripts']);
                addpath([basePath,filesep,'cursorPosFcn']);
                addpath([basePath,filesep,'customColormaps']);
            end
            
        end
        
    end
end
