function [P,O] = SetParams(P,O)
% This function sets the parameters for the Experiment and Settings wrapped
% in a structure P.params


%% Devices
P.devices.CPAR                                    = 0; %set to 1 if used
P.devices.SCR                                     = 0;  % set to 1 if used
P.devices.cuff_on                                 = 1; % which cuff is used for pain (1: left, 2: right - depends on how cuffs plugged into the CPAR unit and put on participant's arm/leg)
P.devices.cuff_off                                = 2; % the other cuff off (only use 1 cuff)
%P.params.devices.arduino                                 = 1; 

% Define outgoing port address
if strcmp(P.env.hostname,'stimpc1')
    %P.com.lpt.CEDAddressThermode = 888; % CHECK IF STILL ACCURATE
    P.com.lpt.CEDAddressSCR     = 36912; % as per new stimPC; used to be =P.com.lpt.CEDAddressThermode;
else
    P.com.lpt.CEDAddressSCR = 888;
end
P.com.lpt.CEDDuration           = 0.005; % wait time between triggers

if strcmp(P.env.hostname,'stimpc1')
    P.com.lpt.pressureOnsetTHE      = 36; % this covers both CHEPS trigger (4) and SCR/Spike (32)
    if P.devices.arduino
        P.com.lpt.pressureOnset      = 32;
    else % note: without arduino, this is NOT necessary on stimpc setup because there is no separate SCR recording device, just spike; therefore, do it with pressureOnsetTHE
        P.com.lpt.pressureOnset      = 0;
    end
    P.com.lpt.VASOnset          = 128; % we'll figure this out later
    P.com.lpt.ITIOnset          = 128; % we'll figure this out later
    P.com.lpt.cueOnset          = 128; % we'll figure this out later
else
    %     P.com.lpt.cueOnset      = 1; % bit 1; cue onset
    P.com.lpt.pressureOnset = 1; %4; % bit 3; pressure trigger for SCR
    P.com.lpt.VASOnset      = 2; %8; % bit 5;
    P.com.lpt.ITIOnset      = 3; %16; % bit 6; white fixation cross
    P.com.lpt.buttonPress   = 4; % button press
end

% Establish parallel port communication.
if P.devices.trigger
    config_io;
    WaitSecs(P.com.lpt.CEDDuration);
    outp(P.com.lpt.CEDAddressSCR,0);
    WaitSecs(P.com.lpt.CEDDuration);
end
 
if P.devices.arduino
    try
        addpath(genpath(P.path.cpar))
    catch
        warning('CPAR scripts not found in %s. Aborting.',P.path.cpar);
    end
end

if P.devices.thermoino
    try
        P.presentation.thermoinoSafetyDelay = 0.1; % thermoino safety delay for short plateaus; 0.1 seems robust
        addpath(P.path.thermoino)
    catch
        warning('Thermoino scripts not found in %s. Aborting.',P.path.thermoino);
        return;
    end

    % instantiate serial object for thermoino control
    UseThermoino('Kill');
    UseThermoino('Init',P.com.thermoino,P.com.thermoinoBaud,P.pain.bT,P.pain.rS); % returns handle of serial object
end

% intensityResponse = input('Please enter calibrated intensitiy on the bike as [low high].\n');


% if ~intensityResponse % if no intensitiy is provided set to empty 
%     P.params.test.exercise.Int = [];
%     fprintf('\nIntensity for cycling has been set to DEFAULT: []\n');
% else
%     P.params.test.exercise.Int = intensityResponse;
%     fprintf('\nIntensity for cycling has been set to [%2.0f %2.0f]\n',P.params.test.exercise.Int(1),P.params.test.exercise.Int(2));
% end 

end






