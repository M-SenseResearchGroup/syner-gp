function evaluation = stdeval_v1(y_true,y_est,y_var,options)
%% stdeval_v1: synergp evaluator
%{
-all evaluators must have a single input struct options which at a minimum
must contain a y_est field corresponding to the estimated output as well as
a y_true field corresponding to the true output
%}

err = y_est - y_true;
evaluation.rmse = rms(err);
evaluation.mae = mean(abs(err));
evaluation.me = mean(err);
evaluation.correlation = corr(y_true,y_est);
evaluation.r_squared = evaluation.correlation ^ 2;
evaluation.cd = 1 - sum(err.^2) / sum( (y_true - mean(y_true)).^2);
evaluation.vaf = 1 - sum(err.^2) / sum(y_true.^2); % torres-oviedo 06

end