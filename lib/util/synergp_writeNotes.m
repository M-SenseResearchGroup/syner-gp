function [] = synergp_writeNotes(options)
%% synergp utility: generate .txt file of all syner-gp session notes
%
% synergp_writeNotes can be run with no input. In this case you will be
% prompted to select the session struct (.mat file) that you want the notes
% for. You will then be prompted for the location to save the notes to and
% the filename to save the notes as (must be .txt extension).
%
% options has 3 fields:
%   (1) session: session struct output from syner-gp
%   (2) savedir: directory to save report to
%   (3) savename: filename to save report as (will be .txt file)

if nargin == 0
    options = struct();
end
if ~isfield(options,'session')
    questdlg('Select the session struct to write notes for.','Session Structure','OK','OK');
    [fname,path] = uigetfile('*.mat');
    options = load(fullfile(path,fname));
    if ~isfield(options,'savedir')
        savehere = questdlg('Save notes in same location?','Save','Yes','No','Yes');
        if savehere(1) == 'Y'
            options.savedir = path;
        end
    end  
end

if ~isfield(options,'savedir')
    questdlg('Select the directory to write the notes to.','Directory','OK','OK');
    options.savedir = uigetdir();
end

if ~isfield(options,'savename')
    works = 0;
    while ~works
        savename = inputdlg('Save report as:','Save As',[1 100],{['synergpNotes_' options.session.project.name '_' options.session.completionDatetime '.txt']});
        if ~strcmp(savename{1}(end-3:end),'.txt')
            questdlg('Requested filename must end with .txt. Try again.', 'File Specifier','OK','OK');
        else
            works = 1;
        end
    end
    options.savename = savename{1};
end

f = fopen(fullfile(options.savedir,options.savename),'w');
for n = 1:length(options.session.notes)
    fprintf(f,'%s',options.session.notes{n});
    fprintf('%s',options.session.notes{n});
end
fclose(f);


