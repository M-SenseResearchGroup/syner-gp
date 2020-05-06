function session = specProject_exampleProject(session)
%% NOTES

% specify project notes here
projectNotes = {'-project notes are a field in the synergp session struct.',...
                '-project notes can be used to quickly describe the nuts and bolts of the project.'...
                '-these are helpful when looking back at project results to remember what the purpose of the project was, settings used, etc.',...
                '-this example project serves as an example of how to use syner-gp to build synergy function models'...
                '-all projects must be stored in the syner-gp/projects folder corresponding to a folder named with the same name as the project (e.g. syner-gp/projects/exampleProject',...
                '-all project folders must have a function named specProject_(projectName) (this file) and it may contain other sub-functions, data, etc.'};
     
%% MUSCLE NAMES

% this is a required field

% it specifies the names of all the muscles used in the analysis

% this includes input muscles and output muscles. any input/output muscles
% must be specified in this cell array

% each muscle name must be a 'location' in: subject.data.trial.(trialName).locations after sEMG import
% thus they must be field appropriate (e.g. no leading numbers, no spaces, etc.)
muscleNames = {'lateral_gastrocnemius_right', 'tibialis_anterior_right', 'biceps_femoris_right','rectus_femoris_right',...
               'peroneus_longus_right', 'medial_gastrocnemius_right', 'soleus_right', 'vastus_medialis_right', 'vastus_lateralis_right', 'semitendinosus_right'};

%% IMPORTER

% this is a required field

% it specifies the importer to use for importing sEMG data

% the name of the importer should be a folder in lib/importers and there
% should be a function with the same name in the folder. The folder may
% also contain other importer sub-functions, data files, etc..

% the importer used in this example project is one that expects the data to
% be stored with filenames with a particular structure (according to our
% lab's preferences). This particular filenaming structure can be seen in
% the example dataset. 

% you can build your own importer, all that matters is the following:
%   -must input synergp session and output same session with a new field
%   called 'subject' organized as per:
%       subject(k).ID = char array, subject identifier
%                 .dataset = char array, name of dataset
%   `             .data.trials.(trialname).locations.(muscleName).elec.time = time array in seconds
%                                                                     .data = data array of raw sEMG data
%                                                                     .samplingFrequency = sampling frequency
%
%   -the data should all be synchronized and have the same number of datapoints per trial
%
%   -the samplingFrequency property should always correspond to the
%   sampling frequency of the data, even if it is resampled
%
%   -the (muscleName) must be an element in muscleNames (see above)
%
%   -importer options can be set in the importer.options field

importer.name = 'importMC10x_subjects';
importer.options.dataset.name = 'synergpExampleDatset';
importer.options.dataset.path2MC10 = '';
importer.options.dataset.subjects = {'synergpExampleSubject'};
importer.options.importOptions.locations = muscleNames;
importer.options.importOptions.trialNames = {'*Max_Voluntary_Contraction*','Treadmill_Walk_Normal'};
importer.options.importOptions.sensors = {'elec'};
importer.options.importOptions.resample = 1000;
importer.options.importOptions.storeSameTrials = 'last';

%% PROCESSOR

% this is a required field

% it specifies the processor to use for processing the importer sEMG data

% the name of the importer should be a folder in lib/processors and there
% should be a function with the same name in the folder. The folder may
% also contain other processor sub-functions, data files, etc.

% you can build your own processor, all that matters is the following:
%   -must input synergp session and output same session where any
%   processed sEMG data is in session.subject.data.trials.(trialname).locations.(muscleName).elec.data
%
%   -if data were resampled, then session.subject.data.trials.(trialname).locations.(muscleName).elec.samplingFrequency
%   must be updated to reflect this
%
%   -processor options can be set in the processor.options field

processor.name = 'semgEnvelope_v1';
processor.options.high_cutoff = 30;
processor.options.high_order = 4;
processor.options.low_cutoff = 6;
processor.options.low_order = 4;
processor.options.downsample = 250;
          
%% DATASET REDUCER

% this is not a required field

% dataset reducers reduce the size of the training set

% reducers are called within synergp_reduceDataset within
% synergp_train_evaluate. The synergp_reduceDataset function tries to make
% it so that data is reduced such that there is equal representation at a 
% user-specified level, appropriate levels are: 
%   (1) dataset
%   (2) task
%   (3) subject
%   (4) subject-task
datasetReducer.reductionLevel = 'subject-task';

% dataset reducer attempts to reduce the number of observations in the
% training set according to this parameter
datasetReducer.maxNumberObservations = 7500;

% the GPML toolbox also has ways of implementing dataset reduction or
% handling large training datasets.

% you can build your own reducer, it must have the following inputs in this
% order:
%   (1) training dataset inputs, m x n array, m is num observations, n is
%   input dimension
%
%   (2) training dataset targets, m x n array, m is num observations, n is
%   dimension of targets
%
%   (3) maxNumberObservations (see above)
%
%   (4) options structure, handles any reducer specific options that can be
%   set in this specProject_ file

% the name of the reducer must be a folder in lib/reducers and there should
% be a function with the same name in the folder. The folder may also
% contain other reducer sub-functions, data files, etc.

% if no datasetReducer field is specified then all observations will be
% used

datasetReducer.name = 'genreduce_v1';
datasetReducer.options.method = 'random';

%% SYNERGY MODEL

% this is a required field

% it specifies the input muscle set, the output muscles, the input window
% structure (size and relative output time) as well as the gaussian process
% model specifications

% a given model should only be applied using data sampled at the 
% sampling frequency of the data for which it was trained. The sampling 
% frequency it is trained with should be specified here and all data will 
% be made sure to have this sampling frequency
synergyModel.inputStructure.samplingFrequency = 250;

% input window size is specified here in milliseconds: t_n - t_1 in 
% manuscript. An array of windowSize_ms parameters can be set and each
% element corresponds to a subset for which a model will be trained for.
% Multiple subsets can be tried in a single project.

% see manuscript for reason for choosing this window size
synergyModel.inputStructure.windowSize_ms = 1500; % to test both a 1500 and a 1000 millisecond window we could set synergyModel.inputStructure.windowSize_ms = [1000 1500];

% window relative output time is specified here: t_n - t in manuscript. Can
% be specified by milliseconds or as a percentage of the input window. An
% array of windowRelativeOutputTime parameters can be set and each element
% corresponds to a subset for which a model will be trained for. Multiple
% subsets can be tried in a single project

% see manuscript for reason for choosing this output time
synergyModel.inputStructure.windowRelativeOutputTime_type = 'percentage'; % or 'milliseconds' in units are milliseconds
synergyModel.inputStructure.windowRelativeOutputTime = 0.5; % to test both a 50% and a 75% window we could set synergyModel.inputStructure.windowRelativeOutputTime = [0.5 0.75];

% predictorMuscles specify the muscles used for prediction. These must be 
% elements in muscle names. All other muscles in muscleNames not included 
% here will be the 'output' muscles the models will be trained to predict 
% excitation of. Each cell array in the predictorMuscles cell array 
% corresponds to a subset for which a model will be trained for. Multiple 
% subsets can be tried in a single project. For example, to test an input
% set using muscle1 and muscle2 as well as a set using muscle3 and muscle4
% in a single project we could set:
%
%   synergyModel.inputStructure.predictorMuscles = {{'muscle1','muscle2'},{'muscle3','muscle4'}}

% see manuscript for reason for choosing this muscle set
synergyModel.inputStructure.predictorMuscles = {{'biceps_femoris_right','peroneus_longus_right','soleus_right','vastus_lateralis_right'}};

% the gpModel specifies the gaussian process model parameters. Users should
% refer to the GPML toolbox for this. It is recommended that users become
% especially familiar with the GPML toolbox before using syner-gp

% mean function and initial hyperparams
gpModel.meanfunc = @meanConst;
gpModel.hypinit.mean = 0.05;

% covariance function and inital hyperparams
gpModel.covfunc = @covSEiso;
gpModel.hypinit.cov = log([1;1]);

% likelihood function and initial hyperparams
gpModel.likfunc = @likGauss;
gpModel.hypinit.lik = log(0.01); 

% inference function
gpModel.inffunc = @infExact;

% note that gpml functions (mean, cov, lik, inf) must be specified using
% the function handle notation (e.g. @covSEiso). GPML provides vast
% flexibility for building new covariance functions. If a new one is built
% using a combination of covariance functions then a name should be given
% to the function. For example, one could do:
%
%   gpModel.covfunc = {@covScale,{'covSEisoU'}}
%
%   this creates a scaled version of the unscaled isotropic squared
%   exponential covariance. A name then must be given since the covfunc
%   field is now a cell type and not a function handle. For example,
%
%   gpModel.covname = 'scaled_covSEisoU'

% the optimStoppingCriteria parameter is the 'length' argument in the GPML
% minimize function
gpModel.optimStoppingCriteria = -50;

% these completely specify a given gp model. multiple models can be tested
% within a single project, e.g. gpModel(1), gpModel(2), ..., but each must
% have all of the required fields. gpModel is then a field within the
% synergyModel
synergyModel.gpModel = gpModel;

% flag to keep training data or not
% NOT RECOMMENDED FOR TRYING MANY MODELS, WILL TAKE UP HUGE SPACE
synergyModel.keepTrainingSet = 0;

% the last part of a synergy model describes the training data is was built
% with. the trainingSetDetails and testSetDetails specify this structure.
% These are organized as a cell array as shown below with the following
% structure:
%
%   {'taskName', 'trialName', start at x percent of whole trial, end at y percent of whole trial}
% the 'taskName' parameter specifies the type of activity. This is so that 
% data from different studies whose activities or trials might have been 
% named differently can all be grouped according to similar tasks.
% note that if there are n unique tasks listed then every subject must have
% at least one trial corresponding to each task

% in this example, we train with the data from the Tredmill_Walk_Normal
% trial (field in data.trials from data import) starting at 20% of the
% trials and ending at 45% of the trial. We call the task associated with
% this data 'walk'.
synergyModel.dataset(1).trainingSetDetails = {'walk','Treadmill_Walk_Normal', 0.2 , 0.45};
synergyModel.dataset(1).testSetDetails = {'walk','Treadmill_Walk_Normal', 0.55 , 0.8};

% note that multiple trials can be used in the same dataset. For example,
% trainingSetDetails = {'task1','trialname1',0,1;...
%                       'task1','trialname2',0,1};

% also, multiple trainingSets/testSets can be tried within the same project
% as per: dataset(1), dataset(2), ... where each dataset(n) must have the
% appropriate trainingSetDetails and testSetDetails cell arrays


%% VALIDATION

% this is a required field

% validation type is specified as either subject-specific where subject
% specific models are built for each subject and evaluated individually or
% where subject general models are built wherein leave one subject out
% (LOSO) cross validation is used to built a subject general model for each
% subject based on all other subjects
validation.type = 'subject-specific';
% validation.type = 'subject-general'; % 'LOSO' would do the same thing

% flag to keep true and estimated time-series or not.
% NOT RECOMMENDED IF TESTING MANY MODELS
validation.keepAllResults = 1;

% evaluator is a required field within validation. The evaluator must be a
% folder within lib/evaluators which contains a function with the same
% name.
% performance assessment
validation.evaluator.name = 'stdeval_v1';
validation.evaluator.options = struct();

% report these metrics when available
% must look up what metrics will be output by specified evaluator.name
% if no reporting desired then leave blank
validation.evaluator.reportEvaluation = {'rmse','mae','correlation','vaf'};
% do >> validation.evaluator.reportEvaluation = 1; to report all metrics

%% SAVE SESSION

% this is not a required field. handles saving the session structure after
% completion. If saveSession not specified then no results will be saved

% save struct
session.saveSession.directory = 'auto'; % 'auto' saves to project folder, or 'path/tosave/resultsto/', or no directory field then user will be prompted
session.saveSession.filename = 'auto'; % 'auto' saves as synergpSession_(projectName)_(date).mat, or no filename field then user will be prompted

%% PACKUP

session.projectNotes = projectNotes;
session.muscleNames = muscleNames;
session.importer = importer;
session.processor = processor;
session.datasetReducer = datasetReducer;
session.synergyModel = synergyModel;
session.validation = validation;

end

