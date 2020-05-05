function ind = genreduce_v1(X,Y,n,options)
if strcmp(options.method,'random')
    ind = randperm(size(X,1),n);
else
    ind = 1:n;
end
end