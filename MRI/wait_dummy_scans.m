function [t0_scan,secs] = wait_dummy_scans(P)

KbQueueRelease();

if strcmp(P.env.hostname,'stimpc1')
    %% Wait for MRI dummy scans
    fprintf('\nWaiting for %i dummy pulses...\n',P.mri.dummy_scans);
    
elseif strcmp(P.env.hostname,'isn3822e2ce3372')
    fprintf('\nImitate %i dummy pulses...\n',P.mri.dummy_scans);
end

if P.mri.dummy_scans > 0
    secs  = NaN(1,P.mri.dummy_scans);
    pulse = 1;
    dummy = []; %#ok<NASGU>
    while pulse < P.mri.dummy_scans + 1 % Listening loop
         fprintf('Waiting for dummy scan %d\n',pulse);
         dummy         = KbTriggerWait(P.keys.pulse); % P.keys.trigger initialized in SetInput(P,O) function
         secs(pulse)   = dummy; % formerly secs(pulse+1)   = dummy;
         pulse         = pulse + 1;
    end
else
    secs = GetSecs; 
end


t0_scan = secs(P.mri.dummy_scans);

end
