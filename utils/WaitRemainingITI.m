function [abort]=WaitRemainingITI(P,O,nTrial,tThresholdRating)    
        WaitSecs(P.presentation.sBlank); 
        abort=0;
        
        % no need to have an ITI after the last stimulus
        if nTrial==P.awiszus.thermoino.N
            return;
        end
        
        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1); 
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2); 
            Screen('Flip',P.display.w);  % gets timing of event for PutLog                    
        end
        send_trigger(P,O,sprintf('ITI_on'));
        
        sITIRemaining=P.presentation.thresholdITIs(nTrial)-tThresholdRating; 
          
        tITIStart=GetSecs;             
        fprintf('Remaining ITI %1.0f seconds (press [%s] to pause, [%s] to abort)...\n',sITIRemaining,upper(char(P.keys.keyList(P.keys.name.pause))),upper(char(P.keys.keyList(P.keys.name.esc))));
        countedDown=1;        
        while GetSecs < tITIStart+sITIRemaining
            [abort]=LoopBreaker(P);
            if abort; return; end
            [countedDown]=CountDown(GetSecs-tITIStart,countedDown,'.');
                            
            % switch on red cross and wait a bit so it won't get switched on a thousand times
            if P.presentation.cueing==1 && ~O.debug.toggleVisual % else we don't want the red cross
                if GetSecs>tITIStart+sITIRemaining-P.presentation.thresholdCues(nTrial) && GetSecs<tITIStart+sITIRemaining-P.presentation.thresholdCues(nTrial)+P.presentation.sBlank
                    fprintf('[Cue at %1.1fs]... ',P.presentation.thresholdCues(nTrial));
                    Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1); 
                    Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2); 
                    Screen('Flip',P.display.w); 
                    send_trigger(P,O,sprintf('cue_on'));
                    WaitSecs(P.presentation.sBlank);
                end
            end
        end
        
        fprintf('\n');
        
    end