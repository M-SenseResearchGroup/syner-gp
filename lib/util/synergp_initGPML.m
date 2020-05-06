function session = synergp_initGPML(session)
%% synergp utility: startup gpml toolbox

gpmldir = dir(fullfile(session.synergpdir,'lib','util','gpmldir.mat'));
gotdir = 0;
if ~isempty(gpmldir)
    loaded = load(fullfile(session.synergpdir,'lib','util','gpmldir.mat'));
    session.gpmldir = loaded.gpmldir;
    gotdir = isfolder(session.gpmldir);
end
if ~gotdir
    ok = questdlg('Select the gpml toolbox directory: gpml-matlab-v4.2-2018-06-11','GPML Directory','OK','OK');
    if isempty(ok); error('synergp terminated'); end
    gpmldir = uigetdir();
    session.gpmldir = gpmldir;
    savedir = questdlg('Use this directory each time?','Save GPML Directory','Yes','No','No');
    if ~isempty(savedir)
        if savedir(1) == 'Y'
            save(fullfile(session.synergpdir,'lib','util','gpmldir.mat'),'gpmldir');
        end
    end
end
session = synergp_addnote(session,replace(char(sprintf("-gpml toolbox directory: %s\n",session.gpmldir)),'\','\\'),1);
addpath(session.gpmldir);
startup;