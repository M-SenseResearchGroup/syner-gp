function dataset = synergp_buildDataset(subject,subjectIndices,datasetDetails,inputStructure,outputMuscles)
%% synergp utility: builds dataset

% initialize
dataset = struct('X',[],'Y',[],'subjectIndices',[],'trialname',{''},'task',{''});

% for each subject
i = 1;
for s = subjectIndices
    
    % for each set
    for t = 1:size(datasetDetails,1)
        
        % sampling frequency
        sf = inputStructure.samplingFrequency;
        
        % convert windowSize_ms to samples
        winsamp = round(sf/1000 * inputStructure.windowSize_ms);
        
        % convert windowRelativeOutputTime_ms to output sample relative to
        % last sample of window
        relsamp = round(sf/1000 * inputStructure.windowRelativeOutputTime_ms);
        
        % indices of specified window
        ndata = length(subject(s).data.trials.(datasetDetails{t,2}).locations.(outputMuscles{1}).elec.data);
        ind = round(datasetDetails{t,3} * ndata) : round(datasetDetails{t,4} * ndata);
        if ind(1) == 0; ind(1) = []; end
        
        % how many observations will there be
        nobs = length(ind) - winsamp + 1;
        
        % for each observation
        for iobs = 1:nobs
            
            % get indices of input window
            window = ind(iobs:iobs + winsamp - 1);
            
            % get index of output sample
            outsamp = window(end) - relsamp;
            
            % get output sample
            dataset.Y(i,:) = zeros(1,length(outputMuscles));
            for m = 1:length(outputMuscles)
                dataset.Y(i,m) = subject(s).data.trials.(datasetDetails{t,2}).locations.(outputMuscles{m}).elec.data(outsamp);
            end
        
            % for each predictor muscle
            dataset.X(i,:) = zeros(1,winsamp * length(inputStructure.predictorMuscles));
            for m = 1:length(inputStructure.predictorMuscles)

                % get input muscle data
                dataset.X(i,winsamp*(m-1)+1:winsamp*m) = subject(s).data.trials.(datasetDetails{t,2}).locations.(inputStructure.predictorMuscles{m}).elec.data(window);

            end
            
            % save subject and trial info
            dataset.subjectIndices(i,1) = s;
            dataset.trialname{i,1} = datasetDetails{t,2};
            dataset.task{i,1} = datasetDetails{t,1};
            
            % next
            i = i + 1;
            
        end
        
    end
    
end
        
