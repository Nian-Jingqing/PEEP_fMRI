function [abort,countedDown]=CountDown(P, secs, countedDown, countString)
%% display string during countdown
if secs>countedDown
    fprintf('%s', countString);
    %DrawFormattedText(P.display.w, ['Noch ',countString,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);
    countedDown=ceil(secs);
    WaitSecs(1);
end

[abort] = LoopBreakerStim(P);
if abort; return; end

end