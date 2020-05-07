function session = importMC10x_subjects(session)
%% importMC10x_subjects: synergp importer
% Reed Gurchiek, 2020
%{

-expects MC10 emg data files to be housed in a folder named MC10

-expects this MC10 folder to be in the directory of a subject folder (it
can be in subdirectories inside the subject folder). The subject folder
name cannot have a period in it

-expects all subject folders for which data is to be imported are within
 a folder specified in options.dataset.directory. Note that data can be imported
from multiple studies. If no dataset directory is specified then the user
will be prompted to select it, but only one study may be specified in this
way. To import subject data from multiple datasets, it must be specified in
the importer.options.dataset(k).() parameters in specProject_()

-importMC10x_subjects calls importMC10x. This function has one input,
importOptions. This structure is an option within the
session.importer.options. See exampleProject for example.

%}

%% HANDLE OPTIONS

% unpack
options = session.importer.options;
importOptions = options.importOptions;
if ~isfield(options,'dataset')
    options.dataset = struct();
end
dataset = options.dataset;

% subject directory
if ~isfield(dataset,'directory')
    ok = questdlg('Select directory containing subject folders.','Study Directory','OK',{'OK'});
    if isempty(ok)
        error('synergp terminated')
    else
        dataset.directory = uigetdir();
    end
end

% dataset name
if ~isfield(dataset,'name')
    dataset.name = dataset.directory;
end

% path to MC10 data
if ~isfield(dataset,'path2MC10')
    path = inputdlg('Enter the path to MC10 directory containing emg data files from subject directory:','MC10 Path',[1 100],{fullfile('Session_1','Lab')});
    if isempty(path)
        error('synergp terminated')
    else
        path = replace(path{1},{'/' '\'},{filesep filesep});
        dataset.path2MC10 = path;
    end
end

% subjects (folder names) to import data for
if ~isfield(dataset,'subjects')
    subjects = dir(dataset.directory);
    if isempty(subjects); error('No directories found in selected dataset directory.'); end
    
    % must be directory
    subjects(~[subjects.isdir]) = [];
    subjects = {subjects.name};
    
    % subject folder names cannot contain periods (also removes hidden)
    subjects(contains(subjects,'.')) = [];
    if isempty(subjects); error('No directories found in selected dataset directory.'); end
    
    % select
    isubject = listdlg('PromptString','Select subject(s) to include:','ListString',subjects,'SelectionMode','multiple');
    if isempty(isubject); error('synergp terminated'); end
    dataset.subjects = subjects{isubject};
    clear subjects
end
    
% make sure MC10 folder exists for each subject
session = synergp_addnote(session,char(sprintf("-verifying MC10 folder exists for each subject\n")),1);
k = 1;
total_subjects = 0;
while k <= numel(dataset)
    s = 1;
    while s <= length(dataset(k).subjects)
        if ~isfolder(fullfile(dataset(k).directory,dataset(k).subjects{s},dataset(k).path2MC10,'MC10'))
            session = synergp_addnote(session,char(sprintf("-WARNING: removing subject %s (directory does not exist: %s)\n",dataset(k).subjects{s},fullfile(dataset(k).directory,dataset(k).subjects{s},dataset(k).path2MC10,'MC10'))),1);
            dataset(k).subjects(s) = [];
        else
            s = s + 1;
            total_subjects = total_subjects + 1;
        end
    end
    if isempty(dataset(k).subjects)
        session = synergp_addnote(session,char(sprintf("WARNING: no subjects available for data import; removing dataset %s\n", dataset(k).directory)),1);
        dataset(k) = [];
    else
        k = k+1;
    end
end
if isempty(dataset); error('No studies specified for data import.'); end
options.dataset = dataset;

%% importMC10x

% for each dataset
subject(total_subjects) = struct('ID','','dataset','dataset','data',struct());
for k = 1:numel(dataset)
    
    session = synergp_addnote(session,char(sprintf("-importing data from dataset %s (%d/%d)\n",dataset(k).name,k,numel(dataset))),1);
    
    % import data for each subject
    for s = 1:numel(dataset(k).subjects)
        session = synergp_addnote(session,char(sprintf("\t-importing data from subject %s (%d/%d)\n",dataset(k).subjects{s},s,numel(dataset(k).subjects))),1);
        importOptions.directory = fullfile(dataset(k).directory,dataset(k).subjects{s},dataset(k).path2MC10,'MC10');
        subject(s).ID = dataset(k).subjects{s};
        subject(s).dataset = dataset(k).name;
        subject(s).data = importMC10x(importOptions);
    end
end

% packup
session.importer.options_used = options;
session.subject = subject;

end
    

