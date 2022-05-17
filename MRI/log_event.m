function P = log_event(P,trial,stimulus,intensity_VAS,intensity,response,resp_onset,rating,rating_rt)

% compute relative timepoint to start of run (last dummy scan)
%t = time - P.mri.time_run(trial);
resp_onset_2 = resp_onset - P.mri.time_run(trial);


% fill in P struct
event_log = {P.protocol.subID,P.protocol.day,P.pain.PEEP.block, trial,stimulus,intensity_VAS,intensity,response,resp_onset_2,rating,rating_rt};
P.data(P.pain.PEEP.block).events = [P.data(P.pain.PEEP.block).events; event_log];

% write to event text file
f_id = fopen(P.path.event_fname,'a+');
fprintf(f_id,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n', P.protocol.subID,P.protocol.day, ...
    P.pain.PEEP.block, trial,stimulus,intensity_VAS, ...
    intensity,response,resp_onset_2,rating,rating_rt);
fclose(f_id);

end