load fisheriris.mat % load some random data for demo (meas)
data = meas;
Fs = 10;
% see help getEEGfeatures, requires chronux to work!
params.features = 13; % specify which features will be claculated (in this case
% only coherence)
params.bands = [0.5 4;  % specify the frequency bands
                4 8;    
                8 12;   
                12 16;  
                16 20;  
                20 50];
params.outputNames = true; % run the function once with names as output so 
% the names of the features are stored

[~, names] = getEEGfeatures(data, Fs, params);
params.outputNames = false;

% here, loop on the data to calculate the features for different windows
features = getEEGfeatures(data, Fs, params);