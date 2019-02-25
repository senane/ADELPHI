clc
clear

warning('off','all')
window_size = 60; % in seconds
Fs = 500;
params.features = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 19 20 21 22 23 24];
params.chans = [1 2 3];
detrendPeriod = true; % if extracted contiguous periods with same label should be detrended 
standardizePeriod = false; % if extracted contiguous periods with same label should be stdized 
% note: seizures are extracted independently but normalized with respect to
% the previous precital period, so hold temporary values for m and sd

% normalizationMode = 'periods'; % determine what params.normalization.m and sd are set to ('periods', 'files'(not yet) or 'none')
% % used only in feature 'spikes'
% % not useful if detrendPeriod and standardizePeriod are set to true

if ~detrendPeriod
    params.m = [];
end
if ~standardizePeriod
    params.sd = [];
end

% import the data 
foldername = uigetdir();
if ~ischar(foldername)
    error('Invalid folder');
end
filenames = dir([foldername '/*.mat']);
filesizes = [filenames.bytes];

k = 1;
features = [];
labels_features = [];
animal_id_features = [];
animal_names = [];

i_period = [];
h = waitbar(0, 'Initializing...');
elapsed_time_mem = 0;
for i=1:length(filenames)
    waitbar(0,h, ['[' filenames(i).name ' (' num2str(i) '/' num2str(length(filenames)) ')] Loading...'])
    load([foldername,'\', filenames(i).name]);
    tic;
    % check if the animal name has alread been added
    check = strcmp(animal_names, animal_name);
    if sum(check)==0
        animal_names{length(animal_names)+1}=animal_name;
        animal_id = length(animal_names);
    else
        animal_id = find(check==1);
    end
    params.outputNames = 1;
    [~, feat_names] = getEEGfeatures(zeros(window_size*Fs,length(params.chans)), Fs, params);
    params.outputNames = 0; 
    
    % create a set of windowed samples
    % first find the differently labeled sets of data
    win_samples = window_size*Fs;
    waitbar(0,h, ['[' filenames(i).name ' (' num2str(i) '/' num2str(length(filenames)) ')] Calculating features...'])
    for j=1:(length(i_sample)-1) % check!!!
        id_beg = double(i_sample(j));
        if j == length(i_sample)
            id_end = size(data_all,1);
        else
            id_end = i_sample(j+1)-1;
        end
        progress_counter = 0;
        if labels(round((id_beg+id_end)/2))==3 % if it's a seizure
            data_temp = preproc(double(data_all(id_beg:id_end,:)),Fs,false,false);
            for i_chan=1:size(data_temp,2)
                if detrendPeriod
                    data_temp(:,i_chan) = data_temp(:,i_chan)-m(i_chan);
                end
                if standardizePeriod
                    data_temp(:,i_chan) = data_temp(:,i_chan)/sd(i_chan);
                end
            end
        else
            data_temp = preproc(double(data_all(id_beg:id_end,:)),Fs,detrendPeriod,standardizePeriod);  
            m = mean(data_temp);
            sd = std(data_temp);
            if ~detrendPeriod
                params.m = m;
            end
            if ~standardizePeriod
                params.sd = sd;
            end
        end

        for i_win = 1:win_samples:(length(data_temp)+1-win_samples)
            try
                features(k,:) = getEEGfeatures(data_temp(i_win:i_win+win_samples-1,:),Fs,params); 
                %features(k,:) = k; % for fast test
                labels_features(k) = labels(round((id_beg+id_end)/2));
                animal_id_features(k) = animal_id;
                i_period(k) = i_win ==1;
                k=k+1;
                progress_counter = progress_counter+1;
            catch e
                disp(e.message)
            end
            elapsed_time = toc + elapsed_time_mem; % in sec
            progr = id_beg/size(data_all,1)+progress_counter/length(id_beg:win_samples:id_end)*(id_end-id_beg)/size(data_all,1);
            total_time_est = elapsed_time/(sum(filesizes(1:(i-1)))+progr*filesizes(i))*sum(filesizes);
            if (total_time_est - elapsed_time)<3600*24
                time_left = datestr(max((total_time_est - elapsed_time)/3600/24,0), 'HH:MM:SS');
            else
                time_left = [datestr((total_time_est - elapsed_time)/3600/24, 'dd') ' day(s) '  datestr((total_time_est - elapsed_time)/3600/24, 'HH:MM:SS')];
            end
            waitbar(progr,h, ...
                {['[' filenames(i).name ' (' num2str(i) '/' num2str(length(filenames)) ')] Calculating features...'],['ETA: ' time_left]})
        end
    end
    elapsed_time_mem = elapsed_time_mem + toc;
end


save_name = ['features_' num2str(window_size) 's_' datestr(now,'yyyy-mm-dd')];
name = [foldername '\' save_name];
save(name, 'features', 'feat_names', 'label_names', 'labels_features', 'i_period', 'animal_names', 'animal_id_features', 'dataset_params');

if (elapsed_time_mem)<3600*24
    total_time = datestr(elapsed_time_mem/3600/24, 'HH:MM:SS');
else
    total_time = [datestr(elapsed_time_mem/3600/24, 'dd') ' day(s) '  datestr(elapsed_time_mem/3600/24, 'HH:MM:SS')];
end
waitbar(1,h, ['Done in ' total_time])
%labels_cat = discretize(labels_windows,[-0.5 0.5 1.5 2.5],'categorical',{'Normal', 'Pre-ictal', 'Seizure'});
