function scores = MdlPredict(Mdl, data, modelName, params_manual)
    % Predict class labels using a model trained with train_predictor
    if ~isempty(params_manual)
       for i_pm = 1:2:length(params_manual)
            if strcmp(params_manual{i_pm},'Nfeat')
                data = data(:,1:params_manual{i_pm+1});
            end
       end
    end
    if strcmp(modelName, 'linear')
    	[~,~,~,scores] = Mdl.predict(data);
    elseif strcmp(modelName, 'svm')
        [~,scores] = Mdl.predict(data);
    elseif strcmp(modelName, 'tree')    
        [~,~,~,scores] = Mdl.predict(data);
    elseif strcmp(modelName, 'neuralnetwork')
        scores = Mdl(data');
        scores = scores';
    elseif strcmp(modelName, 'randomforest')
        [~, scores] = Mdl.predict(data);
    elseif strcmp(modelName, 'combined')
        % in this case Mdl contains all the optimally trained models to
        % combine
        % default parameters
        weights = ones(1,length(Mdl))/length(Mdl);
        mode = 'average';
        if ~isempty(params_manual)
           for i_pm = 1:2:length(params_manual)
                if strcmp(params_manual{i_pm},'weights')
                    weights = params_manual{i_pm+1};
                elseif strcmp(params_manual{i_pm},'mode')
                    mode = params_manual{i_pm+1};
                end
           end
        end
        % call the function for each model 
        scores = [];
        for i_model = 1:length(Mdl)
            if weights(i_model)>0
                scores_temp = MdlPredict(Mdl(i_model).Mdl, data, Mdl(i_model).name, Mdl(i_model).manual_params);
            else
                scores_temp = zeros(length(data), Mdl(i_model).nClasses);
            end
            scores = cat(3, scores, scores_temp);
        end
        % determine the final score
        weights = reshape(weights, [1 1 length(weights)]);
        if strcmp(mode,'average')
            scores = scores.*repmat(weights, [size(scores,1) size(scores,2) 1]);
            scores = scores/sum(weights);
            scores = sum(scores,3);
        elseif strcmp(mode,'majority')
            scores = round(scores);
            scores = scores.*repmat(weights, [size(scores,1) size(scores,2) 1]);
            scores = scores/sum(weights);
            scores = sum(scores,3);
        end      
    end 
    
    % scores median centering !!!
    
end
