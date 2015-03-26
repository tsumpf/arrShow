%% draw to rois in asObj

% asObj = evalin('base','asObj');

% get axes handle from asObj
ah = asObj.getCurrentAxesHandle;

% draw rois
fprintf('draw signal roi...');
roi{1} = asRoiClass(ah);
fprintf('done!\ndraw noise roi...');
roi{2} = asRoiClass(ah);
fprintf('done!\n');


%% get roi position matrices
pos{1} = roi{1}.getPosition;
pos{2} = roi{2}.getPosition;

%% derive noise

% get image and figure title from asObj
ioi = asObj.getSelectedImages(false);
tit = asObj.getFigureTitle;

signalArea = roi{1}.createMask;
noiseArea  = roi{2}.createMask;

% calculate SNR
noiseInds  = find(ioi & noiseArea);
signalInds = find(ioi & signalArea);

signal     = mean(ioi(signalInds));
noise      = std(ioi(noiseInds));

snr = signal / noise;
fprintf('===================\n%s\n',tit);
disp('SNR:');
disp(snr);
asObj.infotext.setString(['SNR: ',num2str(snr)]);
asObj.infotext.setVisible('on');
%% noise SD in percent of mean signal
fprintf('===================\n%s\n',tit);
disp('Noise m +- SD:');
fprintf(' %f +- %f\n',mean(ioi(noiseInds)),noise);
disp('Image m +- SD:');
fprintf(' %f +- %f\n',signal,std(ioi(signalInds)));
disp('100 * noise SD / mean(signal):');
fprintf(' %f %% \n',100 * noise / signal);
disp('100 * noise SD / mean(image):');
fprintf(' %f %% \n',100 * noise / mean(ioi(:)));
disp('100 * noise SD / max(image):');
fprintf(' %f %% \n',100 * noise / max(ioi(:)));

%% delete rois
roi{1}.delete;
roi{2}.delete;

%% create noiseRois from position cell vector
ah = asObj.getCurrentAxesHandle;
roi{1} = asRoiClass(ah,pos{1});   
roi{2} = asRoiClass(ah,pos{2});
