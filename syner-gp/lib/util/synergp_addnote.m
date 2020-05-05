function session = synergp_addnote(session,note,display)
session.notes{length(session.notes)+1} = note;
if display; fprintf(note); end
end