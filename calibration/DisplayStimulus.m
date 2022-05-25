    %% sends trigger to CED and waits approximate stimulus duration
    function [abort]=DisplayStimulus(P,O,nTrial,temp)

        abort=0;
        
        [stimDuration]=CalcStimDuration_heat(P,temp,P.presentation.sStimPlateau);
        fprintf('\n=======TRIAL %d of %d=======\n',nTrial,P.awiszus.N);
                   
        if nTrial == 1 % Turn on the fixation cross for the first trial (no ITI to cover this)
            fprintf('[Initial trial, showing white cross for %1.1f seconds, red cross for %1.1f seconds]\n',P.presentation.firstThresholdITI-P.presentation.firstThresholdCue,P.presentation.firstThresholdCue);
            
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1); 
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2); 
                tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog                        
            else
                tCrossOn = GetSecs;
            end
            send_trigger(P,O,sprintf('ITI_on'));
            
            while GetSecs < tCrossOn + P.presentation.firstThresholdITI-P.presentation.firstThresholdCue 
                [abort]=LoopBreaker(P);
                if abort; return; end
            end
            
            if P.presentation.cueing==1 && ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1); 
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2); 
                tCueOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
                while GetSecs < tCueOn + P.presentation.firstThresholdCue 
                    [abort]=LoopBreaker(P);
                    if abort; return; end
                end
            end
        end

        fprintf('%1.1f°C stimulus initiated',temp);
        
        tStimStart=GetSecs;
        countedDown=1;
                
        if P.devices.thermoino        
            UseThermoino('Trigger'); % start next stimulus
            UseThermoino('Set',temp); % open channel for arduino to ramp up      

            while GetSecs < tStimStart+sum(stimDuration(1:2)) % changed for thermoino, because we need to trigger the return, too
                [countedDown]=CountDown(GetSecs-tStimStart,countedDown,'.');
                [abort]=LoopBreaker(P);
                if abort; break; end % only break because we want the temp to be set to baseline before we crash out
            end
      
            fprintf('\n');
            UseThermoino('Set',P.pain.thermoino.bT); % open channel for arduino to ramp down        

            if ~abort
                while GetSecs < tStimStart+sum(stimDuration) % consider only fall time for wait
                    [countedDown]=CountDown(GetSecs-tStimStart,countedDown,'.');
                    [abort]=LoopBreaker(P);
                    if abort; return; end
                end      
            else
                return;
            end
        else
           
            
            while GetSecs < tStimStart+sum(stimDuration)
                [countedDown]=CountDown(GetSecs-tStimStart,countedDown,'.');
                [abort]=LoopBreaker(P);
                if abort; return; end
            end            
        end
        fprintf(' concluded.\n');

    end
