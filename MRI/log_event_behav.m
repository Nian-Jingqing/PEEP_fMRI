function P = log_event_behav(P,trial,stimulus,intensity_VAS,intensity,response,resp_onset,rating,rating_rt)

% compute relative timepoint to start of run (last dummy scan)
%t = time - P.mri.time_run(trial);
resp_onset_2 = resp_onset - P.mri.mriBlockStart(P.pain.PEEP.block);

% fill in P struct
behav_log = {P.protocol.subID,P.protocol.day,P.pain.PEEP.block, trial,stimulus,intensity_VAS,intensity,response,resp_onset_2,rating,rating_rt};
P.data(P.pain.PEEP.block).behav = [P.data(P.pain.PEEP.block).behav; behav_log];

% write to event text file
f_id = fopen(P.path.behav_fname,'a+');
fprintf(f_id,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\r\n', P.protocol.subID,P.protocol.day, ...
    P.pain.PEEP.block, trial,stimulus,intensity_VAS, ...
    intensity,response,resp_onset_2,rating,rating_rt);
fclose(f_id);

end