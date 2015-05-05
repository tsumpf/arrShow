%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.0.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)

classdef asDataClass < handle
    
    properties (GetAccess = public, SetAccess = private)
        dat                  = [];   % the data dataArrayay
    end
    
    properties (Access = private)
        selection       = [];     % asSelectionClass object containing the valueChanger array
        
        updFig      = [];   % update figure callback from the main gui
        
        
        % allows methods to alter the image array, making it different from
        % the original that might still be in Workspace
        enableDestrFun  = true;
        
    end
    
    methods
        
        function enableDestructiveFunctions(obj, toggle)
            if nargin < 2
                toggle = true;
            else
                if ~isscalar (toggle)
                    warning('asDataClass:invalidArgument','invalid argument\n');
                end
            end
            obj.enableDestrFun = toggle;
        end
        
        function obj = asDataClass(dataArray, figureUpdateCallback)
                        
            % validate input data
            obj.dat = asDataClass.validateImageArray(dataArray);
            
            % store figure update callback to local property
            obj.updFig = figureUpdateCallback;
            
        end
        
        function linkToSelectionClassObject(obj, selectionClassObject)
            obj.selection = selectionClassObject;
        end
        
        
        
        function fft2SelectedFrames(obj)
            if obj.enableDestrFun
                str = obj.selection.getValue;
                
                % create a command string from the gathered informations
                command = strcat('obj.dat(',str,') = asDataClass.mrFft(obj.dat(',str,'));');
                
                % execute command
                eval(command);
                
                obj.updFig();
            end
        end
        
        function ifft2SelectedFrames(obj)
            if obj.enableDestrFun
                str = obj.selection.getValue;
                
                % create a command string from the gathered informations
                command = strcat('obj.dat(',str,') = asDataClass.mrIfft(obj.dat(',str,'));');
                
                % execute command
                eval(command);
                
                obj.updFig();
            end
        end
        
        function replaceInvalidDataWithZeros(obj)                
            obj.dat(~isfinite(obj.dat(:))) = 0;
        end                    
        
        function fftDim(obj, dim)
            obj.dat = asDataClass.mrFft(obj.dat, dim);
            obj.updFig();
        end

        function ifftDim(obj, dim)
            obj.dat = asDataClass.mrIfft(obj.dat, dim);
            obj.updFig();
        end
        
        function fftshift(obj, dim)
            obj.dat = fftshift(obj.dat, dim);
            obj.updFig();            
        end
        
        
        function fft2All(obj)
            if obj.enableDestrFun
                if numel(obj.dat) > 1e7
                    %                 mbh = waitbar(0,'deriving FFT of all
                    %                 images...','MenuBar','none');
                    mbh = msgbox('deriving FFT of all images...');
                    obj.dat = asDataClass.mrFft(obj.dat);
                    close(mbh);
                else
                    obj.dat = asDataClass.mrFft(obj.dat);
                end
                obj.updFig();
            end
        end
        
        function ifft2All(obj)
            if obj.enableDestrFun
                if numel(obj.dat) > 1e7
                    mbh = msgbox('deriving iFFT of all images...');
                    obj.dat = asDataClass.mrIfft(obj.dat);
                    close(mbh);
                else
                    obj.dat = asDataClass.mrIfft(obj.dat);
                end
                obj.updFig();
            end
        end
        
        function fftshift2All(obj)
            if obj.enableDestrFun
                if numel(obj.dat) > 1e7
                    %                 mbh = waitbar(0,'deriving FFT of all
                    %                 images...','MenuBar','none');
                    mbh = msgbox('deriving FFTshift2 of all images...');
                    obj.dat = asDataClass.fftshift2(obj.dat);
                    close(mbh);
                else
                    obj.dat = asDataClass.fftshift2(obj.dat);
                end
                obj.updFig();
            end
        end
        
        
        function rot90(obj, k)
            % performs rot90 on the colon dimensions.

            % check if destructive functions are allowed
            if ~obj.enableDestrFun
                return;
            end

            if nargin < 2
                k = 1;
            else
                if k ~= 1 && k ~=-1
                    warning('arrShow:rot90','k can be either -1 or 1');
                    k = 1;
                end
            end

            si = size(obj.dat);
            noDims = length(si);

            % get original selection
            origSel = obj.selection.getValueAsCell;

            % get colon dims
            colDims = obj.selection.getColonDims;

            if any(colDims == 0)
                warning('arrShow:rot90','both colon dimensions need to be selected for rot90');
            else
                colDims = sort(colDims);
                pOrder = 1 : noDims;  % original panel ordering

                newOrder = pOrder;
                newSel = origSel;

                newOrder(colDims(1)) = pOrder(colDims(2));
                newOrder(colDims(2)) = pOrder(colDims(1));
                newSel{colDims(1)} = origSel{colDims(2)};
                newSel{colDims(2)} = origSel{colDims(1)};

                obj.dat = permute(obj.dat,newOrder);
                if k == 1
                    obj.dat = flipdim(obj.dat,colDims(1));
                else
                    obj.dat = flipdim(obj.dat,colDims(2));
                end


                % valueChanger array
                newDims = size(obj.dat);
                obj.selection.reInit(newDims, newSel);

                obj.updFig();
            end
        end
        
        function flipDim(obj,dim)
            if obj.enableDestrFun
                obj.dat = flipdim(obj.dat,dim);
                obj.updFig();
            end
        end
        
        function sumSqr(obj,dim)
            funPtr = @(x,dim)sqrt(sum(x .* conj(x),dim));
            obj.applyDimFun(dim,funPtr);
        end
        
        function sum(obj,dim)
            obj.applyDimFun(dim,@sum);
        end

        function mean(obj,dim)
            obj.applyDimFun(dim,@mean);
        end
        
        function max(obj,dim)
            funPtr = @(x,d)max(x,[],d);
            obj.applyDimFun(dim,funPtr);
        end
        
        function min(obj,dim)
            funPtr = @(x,d)min(x,[],d);
            obj.applyDimFun(dim,funPtr);
        end
        
        function coilCombine(obj,dim)
            A   = obj.dat;
            si  = size(A);
            sel = obj.selection.getValueAsCell;
            order = 1:length(si);
            order(dim)  = 3;
            C           = si(dim);
            order(3)    = dim;
            permutsi    = si(order);
            A = permute(A,order);
            A = reshape(A, si(1), si(2), si(dim), []);
            
            % Get image dimensions and set filter size
            filtsize    = 7;
            filter_ones = ones(filtsize);
            A_out       = zeros([si(1:2), size(A,4)]);
            
            for i=1:size(A,4)
                tmp1    = A(:,:,:,i);
                ctmp1   = conj(tmp1);
                tmp2    = zeros(si(1), si(2));
                Rs = zeros(si(1),si(2),C,C);
                % Get correlation matrices
                for kc1=1:C
                    for kc2=1:C
                        Rs(:,:,kc1,kc2) = Rs(:,:,kc1,kc2) + filter2(filter_ones, ...
                            tmp1(:,:,kc1) .* ctmp1(:,:,kc2), 'same');
                    end
                end
                % Compute and apply filter at each voxel
                for kx=1:si(1)
                    for ky=1:si(2)
                        % Change suggested by Mark Bydder
                        [U,~]   = svd(squeeze(Rs(kx,ky,:,:)));
                        myfilt  = U(:,1);
                        tmp2(kx,ky) = myfilt'*squeeze(tmp1(kx,ky,:));
                    end
                end
                A_out(:,:,i) = tmp2;
            end
            
            A_out = reshape(A_out, [permutsi(1), permutsi(2), 1, permutsi(4:end)]);
            A_out = permute(A_out, order);
            obj.dat = A_out;
                        
            obj.selection.reInit( size(obj.dat), sel);
            
            obj.updFig();
        end
            
        
        
        function squeeze(obj)
            % squeezes the data array and updates the selection etc. It
            % basically performs:
            % obj.dat = squeeze(obj.dat);
            
            % check if destructive functions are allowed
            if ~obj.enableDestrFun
                return;
            end            

            % get original selection
            sel = obj.selection.getValueAsCell;
            si = size(obj.dat);

            if length(sel) > 2
                % find dims which will be kept alive
                sd = si ~= 1;

                obj.dat = squeeze(obj.dat);
                sel = sel(sd);

                % avoid dealing with less than 2 dimensions
                if length(sel) == 1
                    sel = [sel,{'1'}];
                end


                obj.selection.reInit( size(obj.dat), sel);

                obj.updFig();
            else
                fprintf('squeezing away one of the last 2 dimensions is not implemented yet :-(\n');
            end
        end
        
        
        function setDestructiveSelectionString(obj, str)
            % this overwrites the data array to contain only the data at
            % the indices given in str.
            % I.e.: obj.dat = obj.dat(str);
            
            % check if destructive functions are allowed
            if ~obj.enableDestrFun
                return;
            end

            % get the original data
            A = obj.dat;
            
            % if no selection is given, open dialog with a valid initial
            % proposal
            if nargin < 2
                noDims = length(size(A));
                colonStr = repmat(': , ',[1,noDims]);
                initStr = ['A = A( ',colonStr,';'];
                initStr(end-2) = ')';

                str = mydlg('Enter selection','Set selection string',initStr);                
            end
            
            % did we forgot an input argument or hit the cancel button?
            if isempty(str)
                return;
            end
            
            % make sure that there is a semicolon at the end of the string
            if ~any(strfind(str,';'));
                str = [str,';'];
            end
            
            try
                eval(str);
            catch err
                disp(err);
                return;
            end
            
            obj.overwriteImageArray(A);
        end
                
        function crop(obj, targetSize)
            % Crops data around the center to the size in siz. (for even
            % dimension sizes, the center is assumed to be dim/2 + 1) For
            % dimensions with siz(dim) = 0, the size is unaltered For
            % siz(dim) < 1, the target size for the dimension is calculated
            % from the product of siz(dim) and the original dimension size.
            % A dialog is opend if no targetSize is given.
            
            % check if destructive functions are allowed
            if ~obj.enableDestrFun
                return;
            end
            
            % get size of the input array
            A = obj.dat;
            si = size(A);

            % open dialog
            if nargin < 2
                % create an initial crop proposal with both colon dims
                % divided by 2 and everything else unchanged
                noDims = length(si);                
                colDims = obj.selection.getColonDims;
                colDims = colDims(colDims ~= 0);
                initSiz = zeros(1,noDims);               
                if ~isempty(colDims)
                    initSiz(colDims) = ceil(si(colDims) / 2);                
                end
                initStr = mat2str(initSiz);
                
                str = mydlg('0 = no change in dimension','Enter new size',initStr);
                if isempty(str)
                    return;
                end
                try
                    targetSize = str2num(str); %#ok<ST2NM>
                catch err
                    disp(err);
                    return;
                end
            end
            
            % do the cropping
            
            % init subscripts
            subs = repmat({':'},[1,length(si)]);

            for i = 1 : numel(targetSize)
                if targetSize(i) ~= 0 % (ignore simensions with siz(dim) == 0)

                    currSiz = si(i);        
                    targetSiz = targetSize(i);

                    % check validity of siz
                    if targetSiz > currSiz
                        error('targetSiz > currSiz');
                    end
                    if targetSiz < 0
                        error('targetSiz < 0');
                    end                    
                    
                    % account for relative size arguments
                    if targetSiz < 1
                        targetSiz = targetSiz * currSiz;
                    end                    

                    % round dim size
                    targetSiz = round(targetSiz);
                    
                    % derive center inds for the current dimension
                    cnt = floor(currSiz / 2) + 1;                        

                    % derive full center range
                    start = ceil( cnt - targetSiz/ 2 );
                    stop  = ceil(start + targetSiz - 1);
                    inds = start:stop;

                    subs{i} = inds;
                end
            end

            % create subs struct
            s.type = '()';
            s.subs = subs;

            % create output array
            A = subsref(A,s);           
            
            obj.overwriteImageArray(A);            
        end
        
        function cropDim(obj, dim, targetDimSize)
            % does the same as crop but only for a specific dimension. The
            % function can be called e.g. from the context menu of the
            % valueChanger of single dimensions
            % A dialog is opend if no targetDimSize is given.
            
            % get size of the input array
            A = obj.dat;
            si = size(A);
            
            % check validity of dim
            if dim > length(si)
                error('asDataClass:cropDim','Dim > length(size(data))');
            end

            origDimSize = si(dim);
            if nargin < 3
                % open input dialog
                origSizeStr = ['(original size = ',num2str(origDimSize),')'];
                initStr = num2str(floor(origDimSize/2));
                str = mydlg(origSizeStr,'Enter new size',initStr);
                if isempty(str)
                    return;
                end
                try
                    targetDimSize = str2double(str);
                catch err
                    disp(err);
                    return;
                end
            end
            
            % check validity of siz
            if targetDimSize == 0
                return
            end            
                        
            % create full dimension vector with the new dim size
            si(dim) = targetDimSize;
            
            % do the cropping
            obj.crop(si);
        end
        
        
        function permute(obj,order)
            % permutes the data array and updates the relevant ui elements.
            % It basically performes:
            % obj.dat = permute(obj.dat, order);
            % A dialog is opend if no order is given.
                        
            % check if destructive functions are allowed
            if ~obj.enableDestrFun
                return;
            end
                
            % if no reordering vector is given: open permute dialog
            if nargin < 2 || isempty(order)
                noDims = length(size(obj.dat));
                prevValue = num2str(1:noDims,'%d,');
                prevValue(end) = []; % remove last ','
                newValue = mydlg('Enter new order','Permute input dlg',prevValue);
                if ~isempty(newValue)
                    order = str2num(newValue); %#ok<ST2NM> % need to use str2num instead of str2double as this is not a scalar
                    if (length(order) ~= noDims ||...
                            min(order) ~= 1 ||...
                            max(order) ~= noDims)
                        warning('PermuteDlg:valueCheck','invalid value');
                        return;
                    end
                else
                    return;
                end
            end

            % get original selection
            sel = obj.selection.getValueAsCell;

            % permute array and selection
            obj.dat = permute(obj.dat,order);
            sel = sel(order);

            si = size(obj.dat);
            obj.selection.reInit( si, sel);
            obj.updFig();
        end
            
        function reshape(obj,siz)
            % Reshapes the data array and updates the relevant ui elements.
            % It basically performes:
            % obj.dat = reshape(obj.dat, siz);
            % A dialog is opend if no order is given.
                        
            % check if destructive functions are allowed
            if ~obj.enableDestrFun
                return;
            end
                
            % if no new size vector is given: open input dialog
            if nargin < 2 || isempty(siz)
                origSiz = size(obj.dat);
                prevValue = num2str(origSiz,'%d,');
                prevValue(end) = []; % remove last ','
                newValue = mydlg('Enter new size','Reshape input dlg',prevValue);
                if ~isempty(newValue)
                    siz = str2num(newValue); %#ok<ST2NM> % need to use str2num instead of str2double as this is not a scalar
                    if (numel(siz) < 2)                        
                        warning('ReshapeDlg:invalidValue','New size has to be at least two-dimensional');
                        return;
                    end
                    if prod(siz) < prod(origSiz)
                        warning('ReshapeDlg:invalidValue','Number of elements must not change');
                        return;
                    end
                else
                    return;
                end
            end

            % reshape data
            newDat = reshape(obj.dat, siz);
            
            % overwrite image 
            obj.overwriteImageArray(newDat);
        end
        
        
        function overwriteImageArray(obj, arr)
            % overwrites obj.dat by arr (i.e. obj.dat = arr;)
            % and updates the relevant ui elements
            
            if obj.enableDestrFun
                
                % get original selection
                origSel = obj.selection.getValueAsCell;
                origSi = size(obj.dat);
                
                % accept new array
                obj.dat = asDataClass.validateImageArray(arr);
                newSi = size(obj.dat);
                
                % check if dimensions are equal
                if length(newSi) == length(origSi)
                    dimEqual = true;
                    for i = 1 : length(newSi)
                        if(origSi(i) ~= newSi(i))
                            dimEqual = true;
                            break;
                        end
                    end
                else
                    dimEqual = false;
                end
                
                % create init selection cell array
                if dimEqual
                    sel = origSel;
                else
                    sel = cell(length(newSi),1);
                    sel{1} = ':';
                    sel{2} = ':';
                    for i = 3 : length(newSi)
                        sel{i} = '1';
                    end
                end
                
                % reinit selection class
                obj.selection.reInit(newSi, sel);
                
                obj.updFig();
            end
            
        end
    end
    
    
    
    methods (Static)
        
        function args = struct2varargin(dat)
            fields = fieldnames(dat);
            args = cell(numel(fields),2);
            args(:,1) = fields;
            for i = 1 : numel(fields)
                args{i,2} = dat.(fields{i});
            end                        
        end
        
        function dataArray = validateImageArray(dataArray, skipFullDataInspection)
            
            if nargin < 2
                skipFullDataInspection = true;
                % in some cases, e.g. when viewing memmapfiles, it can be
                % convenient to deactivate the check for infinite data to
                % avoid the necessity to read all data.
                % UPDATE:
                % Deactivated full data inspection by default to speedup
                % the start time for large data arrays.
            end
                        
            if isempty(dataArray)
                error('asDataClass:validateImageArray','Data array is empty'); 
            end
            
            if iscell(dataArray)
                dataArray = asDataClass.cell2imageMat(dataArray);
            end
            
            isaCustomMemmap = ...
                isa(dataArray, 'interleavedComplex') ||...
                isa(dataArray, 'sequencialComplex')  ||...
                isa(dataArray, 'directAccessCooMemmap');
                
            if isa(dataArray, 'memmapfile')
                dataArray = dataArray.data.dat;
                if nargin < 2
                    fprintf('Input data is a memmapfile, skipping full data inspection...\n');                    
                    skipFullDataInspection = true;
                end
            end
            if isaCustomMemmap
%                 fprintf(['Input data is an interleavedComplex
%                 memorymap!\n',...
%                     'Skipping full data inspection...\n']);
                skipFullDataInspection = true;
            end

            if ischar(dataArray) && strcmp(dataArray,'lena')
                % load lena
                tmp = load(fullfile(fileparts(mfilename('fullpath')),'icons','lena.mat'));
                
                % create a fancy phase
                [x,y] = meshgrid(linspace(-pi,pi,512));
                r = -sqrt((x+-1.9).^2 + (y+-1.3).^2);
                r = (r+4.5)*0.8;
                p = exp(-1i*r);
                
                dataArray = tmp.lena .* p;
            end
            
            if ~isnumeric(dataArray) && ~isaCustomMemmap
                warning('asDataClass:validateImageArray','Input dataArrayay seems not to be numeric. Trying to convert it into double...');
                try
                    dataArray = double(dataArray);
                catch ME
                    if strcmp(ME.identifier,'MATLAB:invalidConversion')
                        error('asDataClass:invalidImageArray','Data couldn''t be converted to double');
                    else
                        rethrow(ME);
                    end
                end                
            end
            
            si = size(dataArray);
            if length(si) < 2
                error('asDataClass:validateImageArray','input dataArrayay has to be at least 2 dimensional');
            end
            
            if issparse(dataArray);
                dataArray = full(dataArray);
            end
            
            if ~skipFullDataInspection && any(~isfinite(dataArray(:)))
                warning('asDataClass:validateImageArray','There are invalid entries in the image dataArrayay. Replacing these entries with zeros...');
                dataArray(~isfinite(dataArray(:))) = 0;
            end
            
            if ~(isa(dataArray,'double')||isa(dataArray,'single')) && ~isaCustomMemmap
                % warning: I remember that single precision has been a
                % problem in the past. Apparently it seems to work in
                % Matlab R2013a. However, if you experience datatype
                % problems, you might want to try to remove the
                % ||isa(dataArray,'single') statement
                warning('asDataClass:validateImageArray','Input data is of class %s which is not supported by arrayShow yet. Converting data to double...',class(dataArray));
                dataArray = double(dataArray);
            end
        end
        
        function arr = cell2imageMat(cellArr)
            % converts a cell array of images into a respective matrix.
            % All "images" in the cell array must have the same dimensions.
            % Empty cell content is automatically removed
            
            fprintf('isolating images from input cell vector...');
            
            % check for empty cells
            emptyCells = cellfun(@isempty,cellArr);
            if any(emptyCells)
                if all(emptyCells)
                    error('asDataClass:cell2imageMat','input cell array is empty');
                else
                    % remove empty cells
                    warning('asDataClass:validateImageArray','Removing empty cells from input array. The frame indices may be shifted respectively.');                                        
                    cellArr(emptyCells) = [];
                end
            end
            
            % check if first cell content has at least 2 dimensions
            refSi = size(cellArr{1});
            if length(refSi) >= 2
                refN = prod(refSi);
            else
                error('asDataClass:cell2imageMat','arrays in input cell must be at least 2 dimensional');
            end
            
            % if all other cells contain arrays with same number of
            % elements, sort them into an image array
            arr = zeros([refN,numel(cellArr)]);
            for i = 1 : numel(cellArr)
                if numel(cellArr{i}) == refN
                    arr(:,i) = cellArr{i}(:);
                else
                    error('asDataClass:cell2imageMat','arrays in input cell have different size');
                end
            end
            si  = [refSi, squeeze(size(cellArr))];
            arr = reshape(arr,si);
            fprintf('  done.\n');
        end
        
        function out = fftshift2(in)
            out = fftshift(fftshift(in,1),2);
        end
                
        function out = mrFft(in, dim)
            si = size(in);
            if nargin < 2
                % do 2D FFT by default
                a = 1 / (sqrt(si(1)) * sqrt(si(2)));
                out = asDataClass.fftshift2(fft2(asDataClass.fftshift2(in))) * a;
            else
                a = 1 / sqrt(si(dim));
                out = fftshift(fft(fftshift(in,dim),[],dim),dim) * a;
            end            
        end
        
        function out = mrIfft(in, dim)
            si = size(in);
            if nargin < 2
                % do 2D iFFT by default
                a = sqrt(si(1)) * sqrt(si(2));
                out = asDataClass.fftshift2(ifft2(asDataClass.fftshift2(in))) * a;
            else
                a = sqrt(si(dim));
                out = fftshift(ifft(fftshift(in,dim),[],dim),dim) * a;
            end
        end
        
    end
    
    methods (Access = private)
        function applyDimFun(obj,dim,funPtr)
            if obj.enableDestrFun
                if nargin ==1
                    dim = length(size(obj.dat)); % use the last dimensions
                end
                si = size(obj.dat);
                l = length(si);
                if dim > l
                    fprintf('dimension %d > number of available dimensions (%d)\n',dim, l);
                else
                    obj.dat = funPtr(obj.dat,dim);
                    
                    % get original selection
                    si(dim) = 1;
                    sel = obj.selection.getValueAsCell;
                    sel{dim} = '1';
                    
                    
                    % update selection class
                    obj.selection.reInit(si, sel);
                    
                    obj.updFig();
                end
            end
        end
    end
end



