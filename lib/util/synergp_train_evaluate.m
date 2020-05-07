function session = synergp_train_evaluate(session)
%% synergp utility: train-test-evaluate user specified synergy function models

% for each iteration
session = synergp_addnote(session,char(sprintf("\n-TRAINING AND EVALUATING MODELS:\n")),1);
for i = 1:numel(session.model)
    
    session = synergp_addnote(session,char(sprintf("\n-Model %d of %d:\n",i,numel(session.model))),1);
    
    % get unmeasured muscles (these will be estimated)
    unmeasuredMuscles = session.model(i).unmeasuredMuscles;
    
    % if window relative output time type is percentage
    if strcmpi(session.model(i).inputStructure.windowRelativeOutputTime_type,'percentage')
        
        % convert to milliseconds and define percentage
        session.model(i).inputStructure.windowRelativeOutputTime_ms = round(session.model(i).inputStructure.windowRelativeOutputTime * session.model(i).inputStructure.windowSize_ms);
        session.model(i).inputStructure.windowRelativeOutputTime_percentage = session.model(i).inputStructure.windowRelativeOutputTime;
        
    else
        
        % convert to percentage and define milliseconds
        session.model(i).inputStructure.windowRelativeOutputTime_percentage = session.model(i).inputStructure.windowRelativeOutputTime / session.model(i).inputStructure.windowSize_ms;
        session.model(i).inputStructure.windowRelativeOutputTime_ms = session.model(i).inputStructure.windowRelativeOutputTime;
        
    end
    
    % report input structure
    session = synergp_addnote(session,char(sprintf("\t-Input structure:\n")),1);
    session = synergp_addnote(session,char(sprintf("\t\t-number predictor muscles = %d\n",length(session.model(i).inputStructure.predictorMuscles))),1);
    for m = 1:length(session.model(i).inputStructure.predictorMuscles)
        session = synergp_addnote(session,char(sprintf("\t\t\t(%d) %s\n",m,session.model(i).inputStructure.predictorMuscles{m})),1);
    end
    session = synergp_addnote(session,char(sprintf("\t\t-window size = %6.2f ms\n\t\t-output time = %6.2f ms (%d percent of window size)\n",...
        session.model(i).inputStructure.windowSize_ms,session.model(i).inputStructure.windowRelativeOutputTime_ms,round(session.model(i).inputStructure.windowRelativeOutputTime_percentage * 100))),1);
    session = synergp_addnote(session,char(sprintf("\t-GP model structure:\n")),1);
    
    % report mean fxn
    if ~isa(session.model(i).gpModel.meanfunc,'function_handle')
        session = synergp_addnote(session,char(sprintf("\t\t-mean fxn: %s\n",session.model(i).gpModel.meanname)),1);
    else
        session = synergp_addnote(session,char(sprintf("\t\t-mean fxn: %s\n",func2str(session.model(i).gpModel.meanfunc))),1);
    end
    
    % report covariance fxn
    if ~isa(session.model(i).gpModel.covfunc,'function_handle')
        session = synergp_addnote(session,char(sprintf("\t\t-covariance fxn: %s\n",session.model(i).gpModel.covname)),1);
    else
        session = synergp_addnote(session,char(sprintf("\t\t-covariance fxn: %s\n",func2str(session.model(i).gpModel.covfunc))),1);
    end
    
    % report likelihood fxn
    if ~isa(session.model(i).gpModel.likfunc,'function_handle')
        session = synergp_addnote(session,char(sprintf("\t\t-likelihood fxn: %s\n",session.model(i).gpModel.likname)),1);
    else
        session = synergp_addnote(session,char(sprintf("\t\t-likelihood fxn: %s\n",func2str(session.model(i).gpModel.likfunc))),1);
    end
    
    % report inference fxn
    if ~isa(session.model(i).gpModel.inffunc,'function_handle')
        session = synergp_addnote(session,char(sprintf("\t\t-inference fxn: %s\n",session.model(i).gpModel.infname)),1);
    else
        session = synergp_addnote(session,char(sprintf("\t\t-inference fxn: %s\n",func2str(session.model(i).gpModel.inffunc))),1);
    end
        
    % for each subject
    results = struct('emg_true',[],'emg_estimate',[],'emg_variance',[],'subjectIndices',[],'task',{''},'muscle',{''});
    for s = 1:length(session.subject)

        % initialize subject specific results
        subresults = struct('emg_true',[],'emg_estimate',[],'emg_variance',[],'subjectIndices',[],'task',{''},'muscle',{''});

        % get subjects used for training
        if any(strcmpi(session.validation.type,{'LOSO','subject-general'}))
            subjectIndices = 1:numel(session.subject);
            subjectIndices(s) = [];
            session = synergp_addnote(session,char(sprintf("\t-leaving out subject %d of %d\n",s,numel(session.subject))),1);
        else
            subjectIndices = s;
            session = synergp_addnote(session,char(sprintf("\t-building subject-specific model %d of %d\n",s,numel(session.subject))),1);
        end

        % get training set
        session = synergp_addnote(session,char(sprintf("\t\t-building training set")),1);
        trainingset = synergp_buildDataset(session.subject,subjectIndices,session.model(i).dataset.trainingSetDetails,session.model(i).inputStructure,unmeasuredMuscles);
        session = synergp_addnote(session,char(sprintf(" (number observations = %d)\n",size(trainingset.X,1))),1);

        % reduce dataset
        if isfield(session,'datasetReducer')
            if size(trainingset.X,1) > session.datasetReducer.maxNumberObservations
                session = synergp_addnote(session,char(sprintf("\t\t\t-user requested max observations = %d, reducing dataset...\n",session.datasetReducer.maxNumberObservations)),1);
                trainingset = synergp_reduceDataset(session.datasetReducer,trainingset);
                session = synergp_addnote(session,char(sprintf("\t\t\t-number observations reduced to %d\n",size(trainingset.X,1))),1);
            else
                session = synergp_addnote(session,char(sprintf("\t\t\t-number of observations meets requested maximum (%d); not performing dataset reduction\n",session.datasetReducer.maxNumberObservations)),1);
            end
        end

        % keep if keeping
        if session.model(i).keepTrainingSet
            session.model(i).trainingSet = trainingset;
        end

        % get test set
        session = synergp_addnote(session,char(sprintf("\t\t-building test set")),1);
        testset = synergp_buildDataset(session.subject,s,session.model(i).dataset.testSetDetails,session.model(i).inputStructure,unmeasuredMuscles);
        session = synergp_addnote(session,char(sprintf(" (number observations = %d)\n",size(testset.X,1))),1);

        % for each unmeasured muscle
        for m = 1:numel(unmeasuredMuscles)

            % save muscle
            session.model(i).subject(s).muscle(m).name = unmeasuredMuscles{m};
            session = synergp_addnote(session,char(sprintf("\n\t\t-building muscle-specific synergy function (%d of %d): %s\n",m,numel(unmeasuredMuscles),unmeasuredMuscles{m})),1);
            
            % get true emg and task names
            emg_true = testset.Y(:,m);
            uTasks = unique(testset.task);
            
            % determine if tracking optimization
            gpModel = session.model(i).gpModel;
            iter_increments = gpModel.trackOptimIterations;
            track_iters = iter_increments ~= 0;
            hyp_init = gpModel.hypinit;
            max_iters = abs(gpModel.optimStoppingCriteria);
            iter_type = sign(gpModel.optimStoppingCriteria);
            if ~track_iters
                n_loops = 1;
                iter_increments = max_iters;
            else
                n_loops = ceil(max_iters / iter_increments);
            end
            total_iters = 0;
            total_time = 0;
            
            % evaluate performance for initial hyperparams if tracking
            if track_iters
                session.model(i).subject(s).muscle(m).optimization(1).NLML = gp(hyp_init,gpModel.inffunc,gpModel.meanfunc,gpModel.covfunc,gpModel.likfunc,trainingset.X,trainingset.Y(:,m));
                session.model(i).subject(s).muscle(m).optimization(1).time = 0;
                session.model(i).subject(s).muscle(m).optimization(1).hyperparameters = hyp_init;
                session.model(i).subject(s).muscle(m).optimization(1).iterations = 0;
                [emg_est,emg_var] = gp(hyp_init,gpModel.inffunc,gpModel.meanfunc,gpModel.covfunc,gpModel.likfunc,trainingset.X,trainingset.Y(:,m),testset.X);
                for t = 1:length(uTasks)
                    task_indices = strcmp(testset.task,uTasks{t});
                    session.model(i).subject(s).muscle(m).optimization(1).task(t).name = uTasks{t};
                    session.model(i).subject(s).muscle(m).optimization(1).task(t).evaluation = feval(session.validation.evaluator.name,emg_true(task_indices),emg_est(task_indices),emg_var(task_indices),session.validation.evaluator.options);
                end
            end

            % optimize hyperparams
            for loop_count = 1:n_loops
                session = synergp_addnote(session,char(sprintf("\t\t\t(%d/%d) optimizing hyperparameters: ",loop_count,n_loops)),1);
                
                % reduce iterations for this loop if total exceeds user requested max
                if total_iters + iter_increments > max_iters
                    iter_increments = max_iters - total_iters;
                end
                
                % minimize
                tic;
                [hyp,nlml,optim_iters] = minimize(hyp_init,@gp,iter_type * iter_increments,gpModel.inffunc,gpModel.meanfunc,gpModel.covfunc,gpModel.likfunc,trainingset.X,trainingset.Y(:,m));
                loop_time = toc;
                total_time = total_time + loop_time;
                
                % save results
                session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).time = loop_time;
                session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).hyperparameters = hyp;
                session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).NLML = nlml(end);
                session = synergp_addnote(session,char(sprintf(" (%f seconds)\n",session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).time)),1);
                total_iters = total_iters + optim_iters;
                session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).iterations = total_iters;
                
                % evaluate if tracking increments
                if track_iters
                    [emg_est,emg_var] = gp(hyp,gpModel.inffunc,gpModel.meanfunc,gpModel.covfunc,gpModel.likfunc,trainingset.X,trainingset.Y(:,m),testset.X);
                    for t = 1:length(uTasks)
                        task_indices = strcmp(testset.task,uTasks{t});
                        session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).task(t).name = uTasks{t};
                        session.model(i).subject(s).muscle(m).optimization(loop_count+track_iters).task(t).evaluation = feval(session.validation.evaluator.name,emg_true(task_indices),emg_est(task_indices),emg_var(task_indices),session.validation.evaluator.options);
                    end
                end
                
                % exit if converged early
                if optim_iters < iter_increments
                    break;
                % otherwise update initial hyperparams    
                else
                    hyp_init = hyp;
                end
                
            end
            
            % report total time
            session = synergp_addnote(session,char(sprintf("\t\t\t-total optimization time: %f seconds (%d iterations)\n",total_time,total_iters)),1);

            % test
            session = synergp_addnote(session,char(sprintf("\t\t\t-test set validation...")),1);
            tic;
            [emg_est,emg_var] = gp(hyp,gpModel.inffunc,gpModel.meanfunc,gpModel.covfunc,gpModel.likfunc,trainingset.X,trainingset.Y(:,m),testset.X);
            session.model(i).subject(s).muscle(m).estimationTime = toc;
            session = synergp_addnote(session,char(sprintf("\b\b\b: prediction time = %f seconds\n",session.model(i).subject(s).muscle(m).estimationTime)),1);

            % evaluate: subject specific, task specific, muscle specific
            session = synergp_addnote(session,char(sprintf("\t\t\t-performance evaluation: subject specific, task specific, muscle specific\n")),1);
            uTasks = unique(testset.task);
            for t = 1:length(uTasks)
                task_indices = strcmp(testset.task,uTasks{t});
                session.model(i).subject(s).muscle(m).task(t).name = uTasks{t};
                session.model(i).subject(s).muscle(m).task(t).evaluation = feval(session.validation.evaluator.name,emg_true(task_indices),emg_est(task_indices),emg_var(task_indices),session.validation.evaluator.options);
                session = synergp_addnote(session,char(sprintf("\t\t\t\t-%s:\n",uTasks{t})),1);
                session = synergp_reportEvaluation(session,session.model(i).subject(s).muscle(m).task(t).evaluation,5);
            end

%             % evaluate: subject specific, muscle specific, aggregated across tasks
%             session = synergp_addnote(session,char(sprintf("\t\t\t-performance evaluation: subject specific, muscle specific, average across tasks\n")),1);
%             session.model(i).subject(s).muscle(m).evaluation = feval(session.validation.evaluator.name,emg_true,emg_est,emg_var,session.validation.evaluator.options);
%             session = synergp_reportEvaluation(session,session.model(i).subject(s).muscle(m).evaluation,4);

            % save subject results
            subresults.emg_true = vertcat(subresults.emg_true,emg_true);
            subresults.emg_estimate = vertcat(subresults.emg_estimate,emg_est);
            subresults.emg_variance = vertcat(subresults.emg_variance,emg_var);
            subresults.muscle = vertcat(subresults.muscle,repmat(unmeasuredMuscles(m),[length(emg_est) 1]));
            subresults.task = vertcat(subresults.task,testset.task);
            subresults.subjectIndices = vertcat(subresults.subjectIndices,testset.subjectIndices);

        end

%         % evaluate: subject specific, task general, muscle general
%         session = synergp_addnote(session,char(sprintf("\n\t\t-performance evaluation: subject specific, task general, muscle general\n")),1);
%         session.model(i).subject(s).evaluation = feval(session.validation.evaluator.name,subresults.emg_true,subresults.emg_estimate,subresults.emg_variance,session.validation.evaluator.options);
%         session = synergp_reportEvaluation(session,session.model(i).subject(s).evaluation,3);
% 
%         % evaluate: subject specific, task specific, muscle general
%         session = synergp_addnote(session,char(sprintf("\t\t-performance evaluation: subject specific, task specific, muscle general\n")),1);
%         uTasks = unique(subresults.task);
%         for t = 1:length(uTasks)
%             task_indices = strcmp(subresults.task,uTasks{t});
%             session.model(i).subject(s).task(t).name = uTasks{t};
%             session.model(i).subject(s).task(t).evaluation = feval(session.validation.evaluator.name,subresults.emg_true(task_indices),subresults.emg_estimate(task_indices),subresults.emg_variance(task_indices),session.validation.evaluator.options);
%             session = synergp_addnote(session,char(sprintf("\t\t\t-%s:\n",uTasks{t})),1);
%             session = synergp_reportEvaluation(session,session.model(i).subject(s).task(t).evaluation,4);
%         end

        % save results
        results.emg_true = vertcat(results.emg_true,subresults.emg_true);
        results.emg_estimate = vertcat(results.emg_estimate,subresults.emg_estimate);
        results.emg_variance = vertcat(results.emg_variance,subresults.emg_variance);
        results.muscle = vertcat(results.muscle,subresults.muscle);
        results.task = vertcat(results.task,subresults.task);
        results.subjectIndices = vertcat(results.subjectIndices,subresults.subjectIndices);

    end

%     % evaluate: subject general, task general, muscle general
%     session = synergp_addnote(session,char(sprintf("\n\t-performance evaluation: subject general, task general, muscle general\n")),1);
%     session.model(i).evaluation = feval(session.validation.evaluator.name,results.emg_true,results.emg_estimate,results.emg_variance,session.validation.evaluator.options);
%     session = synergp_reportEvaluation(session,session.model(i).evaluation,2);
% 
%     % evaluate: subject general, task specific, muscle general
%     session = synergp_addnote(session,char(sprintf("\t-performance evaluation: subject general, task specific, muscle general\n")),1);
%     uTasks = unique(results.task);
%     for t = 1:length(uTasks)
%         task_indices = strcmp(results.task,uTasks{t});
%         session.model(i).task(t).name = uTasks{t};
%         session.model(i).task(t).evaluation = feval(session.validation.evaluator.name,results.emg_true(task_indices),results.emg_estimate(task_indices),results.emg_variance(task_indices),session.validation.evaluator.options);
%         session = synergp_addnote(session,char(sprintf("\t\t-%s:\n",uTasks{t})),1);
%         session = synergp_reportEvaluation(session,session.model(i).task(t).evaluation,3);
%     end
% 
%     % evaluate: subject general, task general, muscle specific
%     session = synergp_addnote(session,char(sprintf("\t-performance evaluation: subject general, task general, muscle specific\n")),1);
%     uMuscles = unique(results.muscle);
%     for m = 1:length(uMuscles)
%         muscle_indices = strcmp(results.muscle,uMuscles{m});
%         session.model(i).muscle(m).name = uMuscles{m};
%         session.model(i).muscle(m).evaluation = feval(session.validation.evaluator.name,results.emg_true(muscle_indices),results.emg_estimate(muscle_indices),results.emg_variance(muscle_indices),session.validation.evaluator.options);
%         session = synergp_addnote(session,char(sprintf("\t\t-%s:\n",uMuscles{m})),1);
%         session = synergp_reportEvaluation(session,session.model(i).muscle(m).evaluation,3);
%     end

    % keep results
    if session.validation.keepAllResults
        session.model(i).results = results;
    end

    % status update
    session = synergp_memoryStatus(session);
    
end
            
