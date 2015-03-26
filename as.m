% AS Visualize a data array with arrayShow.
% (Shortcut to "arrShow.appendToGlobalAsArray(arr, varargin)")
% The arrShow handle object is hereby appended to the global variable
% 'asObjs' in the workspace, providing easy access to the
% object's methods or properties. 
%
% Hint: A list of all current arrShow objects can be displayed with 
% the command ab().
% 
% Usage: as(arr, varargin)
%
%  arr     : Either a numeric array or an arrayShow object 
%            (e.g. a stored object from a previous Matlab session)
%
%
%  varargin:
%   optional arguments with the syntax <option>,<value>
%
%
%  varargin options:
%
%   'title':
%       figure title string (e.g. 'tolles Bild')
%
%   'position':
%       initial position ([bottom, left, width, height])
%       of the arrayShow main window
%
%   'windowing':
%       start values [center, width] for the windowing
%       (i.e. brightness and contrast)
%
%   'select':
%       initial selection string, e.g.:
%       ':,:,3'        to select the 3rd frame in a 3D data array,
%       ':,:,:'        to show all frames at once, or
%       'end:-1:1,:,1' to show the first frame, mirrored along the x-axis
%
%   'complexSelect':
%       inital setting for the complexChooser class. Can be either
%       'Magnitude', 'Real', Imaginary', 'Phase', or 'Complex'.
%       (Or shortcuts: 'm', 'r', 'i', 'p', or 'c').
% 
%   'colormap':
%       initial colormap (cm) for non-complex data visualization. cm can
%       be either an actual RGB colormap with size(cm) = [N,3] or the name
%       of a standard matlab colormap, e.g. 'Gray(256)'
%
%   'phaseColormap:
%       initial colormap for phase visualization (e.g. 'Jet(16)')%
%
%   'imageText':
%       Text to be shown within the image. 
%       If the imageText value (txt) is a single string, e.g.
%       txt = 'supertolle Reco';,
%       txt is shown regardles of the selected frame. This can be useful
%       e.g. to annotate images prior printout or export.
%
%       For 3-dimensional image arrays and the 3rd dimension being a frame
%       numer, imageText can also be a cell array of strings with
%       number-of-frames entries. 
%       This allows for frame-spacific text overlays, e.g.
%       txt = {'Spin-Density', 'R2', 'T2'}        
%
%       For N-dimensional images in 'arr', and
%       size(arr) = [dimY, dimX, Na, Nb, ...]
%       Frame-specific text overlays are still possible with 
%       with txt being a cell array of strings and
%       size(txt) = [1, 1, Na, Nb, ...].
%       However, this functionality is yet only possible with the first 2
%       dimensions being the 'colon dimensions'.
%
%   'info':
%       string or parameter struct (par) to describe the data. E.g.:
%       par = 'just another image reconstruction';
%       or:
%       par.reco      = 'MARTINI';
%       par.accFactor = 5;
%       par.date      = date();
%
%       The information is shown within the arrayShow GUI and will be
%       conserved when saving the arrayShow object to a .mat file. The text
%       will also be included in the image-description file when using any 
%       of the image export methods.
%
%   'callback':
%       user-defined callback function (fun) which is triggered whenever the
%       image selection changes. The first argument of the callback function 
%       is the calling arrayShow object. E.g.:
%       fun = @(obj)disp(obj.selection.getValue());
%       or:
%       fun = @(tmp)disp('wer dies liest ist toll');
%
% ------------------------------------------------------------------------
%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


function newObj = as(arr, varargin)

% if no input argument is given: show help text
if nargin <1 || isempty(arr)
    help('as');
    return;
end


% auto title
if nargin > 1 && length(varargin) == 1
    % if only one additional argument is given, assume this to be the
    % desired figure title.
    % (This is an exception in the standard varargin syntax, but it's convenient)
    varargin = [{'inputname'}, varargin];    
else
    % per default use the name of the inputvariable "arr" as a title
    % (the 'auto title' is added at the beginning of the varargin vector 
    %  such that it will be overwritten if another inputname is explicitly given)
    varargin = [varargin, {'inputname'}, {inputname(1)}];    
end

% use global list of relatives per default
varargin = [varargin, {'useglobalarray'}, {true}];




% call arrShow
if nargout == 1
    newObj = arrShow.appendToGlobalAsArray(arr,varargin{:});
else
    arrShow.appendToGlobalAsArray(arr,varargin{:});
end

end
