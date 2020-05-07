%% synergp
% Reed Gurchiek, 2020
% streamlines development of muscle synergy functions for estimating
% unmeasured muscle excitations from a measured subset as specified in a
% giver user-define project. Users should be especially familiar with the
% GPML toolbox before using synergp. Users are directed to the README and
% the exampleProject file to become familiar with the syner-gp toolbox.

% the main output from this script is the session struct. It is a structure
% that contains all details of model development, model evaluation, and
% more. Users will be prompted (or can specify ahead of time) for the
% location at which to save the structure. 

% while the script is running, notes are constantly printed to the command
% window for details of the pipeline, current status, etc. These notes are
% also stored within the session structure for later review. A notes .txt
% file can be generated easily by running synergp_writeNotes() which is
% stored in lib/util.

% the GPML toolbox prints to the command window status updates concerning
% the hyperparameter optimization. These can take up a lot of space. Users
% can make the following replacements to the minimize.m file in the
% gpml-matlab-v4.2-2018-06-11 toolbox:
%
%   replace line 77: fprintf('%s %6i;  Value %4.6e\r', S, i, f0);
%              with: synergp_report = sprintf('%s: %d of %d, Current Minimum NLML: %4.6e',S,i,abs(length),f0); fprintf(synergp_report);
%
%   replace line 150: fprintf('%s %6i;  Value %4.6e\r', S, i, f0);
%               with: fprintf(repmat('\b',[1 numel(synergp_report)])); synergp_report = sprintf('%s: %d of %d, Current Minimum NLML: %4.6e',S,i,abs(length),f0); fprintf(synergp_report);
%
%   replace line 171: fprintf('\n'); if exist('fflush','builtin') fflush(stdout); end
%               with: fprintf(repmat('\b',[1 numel(synergp_report)])); synergp_report = sprintf('%s: %d of %d, Current Minimum NLML: %4.6e',S,i,abs(length),f0); fprintf(synergp_report); if exist('fflush','builtin') fflush(stdout); end 

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
