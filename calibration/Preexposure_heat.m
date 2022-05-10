function [abort,preexPainful_heat]=Preexposure_heat(P,O,varargin)
        
        if nargin<3
            preExpInts = P.pain.preExposure.vec_int;
        else % override (e.g. for validation sessions)
            preExpInts = varargin{1};
        end
        
        abort=0;
        preexPainful_heat = NaN;
        
        fprintf('\n==========================\nRunning preexposure sequence.\n');
        fprintf('[Initial trial, showing P.style.white cross for %1.1f seconds, red cross for %1.1f seconds]\n',P.presentation.sPreexpITI,P.presentation.sPreexpCue);

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.style.whiteFix1); 
            Screen('FillRect', P.display.w, P.style.white, P.style.whiteFix2); 
            tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog                        
        else
            tCrossOn = GetSecs;
        end
        while GetSecs < tCrossOn + P.presentation.sPreexpITI-P.presentation.sPreexpCue 
            [abort]=LoopBreaker(P);
            if abort; break; end
        end

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.red, P.style.whiteFix1); 
            Screen('FillRect', P.display.w, P.style.red, P.style.whiteFix2); 
            tCueOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
        else
            tCueOn = GetSecs;
        end
        send_trigger(P,O,sprintf('cue_on'));
        
        while GetSecs < tCueOn + P.presentation.sPreexpCue 
            [abort]=LoopBreaker(P);
            if abort; break; end
        end
        
        for i = 1:length(preExpInts)
            if i>1 % preexposure ITIs
                if ~O.debug.toggleVisual
                    Screen('FillRect', P.display.w, P.style.white, P.style.whiteFix1); 
                    Screen('FillRect', P.display.w, P.style.white, P.style.whiteFix2); 
                    tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
                else
                    tCrossOn = GetSecs;
                end
                send_trigger(P,O,sprintf('ITI_on'));
                
                while GetSecs < tCrossOn + P.presentation.sPreexpITI 
                    [abort]=LoopBreaker(P);
                    if abort; break; end
                end            

                if ~O.debug.toggleVisual
                    Screen('FillRect', P.display.w, P.style.red, P.style.whiteFix1); 
                    Screen('FillRect', P.display.w, P.style.red, P.style.whiteFix2); 
                    tCueOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
                else
                    tCueOn = GetSecs;
                end
                send_trigger(P,O,sprintf('cue_on'));
                
                while GetSecs < tCueOn + P.presentation.sPreexpCue
                    [abort]=LoopBreaker(P);
                    if abort; break; end
                end            
            end
            
            fprintf('%1.1f°C stimulus initiated.',preExpInts(i));
            stimDuration=CalcStimDuration(P,preExpInts(i),P.presentation.sStimPlateauPreexp);  
                        
            countedDown=1;
            send_trigger(P,O,sprintf('stim_on'));
            
            if P.devices.thermoino                
                UseThermoino('Trigger'); % start next stimulus
                UseThermoino('Set',preExpInts(i)); % open channel for arduino to ramp up  
                tStimStart=GetSecs; % this makes the Thermoino plateau issue handled more conservatively

                while GetSecs < tStimStart+sum(stimDuration(1:2))+P.presentation.thermoinoSafetyDelay
                    [countedDown]=CountDown(GetSecs-tStimStart,countedDown,'.');
                    [abort]=LoopBreaker(P);
                    if abort; break; end % only break because we want the temperature to return to BL before we quit
                end
                
                UseThermoino('Set',P.pain.bT); % open channel for arduino to ramp down        
                
                if ~abort
                    while GetSecs < tStimStart+sum(stimDuration)
                        [countedDown]=CountDown(GetSecs-tStimStart,countedDown,'.');
                        [abort]=LoopBreaker(P);
                        if abort; return; end
                    end 
                else
                    return;
                end             
            else                
                send_trigger(P,O,sprintf('stim_on'));                
                tStimStart=GetSecs;
                
                while GetSecs < tStimStart+sum(stimDuration)
                    [countedDown]=CountDown(GetSecs-tStimStart,countedDown,'.');
                    [abort]=LoopBreaker(P);
                    if abort; return; end
                end
            end                        
            if ~abort
                fprintf(' concluded.\n');
            else
                break; 
            end
        end
        
        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);                  
        end
        send_trigger(P,O,sprintf('vas_on'));
        
        preexPainful_heat = QueryPreexPain(P,O,preExpInts);
        
    end
