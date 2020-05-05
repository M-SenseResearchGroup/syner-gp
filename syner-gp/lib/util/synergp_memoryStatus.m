function session = synergp_memoryStatus(session)
%% synergp utility: calculate/report session structure memory

%% total
mem = whos('session');
mem = mem.bytes/1024^3;
unit = 'GB';
if mem < 1
    mem = mem * 1024;
    unit = 'MB';
end
if mem < 1
    mem = mem * 1024;
    unit = 'KB';
end
session.memory.total = mem;
session.memory.total_unit = unit;
session = synergp_addnote(session,char(sprintf("\n-Current memory: %3.2f %s:\n",mem,unit)),1);

%% notes
notes = session.notes;
mem = whos('notes');
mem = mem.bytes/1024^3;
unit = 'GB';
if mem < 1
    mem = mem * 1024;
    unit = 'MB';
end
if mem < 1
    mem = mem * 1024;
    unit = 'KB';
end
session.memory.notes = mem;
session.memory.notes_unit = unit;
session = synergp_addnote(session,char(sprintf("\t-notes: %3.2f %s\n",mem,unit)),1);

%% subject
if isfield(session,'subject')
    subject = session.subject;
    mem = whos('subject');
    mem = mem.bytes/1024^3;
    unit = 'GB';
    if mem < 1
        mem = mem * 1024;
        unit = 'MB';
    end
    if mem < 1
        mem = mem * 1024;
        unit = 'KB';
    end
    session.memory.subject = mem;
    session.memory.subject_unit = unit;
    session = synergp_addnote(session,char(sprintf("\t-subjects: %3.2f %s\n",mem,unit)),1);
end

%% model
model = session.model;
mem = whos('model');
mem = mem.bytes/1024^3;
unit = 'GB';
if mem < 1
    mem = mem * 1024;
    unit = 'MB';
end
if mem < 1
    mem = mem * 1024;
    unit = 'KB';
end
session.memory.model = mem;
session.memory.model_unit = unit;
session = synergp_addnote(session,char(sprintf("\t-models: %3.2f %s\n",mem,unit)),1);
end