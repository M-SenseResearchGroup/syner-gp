function session = synergp_initModels(session)
%% synergp utility: initialize models and verify correct structure


%% POST-PROJECT INIT ERROR CHECK

% muscle names
if ~isfield(session,'muscleNames'); error('Must specify muscleNames in specProject_(projectName).'); end

% importer
if ~isfield(session,'importer'); error('Must specifiy importer in specProject_(projectName).'); end
if ~isfield(session.importer,'name'); error('Must specify importer.name in specProject_(projectName).'); end
if ~isfolder(fullfile(session.synergpdir,'lib','importers',session.importer.name)); error('Requested importer %s must be a folder in syner-gp%clib%cimporters.',session.importer.name,filesep,filesep);
else, addpath(genpath(fullfile(session.synergpdir,'lib','importers',session.importer.name)));
end
if exist(session.importer.name,'file') == 0; error('Requested importer (%s) does not exist.',session.importer.name); end

% processor
if ~isfield(session,'processor'); error('Must specifiy processor in specProject_(projectName).'); end
if ~isfield(session.processor,'name'); error('Must specify processor.name in specProject_(projectName).'); end
if ~isfolder(fullfile(session.synergpdir,'lib','processors',session.processor.name)); error('Requested processor %s must be a folder in syner-gp%clib%cprocessors.',session.processor.name,filesep,filesep);
else, addpath(genpath(fullfile(session.synergpdir,'lib','processors',session.processor.name)));
end
if exist(session.processor.name,'file') == 0; error('Requested processor (%s) does not exist.',session.processor.name); end

% reducer
if isfield(session,'datasetReducer')
    if ~isfield(session.datasetReducer,'name'); error('If datasetReducer specified, so must also datasetReducer.name.'); end
    if ~isfolder(fullfile(session.synergpdir,'lib','reducers',session.datasetReducer.name)); error('Requested reducer %s must be a folder in syner-gp%clib%creducers.',session.datasetReducer.name,filesep,filesep);
    else, addpath(genpath(fullfile(session.synergpdir,'lib','reducers',session.datasetReducer.name)));
    end
    if exist(session.datasetReducer.name,'file') == 0; error('Requested datasetReducer (%s) does not exist.',session.datasetReducer.name); end
    if ~isfield(session.datasetReducer,'maxNumberObservations'); error('If datasetReducer specified, so must also datasetReducer.maxNumberObservations.'); end
    if session.datasetReducer.maxNumberObservations <= 0; error('datasetReducer.maxNumberObservations must be greater than zero.'); end
    if ~isfield(session.datasetReducer,'reductionLevel'); error('If datasetReducer specified, so must also datasetReducer.reductionLevel.'); end
    if ~any(strcmpi({'dataset','task','subject','subject-task'},session.datasetReducer.reductionLevel)); error('datasetReducer.reductionLevel must be either ''dataset'', ''task'', ''subject'', or ''subject-task''.'); end
end

% validation
if ~isfield(session,'validation'); error('Must specify validation in specProject_(projectName).'); end
if ~isfield(session.validation,'type'); error('Must specify validation.type in specProject_(projectName).'); end
if ~any(strcmpi({'subject-specific','loso','subject-general'},session.validation.type)); error('validation.type must be either ''subject-specific'', ''loso'', or ''subject-general'' (loso and subject-general are same). Note: Not case sensitive.'); end
if ~isfield(session.validation,'keepAllResults'); error('Must specify validation.keepAllResults in specProject_(projectName). Set to = 1 to keep results or set to = 0 to not keep results.'); end

% evaluator
if ~isfield(session.validation,'evaluator'); error('Must specify validation.evaluator in specProject_(projectName).'); end
if ~isfield(session.validation.evaluator,'name'); error('Must specify validation.evaluator.name in specProject_(projectName).'); end
if ~isfolder(fullfile(session.synergpdir,'lib','evaluators',session.validation.evaluator.name)); error('Requested evaluator %s must be a folder in syner-gp%clib%cevaluators.',session.validation.evaluator.name,filesep,filesep);
else, addpath(genpath(fullfile(session.synergpdir,'lib','evaluators',session.validation.evaluator.name)));
end
if exist(session.validation.evaluator.name,'file') == 0; error('Requested evaluator (%s) does not exist.',session.validation.evaluator.name); end
if ~isfield(session.validation.evaluator,'options'); error('Must specify validation.evaluator.name.options in specProject_(projectName). If this specific evaluator does not require options then set to = struct()'); end
if ~isfield(session,'synergyModel'); error('Must specifiy synergyModel in specProject_(projectName).'); end
if ~isfield(session.synergyModel,'keepTrainingSet'); error('Must specify synergyModel.keepTrainingSet in specProject_(projectName).'); end
if isfield(session,'saveSession')
    if isfield(session.saveSession,'directory')
        if ~strcmpi(session.saveSession.directory,'auto')
            if ~isfolder(session.saveSession.directory); error('User requested to save session to a directory that does not exist'); end
        end
    end
end

% model
if ~isfield(session.synergyModel.inputStructure,'samplingFrequency'); error('Must specify synergyModel.inputStructure.samplingFrequency (must be same for all EMG data) in specProject_(projectName).'); end
if ~isfield(session.synergyModel.inputStructure,'windowRelativeOutputTime_type'); error('Must specify synergyModel.inputStructure.windowRelativeOutputTime_type in specProject_(projectName).'); end
if ~any(strcmpi(session.synergyModel.inputStructure.windowRelativeOutputTime_type,{'percentage','milliseconds'})); error('synergyModel.inputStructure.windowRelativeOutputTime_type must either be specified as ''milliseconds'' or ''percentage'' in specProject_(projectName).'); end


%% INITIALIZE MODELS

loopControl.nWindowSizes = length(session.synergyModel.inputStructure.windowSize_ms); session = synergp_addnote(session,char(sprintf("-Number requested window sizes: %d\n",loopControl.nWindowSizes)),1);
loopControl.nRelativeTimes = length(session.synergyModel.inputStructure.windowRelativeOutputTime); session = synergp_addnote(session,char(sprintf("-Number requested output times: %d\n",loopControl.nRelativeTimes)),1);
loopControl.nPredictorSets = length(session.synergyModel.inputStructure.predictorMuscles); session = synergp_addnote(session,char(sprintf("-Number requested predictor muscle subsets: %d\n",loopControl.nPredictorSets)),1);
loopControl.nGPModels = numel(session.synergyModel.gpModel); session = synergp_addnote(session,char(sprintf("-Number requested GP model structures: %d\n",loopControl.nGPModels)),1);
loopControl.nDatasets = numel(session.synergyModel.dataset); session = synergp_addnote(session,char(sprintf("-Number requested training/test set pairs: %d\n",loopControl.nDatasets)),1);
loopControl.nModels = loopControl.nWindowSizes  * loopControl.nRelativeTimes * loopControl.nPredictorSets * loopControl.nGPModels * loopControl.nDatasets; session = synergp_addnote(session,char(sprintf("-total models requested for training/testing: %d\n",loopControl.nModels)),1);

% for each windowSize
i = 1;
for w = 1:loopControl.nWindowSizes
    
    % for each relative output time
    for r = 1:loopControl.nRelativeTimes
        
        % for each set of predictor muscles
        for p = 1:loopControl.nPredictorSets
            
            % for each gp model
            for m = 1:loopControl.nGPModels
                
                % for each dataset
                for d = 1:loopControl.nDatasets
                
                    session.model(i).inputStructure.samplingFrequency = session.synergyModel.inputStructure.samplingFrequency;
                    session.model(i).inputStructure.windowSize_ms = session.synergyModel.inputStructure.windowSize_ms(w);
                    session.model(i).inputStructure.windowRelativeOutputTime_type = session.synergyModel.inputStructure.windowRelativeOutputTime_type;
                    session.model(i).inputStructure.windowRelativeOutputTime = session.synergyModel.inputStructure.windowRelativeOutputTime(r);
                    session.model(i).inputStructure.predictorMuscles = session.synergyModel.inputStructure.predictorMuscles{p};
                    session.model(i).gpModel = session.synergyModel.gpModel(m); if ~isfield(session.model(i).gpModel,'trackOptimIterations'); session.model(i).gpModel.trackOptimIterations = 0; end
                    session.model(i).dataset = session.synergyModel.dataset(d);
                    session.model(i).keepTrainingSet = session.synergyModel.keepTrainingSet;
                    
                    % get 'unmeasuredMuscles'
                    unmeasuredMuscles = session.muscleNames;
                    for u = 1:numel(session.model(i).inputStructure.predictorMuscles)
                        ndx = strcmp(unmeasuredMuscles,session.model(i).inputStructure.predictorMuscles{u});
                        if any(ndx)
                            unmeasuredMuscles(ndx) = [];
                        end
                    end
                    session.model(i).unmeasuredMuscles = unmeasuredMuscles;
                    
                    % next model
                    i = i + 1;
                    
                end
                
            end
            
        end
        
    end
    
end

i = 1;
while i <= numel(session.model)
    if strcmpi(session.model(i).inputStructure.windowRelativeOutputTime_type,'percentage')
        if session.model(i).inputStructure.windowRelativeOutputTime < 0 || session.model(i).inputStructure.windowRelativeOutputTime > 1
            session = synergp_addnote(session,char(sprintf("-WARNING: a requested model has windowRelativeOutputTime (percentage) < 0 or > 1, but this must be between 0 and 1. Deleting model....\n")),1);
            session.model(i) = [];
        else
            i = i + 1;
        end
    elseif strcmpi(session.model(i).inputStructure.windowRelativeOutputTime_type,'milliseconds')
        if session.model(i).inputStructure.windowRelativeOutputTime < 0
            session = synergp_addnote(session,char(sprintf("-WARNING: a requested model has windowRelativeOutputTime (milliseconds) < 0, but this must be non-negative. Deleting model....\n")),1);
            session.model(i) = [];
        elseif session.model(i).inputStructure.windowRelativeOutputTime > session.model(i).inputStructure.windowSize_ms
            session = synergp_addnote(session,char(sprintf("-WARNING: a requested model has windowRelativeOutputTime (milliseconds) larger than windowSize_ms. Deleting model....\n")),1);
            session.model(i) = [];
        else
            i = i + 1;
        end
    elseif ~isfield(session.model(i).dataset,'trainingSetDetails') || ~isfield(session.model(i).dataset,'testSetDetails')
        session = synergp_addnote(session,'-WARNING: a requested model dataset does not have trainingSetDetails and/or testSetDetails. These are required. Deleting model...\n',1);
        session.model(i) = [];
    elseif size(session.model(i).dataset.trainingSetDetails,2) ~= 4 || size(session.model(i).dataset.testSetDetails,2) ~= 4
        session = synergp_addnote(session,'-WARNING: a requested model trainingSetDetails and/or testSetDetails cell array does not have 4 columns. Must have 4 columns. Deleting model.....\n',1);
        session.model(i) = [];
    elseif any(any(any(cell2mat(session.model(i).dataset.trainingSetDetails(:,3:4)) > 1))) || any(any(any(cell2mat(session.model(i).dataset.trainingSetDetails(:,3:4)) < 0)))
        session = synergp_addnote(session,'-WARNING: an element in a requested model trainingSetDetails 3rd or 4th column (specifying start and end of trial as percentage of dataset) is not between 0 and 1. Deleting model.....\n',1);
        session.model(i) = [];
    elseif any(any(any(cell2mat(session.model(i).dataset.testSetDetails(:,3:4)) > 1))) || any(any(any(cell2mat(session.model(i).dataset.testSetDetails(:,3:4)) < 0)))
        session = synergp_addnote(session,'-WARNING: an element in a requested model testSetDetails 3rd or 4th column (specifying start and end of trial as percentage of dataset) is not between 0 and 1. Deleting model.....\n',1);
        session.model(i) = [];
    elseif isempty(session.model(i).unmeasuredMuscles)
        session = synergp_addnote(session,'-WARNING: all muscles were chosen as predictor muscles for a requested model. Deleting model...\n',1);
        session.model(i) = [];
    elseif session.model(i).gpModel.trackOptimIterations < 0
        session = synergp_addnote(session,'-WARNING: trackOptimIterations was less than zero. Deleting model...\n',1);
        session.model(i) = [];
    else
        i = i+1;
    end
end

if loopControl.nModels ~= numel(session.model)
    session = synergp_addnote(session,char(sprintf("-Identified %d invalid models. synergp will train/evaluate %d unique models\n",loopControl.nModels-numel(session.model),numel(session.model))),1);
    if isempty(session.model)
        error('All models were deleted. Cannot proceed.')
    end
end

% save loop control
session.loopControl = loopControl;

end