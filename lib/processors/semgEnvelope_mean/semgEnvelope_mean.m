function session = semgEnvelope_mean(session)
%% semgEnvelope_mean: synergp processor
% Reed Gurchiek, 2020
%{

-same as semgEnvelope_v1, but here it handles the parsing of raw trial data
into training/testing sets and normalizes all time series by the set mean

-options:
    .hp_cutoff: high pass cutoff frequency
    .hp_order: order of high pass butterworth filter
    .lp_cutoff: low pass cutoff frequency
    .lp_order: order of low pass butterworth filter
    .downsample: frequency at which to downsample

%}

%% UNPACK

options = session.processor.options;
subject = session.subject;
session = synergp_addnote(session,char(sprintf("-high pass cutoff = %f\n-low pass cutoff = %f\n",options.high_cutoff,options.low_cutoff)),1);
if isfield(options,'downsample'); session = synergp_addnote(session,char(sprintf("-downsample frequency = %f hz\n",options.downsample)),1); end
split = options.split;

%% PROCESS

% for each subject
for s = 1:numel(subject)
    
    session = synergp_addnote(session,char(sprintf("-processing subject %d of %d\n",s,numel(subject))),1);
        
    % for each muscle
    trialNames = fieldnames(subject(s).data.trials);
    muscleNames = fieldnames(subject(s).data.trials.(trialNames{1}).locations);
    for m = 1:length(muscleNames)
    
        % for each trial
        for t = 1:length(trialNames)
            
            % get sampling frequency
            sf = 1/mean(diff(subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.time));
            
            % hp, rectify, lp
            e = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.data;
            e = bwfilt(abs(bwfilt(e,options.high_cutoff,sf,'high',options.high_order)),options.low_cutoff,sf,'low',options.low_order);
            
            % downsample?
            if isfield(options,'downsample')
                
                if options.downsample > 0
                    
                    old_time = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.time;
                    new_time = old_time(1):1/options.downsample:old_time(end);
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.samplingFrequency = options.downsample;
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.postProcessor_samplingFrequency = options.downsample;
                    e = interp1(old_time,e,new_time,'pchip');
                                                                                                      
                else
                    
                    subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.postProcessor_samplingFrequency = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.samplingFrequency;
                    
                end
                
            else
                
                subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.postProcessor_samplingFrequency = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.samplingFrequency;
                
            end
            
            % for each trial to be split from this one
            ind = find(strcmp(split(:,1),trialNames{t}));
            for k = 1:length(ind)
                
                % samples to keep
                ndata = length(e);
                samps = round(split{ind(k),3} * ndata) : round(split{ind(k),4} * ndata);
                
                % split data and time (zero reference)
                esplit = e(samps);
                timesplit = new_time(samps);
                timesplit = timesplit - timesplit(1);
                
                % MEAN NORMALIZE
                e_mean = mean(esplit);
                esplit = esplit/e_mean;
                
                % populate trial details
                trials.(split{ind(k),2}).locations.(muscleNames{m}).elec.samplingFrequency = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.samplingFrequency;
                trials.(split{ind(k),2}).locations.(muscleNames{m}).elec.postProcessor_samplingFrequency = subject(s).data.trials.(trialNames{t}).locations.(muscleNames{m}).elec.postProcessor_samplingFrequency;
                trials.(split{ind(k),2}).locations.(muscleNames{m}).elec.time = timesplit;
                trials.(split{ind(k),2}).locations.(muscleNames{m}).elec.data = esplit;
                trials.(split{ind(k),2}).locations.(muscleNames{m}).elec.normalization_constant = e_mean;
                
            end
            
        end
        
    end
    
    subject(s).data.trials = trials;
    clear trials
    
end

%% PACKUP

session.subject = subject;
            
end
