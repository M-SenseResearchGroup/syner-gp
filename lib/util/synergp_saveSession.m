function session = synergp_saveSession(session)
%% synergp utility: save session structure
if isfield(session,'saveSession')
    if isfield(session.saveSession,'directory')
        if strcmpi(session.saveSession.directory,'auto')
            session.saveSession.directory = fullfile(session.synergpdir,'projects',session.project.name);
        end
    else
        ok = questdlg('Select the directory to save results to.','Save','OK');
        if ~isempty(ok)
            session.saveSession.directory = uigetdir();
        end
    end
    if isfield(session.saveSession,'filename')
        if strcmpi(session.saveSession.filename,'auto')
            session.saveSession.filename = ['synergpSession_' session.project.name '_' date];
        end
    else
        fname = inputdlg('Save As','Save As',[1 100],{['synergpSession_' session.project.name '_' date]});
        if ~isempty(fname)
            session.saveSession.filename = fname{1};
        end
    end
    save(fullfile(session.saveSession.directory,session.saveSession.filename),'session');
    session = synergp_addnote(session,replace(char(sprintf("-synergp session saved to: %s\n",fullfile(session.saveSession.directory,session.saveSession.filename))),'\','\\'),1);
else
    session = synergp_addnote(session,char(sprintf("-no session saving details specified; session struct unsaved\n")),1);
end
end