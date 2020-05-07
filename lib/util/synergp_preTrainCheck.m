function session = synergp_preTrainCheck(session)
%% synergp utility:  correct potential errors before train/evaluation loop

muscleNames = session.muscleNames;

% for each subject
session = synergp_addnote(session,char(sprintf("\n-performing pre-training error check\n")),1);
for s = 1:numel(session.subject)
    
    % for each trial
    trialnames = fieldnames(session.subject(s).data.trials);
    for t = 1:length(trialnames)
        
        % for each muscle name
        for m = 1:length(muscleNames)
             
            % verify muscle data available
            if ~isfield(session.subject(s).data.trials.(trialnames{t}).locations,muscleNames{m})
                error('-Subject %d does not have data for muscle %s during trial %s',s,muscleNames{m},trialnames{t});
            end
            
            % verify all data same length
            if m == 1
                n = length(session.subject(s).data.trials.(trialnames{t}).locations.(muscleNames{m}).elec.data);
            else
                if n ~= length(session.subject(s).data.trials.(trialnames{t}).locations.(muscleNames{m}).elec.data)
                    error('-Not all muscles have the same number of emg samples for subject %d for trial %s. This is necessary (not sufficient) for synchronization.',s,trialnames{t});
                end
            end
            
            % verify correct sampling frequency
            if session.synergyModel.inputStructure.samplingFrequency ~= session.subject(s).data.trials.(trialnames{t}).locations.(muscleNames{m}).elec.samplingFrequency
                error('EMG data for subject %d, trial %s, muscle %s, has sampling frequency = %f, but the synergyModel requires %f',s,trialnames{t},muscleNames{m},...
                    session.subject(s).data.trials.(trialnames{t}).locations.(muscleNames{m}).elec.samplingFrequency,session.synergyModel.inputStructure.samplingFrequency);
            end
            
        end
        
    end
    
end  

end