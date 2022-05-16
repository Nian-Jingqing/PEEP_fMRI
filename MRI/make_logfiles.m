function P = make_logfiles(P)    
% ----------------- output settings ---------------------------------------
    % if P.training
    %     P.path.filename          = sprintf('sub_%03d_train.txt',P.subID);
    %     P.path.filename          = fullfile(P.path.sub, P.path.filename);
    %     P.time.train_date              = datestr(now,30);
    % end
    P.path.filename          = sprintf('sub-%02d_task-copain_acq-%s_run-%02d_beh.tsv',...
                              P.subID, P.condition, P.session);
    P.path.filename          = fullfile(P.path.sub, P.path.filename);

    % make header for path file
    if exist(P.path.filename, 'file')
        [f_path, f_name, f_ext] = fileparts(P.path.filename);
        f_dir = dir(fullfile(f_path,[f_name,'*',f_ext]));
        f_num = length(f_dir);
        new_v = f_num + 1;
        P.path.filename = fullfile(f_path, [f_name, sprintf('_v%d',new_v), f_ext]);
    end

    path_file_id = fopen(P.path.filename,'a+');
    fprintf(path_file_id, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'sub','session','condition',...
    'trial','choice','rt','intensity','temp','resp','remain_cat',...
    'error','chosen_empty','rating','rating_rt','rating_resp',...
    'test_trial','stim_color');
    fprintf(path_file_id,'\r\n');
    fclose(path_file_id);


    % -----------------  table behavioral data ----------------------------
    P.data(P.session).behav = createTable({'sub','session','condition',...
        'trial','choice','rt','intensity','temp','resp','remain_cat',...
        'error','chosen_empty','rating','rating_rt','rating_resp',...
        'test_trial','stim_color'});
    
    % -----------------  table event data ------------ö--------------------
    P.data(P.session).events = createTable({'run', 'trial', 'time',...
                                            'info'});
    
    % ---------- path table mri pulses & button presses -------------------
    % save in P struct
    P.data(P.session).pulses     = createTable({'run','trial','time'});
    P.data(P.session).b_presses  = createTable({'run','trial','key','time'});
    
    P.path.pulse_bpress_fname = sprintf('sub-%02d_task-copain_acq-%s_run-%02d_trigger.tsv',...
                              P.subID, P.condition, P.session);
    P.path.pulse_bpress_fname = fullfile(P.path.sub, P.path.pulse_bpress_fname);

    if ~exist(P.path.pulse_bpress_fname, 'file')
        f_id = fopen(P.path.pulse_bpress_fname,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s', 'run','trial','key','time');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end
    
    P.path.pulses_fname =  sprintf('sub-%02d_task-copain_acq-%s_run-%02d_pulses.tsv',...
                              P.subID, P.condition, P.session);
    P.path.pulses_fname = fullfile(P.path.sub, P.path.pulses_fname);
    
    if ~exist(P.path.pulses_fname, 'file')
        f_id = fopen(P.path.pulses_fname,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s', 'run','trial','time');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end


    % ------------ path table all other triggers -------------------------------
    P.path.event_fname = sprintf('sub-%02d_task-copain_acq-%s_run-%02d_events.tsv',...
                              P.subID, P.condition, P.session);
    P.path.event_fname = fullfile(P.path.sub, P.path.event_fname);

    if ~exist(P.path.event_fname, 'file')
        f_id = fopen(P.path.event_fname,'a+');
        fprintf(f_id,'%s\t%s\t%s\t%s', 'run','trial','time','event_info');
        fprintf(f_id,'\r\n');
        fclose(f_id);
    end

    % events = physiopathy triggers, button presses
    P.data(P.session).events = createTable({'run','trial','time',...
        'event_info'}); 
end