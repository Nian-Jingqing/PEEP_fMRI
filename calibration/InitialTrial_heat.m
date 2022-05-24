function InitialTrial_heat(P,O)

fprintf('[Initial trial, white fixation cross for %1.1f seconds, red cross for %1.1f seconds]\n',P.presentation.firstPlateauITI-P.presentation.firstPlateauCue,P.presentation.firstPlateauCue);

if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    tCrossOn = Screen('Flip',P.display.w); % gets timing of event for PutLog
else
    tCrossOn = GetSecs;
end
while GetSecs < tCrossOn + P.presentation.firstPlateauITI-P.presentation.firstPlateauCue
    [abort]=LoopBreaker(P);
    if abort; return; end
end

if P.presentation.cueing==1 % else we don't want the red cross
    if ~O.debug.toggleVisual
        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
        tCrossOn = Screen('Flip',P.display.w); % gets timing of event for PutLog
    else
        tCrossOn = GetSecs;
    end
    send_trigger(P,O,sprintf('cue_on'));

    while GetSecs < tCrossOn + P.presentation.firstPlateauCue
        [abort]=LoopBreaker(P);
        if abort; return; end
    end
end
end