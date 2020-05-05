function evaluation = stdeval_v2(y_true,y_est,y_var,options)
%% stdeval_v2: synergp evaluator
%{

-this same as stdeval_v1 except includes RMSE & MAE normalized by range,
mean, and std dev of the y_true. Also includes std dev of error & absolute 
error and the number of data points.

-all evaluators must have a single input struct options which at a minimum
must contain a y_est field corresponding to the estimated output as well as
a y_true field corresponding to the true output
%}

err = y_est - y_true;
yrange = max(y_true) - min(y_true);
ymean = mean(y_true);
ystd = std(y_true);

evaluation.nDatapoints = length(err);

evaluation.rmse = rms(err);
evaluation.nrmse_range = evaluation.rmse / yrange;
evaluation.nrmse_mean = evaluation.rmse / ymean;
evaluation.nrmse_std = evaluation.rmse / ystd;

evaluation.mae = mean(abs(err));
evaluation.sdae = std(abs(err));
evaluation.nmae_range = evaluation.mae / yrange;
evaluation.nmae_mean = evaluation.mae / ymean;
evaluation.nmae_std = evaluation.mae / ystd;

evaluation.me = mean(err);
evaluation.sde = std(err);

evaluation.correlation = corr(y_true,y_est);
evaluation.r_squared = evaluation.correlation ^ 2;
evaluation.cd = 1 - sum(err.^2) / sum( (y_true - mean(y_true)).^2);
evaluation.vaf = 1 - sum(err.^2) / sum(y_true.^2); % torres-oviedo 06

end