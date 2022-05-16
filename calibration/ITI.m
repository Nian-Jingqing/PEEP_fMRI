% wait for remainder of ITI after subtracting rating time
    function [abort] = ITI(P,O,tPlateauRating)
        
        abort=0;
        
        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1); 
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);    
            Screen('Flip',P.display.w);  
        end        

        % contrast the time spent on the rating with the maximum time available for the rating
        % calculate required ITI for this trial from there                
        sITIRemaining=(P.presentation.sMaxRating-tPlateauRating)+P.currentTrial.sITI; 
        if sITIRemaining<P.currentTrial.sCue
            sITIRemaining = P.currentTrial.sCue; % we at least want to have the cue
        end
            
        % wait for remainder of ITI
        fprintf('ITI (%1.1fs)',sITIRemaining);        
        tITIOn = GetSecs;

        countedDown=1;
        send_trigger(P,O,sprintf('ITI_on'));
        
        while GetSecs < tITIOn + sITIRemaining
            [countedDown]=CountDown(GetSecs-tITIOn,countedDown,'.');                             
            [abort]=LoopBreaker(P);
            if abort; return; end
                
            % switch on red cross and wait a bit so it won't get switched on a thousand times
            if P.presentation.cueing==1 % else we don't want the red cross
                if GetSecs>tITIOn+sITIRemaining-P.currentTrial.sCue && GetSecs<tITIOn+sITIRemaining-P.currentTrial.sCue+P.presentation.sBlank
                    fprintf(' [Red cross at %1.1fs]',P.currentTrial.sCue);
                    if ~O.debug.toggleVisual
                        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1); 
                        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2); 
                        Screen('Flip',P.display.w);  
                    end
                    send_trigger(P,O,sprintf('cue_on'));
                    WaitSecs(P.presentation.sBlank);
                end
            end
        end
        fprintf('\n'); 
                
    end