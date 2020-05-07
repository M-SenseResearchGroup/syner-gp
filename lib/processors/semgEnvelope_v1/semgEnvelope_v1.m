function session = semgEnvelope_v1(session)
%% semgEnvelope_v1: synergp processor
% Reed Gurchiek, 2020
%{

-Implements high pass, rectify, low pass based estimate of sEMG amplitudes.
Normalizes sEMG data by maximum value observed across all trials. 
-Also provides the option to downsample after
this processing.
-uses Matlab's butter function to determine filter coefs (see bwfilt)

-options:
    .hp_cutoff: high pass cutoff frequency
    .hp_order: order of high pass butterworth filter (must be even)
    .lp_cutoff: low pass cutoff frequency
    .lp_order: order of low pass butterworth filter (must be even)
    .downsample: frequency at which to downsample

%}

%% UNPACK

options = session.processor.options;
subject = session.subject;
session = synergp_addnote(session,char(sprintf("-high pass cutoff = %f\n-low pass cutoff = %f\n",options.high_cutoff,options.low_cutoff)),1);
if isfield(options,'downsample'); session = synergp_addnote(session,char(sprintf("-downsample frequency = %f hz\n",options.downsample)),1); end

%% PROCESS

% for each subject
for s = 1:numel(subject)
    
    session = synergp_addnote(session,char(sprintf("-processing subject %d of %d\n",s,numel(subject))),1);
        
    % for each muscle
    trialNames = fieldnames(subject(s).data.trials);
    muscleNames = fieldnames(subject(s).data.trials.(trialNames{1}).locations);
    for m = 1:length(muscleNames)
    
        % keep track of largest emg value for normalization later
        normalization_constant.value = 0;
        normalization_constant.trial = '';
    
        % for each trial
        for t = 1:length(trialNames)
            
            % get sampling frequency
            sf = 1/mean(diff(subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.time));
            
            % hp, rectify, lp
            e = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data;
            e = bwfilt(abs(bwfilt(e,options.high_cutoff,sf,'high',options.high_order)),options.low_cutoff,sf,'low',options.low_order);
            
            % normalization constant
            if max(e) > normalization_constant.value
                normalization_constant.value = max(e); 
                normalization_constant.trial = trialNames{t};
            end
            
            % store
            subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data = e;
            
        end
        
        session = synergp_addnote(session,char(sprintf("\t-%s normalization constant = %f from trial %s\n",muscleNames{m},normalization_constant.value,normalization_constant.trial)),1);
    
        % for each trial
        for t = 1:length(trialNames)
            
            % normalize
            subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data / normalization_constant.value;
            
            % store
            subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.normalization_constant = normalization_constant;
            
            % downsample?
            if isfield(options,'downsample')
                
                if options.downsample > 0
                    
                    old_time = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.time;
                    new_time = old_time(1):1/options.downsample:old_time(end);
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.samplingFrequency = options.downsample;
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.time = new_time;
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.postProcessor_samplingFrequency = options.downsample;
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data = interp1(old_time,subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data,new_time,'pchip');
                                                                                                      
                end
                
            end
            
        end
        
    end
    
end

%% PACKUP

session.subject = subject;
            
end
