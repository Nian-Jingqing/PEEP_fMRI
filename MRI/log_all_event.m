function P = log_all_event(P, time, info,trial,t0_scan)

% compute relative timepoint to start of run (last dummy scan)
t = time - t0_scan;

% fill in P struct
event_log = {P.pain.PEEP.block, trial, t, info};
P.data(P.pain.PEEP.block).events = [P.data(P.pain.PEEP.block).events; event_log];

% write to event text file
f_id = fopen(P.path.all_event_fname,'a+');
fprintf(f_id,'%d\t%d\t%f\t%s\r\n', P.pain.PEEP.block, trial, t, info);
fclose(f_id);

end