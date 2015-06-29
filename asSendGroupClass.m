classdef asSendGroupClass < handle
    
    properties (GetAccess = private, SetAccess = private)
        ph      = 0 ; % panel handle
        
        sg      = 1; % send group (the main parameter to controlled)
                     % can be each positive integer number or -1 for "none"
                     % and 0 for "all"
        
        % send group button handle
        sgbh    = cell(6,1); % send groups 1-4, all, none, userDef
    end

    
    methods
        
        function obj = asSendGroupClass(parentPanel)
            obj.ph = parentPanel;
            
            % text height
            tHeight = .15;
            
            % text
            uicontrol('Style','Text',...
                'Parent', obj.ph,...
                'String','Send/Rec.-Group',...
                'FontSize',8,...
                'Units','normalized',...
                'HorizontalAlignment','left',...
                'Position',[0,1-tHeight,1,tHeight]);

            % initialize buttons            
            nsg = length(obj.sgbh); % number of send group buttons
            bWidth  = 1/nsg;    % normalized send group button width
            bHeight = .25;      % normalized send group button height
%             bBot    = .32;      % normalized send group button bottom position
            bBot    = 1-bHeight-tHeight;      % normalized send group button bottom position
            
                        
            % send group 1 to 3 buttons
            for c = 1 : 3
            obj.sgbh{c} = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[(c-1)*bWidth, bBot, bWidth, bHeight],...
                'tooltip',['Send group ',num2str(c)],...
                'Callback',@(src,evnt)obj.set(c),...
                'string',num2str(c));
            end
            
            % send group 0 (send to all) button
            c = c + 1;
            obj.sgbh{c} = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[(c-1)*bWidth, bBot, bWidth, bHeight],...
                'tooltip','Send group 0 (= send to all)',...
                'Callback',@(src,evnt)obj.set(0),...
                'string','A');
            
            
            % send group -1 (send and receive none)
            c = c + 1;
            obj.sgbh{c} = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[(c-1)*bWidth, bBot, bWidth, bHeight],...
                'tooltip','Send group -1 (= send and receive none)',...
                'Callback',@(src,evnt)obj.set(-1),...
                'string','-');

            % user defined send group
            c = c + 1;
            obj.sgbh{c} = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[(c-1)*bWidth, bBot, bWidth, bHeight],...
                'tooltip','User defined send group',...
                'Callback',@(src,evnt)obj.set(),...
                'string','...');       
            
            % activate first send group per default
            set(obj.sgbh{1},'value',true);
            
        end
        
        function set(obj, groupNo)

            % if no group number is given, open dialog
            if nargin < 2 || isempty(groupNo)
                groupNo = mydlg('Enter send/rec.-group','Group number input dlg',obj.sg);
                groupNo = str2double(groupNo);                
                if ~isfinite(groupNo)
                    set(obj.sgbh{6}, 'value', false);
                    return;
                end                
            end
            obj.sg = groupNo;
            
            % determine the button number that corresponds to the group number
            switch(groupNo)
                case -1
                    actButton = 5; % send/receive none                
                case 0
                    actButton = 4; % send/receive all-button
                case {1, 2, 3}
                    actButton = groupNo;
                otherwise
                    actButton = 6; % user defined group
            end    
            
            % activate the actButton, deactivate all others
            for i = 1 : length(obj.sgbh)
                set(obj.sgbh{i}, 'value', i==actButton);
            end
            
            if actButton == 6 %(user defined group)
                set(obj.sgbh{6}, 'string', num2str(groupNo));
            else
                set(obj.sgbh{6}, 'string', '...');
            end
                
        end
        
        function groupNo = get(obj)
            groupNo = obj.sg;
        end
    end
end

