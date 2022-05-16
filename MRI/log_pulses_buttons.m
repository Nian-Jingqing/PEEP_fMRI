function [P] = log_pulses_buttons(P,t0_scan)

[keycode, secs] = KbQueueDump();

session        = repelem(P.session, length(keycode));
trial          = repelem(P.trial, length(keycode));
t_pulses       = secs(keycode == P.keys.pulse);

keycode        = keycode(end:-1:1);
secs           = secs(end:-1:1);

% write to P struct
for ix = 1:length(keycode)
     if keycode(ix) == P.keys.pulse
        P.data(P.session).pulses = [P.data(P.session).pulses;...
             {session(ix), trial(ix),secs(ix)-t0_scan}];
     else
          % all non mr-pulse trigger
         P.data(P.session).b_presses = [P.data(P.session).b_presses;...
             {session(ix), trial(ix),KbName(keycode(ix)), secs(ix)-t0_scan}];
     end
end


% write to txt file
f_id = fopen(P.path.pulse_bpress_fname,'a+');
for ix = 1:length(keycode)
    if keycode(ix) ~= P.keys.pulse
        fprintf(f_id, '%d\t%d\t%d\t%f\r\n', session(ix), trial(ix),...
            keycode(ix), secs(ix)-t0_scan);
    end
end
fclose(f_id);

% write to txt file
f_id1 = fopen(P.path.pulses_fname,'a+');
for ix = 1:length(t_pulses)
    if keycode(ix) == P.keys.pulse
        fprintf(f_id1, '%d\t%d\t%f\r\n', session(ix), trial(ix),...
             secs(ix)-t0_scan);
    end
end
fclose(f_id1);


end