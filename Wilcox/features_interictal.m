clear
clc
window = 5;                                                                 %set window size (seconds)
sampfr = 500;                                                               %sampling frequency
sampsize = 1800001;                                                         %size of input samples (all are same size)
numwin = floor(sampsize/(window*sampfr));                                   %number of windows 
params.features = [1 2 3 4 5 6 7 8 9 10 11 14 15];                                                  %choose features (see getEEGfeatures.m)
params.chans = 1;                                                           %recording from 1 channel
test = randi(1000,1,(sampfr*window));                                              %test vector of sample size
[testfeat] = getEEGfeatures(test',sampfr, params);                          %feature array for test vector
[r, c] = size(testfeat);                                                    %finding dimensions for feature array
ii_features = zeros(numwin, c);   

samples = dir('*mat');
for sample = samples'
    loaded = load(sample.name);
    excess = mod(sampsize,(window*sampfr));
    data = loaded.sample;
    trimmed = data(1:(end-excess));
    windows = vec2mat(trimmed,(window*sampfr));
    for i=1:numwin
        passed = windows(i,:);
        [win_feat] = getEEGfeatures(passed',sampfr, params);
        ii_features(i,:) = win_feat;
    end
    save_path = '/Volumes/Aafreen/Wilcox + Staley Data/Wilcox-Interictal Features/';
    file_name = [save_path sample.name '_Features.mat'];
    save(file_name, 'ii_features');
end
