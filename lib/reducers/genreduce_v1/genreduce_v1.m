function ind = genreduce_v1(X,Y,n,options)
%% genreduce_v1: synergp reducer
% currently only has one option ('random'): implements random subsets
% selection. The GPML toolbox has other ways of handling large datasets. If
% 'random' not specified as the option, then the first n datapoints are
% returned
if strcmp(options.method,'random')
    ind = randperm(size(X,1),n);
else
    ind = 1:n;
end
end