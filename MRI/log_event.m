function P = log_event(P, time, info)

% compute relative timepoint to start of run (last dummy scan)
t = time - P.mri.time_run(P.session);

% fill in P struct
event_log = {P.session, P.trial, t, info};
P.data(P.session).events = [P.data(P.session).events; event_log];

% write to event text file
f_id = fopen(P.path.event_fname,'a+');
fprintf(f_id,'%d\t%d\t%f\t%s\r\n', P.session, P.trial, t, info);
fclose(f_id);

end