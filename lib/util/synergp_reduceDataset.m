function dataset = synergp_reduceDataset(datasetReducer,dataset)
%% synergp utility: reduce dataset size
    
% if reducing at dataset level
if strcmp(datasetReducer.reductionLevel,'dataset')

    % get indices of reduced dataset
    ind = feval(datasetReducer.name,dataset.X,dataset.Y,datasetReducer.maxNumberObservations,datasetReducer.options);

% if reducing at task level
elseif strcmp(datasetReducer.reductionLevel,'task')

    % get unique tasks
    [uTasks,~,uTasks_indices] = unique(dataset.task);

    % get number per trial to meet requested max number
    n = floor(datasetReducer.maxNumberObservations / length(uTasks));

    % get indices for each unique task
    ind = zeros(n * length(uTasks),1);
    for t = 1:length(uTasks)
        task_indices = find(uTasks_indices == t);
        reduced_indices = feval(datasetReducer.name,dataset.X(task_indices,:),dataset.Y(task_indices),n,datasetReducer.options);
        ind(n*(t-1)+1:n*t) = task_indices(reduced_indices);
    end

% if reducing at subject level    
elseif strcmp(datasetReducer.reductionLevel,'subject')

    % get unique subjects
    [uSubjects,~,uSubjects_indices] = unique(dataset.subjectIndices);

    % get number per subject to meet requested max number
    n = floor(datasetReducer.maxNumberObservations / length(uSubjects));

    % get indices for each unique subject
    ind = zeros(n * length(uSubjects),1);
    for s = 1:length(uSubjects)
        subject_indices = find(uSubjects_indices == s);
        reduced_indices = feval(datasetReducer.name,dataset.X(subject_indices,:),dataset.Y(subject_indices),n,datasetReducer.options);
        ind(n*(s-1)+1:n*s) = subject_indices(reduced_indices);
    end

% if reducing at subject-task level
elseif strcmp(datasetReducer.reductionLevel,'subject-task')

    % get unique subjects
    [uSubjects,~,uSubjects_indices] = unique(dataset.subjectIndices);
    uSubjects = cell2struct(num2cell(uSubjects)','index');

    % get number of unique subject-task pairs
    nunique = 0;
    for s = 1:length(uSubjects)

        % get unique tasks pertaining to this subject
        uSubjects(s).uTasks = unique(dataset.task(uSubjects_indices == s));

        % update unique counter
        nunique = nunique + length(uSubjects(s).uTasks);

    end
    n = floor(datasetReducer.maxNumberObservations / nunique);

    % for each unique subject
    ind = zeros(n * nunique,1);
    curr = 1;
    for s = 1:length(uSubjects)

        % for each unique task
        for t = 1:length(uSubjects(s).uTasks)

            % get indices for unique subject + trial set
            set_indices = find(dataset.subjectIndices == uSubjects(s).index & strcmp(dataset.task,uSubjects(s).uTasks{t}));
            reduced_indices = feval(datasetReducer.name,dataset.X(set_indices,:),dataset.Y(set_indices),n,datasetReducer.options);
            ind(curr:curr+n-1) = set_indices(reduced_indices);
            curr = curr + n;
        end
    end

else
    error('Unrecognized requested dataset reduction level')
end

% reduce dataset
ind = sort(ind,'ascend');
dataset.X = dataset.X(ind,:);
dataset.Y = dataset.Y(ind,:);
dataset.subjectIndices = dataset.subjectIndices(ind);
dataset.task = dataset.task(ind);

end