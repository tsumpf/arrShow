function asFileMonitor(filename)
% USAGE: asFileMonitor() (default), or asFileMonitor(filename)
%
% Input argument <filename> can be either a file or:
%   <empty> : (default) monitors default temporary file
%   "stop"  : stop previously created timeres are stoped
% "suppress": creates a temporary file in the temp folder to suppress the C
%               as function from writing temporary files
% "continue": delete temporary "supress file"


per = 0.5; % timer period in seconds


% figure out username
[~,usr] = system('whoami');
usr = usr(1:end-1);  

% define suppress file name
suppressFileName = fullfile(tempdir,[usr,'_asSuppressFile.tmp']);

% if no filename is given (defaut) automatically define it using the
% username
if nargin < 1    
    % default coo file name
    filename = fullfile(tempdir,[usr,'_asTmpFile.coo']);
end

% if filename is "stop": 
% stop and delete previous timer
if strcmpi(filename,'stop')
    % try to find previous timer
    T = timerfind('name','asFileMonitorTimer');
        
    if isempty(T)
        disp('no asFileMonitor found');
    else
        stop(T);
        delete(T);
        disp('asFileMonitor stopped');
    end        
    return;
end

% if filename is "suppress": 
% create a "suppress file"
if strcmpi(filename,'suppress')
    % ...there's probably a more elegant way to do this :)
    fclose(fopen(suppressFileName,'w'));
    return;
else    
    % delete "suppress file", if present
    if exist(suppressFileName, 'file')
        delete(suppressFileName);   
    end
end

% if filename is "continue", return (since the suppress file should be
% deleted by now)
if strcmpi(filename,'continue')
    return;
end


% start timer
global T;
T = timer('Period',per, 'TimerFcn',@(src, evnt)timerCb(src, filename),...
    'ExecutionMode','fixedDelay', 'Name','asFileMonitorTimer');
start(T);

fprintf('monitoring file: %s\n',filename);
end


% define timer callback
function timerCb(T, filename)
    if exist(filename,'file')
        stop(T);
        try
            cooAs(filename,false);
        catch err
            fprintf(['asFileMonitor: an error occured when executing cooAs on %s!!\n',...
                'Deleting the file...\n'],filename);
            delete(filename);
            
            % restart asFileMonitor
            asFileMonitor(filename);
            
            throw(err);
        end            
        delete(filename);
        start(T);
    end                    
end    
