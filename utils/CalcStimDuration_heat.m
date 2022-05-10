function [stimDuration] = CalcStimDuration_heat(P,temp,sStimPlateau)
    diff=abs(temp-P.pain.bT);
    riseTime=diff/P.pain.rS;
    fallTime=diff/P.pain.fS;

    stimDuration=[riseTime sStimPlateau fallTime];
end