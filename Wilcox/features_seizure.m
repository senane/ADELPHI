clear
clc
window = 5;                                                                 %set window size (seconds)
sampfr = 500;                                                               %sampling frequency
params.features = [1 2 3 4 5 6 7 8 9 10 11 14 15];                                                  %choose features (see getEEGfeatures.m)
params.chans = 1; 
test = randi(1000,1,(sampfr*window));                                              %test vector of sample size
[testfeat] = getEEGfeatures(test',sampfr, params); 
[r, c] = size(testfeat);                                                    %finding dimensions for feature array                                                         %recording from 1 channel
samples = dir('*/seizure/*dat');
filepath = '/Volumes/Aafreen/Wilcox + Staley Data/WilcoxData';

for sample = samples'
    folder = sample.name(1:15); 
    fname = [filepath '/' folder '/seizure/' sample.name]
    fid = fopen(fname,'r');
    datacell = textscan(fid, '%f%f%f', 'HeaderLines', 1, 'Collect', 1);
    data = fread(fid,'int32');
    fclose(fid);
    A.data = datacell{1};
    s_data = transpose(data);
    [x, sampsize] = size(s_data);
    numwin = floor(sampsize/(window*sampfr));                                   %number of windows 
    excess = mod(sampsize,(window*sampfr));
    data = loaded.sample;
    trimmed = data(1:(end-excess));
    windows = vec2mat(trimmed,(window*sampfr));
    for i=1:numwin
        passed = windows(i,:);
        [win_feat] = getEEGfeatures(passed',sampfr, params);
        sz_features(i,:) = win_feat;
    end
    save_path = '/Volumes/Aafreen/Wilcox + Staley Data/Wilcox-Interictal Features/';
    file_name = [save_path sample.name '_Features.mat'];
    save(file_name, 'sz_features');
end
