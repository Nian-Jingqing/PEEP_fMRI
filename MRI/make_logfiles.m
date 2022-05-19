function P = make_logfiles(P)    
% ----------------- output settings ---------------------------------------
   
%     P.path.filename          = sprintf('sub-%02d_block-%02d-peep_exp-day-%02d_events.tsv',...
%                               P.protocol.subID, P.pain.PEEP.block , P.protocol.day);
%     P.path.filename          = fullfile(P.out.dirExp, P.path.filename);
% 
%     % make header for path file
%     if exist(P.path.filename, 'file')
%         [f_path, f_name, f_ext] = fileparts(P.path.filename);
%         f_dir = dir(fullfile(f_path,[f_name,'*',f_ext]));
%         f_num = length(f_dir);
%         new_v = f_num + 1;
%         P.path.filename = fullfile(f_path, [f_name, sprintf('_v%d',new_v), f_ext]);
%     end
% 
%     path_file_id = fopen(P.path.filename,'a+');
%     fprintf(path_file_id, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
%     'sub','day','block','trial','stim','intensity','kPa/temp','resp','resp_onset','rating','rating_rt', 'error');
%     fprintf(path_file_id,'\r\n');
%     fclose(path_file_id);


    % -----------------  table meta data ----------------------------
   P.data(P.pain.PEEP.block).meta = createTable({'sub','part','day','cuff_arm','thermode_arm',...
            'age','gender','pharm_day2','pharm_day3'});

    
    P.path.filename_meta = sprintf('sub-%02d_block-%02d-peep_exp-day-%02d_meta.tsv',...
                              P.protocol.subID, P.pain.PEEP.block, P.protocol.day);
    P.path.filename_meta = fullfile(P.out.dirExp, P.path.filename_meta);

    if ~exist(P.path.filename_meta, 'file')
        f_id = fopen(P.path.filename_meta,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', 'sub','part','day','cuff_arm','thermode_arm','age','gender','pharm_day2','pharm_day3');
        fprintf(f_id,'\r\n');
        fclose(f_id);

    end


    % -----------------  table behavioral data ----------------------------
    P.data(P.pain.PEEP.block).behav = createTable({ 'sub','day','block','trial','stim','intensity_VAS', ...
        'intensity_kPA_temp','response','resp_onset','rating','rating_rt'});
    
    P.path.behav_fname = sprintf('sub-%02d_block-%02d-peep_exp-day-%02d_behav.tsv',...
                              P.protocol.subID, P.pain.PEEP.block, P.protocol.day);
    P.path.behav_fname = fullfile(P.out.dirExp, P.path.behav_fname);

    if ~exist(P.path.behav_fname, 'file')
        f_id = fopen(P.path.behav_fname,'a+');
        fprintf(f_id, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t',...
     'sub','day','block','trial','stim','intensity_VAS', 'intensity_kPA_temp','response','resp_onset','rating','rating_rt');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end

    
    % -----------------  table event data --------------------------------

    P.path.all_event_fname = sprintf('sub-%02d_block-%02d-peep_exp-day-%02d_all_events.tsv',...
                              P.protocol.subID, P.pain.PEEP.block, P.protocol.day);
    P.path.all_event_fname = fullfile(P.out.dirExp, P.path.all_event_fname);

    if ~exist(P.path.all_event_fname, 'file')
        f_id = fopen(P.path.all_event_fname,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s\t%s', 'block','trial','time_on','event_info');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end

    % events = physiopathy triggers, button presses
    P.data(P.pain.PEEP.block).events = createTable({'block','trial','time_on',...
        'event_info'}); 

    % ---------- path table mri pulses & button presses -------------------
    % save in P struct
    P.data(P.pain.PEEP.block).pulses     = createTable({'block','trial','time'});
    P.data(P.pain.PEEP.block).b_presses  = createTable({'block','trial','key','time'});
    
    P.path.pulse_bpress_fname = sprintf('sub-%02d_block-%02d-peep_exp-day-%02d_trigger.tsv',...
                              P.protocol.subID, P.pain.PEEP.block, P.protocol.day);
    P.path.pulse_bpress_fname = fullfile(P.out.dirExp, P.path.pulse_bpress_fname);

    if ~exist(P.path.pulse_bpress_fname, 'file')
        f_id = fopen(P.path.pulse_bpress_fname,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s', 'block','trial','key','time');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end
    
    % pulses mr
    P.path.pulses_fname =  sprintf('sub-%02d_block-%02d-peep_exp-day-%02d_pulses.tsv',...
                              P.protocol.subID, P.pain.PEEP.block, P.protocol.day);
    P.path.pulses_fname = fullfile(P.out.dirExp, P.path.pulses_fname);
    
    if ~exist(P.path.pulses_fname, 'file')
        f_id = fopen(P.path.pulses_fname,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s', 'block','trial','time');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end


    
end