function session = synergp_reportEvaluation(session,evaluation,ntabs)
%% synergp utility: prints model evaluation results to command window

tabs = string(repmat('\t',[1 ntabs]));
if isfield(session.validation.evaluator,'reportEvaluation')
    report = 1;
    if isa(session.validation.evaluator.reportEvaluation,'char')
        metrics = {session.validation.evaluator.reportEvaluation};
    elseif isa(session.validation.evaluator.reportEvaluation,'cell')
        metrics = session.validation.evaluator.reportEvaluation;
        if isempty(metrics)
            report = 0;
            session = synergp_addnote(session,char(sprintf(strcat(tabs,"-reportEvaluation is empty\n"))),1);
        end
    elseif isa(session.validation.evaluator.reportEvaluation,'logical')
        if session.validation.evaluator.reportEvaluation
            metrics = fieldnames(evaluation);
            if isempty(metrics)
                report = 0;
                session = synergp_addnote(session,char(sprintf(strcat(tabs,"-no metrics to report\n"))),1);
            end
        end
    elseif isa(session.validation.evaluator.reportEvaluation,'numeric')
        if session.validation.evaluator.reportEvaluation
            metrics = fieldnames(evaluation);
            if isempty(metrics)
                report = 0;
                session = synergp_addnote(session,char(sprintf(strcat(tabs,"-no metrics to report\n"))),1);
            end
        end
    else
        report = 0;
    end
    if report
        for m = 1:length(metrics)
            if isfield(evaluation,metrics{m})
                session = synergp_addnote(session,char(sprintf(strcat(tabs,"-%s = %f\n"),metrics{m},evaluation.(metrics{m}))),1);
            end
        end
    end
end
end