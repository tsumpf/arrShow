%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef (Sealed) asIconClass <handle
    % the icon class is implemented as a singleton class to load the icons
    % only once per session

    properties (SetAccess = private, GetAccess = public)
        
        % each entry represents an icon which is loaded from an equally
        % named png file during object construction.
        
        asBrowse        
        colorbar
        dontSend
        download
        lineup
        magnify
        pause
        play
        refresh
        rotLeft
        rotRight
        send
        lock
        squeeze
        upload
        wsObj
        filter
        showMarker
    end
    
    % private constructor
    methods (Access = private)
        function obj = asIconClass
        end
    end
        
    methods (Static)
        
        % public method to get an instance of the iconClass
        
        function obj = getInstance(iconPath)
            
            % persistent variable (stays in memory even after the calling
            % arrayShow object has been closed)
            persistent localObj

            % if this is the first call, actually construct the object...
            % if not, just return the previous instance
            if isempty(localObj) || ~isvalid(localObj)
                
                localObj = asIconClass;
                
                % determine property names of this class
                iconNames = properties(mfilename);
                iconPaths = cellfun(@(x)[iconPath,filesep,x,'.png'],iconNames,...
                    'UniformOutput',false);                   

                % load pngs
                for i = 1 : length(iconNames)
                    localObj.(iconNames{i}) = iconRead(iconPaths{i});
                end

                % workaround for linux pcs with apparently sometimes different background colors
                if ~ispc()
                    defaultBg = get(0,'defaultuicontrolbackgroundcolor');
                    localObj.send  = imread(fullfile(iconPath,'send.png'),'Background',defaultBg);
                end                
            end
            
            obj = localObj;
            
        end
    end        
end
