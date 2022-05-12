function [stimDuration] = CalcStimDuration_heat(P,temp,sStimPlateau)
    diff=abs(temp-P.pain.thermoino.bT);
    riseTime=diff/P.pain.thermoino.rS;
    fallTime=diff/P.pain.thermoino.fS;

    stimDuration=[riseTime sStimPlateau fallTime];
end