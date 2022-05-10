% See MRTrig_WRAPPER for additional information.

function tStart = MRTrig_Start(P,forceInput)    

    [~, tmp] = system('hostname');
    hostname = deblank(tmp);

    % Wait for nDelay scans to continue - commonly, these would be the dummy scans at the start of the EPI sequence
    if ( strcmp(hostname,'stimpc1') && P.mri.nDelay>0 ) || forceInput
        fprintf('\n==================================================\n==================================================\n');

        fprintf('Script now in READY MODE, will wait for %d MR triggers to continue.\n',P.mri.nDelay)
        fprintf('Note: [Last trigger] signifies [start of the first scan] (time of last trigger = scan 0.0 for SPM onsets).\n')                
        fprintf('Check that subject is ready, then ask MTRA to start sequence...\n');
        
        tStart = MRTrig_Wait(P); 
    else
        if strcmp(hostname,'stimpc1')
            warning('Script continues IMMEDIATELY, without waiting for ANY scanner triggers.'); % this case should be rare
        else
            fprintf('[skipping MRTrig_Wait block]\n'); 
        end
        tStart = GetSecs;
    end
    