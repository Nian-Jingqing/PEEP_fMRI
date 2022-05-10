function [stimDuration] = CalcStimDuration(P,pressure,sStimPlateau)
%% Returns a vector with riseTime, P.presentation.sStimPlateau and fallTime for the target stimulus

riseTime = pressure/P.pain.preExposure.riseSpeed;
stimDuration = [riseTime sStimPlateau];% only rise time

end