function session = synergp_addnote(session,note,display)
%% synergp utility: updates notes cell array and prints to command window

session.notes{length(session.notes)+1} = note;
if display; fprintf(note); end

end