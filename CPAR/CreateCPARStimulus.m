% Creationg of CPAR pressure cuff stimuli
%
% [stimulus1, stimulus2, cuff] = CreateCPARStimulus(varargin)
%
% Varargin:
%   1. type - pre-exposure, calibration, exercise or experiment
%   2. settings - P
%   3. duration - an array of stimulus durations
%                   pre-exposure stimuli:
%                           duration(1): ramp up
%                           duration(2): plateau
%                   PEEP stimuli:
%                           not used, durations defined in InstantiateParameters.m
%   4. pressure - intensity in kPa
%                   pre-exposure stimuli:
%                           pressure(1): constant plateau pressure
%                   continous exercise:
%                            pressure(1): constant pressure at 5 kPa
%                   Experiment PEEP stimuli:
%                           pressure(1): pressure stimulus VAS 10
%                           pressure(2): pressure stimulus VAS 30
%                           pressure(3): pressure stimulus VAS 50
%                           pressure(4): pressure stimulus VAS 70
%  
%   5. pressure intensity indicator (1,3,5,7)


% Version: 1.0
% Author: Karita Ojala, University Medical Center Hamburg-Eppendorf
% Modified by Janne Nold, University Medical Center Hamburg-Eppendorf
% Date: 2021-11-05

function [stimulus1, stimulus2, cuff] = CreateCPARStimulus(varargin)

varargin = varargin{:};
type = varargin{1}; % pre-exposure, conditioning, or test stimulus
settings = varargin{2}; % Settings structure P

cuff = settings.pain.preExposure.cuff_left;
cuff_off = settings.pain.preExposure.cuff_right;


if strcmp(type,'preExp') || strcmp(type,'Calibration')

    duration = varargin{3};
    pressure = varargin{4}; % target pressure (kPa)
    rampRate = pressure/duration(1);

    % Safety net to not provide any pressures above 100 kPa
    if pressure > 100
        error('Warning: Initiated pressure over 100 kPa')
    end 


    stimulus1 = cparCreateWaveform(cuff,1); % combined stimulus
    stimulus2 = cparCreateWaveform(cuff_off,1); % off cuff set to zero

    cparWaveform_Inc(stimulus1, rampRate, duration(1)); % ramp up
    cparWaveform_Step(stimulus1, pressure, duration(2)); % constant pressure


elseif strcmp(type,'Exercise')

    duration = varargin{3};
    pressure = varargin{4};
    rampRate = pressure/duration(1);

    % Safety net to not provide any pressures above 100 kPa
    if pressure > 100
        error('Warning: Initiated pressure over 100 kPa')
    end 

    stimulus1 = cparCreateWaveform(cuff,1); % combined stimulus
    stimulus2 = cparCreateWaveform(cuff_off,1); % off cuff set to zero

    cparWaveform_Inc(stimulus1, rampRate, duration(1)); % ramp up
    cparWaveform_Step(stimulus1, pressure, duration(2)); % constant pressure


elseif strcmp(type,'Experiment')
   
    duration = varargin{3};
    pressure = varargin{4};
    rampRate = pressure/duration(1);

    % Safety net to not provide any pressures above 100 kPa
    if pressure > 100
        error('Warning: Initiated pressure over 100 kPa')
    end 


    stimulus1 = cparCreateWaveform(cuff,1); % combined stimulus
    stimulus2 = cparCreateWaveform(cuff_off,1); % off cuff set to zero

    cparWaveform_Inc(stimulus1, rampRate, duration(1)); % ramp up
    cparWaveform_Step(stimulus1, pressure, duration(2)); % constant pressure



end

end

