clear
clc
[cage, start, file, folder_name] = deal({},{},{},{}); %initialize arrays for interictal table 
[File, pathname] = uigetfile('*.acq','Pick ACQ File');  %Browse for ACQ File.
[seizure_table] = uigetfile('*.mat','Pick MAT File');   %Browse for seizure File.
folder = [' ' File(1:15)];       %from name of acq file take folder name
table = load(seizure_table);     %load table from csv
seizures = table.allsz;          %open seizure table
filtered = seizures(ismember(seizures.Folder, folder), :); %filter seizures from folder
info = acqreader07092013([pathname,File]);   %load ACQ file
start_time = 0;                        %start time (seconds)
duration_time = info.EndOfFileInSeconds;    
DATA = acqdatareader(info,start_time,duration_time);  %load all data in file
EEG = DATA.data;      %EEG data, each row corresponds to a cage                                                     
TIME = DATA.time;      %time vector for EEG data 
[r,c] = size(EEG);                          %dimensions of data
[w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12] = deal([ones(1,c-(3600*500)) zeros(1,(3600*500))]);
weights = vertcat(w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12); %create weight matrix  

for i=1:height(filtered) %updating weight matrix with seizures
    i_cage = filtered{i, 2};  %get cage number
    rawtime = filtered{i, 5}; %get seizure start time
    [h,m,s] = hms(rawtime);
    i_time = 500*((h*3600) + (m*60) + s); %convert start time to table index  
    if i_time + (7200*500) <= c
        weights(i_cage,(i_time:i_time+(7200*500))) = 0;
    else
        weights(i_cage,(i_time:c)) = 0;
    end 
    if i_time - (7200*500) > 0
        weights(i_cage,(i_time - (7200*500):i_time)) = 0;
    else if i_time - (7200*500) == 0
        weights(i_cage,(i_time-(7200*500)+1:i_time)) = 0;   
    else
        weights(i_cage,(1:i_time)) = 0;
    end 
    end
end

for i=1:height(filtered)   %choosing random interictal samples
    all_cages = [];
    for j=1:12        % if w is all 0s choose a new cage index else
        is_valid = weights(j,:);
        if 1 && any(is_valid)
            all_cages = [all_cages, j];
        end     
    end 
    cage_index = datasample(all_cages, 1);
    w = weights(cage_index,:);
    index_vec = [1:c];
    index = randsample(index_vec,1,true,w); %choose random index w/ weight matrix
    x = EEG(cage_index,:); %choose population vector
    sample = x(index:index+(3600*500)); %create random sample
    if index + (3600*500) <= c
        w(index:index+(3600*500)) = 0;
    else
        w(index:c) = 0;
    end 
    if index - (3600*500) > 0
        w(index - (3600*500):index) = 0;
    else if index - (3600*500) == 0
        w(index-(3600*500)+1:index) = 0;   
    else
        w(1:index) = 0;
    end 
    end    
    weights(cage_index,:) = w;       %replace row in weight matrix
    save_path = '/Volumes/Aafreen/Wilcox + Staley Data/Wilcox-Interictal Segments/';
    name = [folder '_' int2str(cage_index -1) '_Interictal_' int2str(i) '.mat']; 
    file_name = [save_path name];
    save(file_name, 'sample');
    cage{end+1} = cage_index;
    inter_start = datestr((index/500)/(24*60*60), 'DD:HH:MM:SS');
    folder_name{end+1} = folder;
    start{end+1} = inter_start;
    file{end+1} = name;  
end

fix_cage = reshape(cage, [i 1]);
fix_start = reshape(start, [i 1]);
fix_file = reshape(file, [i 1]);
interictal = cell2table([fix_cage fix_start fix_file]);
table_path = '/Volumes/Aafreen/Wilcox + Staley Data/Wilcox-Interictal segment info/';
table_name = [table_path folder '_Interictal.mat']; 
save(table_name, 'interictal');
