function [abort] = LoopBreaker(P)
        abort = 0;
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.esc %esc
                abort = 1;
                return;
            end
        end
 end 
