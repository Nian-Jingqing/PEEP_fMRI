function [P,abort]=PreExposure(P,O,dev)
% This function runs the PreExposure.
%
% Pre Exposure: uses two low intensity pressure stimuli of 10 and 20 kPa to
% get the participant used to the feeling of the pressure cuff inflating
%
% Version: 1.2
% Author: Bjoern Horing, University Medical Center Hamburg-Eppendorf
% including code developed by Christian Sprenger, and conceptual work by Friedemann Awiszus,
% TMS and threshold hunting, Awiszus et al.(2003), Suppl Clin Neurophysiol. 2003;56:13-23.
% Adapted from Karita Ojala, University Clinic Hamburg Eppendorf
% Last adapted by Janne Nold, University Clinic Hambrg Eppendorf
% Date: 2021-11-08
%
% Version notes
% 1.0 2019-06-07
% - [extracted from calibration script]
% 1.1 2020-07-16
% - restructured to utilize P struct
% 1.2 2021- 11-08
% -restructed to avoid global variables (dev)
% 1.2.1 2022-02-08
% - took out Awiszus to only run Pre exposure 


% Define output file
cparFile = fullfile(P.out.dirExp,[P.out.file.CPAR '_PreExposure.mat']);

abort=0;

% Print to experimenter what is running
fprintf('\n====================================================\nRunning pre-exposure\n====================================================\n');

% Give experimenter chance to abort if neccesary
fprintf('\nContinue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));

while 1
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.name.confirm
            break;
        elseif find(keyCode) == P.keys.name.esc
            abort = 1;
            break;
        end
    end
end
if abort; return; end

WaitSecs(0.2);

P.time.preExpMainStart = GetSecs;

cuff = P.calibration.cuff_arm;

fprintf([P.pain.cuffSide{cuff} ' ARM \n']); %P.pain.stimName{stimType} ' STIMULUS\n--------------------------\n']);

for trial = 1:numel(P.pain.preExposure.startSimuli) % pre-exposure


    if trial > numel(P.pain.preExposure.startSimuli)
        return;
    end

    if ~O.debug.toggleVisual
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
    else
        tCrossOn = GetSecs;
    end

    fprintf('Displaying fixation cross... ');

    while GetSecs < tCrossOn + P.pain.preExposure.sPreexpITI
        [abort]=LoopBreaker(P);
        if abort; break; end
    end

    if ~O.debug.toggleVisual
        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
        Screen('Flip',P.display.w);
    end

    if trial <= numel(P.pain.preExposure.startSimuli) % pure pre-exposure to get used to the feeling
        preExpInt = P.pain.preExposure.startSimuli(trial);
        preExpPhase = 'pre-exposure';
    end
    fprintf('\n%1.1f kPa %s stimulus initiated.\n',preExpInt,preExpPhase);


    % Calculate Stimulus Duration including ramp and plateau
    stimDuration = CalcStimDuration(P,preExpInt,P.pain.preExposure.sStimPlateauPreExp);
    countedDown = 1;
    tStimStart = GetSecs;
    

    if P.devices.arduino && P.cpar.init

        abort = UseCPAR('Set',dev,'preExp',P,stimDuration,preExpInt); % set stimulus
        [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus

    end


    while GetSecs < tStimStart+sum(stimDuration)
        [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
        if abort; return; end
    end

    fprintf(' concluded.\n');

    if P.devices.arduino && P.cpar.init
        data = cparGetData(dev, data);
        preExpCPARdata = cparFinalizeSampling(dev, data);
        saveCPARData(preExpCPARdata,cparFile,cuff,trial);
    end


    if ~O.debug.toggleVisual
        Screen('Flip',P.display.w);
    end

    
end
    fprintf('\nWARM-UP and Pre exposure finished. \n');
    return;
end
