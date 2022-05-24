% =======================================================================
%% Block 1a: Calibration Heat Thermode
% =======================================================================

function [abort,P,O] = calib_heat(P,O)


% restore the default path to delete other saved paths
restoredefaultpath

% add script base path
addpath('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI')


%% ------------------ Experiment Preparations -------------------------

% Instantiate Parameters and Overrides
P                       = InstantiateParameters_calib;
O                       = InstantiateOverrides;

% Load parameters if there
if exist(P.out.file.paramCalib,'file')
    load(P.out.file.paramCalib,'P','O');
else
    warning('No calibration parameters file P loaded');
end

% Add paths CPAR
if P.devices.arduino
    addpath(genpath(P.path.cpar));
end

% Add paths Thermoino
if P.devices.thermoino
    try
        P.presentation.thermoinoSafetyDelay = 0.1; % thermoino safety delay for short plateaus; 0.1 seems robust
        addpath(P.path.thermoino)
    catch
        warning('Thermoino scripts not found in %s. Aborting.',P.path.thermoino);
        return;
    end
end

addpath(genpath(P.path.scriptBase));
addpath(genpath(P.path.PTB));
addpath(fullfile(P.path.PTB,'PsychBasic','MatlabWindowsFilesR2007a'));

% Clear global functions
clear mex global functions;
commandwindow;


%% ---------------- Initialise Parameters and Screen -------------------

% Load Parameters for experiment
[P,O]                   = SetParams(P,O);
[P,O]                   = SetKeys(P,O);

% Query where to start experiment
[abort, P] = StartExperimentAt(P);
if abort; QuickCleanup(P); return; end

% Open Screen
[P,O]                   = SetPTB(P,O);

% Get timing at script start
P.time.stamp            = datestr(now,30);
P.time.scriptStart      = GetSecs;

%% Pre Exposure
 
ShowIntroduction(P,1);
if abort;QuickCleanup(P);return;end

[abort,preexPainful_heat]=Preexposure_heat(P,O); % sends four triggers, waits ITI seconds after each

if abort;QuickCleanup(P);return;end

%% Awiszus

if preexPainful_heat==0
    P.awiszus.thermoino.mu = 44.0;
else
    P.awiszus.thermoino.mu = 43.0;
end
fprintf('\nReady FIRST THRESHOLD at %1.1f°C.\n',P.awiszus.mu);

if abort;QuickCleanup(P);return;end
P = DoAwiszus_heat(P,O);



%% Rating Training Psychometric Scaling and VAS Target Regression

P=DetermineSteps(P);

WaitSecs(0.2);
if ~O.debug.toggleVisual
    Screen('Flip',P.display.w);
end

P.time.plateauStart=GetSecs;

ShowIntroduction(P,2);

[abort,P]=TrialControl(P,O);
if abort;QuickCleanup(P);return;end

% Save Calibrated Heats
save(P.out.file.paramCalib,'P','O');


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [abort,preexPainful_heat]=Preexposure_heat(P,O,varargin)

if nargin<3
    preExpInts = P.pain.preExposure.vec_int;
else % override (e.g. for validation sessions)
    preExpInts = varargin{1};
end

abort=0;
preexPainful_heat = NaN;

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

P.presentation.sPreexpITI = 15;

fprintf('\n==========================\nRunning preexposure sequence.\n');
fprintf('[Initial trial, showing P.style.white cross for %1.1f seconds, red cross for %1.1f seconds]\n',P.presentation.sPreexpITI,P.presentation.sPreexpCue);

if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
else
    tCrossOn = GetSecs;
end
while GetSecs < tCrossOn + P.presentation.sPreexpITI-P.presentation.sPreexpCue
    [abort]=LoopBreaker(P);
    if abort; break; end
end

if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
    tCueOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
else
    tCueOn = GetSecs;
end
send_trigger(P,O,sprintf('cue_on'));

while GetSecs < tCueOn + P.presentation.sPreexpCue
    [abort]=LoopBreaker(P);
    if abort; break; end
end

for i = 1:length(preExpInts)
    if i>1 % preexposure ITIs
        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
        else
            tCrossOn = GetSecs;
        end
        send_trigger(P,O,sprintf('ITI_on'));

        while GetSecs < tCrossOn + P.presentation.sPreexpITI
            [abort]=LoopBreaker(P);
            if abort; break; end
        end

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
            tCueOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
        else
            tCueOn = GetSecs;
        end
        send_trigger(P,O,sprintf('cue_on'));

        while GetSecs < tCueOn + P.presentation.sPreexpCue
            [abort]=LoopBreaker(P);
            if abort; break; end
        end
    end

    fprintf('%1.1f°C stimulus initiated.',preExpInts(i));
    stimDuration=CalcStimDuration(P,preExpInts(i),P.presentation.sStimPlateauPreexp);

    countedDown=1;
    send_trigger(P,O,sprintf('stim_on'));

    if P.devices.thermoino
        UseThermoino('Trigger'); % start next stimulus
        UseThermoino('Set',preExpInts(i)); % open channel for arduino to ramp up
        tStimStart=GetSecs; % this makes the Thermoino plateau issue handled more conservatively

        while GetSecs < tStimStart+sum(stimDuration(1:2))+P.presentation.thermoinoSafetyDelay
            [countedDown]=CountDown(P,GetSecs-tStimStart,countedDown,'.');
            [abort]=LoopBreaker(P);
            if abort; break; end % only break because we want the temperature to return to BL before we quit
        end

        UseThermoino('Set',P.pain.thermoino.bT); % open channel for arduino to ramp down

        if ~abort
            while GetSecs < tStimStart+sum(stimDuration)
                [countedDown]=CountDown(P,GetSecs-tStimStart,countedDown,'.');
                [abort]=LoopBreaker(P);
                if abort; return; end
            end
        else
            return;
        end
    else
        send_trigger(P,O,sprintf('stim_on'));
        tStimStart=GetSecs;

        while GetSecs < tStimStart+sum(stimDuration)
            [countedDown]=CountDown(P,GetSecs-tStimStart,countedDown,'.');
            [abort]=LoopBreaker(P);
            if abort; return; end
        end
    end
    if ~abort
        fprintf(' concluded.\n');
    else
        break;
    end
end

if ~O.debug.toggleVisual
    Screen('Flip',P.display.w);
end
send_trigger(P,O,sprintf('vas_on'));

preexPainful_heat = QueryPreexPain_heat(P,O,preExpInts);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
function [P] = DoAwiszus_heat(P,O)

painful=[];

P.time.threshStart=GetSecs;

P = Awiszus_heat('init',P);

% iteratively increase or decrease the target temperature to approximate pain threshold
P.awiszus.thermoino.nextX = P.awiszus.thermoino.mu; % start with assumed population mean
for awn = 1:P.awiszus.thermoino.N
    P.awiszus.thermoino.nextX = round(P.awiszus.thermoino.nextX,1); % al gusto

    [abort]=DisplayStimulus(P,O,awn,P.awiszus.thermoino.nextX);
    if abort; break; end
    [painful,tThresholdRating]=BinaryRating(P,O,awn);
    P.awiszus.thermoino.threshRatings(awn,1) = P.awiszus.thermoino.nextX;
    P.awiszus.thermoino.threshRatings(awn,2) = painful;

    if ~O.debug.toggle
        if painful==0
            awstr = 'not painful';
        elseif painful==1
            awstr = 'painful';
        elseif painful==-1
            break; % yeah let's not do that anymore...
        end
    else
        awstr = 'painful';
        painful=1;
    end
    fprintf('Stimulus rated %s.\n',awstr);

    P = Awiszus_heat('update',P,painful); % awP,awPost,awNextX,painful
    [abort]=WaitRemainingITI(P,O,awn,tThresholdRating);
    if abort; break; end
end

if abort;QuickCleanup(P);return;end

P.pain.calibration.heat.AwThrTemps = P.awiszus.thermoino.threshRatings(:,1);
P.pain.calibration.heat.AwThrResponses = P.awiszus.thermoino.threshRatings(:,2);
P.pain.calibration.heat.AwThr = P.awiszus.thermoino.nextX;

if painful==-1
    fprintf('No rating provided for temperature %1.1f. Please restart program. Resuming at the current break point not yet implemented.\n',P.pain.calibration.heat.AwThr);
    return;
else
    %save([P.out.dir P.out.file], 'P');
    save(P.out.file.paramCalib,'P','O');
    fprintf('\n\nThreshold determined around %1.1f°C, after %d trials.\nThreshold data and results saved under\n %s%s.mat.\n\n',P.pain.calibration.heat.AwThr,P.awiszus.thermoino.N,P.out.file.paramCalib);
end

P.time.threshEnd=GetSecs;

end

%%
function [painful,tThresholdRating]=BinaryRating(P,O,nTrial)
P.textrIndex = GetImg(P);
painful=-1;
upperEight = P.display.screenRes.height*P.display.Ytext;

% await rating within a time frame that leaves enough time to adjust the stimulus
tRatingStart=GetSecs;
fprintf('Not painful [%s] or painful [%s]?\n',P.keys.notPainful,P.keys.painful);

nY = P.display.screenRes.height/8;
if strcmp(P.env.hostname,'stimpc1')
    if strcmp(P.language,'de')
        keyNotPainful = '[linker Knopf]';
        keyPainful = '[rechter Knopf]';
    elseif strcmp(P.language,'en')
        keyNotPainful = '[left button]';
        keyPainful = '[right button]';
    end
else
    keyNotPainful = [ '[' P.keys.notPainful ']' ];
    keyPainful = [ '[' P.keys.painful ']' ];
end
if ~O.debug.toggleVisual
    if strcmp(P.language,'de')
        Screen('TextSize', P.display.w, P.display.textsize_ratingBIG);
        Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex7, [], [], 0);

        %[P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Nicht schmerzhaft ' keyNotPainful ' oder (mindestens) leicht schmerzhaft ' keyPainful '?'], 'center', upperEight, P.style.white);
    elseif strcmp(P.language,'en')
        [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ['Not painful ' keyNotPainful ' oder (at least) slightly painful ' keyPainful '?'], 'center', upperEight, P.style.white);
    end

    Screen('Flip',P.display.w);
end

send_trigger(P,O,sprintf('vas_on'));

WaitSecs(P.presentation.sBlank);
%KbQueueRelease;

while 1 % there is no escape...
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.painful
            painful=1;
            break;
        elseif find(keyCode) == P.keys.notPainful
            painful=0;
            break;
        elseif find(keyCode) == P.keys.abort
            painful=-1;
            break;
        end
    end

    nY = P.display.screenRes.height/8;
    if ~O.debug.toggleVisual && GetSecs > tRatingStart+P.presentation.thresholdITIs(nTrial)
        if strcmp(P.language,'de')
            Screen('TextSize', P.display.w, P.display.textsize_ratingBIG);
            Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex7, [], [], 0);

            %[P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ['Nicht schmerzhaft ' keyNotPainful ' oder (mindestens) leicht schmerzhaft ' keyPainful '?'], 'center', upperEight, P.style.white);
            %[P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ' ', 'center', nY+P.lineheight, P.style.white);
            %[P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ' ', 'center', nY+P.lineheight, P.style.white);
            %[P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, 'Eingabe erforderlich', 'center', nY+P.lineheight, P.style.red);
        elseif strcmp(P.language,'en')
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ['Not painful ' keyNotPainful ' oder (at least) slightly painful ' keyPainful '?'], 'center', upperEight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, '', 'center', nY+P.lineheight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, '', 'center', nY+P.lineheight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, '^ ^ ^ Input required ^ ^ ^', 'center', nY+P.lineheight, P.style.red);
        end

        Screen('Flip',P.display.w);
    end
end

tThresholdRating=GetSecs-tRatingStart;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function [abort]=WaitRemainingITI(P,O,nTrial,tThresholdRating)
WaitSecs(P.presentation.sBlank);
abort=0;

% no need to have an ITI after the last stimulus
if nTrial==P.awiszus.N
    return;
end

if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);  % gets timing of event for PutLog
end
send_trigger(P,O,sprintf('ITI_on'));

sITIRemaining=P.presentation.thresholdITIs(nTrial)-tThresholdRating;

tITIStart=GetSecs;
fprintf('Remaining ITI %1.0f seconds (press [%s] to pause, [%s] to abort)...\n',sITIRemaining,upper(char(P.keys.keyList(P.keys.name.pause))),upper(char(P.keys.keyList(P.keys.name.esc))));
countedDown=1;
while GetSecs < tITIStart+sITIRemaining
    [abort]=LoopBreaker(P);
    if abort; return; end
    [countedDown]=CountDown(P,GetSecs-tITIStart,countedDown,'.');

    %switch on red cross and wait a bit so it won't get switched on a thousand times
                if P.presentation.cueing==1 && ~O.debug.toggleVisual % else we don't want the red cross
                    if GetSecs>tITIStart+sITIRemaining-P.presentation.thresholdCues(nTrial) && GetSecs<tITIStart+sITIRemaining-P.presentation.thresholdCues(nTrial)+P.presentation.sBlank
                        fprintf('[Cue at %1.1fs]... ',P.presentation.thresholdCues(nTrial));
                        Screen('FillRect', P.display.w, P.style.red,P.fixcross.Fix1);
                        Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
                        Screen('Flip',P.display.w);
                        send_trigger(P,O,sprintf('cue_on'));
                        WaitSecs(P.presentation.sBlank);
                    end
                end
end

fprintf('\n');

end

%%
function P=DetermineSteps(P)

P.plateaus.step1Order = P.pain.calibration.heat.AwThr+P.plateaus.step1Seq;
P.plateaus.step2Order = P.pain.calibration.heat.AwThr+P.plateaus.step2Seq;

% display plateaus for protocol creation and as sanity check
fprintf('\nPrepare protocol using %1.1f°C as threshold with the following specifications:\n--\n',P.pain.calibration.heat.AwThr);
for nTrial = 1:length(P.plateaus.step2Order)
    fprintf('Step %02d: %1.1f°C\n',nTrial,P.plateaus.step2Order(nTrial));
end
fprintf('--\nRepeat, awTT is %1.1f°C\n',P.pain.calibration.heat.AwThr);

end

%%

function [abort,P]=TrialControl(P,O)

abort=0;
plateauLog = [];

% fprintf('\nSCALE TRANSLATION\n');
% fprintf('\nContinue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
% 
% while 1
%     [keyIsDown, ~, keyCode] = KbCheck();
%     if keyIsDown
%         if find(keyCode) == P.keys.name.confirm
%             break;
%         elseif find(keyCode) == P.keys.name.esc
%             abort = 1;
%             break;
%         end
%     end
% end
% if abort; return; end
% 
% WaitSecs(0.2);
% 
% %SEGMENT -1 (yeah yeah): SCALE TRANSLATION; data NOT saved
% %if P.startSection<4
% if P.toggles.doScaleTransl && P.toggles.doPainOnly
%     P.toggles.doPainOnly = 0; % this is the whole point here, to translate the y/n binary via the two-dimensional VAS to the unidimensional
% 
%     %                [abort]=ShowInstruction(P,O,7,1);
%     if abort;QuickCleanup(P);return;end
% 
%     step0Order = [P.pain.calibration.heat.AwThr P.pain.calibration.heat.AwThr+0.2 P.pain.calibration.heat.AwThr-0.2]; % provide some perithreshold intensities
%     fprintf('\n=================================');
%     fprintf('\n========SCALE TRANSLATION========\n');
%     for nStep0Trial = 1:numel(step0Order)
%         fprintf('\n=======TRIAL %d of %d=======\n',nStep0Trial,numel(step0Order));
%         [abort]=ApplyStimulus_heat(P,O,step0Order(nStep0Trial));
%         if abort; return; end
%         P=InstantiateCurrentTrial(P,O,-1,step0Order(nStep0Trial),-1);
%         P=PlateauRating(P,O);
%         [abort]=ITI(P,O,P.currentTrial.reactionTime);
%         if abort; return; end
%     end
% 
%     P.toggles.doPainOnly = 1; % RESET
% 
%     %                [abort]=ShowInstruction(P,O,8,1);
%     if abort;QuickCleanup(P);return;end
%     WaitSecs(0.5);
% 
% end
% %end
% 
% %if P.startSection<6
% %            [abort]=ShowInstruction(P,O,3,1);
% if abort;QuickCleanup(P);return;end
% %end


%        SEGMENT 0: RATING TRAINING; data NOT saved
if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);
end

fprintf('\nRATING TRAINING\n');
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
%if P.startSection<5

WaitSecs(0.5);
step0Order = repmat(P.pain.calibration.heat.AwThr,1,2);
fprintf('\n=================================');
fprintf('\n=========RATING TRAINING=========\n');
for nStep0Trial = 1:numel(step0Order)
    fprintf('\n=======TRIAL %d of %d=======\n',nStep0Trial,numel(step0Order));
    [abort]=ApplyStimulus_heat(P,O,step0Order(nStep0Trial));
    if abort; return; end
    P=InstantiateCurrentTrial(P,O,0,step0Order(nStep0Trial));
    P=PlateauRating(P,O);
    if nStep0Trial<2
        [abort]=ITI(P,O,P.currentTrial.reactionTime);
    else
        WaitSecs(2);
    end
    
    if abort; return; end
end

if any(P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType==0)>25) % 25 being an arbitrary threshold
    fprintf('\nSb rated training stimuli at threshold (%1.1f°C) that should be rated VAS~0\nat',P.pain.calibration.heat.AwThr)
    fprintf('\t%d',P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType==0));
    fprintf('\n');
    fprintf('This does not impact the regression, but could be a sign of poor understanding of the instructions.\n');
    fprintf('Reinstruct if desired, then continue [%s] or abort [%s] (for new calibration)?\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.abort))));
    commandwindow;

    while 1
        abort=0;
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.abort
                abort=1;
                return;
            elseif find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.5);
end
%end

%if P.startSection<6 % from this point on, data will be saved and integrated into regression analyses
% SEGMENT 1: PSYCHOMETRIC-PERCEPTUAL SCALING
if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);
end


fprintf('\nPSYCHOMETRIC-PERCEPTUAL SCALING\n');
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

ShowIntroduction(P,3);
Screen('Flip',P.display.w);

if P.toggles.doPsyPrcScale
    fprintf('\n=================================');
    fprintf('\n=PSYCHOMETRIC-PERCEPTUAL SCALING=\n');
    for nStep1Trial = 1:numel(P.plateaus.step1Order)
        fprintf('\n=======TRIAL %d of %d=======\n',nStep1Trial,numel(P.plateaus.step1Order));
        [abort]=ApplyStimulus_heat(P,O,P.plateaus.step1Order(nStep1Trial));
        if abort; return; end
        P=InstantiateCurrentTrial(P,O,1,P.plateaus.step1Order(nStep1Trial));
        P=PlateauRating(P,O);
        [abort]=ITI(P,O,P.currentTrial.reactionTime);
        if abort; return; end
    end
end

%             % SEGMENT 2: FIXED INTENSITIES
%             if P.toggles.doFixedInts
%                 fprintf('\n===============================');
%                 fprintf('\n=======FIXED INTENSITIES=======\n');
%                 for nStep2Trial = 1:length(P.plateaus.step2Order)
%                     fprintf('\n=======TRIAL %d of %d=======\n',nStep2Trial,length(P.plateaus.step2Order));
%                     [abort]=ApplyStimulus(P,O,P.plateaus.step2Order(nStep2Trial));
%                     if abort; return; end
%                     P=InstantiateCurrentTrial(P,O,2,P.plateaus.step2Order(nStep2Trial));
%                     P=PlateauRating(P,O);
%                     if nStep2Trial<length(P.plateaus.step2Order)
%                         [abort]=ITI(P,O,P.currentTrial.reactionTime);
%                         if abort; return; end
%                     end
%                 end
%             end

% SEGMENT 3: PRE-ESTIMATED INTENSITIES

fprintf('\nFIXED TARGET REGRESSION\n');
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


if P.toggles.doPredetInts
    fprintf('\n===============================');
    fprintf('\n=====FIXED TARGET RATINGS======\n');

    x = P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>0); % could restrict to ==1, but the more info the better
    y = P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>0);
    [P.plateaus.step3Order,~] = FitData(x,y,P.plateaus.step3TarVAS,2);

    if any(P.plateaus.step3Order > 49 | P.plateaus.step3Order < 41)
        % find too high stimuli
        idx_2high = find(P.plateaus.step3Order > 49);
        if ~isempty(idx_2high)
            fprintf('suggested temperatures too high (> 49.0°C), will be replaced automatically with 49.0°C');
            if ~(length(idx_2high) >= 2)
                P.plateaus.step3Order(idx_2high) = P.pain.thermoino.maxSaveTemp;
            elseif length(idx_2high) == 2
                P.plateaus.step3Order(idx_2high) = [P.pain.thermoino.maxSaveTemp - 1,  P.pain.thermoino.maxSaveTemp];
            else
                P.plateaus.step3Order(idx_2high) = [P.pain.thermoino.maxSaveTemp - 2,  P.pain.thermoino.maxSaveTemp - 1,  P.pain.thermoino.maxSaveTemp];
            end
        end

        % find too low stimuli
        idx_2low  = find(P.plateaus.step3Order < 40);

        if ~(length(idx_2low) >= 2)
            fprintf('suggested temperatures too low (< 40.0°C), will be replaced automatically with 40°C');
            P.plateaus.step3Order(idx_2low) = P.pain.thermoino.minTemp;
        elseif length(idx_2low) == 2
            P.plateaus.step3Order(idx_2low) = [P.pain.thermoino.minTemp, P.pain.thermoino.minTemp+0.5];
        else
            P.plateaus.step3Order(idx_2low) = [P.pain.thermoino.minTemp, P.pain.thermoino.minTemp+0.5, P.pain.thermoino.minTemp+1];
        end
    end

    P = BetterGuess(P); % option to change FTRs if regression was off...
    for nStep3Trial = 1:length(P.plateaus.step3Order)
        fprintf('\n=======TRIAL %d of %d=======\n',nStep3Trial,length(P.plateaus.step3Order));
        [abort]=ApplyStimulus_heat(P,O,P.plateaus.step3Order(nStep3Trial));
        if abort; return; end
        P=InstantiateCurrentTrial(P,O,3,P.plateaus.step3Order(nStep3Trial),P.plateaus.step3TarVAS(nStep3Trial));
        P=PlateauRating(P,O);
        [abort]=ITI(P,O,P.currentTrial.reactionTime);
        if abort; return; end
    end
end

% SEGMENT 4: ADAPTIVE PROCEDURE

fprintf('\nADAPTIVE TARGET REGRESSION\n');
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


if P.toggles.doAdaptive
    fprintf('\n===============================');
    fprintf('\n====VARIABLE TARGET RATINGS====\n');
    nextStim = 1; % just so it isn't empty...
    varTrial = 0;
    nH = figure;
    while ~isempty(nextStim)
        ex = P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>1);
        ey = P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>1);
        if varTrial<2 % lin is more robust for the first additions; in the worst case [0 X 100], sig will get stuck in a step fct
            linOrSig = 'lin';
        else
            linOrSig = 'sig';
        end
        [nextStim,~,tValidation,targetVAS] = CalibValidation(ex,ey,[],[],linOrSig,P.toggles.doConfirmAdaptive,1,0,nH,num2cell([zeros(1,numel(ex)-1) varTrial]),['s' num2str(numel(varTrial)+1)]);
        if ~isempty(nextStim)
            varTrial = varTrial+1;
            fprintf('\n=======VARIABLE TRIAL %d=======\n',varTrial);
            [abort]=ApplyStimulus_heat(P,O,nextStim);
            if abort; return; end
            % note: ITI could additionally subtract tValidation!
            P=InstantiateCurrentTrial(P,O,4,nextStim,P.currentTrial.targetVAS);
            P=PlateauRating(P,O);
            [abort]=ITI(P,O,P.currentTrial.reactionTime); % +tValidation
            if abort; return; end
        end
        if varTrial == P.presentation.n_max_varTrial
            break
        end
    end
end

GetRegressionResults_heat(P);

%P = GetExistingCalibData(P);

%             if isempty(plateauLog)
%                 error('Calibration data not found at %s. Aborting.',P.out.dir);
%             end
%end

end

%%
function P=PlateauRating(P,O)

if ~O.debug.toggleVisual
    % brief blank screen prior to rating
    tBlankOn = Screen('Flip',P.display.w);
else
    tBlankOn = GetSecs;
end
while GetSecs < tBlankOn + 0.5 end

% VAS
fprintf('VAS... ');

send_trigger(P,O,sprintf('vas_on'));

if P.toggles.doPainOnly
    P = VASScale_v6_new(P,O,2);
else
    P = VASScale_v6_new(P,O,2);
end

P = PutRatingLog(P);

if ~O.debug.toggleVisual
    Screen('Flip',P.display.w);
end

end

%%
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
    [countedDown]=CountDown(P,GetSecs-tITIOn,countedDown,'.');
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

%%
function [P,calibration] = GetRegressionResults_heat(P)

if P.toggles.doPainOnly
    thresholdVAS = 0;
else
    thresholdVAS = 50;
end
x = P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>1 & P.pain.calibration.heat.PeriThrStimType<5);
y = P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>1 & P.pain.calibration.heat.PeriThrStimType<5);
[predTempsLin,predTempsSig,predTempsRob,betaLin,betaSig,betaRob] = FitData(x,y,[thresholdVAS P.plateaus.VASTargets],0);

painThresholdLin = predTempsLin(1);
painThresholdSig = predTempsSig(1);
predTempsLin(1) = []; % remove threshold temp, retain only VASTargets
predTempsSig(1) = []; % remove threshold temp, retain only VASTargets

if betaLin(2)<0
    warning(sprintf('\n\n********************\nNEGATIVE SLOPE. This is physiologically highly implausible. Exclude participant.\n********************\n'));
end

% construct regression results output file

calibration.fitData.heat.interceptLinear = betaLin(1); % lin intercept
calibration.fitData.heat.slopeLinear = betaLin(2); % lin slope
calibration.fitData.heat.interceptSigmoid = betaSig(1); % sig intercept
calibration.fitData.heat.slopeSigmoid = betaSig(2); % sig slope
calibration.fitData.heat.painThresholdAwiszus = P.pain.calibration.heat.AwThr; % as per Awiszus thresholding
calibration.fitData.heat.predHeatLinear = painThresholdLin; % as per linear regression for VAS 50 (pain threshold)
calibration.fitData.heat.predHeatSigmoid = painThresholdSig; % as per nonlinear regression for VAS 50 (pain threshold)
calibration.fitData.heat.predTempsLin = predTempsLin;

fprintf('\n\n==========REGRESSION RESULTS==========\n');
fprintf('>>> Linear intercept %1.1f, slope %1.1f. <<<\n',betaLin);
fprintf('>>> Sigmoid intercept %1.1f, slope %1.1f. <<<\n',betaSig);
fprintf('To achieve VAS50, use %1.1f%°C (lin) or %1.1f°C (sig).\n',painThresholdLin,painThresholdSig);
fprintf('This yields for\n');

for vas = 1:numel(P.plateaus.VASTargets)
    fprintf('- VAS%d: %1.1f°C (lin), %1.1f°C (sig)\n',P.plateaus.VASTargets(vas),predTempsLin(vas),predTempsSig(vas));
end

save(P.out.file.paramCalib, 'P');

% Save as individual structure
calibrated_heats = calibration;
save(P.out.file.heatsCalib,"calibrated_heats");

end

%%
% when skipping parts of the calibration in StartExperimentAt, try to obtain existing calib data
function P = GetExistingCalibData(P)

painCFiles = cellstr(ls(P.out.dir));
painCFiles = painCFiles(contains(painCFiles,'calib_data'));

if isempty(painCFiles)
    error('Previous calibration data file not found in %s. Aborting.',P.out.dir);
elseif numel(painCFiles)>1
    painCFiles = painCFiles(end);
    warning('Multiple calibration data files found. Proceeding with most recent one (%s).',cell2mat(painCFiles))
    existP = load([P.out.dir cell2mat(painCFiles)]); % load existing parameters
    existP = existP.P;

    try
        P.pain.calibration.heat.PeriThrN = existP.pain.calibration.heat.PeriThrN;
        P.pain.calibration.heat.PeriThrReactionTime = existP.pain.calibration.heat.PeriThrReactionTime;
        P.pain.calibration.heat.PeriThrResponseGiven = existP.pain.calibration.heat.PeriThrResponseGiven;
        P.pain.calibration.heat.PeriThrStimScaleInitVAS = existP.pain.calibration.heat.PeriThrStimScaleInitVAS;
    catch % for old log files
        warning('Old log file, some non-critical data not available.');
        P.pain.calibration.heat.PeriThrN = size(existP.pain.calibration.heat.PeriThrStimType,1);
        P.pain.calibration.heat.PeriThrReactionTime = NaN(size(existP.pain.calibration.heat.PeriThrStimType));
        P.pain.calibration.heat.PeriThrResponseGiven = NaN(size(existP.pain.calibration.heat.PeriThrStimType));
        P.pain.calibration.heat.PeriThrStimScaleInitVAS = NaN(size(existP.pain.calibration.heat.PeriThrStimType));
    end
else
    existP = load([P.out.dir cell2mat(painCFiles)]); % load existing parameters
    existP = existP.P;
    P.pain.calibration.heat.PeriThrStimType = existP.pain.calibration.heat.PeriThrStimType;
    P.pain.calibration.heat.PeriThrStimOffs = existP.pain.calibration.heat.PeriThrStimOffs;
    P.pain.calibration.heat.PeriThrStimTemps = existP.pain.calibration.heat.PeriThrStimTemps;
    P.pain.calibration.heat.PeriThrStimRatings = existP.pain.calibration.heat.PeriThrStimRatings;
    P.pain.calibration.heat.PeriThrRatingTime = existP.pain.calibration.heat.PeriThrRatingTime;
    P.pain.calibration.heat.PeriThrStimTarVAS = existP.pain.calibration.heat.PeriThrStimTarVAS;

    P.pain.calibration.heat.ResInterLin = existP.pain.calibration.heat.ResInterLin;
    P.pain.calibration.heat.ResSlopeLin = existP.pain.calibration.heat.ResSlopeLin;
    P.pain.calibration.heat.ResInterSig = existP.pain.calibration.heat.ResInterSig;
    P.pain.calibration.heat.ResSlopeSig = existP.pain.calibration.heat.ResSlopeSig;
    P.pain.calibration.heat.ResThrAw = existP.pain.calibration.heat.ResThrAw;
    P.pain.calibration.heat.ResThrLin = existP.pain.calibration.heat.ResThrLin;
    P.pain.calibration.heat.ResThrSig = existP.pain.calibration.heat.ResThrSig;

    P.pain.calibration.heat.notes{end+1} = sprintf('Perithresholding data imported from %s',[P.out.dir cell2mat(painCFiles)]);
end


end

%%
function  P = VASScale_v6_new(P,O,ratingsection)

abort = 0;

KbName('UnifyKeyNames');
keys        = P.keys;
lessKey     = P.keys.name.left; % yellow button
moreKey     = P.keys.name.right; % red button
confirmKey  = P.keys.name.confirm;
escapeKey   = P.keys.name.esc;

window      = P.display.w;
windowRect  = P.display.windowrect;
durRating   = P.pain.VAStraining.durationVAS;

if isempty(window); error('Please provide window pointer for likertScale!'); end
if isempty(windowRect); error('Please provide window rect for likertScale!'); end
if isempty(durRating); error('Duration length of rating has to be specified!'); end

%% Default values

tempCursorStart             = randi([31 71]);
currentRating               = tempCursorStart;
ratings                     = currentRating;
finalRating                 = 0;
reactionTime                = 0;
response                    = 0;
numberOfSecondsRemaining    = durRating;
keyTime                     = 0;
keyId                       = 0;
nRatingSteps                = 101;
scaleWidth                  = 1100;
textSize                    = 50;
lineWidth                   = 6;
scaleColor                  = [255 255 255];
activeColor                 = [255 0 0];
defaultRating               = 1;
backgroundColor             = P.style.backgr;
startY                      = P.style.startY;
nRating                     = 1;

%% Calculate rects

activeAddon_width           = 1.5;
activeAddon_height          = 30;
[xCenter, yCenter]          = RectCenter(windowRect);
yCenter                     = startY;
axesRect                    = [xCenter - scaleWidth/2; yCenter - lineWidth/2; xCenter + scaleWidth/2; yCenter + lineWidth/2];
lowLabelRect                = [axesRect(1),yCenter-30,axesRect(1)+6,yCenter+30];
highLabelRect               = [axesRect(3)-6,yCenter-30,axesRect(3),yCenter+30];
midLabelRect                = [xCenter-3,yCenter-30,xCenter+3,yCenter+30];
midlLabelRect               = [xCenter-3-scaleWidth/4,yCenter-30,xCenter+3-scaleWidth/4,yCenter+30];
midhLabelRect               = [xCenter-3+ scaleWidth/4,yCenter-30,xCenter+3+scaleWidth/4,yCenter+30];
ticPositions                = linspace(xCenter - scaleWidth/2,xCenter + scaleWidth/2-lineWidth,nRatingSteps);
activeTicRects              = [ticPositions-activeAddon_width;ones(1,nRatingSteps)*yCenter-activeAddon_height;ticPositions + lineWidth+activeAddon_width;ones(1,nRatingSteps)*yCenter+activeAddon_height];

Screen('TextSize',window,textSize);
Screen('TextColor',window,[255 255 255]);
Screen('TextFont', window, 'Arial');



%%%%%%%%%%%%%%%%%%%%%%% loop while there is time %%%%%%%%%%%%%%%%%%%%%
% tic; % control if timing is as long as durRating

startTime = GetSecs;
while numberOfSecondsRemaining  > 0

    Screen('FillRect',window,backgroundColor);
    Screen('FillRect',window,activeColor,[activeTicRects(1,1)+3 activeTicRects(2,1)+ 5 activeTicRects(3,currentRating)-3 activeTicRects(4,1)-5]);
    Screen('FillRect',window,scaleColor,lowLabelRect);
    Screen('FillRect',window,scaleColor,highLabelRect);
    Screen('FillRect',window,scaleColor,midLabelRect);
    Screen('FillRect',window,scaleColor,midlLabelRect);
    Screen('FillRect',window,scaleColor,midhLabelRect);

    if ratingsection == 1
        % Draw text for Exercise Rating (BORG Scale, Convert Scale)
        DrawFormattedText(window, 'Bitte bewerten Sie, wie anstrengend das Fahrradfahren war!', 'center',yCenter-200, scaleColor);

        Screen('DrawText',window,'überhaupt nicht',axesRect(1)-150,yCenter+40,scaleColor);
        Screen('DrawText',window,'anstrengend (6)',axesRect(1)-100,yCenter+80,scaleColor);

        Screen('DrawText',window,'maximale',axesRect(3)-55,yCenter+40,scaleColor);
        Screen('DrawText',window,'Anstrengung (20)',axesRect(3)-40,yCenter+80,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);



    elseif ratingsection == 2

        % Draw text for Painfulness
        DrawFormattedText(window, 'Wie SCHMERZHAFT war der letzte Reiz?', 'center',yCenter-200, scaleColor);

        Screen('DrawText',window,'minimaler',axesRect(1)-150,yCenter+40,scaleColor);
        Screen('DrawText',window,'Schmerz',axesRect(1)-100,yCenter+80,scaleColor);

        Screen('DrawText',window,'kaum aushaltbarer',axesRect(3)-55,yCenter+40,scaleColor);
        Screen('DrawText',window,'Schmerz',axesRect(3)-40,yCenter+80,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);


    elseif ratingsection == 3
        % Draw text for unpleasentness
        DrawFormattedText(window, 'Wie UNANGENEHM war der letzte Druckreiz?', 'center',yCenter-200, scaleColor);
        DrawFormattedText(window, '(maximal 7 Sekunden Zeit)', 'center',yCenter-100, scaleColor);

        Screen('DrawText',window,'gar nicht',axesRect(1)-150,yCenter+40,scaleColor);
        Screen('DrawText',window,'unangenehm',axesRect(1)-100,yCenter+80,scaleColor);

        Screen('DrawText',window,'extrem',axesRect(3)-55,yCenter+40,scaleColor);
        Screen('DrawText',window,'unangenehm',axesRect(3)-40,yCenter+80,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);

    elseif ratingsection == 4
        % Draw text for affective component
        DrawFormattedText(window, 'Wie DEUTLICH haben Sie den letzten Druckreiz wahrgenommen?', 'center',yCenter-100, scaleColor);
        DrawFormattedText(window, '(maximal 7 Sekunden Zeit)', 'center',yCenter-70, scaleColor);

        Screen('DrawText',window,'gar',axesRect(1)-17,yCenter+25,scaleColor);
        Screen('DrawText',window,'nicht',axesRect(1)-40,yCenter+50,scaleColor);

        Screen('DrawText',window,'extrem',axesRect(3)-55,yCenter+25,scaleColor);
        Screen('DrawText',window,'deutlich',axesRect(3)-40,yCenter+50,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);

    end


    %% Set the Response and keys pressed

    [keyIsDown,secs,keyCode] = KbCheck; % this checks the keyboard very, very briefly.

    if keyIsDown % only if a key was pressed we check which key it was
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.buttonPress); % log key/button press as a marker
        if keyCode(moreKey) % if it was the key we named key1 at the top then...
            currentRating = currentRating + 1; %original: currentRating = currentRating + 1;
            if currentRating > nRatingSteps
                currentRating = nRatingSteps;
            end
            ratings(end+1) = currentRating;
            keyTime(end+1) = secs - startTime;
            keyId(end+1) = 1;
            finalRating = currentRating;
            reactionTime = secs - startTime;
            response = 1;
        elseif keyCode(lessKey)
            currentRating = currentRating - 1; %original currentRating = currentRating - 1;
            if currentRating < 1
                currentRating = 1;
            end
            ratings(end+1) = currentRating;
            keyTime(end+1) = secs - startTime;
            keyId(end+1) = -1;
            finalRating = currentRating;
            reactionTime = secs - startTime;
            response = 1;
            %         elseif keyCode(confirmKey)
            %             finalRating = currentRating;
            %             fprintf('Rating %d\n',finalRating);
            %             reactionTime = secs - startTime;
            %             response = 1;
            %             break;
        elseif keyCode(escapeKey)
            abort = 1;
            break;
        end
    end

    keyId(end+1) = 0;
    keyTime(end+1) = 0;

    numberOfSecondsElapsed   = (GetSecs - startTime);
    numberOfSecondsRemaining = durRating - numberOfSecondsElapsed;

    P.currentTrial(nRating).finalRating = finalRating;
    P.currentTrial(nRating).reactionTime = reactionTime;
    P.currentTrial(nRating).response = response;

end

end
%%
function [abort]=ApplyStimulus_heat(P,O,trialTemp)
% be sure to never go higher than 49°C and never lower than
% baseline, otherwise the "cold" can hurt as well
if trialTemp > P.pain.thermoino.maxSaveTemp
    trialTemp = P.pain.thermoino.maxSaveTemp;
elseif trialTemp < P.pain.thermoino.bT
    trialTemp = P.pain.thermoino.bT;
end

abort=0;
[stimDuration]=CalcStimDuration(P,trialTemp,P.presentation.sStimPlateau);

if P.pain.calibration.heat.PeriThrN==1 % Turn on the fixation cross for the first trial (no ITI to cover this)
    InitialTrial_heat(P,O);
elseif P.pain.calibration.heat.PeriThrN == 4
    InitialTrial_heat(P,O);
end

fprintf('%1.1f°C stimulus initiated.',trialTemp);

tHeatOn = GetSecs;
countedDown=1;
send_trigger(P,O,sprintf('stim_on'));

if P.devices.thermoino
    UseThermoino('Trigger'); % start next stimulus
    UseThermoino('Set',trialTemp); % open channel for arduino to ramp up

    while GetSecs < tHeatOn + sum(stimDuration(1:2))
        [countedDown]=CountDown(P,GetSecs-tHeatOn,countedDown,'.');
        [abort]=LoopBreaker(P);
        if abort; break; end
    end

    fprintf('\n');
    UseThermoino('Set',P.pain.thermoino.bT); % open channel for arduino to ramp down

    if ~abort
        while GetSecs < tHeatOn + sum(stimDuration)
            [countedDown]=CountDown(P,GetSecs-tHeatOn,countedDown,'.');
            [abort]=LoopBreaker(P);
            if abort; return; end
        end
    else
        return;
    end
else
    send_trigger(P,O,sprintf('stim_on'));

    while GetSecs < tHeatOn + sum(stimDuration)
        [countedDown]=CountDown(P,GetSecs-tHeatOn,countedDown,'.');
        [abort]=LoopBreaker(P);
        if abort; return; end
    end
end
fprintf(' concluded.\n');

end

%%
function P=InstantiateCurrentTrial(P,O,stepId,trialTemp,varargin)

P.pain.calibration.heat.PeriThrN =  P.pain.calibration.heat.PeriThrN+1;

P.currentTrial = struct; % reset
P.currentTrial.N = P.pain.calibration.heat.PeriThrN;
P.currentTrial.nRating = 1; % currently, CalibHeat contains only one rating scale; cf P11_WindUp for expanding this
P.currentTrial.ratingId = 11; % 11 = heat/pain VAS
if P.toggles.doPainOnly
    P.currentTrial.trialType = 'single';
else
    P.currentTrial.trialType = 'double';
end
P.currentTrial.stepId = stepId;
P.currentTrial.temp = trialTemp;

if nargin>4
    P.currentTrial.targetVAS = varargin{1}; % include predicted VAS in log file (redundancy)
else
    P.currentTrial.targetVAS = -1;
end

P.currentTrial.sITI = round(P.presentation.sMinMaxPlateauITIs(1) + (P.presentation.sMinMaxPlateauITIs(2)-P.presentation.sMinMaxPlateauITIs(1))*rand,1); % note: this is RANDOM in a range, since it's just the calibration; could revert to balanced sITIs
P.currentTrial.sCue = round(P.presentation.sMinMaxPlateauCues(1) + (P.presentation.sMinMaxPlateauCues(2)-P.presentation.sMinMaxPlateauCues(1))*rand,1); % note: this is RANDOM in a range, since it's just the calibration; could revert to balanced sCues

P.log.scaleInitVAS(P.currentTrial.N,1) = randi(P.presentation.scaleInitVASRange); % different starting value for each trial; legacy log

end

%% Set Marker for CED and BrainVision Recorder
function SendTrigger(P,address,port)
% Send pulse to CED for SCR, thermode, digitimer
% [handle, errmsg] = IOPort('OpenSerialport',num2str(port)); % gives error
% msg on grahl laptop
if P.devices.trigger
    outp(address,port);
    WaitSecs(P.com.lpt.CEDDuration);
    outp(address,0);
    WaitSecs(P.com.lpt.CEDDuration);
end

end
%%
function P = BetterGuess(P)

fprintf('Ratings so far were for\n');
fprintf('%1.1f\t',P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>0));
fprintf('\n');
fprintf('%d\t',P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>0));
fprintf('\n\n');

fprintf('Suggested target intensities for\n');
fprintf('%d\t',P.plateaus.step3TarVAS);
fprintf('\n');
fprintf('%1.1f\t',P.plateaus.step3Order);

fprintf('\nWhen in doubt, try [42.5 43.5 44.5]\n(this pattern MUST be 2 digits dot 1 digit, e.g. 44.0 NOT just 44)\nComputes _all_ chars, so if backspace or cursor were used, enter an x and press Enter, then re-enter.\n\n');

ListenChar(0);

% this weird construct is necessary because some lingering keyboard input just skips the first input() apparently...
%         fprintf('Please press [Return] once...\n');
%         KbWait([], 2)
%         WaitSecs(0.5);
%
%         override = input(sprintf('Press [Return] to continue, or enter full vector (length %d) to override.\n',numel(step3Order)));

commandwindow;
override = 'x';
while ( ~isempty(regexp(override,'x','ONCE')) || length(override)~=16 ) && ~isempty(override)
    override = GetString();
end
if ~isempty(override)
    override=regexprep(override,'[\[\]]','');
    override=regexp(override,'\d{2}\.\d{1}','MATCH');
    override=str2double(override);
    P.plateaus.step3Order = override;
end

ListenChar(2);

end


function PrintDurations(P)

durationTotal=P.time.scriptEnd-P.time.scriptStart;
durationExp=P.time.scriptEnd-P.time.threshStart;
durationThresholding=P.time.threshEnd-P.time.threshStart;
durationPlateaus=P.time.scriptEnd-P.time.plateauStart;

fprintf('\n--\n');
fprintf('Total minutes since script start: %1.1f\n',SecureRound(durationTotal/60,1));
fprintf('Minutes since start of experiment proper: %1.1f\n',SecureRound(durationExp/60,1));
fprintf('Minutes thresholding: %1.1f\n',SecureRound(durationThresholding/60,1));
fprintf('Minutes plateaus: %1.1f\n',SecureRound(durationPlateaus/60,1));

end

%%
function [abort,countedDown]=CountDown(P, secs, countedDown, countString)
% display string during countdown
if secs>countedDown
    fprintf('%s', countString);
    %DrawFormattedText(P.display.w, ['Noch ',countString,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);
    countedDown=ceil(secs);
    WaitSecs(1);
end

[abort] = LoopBreakerStim(P);
if abort; return; end
end

%%
function [abort]=LoopBreakerStim(P)
abort=0;
[keyIsDown, ~, keyCode] = KbCheck();
if keyIsDown
    if find(keyCode) == P.keys.name.esc
        abort=1;
    end
end
end




