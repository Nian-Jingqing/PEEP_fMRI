function send_trigger(P,O,event_type)

 if O.send_trigger
     send = 1;
 else
     send = 0;
 end

switch event_type
    case 'start_run' 
        n_address = 1;
        
    case 'trial_start'  % main = 4
        n_address = 1;
        n_code    = 1;
        
    case 'ITI_on'       % calib = 4
         n_address = 1;
         n_code    = 1;
    
    case 'button' % = 5
        n_address = 1;
        n_code    = 2;
        
    case 'expect_on'  % = 6 
        n_address = 1;
        n_code    = 3;
        
    case  'cue_on' %  calib = 6
        n_address = 1;
        n_code    = 3;
        
    case 'stim_on'  % = 9
        n_address = 2;
        n_code    = 2;
        
    case 'stim_off' % = 10
        n_address = 2;
        n_code    = 3;
        
    case 'vas_on'   % = 11
        n_address = 2;
        n_code    = 1;
end

% add for calib: 'cue_on', 'ITI_on'
if ~strcmp(event_type, 'start_run')
    address = P.com.port_addresses(n_address);
    code    = P.com.codes(n_address,n_code);
else
    address = P.com.port_addresses(n_address);
    code    = sum(P.com.codes(1,1:3)); % make a salient trigger at start
end


if strcmp(P.env.hostname,'stimpc1')
    % Send pulse for spike program
    if send
        if ~isempty(regexp(computer('arch'),'64','ONCE'))
            outp(address,code);
            WaitSecs(P.com.duration);
            outp(address,0);
            WaitSecs(P.com.duration);

        elseif ~isempty(regexp(computer('arch'),'32','ONCE'))
            outp32(address,code);
            WaitSecs(P.com.duration);            
            outp32(address,0);
            WaitSecs(P.com.duration);
        end  
    else
        fprintf('\n no trigger send\n');
    end
    
elseif strcmp(P.env.hostname,'isn3822e2ce3372')
    %fprintf('\nphysiology trigger test:%s\nport address:%d\ntrigger nr: %d\n',...
        %event_type,address,code);
end

end
