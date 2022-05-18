function [P] = log_pulses_buttons(P,t0_scan,cur_trial)

[keycode, secs] = KbQueueDump();

block           = repelem(P.pain.PEEP.block, length(keycode));
trial          = repelem(cur_trial, length(keycode));
t_pulses       = secs(keycode == P.keys.pulse);

keycode        = keycode(end:-1:1);
secs           = secs(end:-1:1);

% % write to P struct
% for ix = 1:length(keycode)
%      if keycode(ix) == P.keys.pulse
%         P.data(P.pain.PEEP.block).pulses = [P.data(P.pain.PEEP.block).pulses;...
%              {block(ix), trial(ix),secs(ix)-t0_scan}];
%      else
%           % all non mr-pulse trigger
%          P.data(P.pain.PEEP.block).b_presses = [P.data(P.pain.PEEP.block).b_presses;...
%              {block(ix), trial(ix),KbName(keycode(ix)), secs(ix)-t0_scan}];
%      end
% end


% write to txt file
f_id = fopen(P.path.pulse_bpress_fname,'a+');
for ix = 1:length(keycode)
    if keycode(ix) ~= P.keys.pulse
        fprintf(f_id, '%d\t%d\t%d\t%f\r\n', block(ix), trial(ix),...
            keycode(ix), secs(ix)-t0_scan);
    end
end
fclose(f_id);

% write to txt file
f_id1 = fopen(P.path.pulses_fname,'a+');
for ix = 1:length(t_pulses)
    if keycode(ix) == P.keys.pulse
        fprintf(f_id1, '%d\t%d\t%f\r\n', block(ix), trial(ix),...
             secs(ix)-t0_scan);
    end
end
fclose(f_id1);


end