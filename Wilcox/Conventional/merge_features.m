% simple script to combine features files 

files_to_merge = {'T:\Projects\ADELPHI_Senan\Nico ML Backup\Desktop\interictal imbalanced artifacts\features_10s_2019-04-16.mat',...
    'T:\Projects\ADELPHI_Senan\Nico ML Backup\Desktop\interictal imbalanced artifacts 2\features_10s_2019-04-15.mat',...
   'E:\Data extraction 2\old_features\features_10s_2019-01-30.mat'};
merged_name = 'merged_10s_2019-04-17';

for i_file = 1:length(files_to_merge)
    load(files_to_merge{i_file})
    disp(['dataset ' files_to_merge{i_file} ': ' num2str(size(features,1)) ' samples'])
    if i_file == 1
        temp.dataset_params = dataset_params;
        temp.animal_id_features = animal_id_features;
        temp.animal_names = animal_names;
        temp.features = features;
        temp.labels_features = labels_features;
        temp.i_period = i_period;
        temp.label_names = label_names;
        temp.feat_names = feat_names;
    else
        bParams = true;
        bParams = bParams && temp.dataset_params.preictal_s == dataset_params.preictal_s;
        bParams = bParams && temp.dataset_params.szbuffer_s == dataset_params.szbuffer_s;
        bParams = bParams && temp.dataset_params.normal_s == dataset_params.normal_s;
        bParams = bParams && temp.dataset_params.szdist_s == dataset_params.szdist_s;
        bParams = bParams && temp.dataset_params.ratio_normalpreictal == dataset_params.ratio_normalpreictal;
        if ~bParams
            warning('dataset parameters do not match')
        end
        for i=1:length(label_names)
            if ~strcmp(label_names{i},temp.label_names{i})
                error('labels names do not match')
            end
        end
        
        animal_id_temp = zeros(size(animal_id_features));
        for j=1:length(animal_names)
            bFound = false;
            for i=1:length(temp.animal_names)
                if strcmp(animal_names{j}, temp.animal_names{i})
                    animal_id_temp(animal_id_features==j) = i*ones(1, sum(animal_id_features==j));
                    bFound = true;
                end
            end
            if ~bFound
                temp.animal_names{length(temp.animal_names)+1} = animal_names{j};
                animal_id_temp(animal_id_features==j) = (length(temp.animal_names))*ones(1, sum(animal_id_features==j));
            end
        end
        animal_id_features = animal_id_temp;
        
        % add data to the temp structure that holds the merged data
        temp.animal_id_features = [temp.animal_id_features animal_id_features];
        temp.features = [temp.features; features];
        temp.labels_features = [temp.labels_features labels_features];
        temp.i_period = [temp.i_period i_period];
    end
end
features = temp.features;
labels_features = temp.labels_features;
label_names = temp.label_names;
i_period = temp.i_period;
feat_names = temp.feat_names;
dataset_params = temp.dataset_params;
animal_names = temp.animal_names;
animal_id_features = temp.animal_id_features;
disp(['merged dataset: ' num2str(length(features)) ' samples'])

% write features to file
foldername = uigetdir('', 'Select folder to save the data');
if ischar(foldername)
    name = [foldername '\' merged_name];
    save(name, 'features', 'labels_features', 'animal_names', 'animal_id_features', 'dataset_params',...
        'feat_names', 'i_period', 'label_names');
    msgbox(['Data written to ' name]);
else
    errordlg('Data could not be written');
end