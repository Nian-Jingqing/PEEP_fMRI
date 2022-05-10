% See MRTrig_WRAPPER for additional information.

function tTrig = MRTrig_Wait(P)

    % This function waits for the P.mri.nDelayth upcoming trigger. If N=1, it will wait for
    % the very next pulse to arrive. 1 MEANS NEXT PULSE. So if you wish to wait
    % for 6 full dummy scans, use N=7 so that 6 full acquisitions are finished.
    %
    % The full array of all tTrig.
    %
    % The function avoids KbCheck, KbWait functions, but relies on the OS level event queues, 
    % which are much less likely to skip short events. A nice discussion on the topic can be found here:
    % http://ftp.tuebingen.mpg.de/pub/pub_dahl/stmdev10_D/Matlab6/Toolboxes/Psychtoolbox/PsychDocumentation/KbQueue.html

    commandwindow;
    if P.mri.nDelay > 0
        % instantiate counter/log variables
        nTrig = 0;
        tTrig  = NaN(1,P.mri.nDelay);
        while nTrig < P.mri.nDelay % Listening loop
            nTrig = nTrig+1;
            fprintf('Waiting for trigger %d... ',nTrig);
            t = KbTriggerWait(P.keys.trigger,P.devices.input);
            fprintf('received.\n');
            
            tTrig(nTrig) = t; % formerly secs(pulse+1)   = dummy;
        end
    else
        tTrig = GetSecs; % redundant, but just in case MRTrig_Wait is called outside TrigFct_Start
    end
    