function session = synergp_initProject(session)
%% synergp utility: initialize user specified project
%{
-projectName must not contain periods
%}
%% PROJECT SELECTION

% get project names 
% project names correspond to the folders in syner-gp/projects/
% must not be named template
% must contain a function called specProject_projectName
projects = dir(fullfile(session.synergpdir,'projects'));
projects = projects([projects.isdir]);
p = 1;
while p <= numel(projects)
    if projects(p).name(1) == '.'
        projects(p) = [];
    elseif strcmp(projects(p).name,'template')
        projects(p) = [];
    elseif isempty(dir(fullfile(session.synergpdir,'projects',projects(p).name,['specProject_' projects(p).name '.m'])))
        projects(p) = [];
    else
        p = p + 1;
    end
end
if isempty(projects); error('No projects found in projects directory.'); end
projects = {projects.name};

% select project
iproject = listdlg('PromptString','Select a project:','ListString',replace(projects,'specProject_',''),'SelectionMode','single');
if isempty(iproject); error('synergp terminated'); end
session.project.name = projects{iproject};
session.project.specifier = ['specProject_' projects{iproject}];
addpath(genpath(fullfile(session.synergpdir,'projects',session.project.name)))

%% SPEC PROJECT

session = synergp_addnote(session,char(sprintf("-specifying project: %s\n",session.project.name)),1);
session = feval(session.project.specifier,session);

end

