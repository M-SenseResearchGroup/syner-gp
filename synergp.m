%% synergp
% Reed Gurchiek, 2020

% modified line 77, 150, and 171 of gpml minimize func. original code is
% commented out at end of those lines

%% INITIALIZATION

clear
clc

% init session
session.initializationDatetime = char(datetime);
session.synergpdir = replace(which('synergp'),strcat(filesep,'synergp.m'),'');
if ~isfolder(fullfile(session.synergpdir,'lib')); error(['syner-gp' filesep 'lib directory is missing.'])
elseif ~isfolder(fullfile(session.synergpdir,'lib','util')); error(['syner-gp' filesep 'lib' filesep 'util directory is missing.']);
else, addpath(fullfile(session.synergpdir,'lib','util')); 
end
session.notes = {''};
session = synergp_addnote(session,char(sprintf("-initializing synergp session: %s\n",char(datetime))),1);
session.notes(1) = [];
synergp_setup(session);

% init gpml toolbox
session = synergp_initGPML(session);

% init project
session = synergp_initProject(session);

% init models and first level error check
session = synergp_initModels(session);

% status update
session = synergp_memoryStatus(session);

%% IMPORT/CONDITION EMG DATA

% emg import
session = synergp_addnote(session,char(sprintf("\n-IMPORTING DATA: %s\n",session.importer.name)),1);
session = feval(session.importer.name,session);

% emg pre-processing
session = synergp_addnote(session,char(sprintf("\n-PRE PROCESSING DATA: %s\n",session.processor.name)),1);
session = feval(session.processor.name,session);

% status update
session = synergp_memoryStatus(session);

%% TRAIN/EVALUATE MODELS

% final error check for train/evaluation loop
session = synergp_preTrainCheck(session);

% train/evaluate models
session = synergp_train_evaluate(session);

%% SAVE RESULTS

session.completionDatetime = char(datetime);
session = synergp_addnote(session,char(sprintf("-synergp session completed: %s\n",char(datetime))),1);
session = synergp_saveSession(session);
