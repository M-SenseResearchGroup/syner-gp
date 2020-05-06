function [] = synergp_setup(session)
%% synergp utility: path setup

warning('off', 'MATLAB:rmpath:DirNotFound');

% verify projects exist and remove all from path
% only want one user eventually selects on path
if ~isfolder(fullfile(session.synergpdir,'projects')); error(['syner-gp' filesep 'projects directory is missing.']);
else, rmpath(genpath(fullfile(session.synergpdir,'projects'))); end
addpath(fullfile(session.synergpdir,'projects'));

% remove all sub folders in lib and add lib as parent
rmpath(genpath(fullfile(session.synergpdir,'lib')));
addpath(fullfile(session.synergpdir,'lib'));

% add parents
folders = {'util','reducers','processors','importers','evaluators'};
for f = 1:length(folders)
    if ~isfolder(fullfile(session.synergpdir,'lib',folders{f}))
        error(['syner-gp' filesep 'lib' filesep folders{f} ' directory is missing']);
    end
    addpath(fullfile(session.synergpdir,'lib',folders{f})); 
end

warning('on', 'MATLAB:rmpath:DirNotFound');

end