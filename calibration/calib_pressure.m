function [abort, P, O, calibrated_pressures] = calib_pressure(P,O)

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

addpath(genpath(P.path.scriptBase));
addpath(genpath(P.path.PTB));
addpath(fullfile(P.path.PTB,'PsychBasic','MatlabWindowsFilesR2007a'));

% Clear global functions
clear mex global functions;
commandwindow;



%% ----------------- Initial pressure cuff -----------------------------

if P.devices.arduino
    [abort,initSuccess,dev] = InitCPAR; % initialize CPAR

    if initSuccess
        P.cpar.init = initSuccess;
        P.cpar.dev = dev;
    else
        warning('\nCPAR initialization not successful, aborting!');
        abort = 1;
    end
    if abort
        QuickCleanup(P,dev);
        return;
    end
end

%% ---------------- Initialise Parameters and Screen -------------------

% Load Parameters for experiment
[P,O]                   = SetParams(P,O);
[P,O]                   = SetKeys(P,O);

% Query where to start experiment
%[abort, P] = StartExperimentAt(P);
if abort; QuickCleanup(P,dev); return; end

% Open Screen
[P,O]                   = SetPTB(P,O);

% Get timing at script start
P.time.stamp            = datestr(now,30);
P.time.scriptStart      = GetSecs;


%% Step 1: Pre Exposure and Awiszus Method + VAS Training

%if P.startSection < 4

    ShowIntroduction(P,1);
    [P,abort] = PreExposureAwiszus(P,O,dev);

    % VAS Training
    load(P.out.file.paramCalib,'P','O');
    ShowIntroduction(P,2);
    [P,abort] = VASTraining(P,O,2,dev);

%end


%% Step 2: Calibration: Psychometric Scaling


%if P.startSection < 5
    load(P.out.file.paramCalib,'P','O');
    ShowIntroduction(P,3);
    [P,abort] = PsychometricScaling(P,O);


%% Step 3: Calibration: VAS Target Regresion


    load(P.out.file.paramCalib,'P','O');
    [P,abort] = TargetRegressionVAS(P,O);

%end

% Save Calibrated Pressures
calibrated_pressures = P.pain.calibration.results;
save(P.out.file.paramCalib,'P','O');
save(P.out.file.pressuresCalib,"calibrated_pressures");

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                      FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,abort]=PreExposureAwiszus(P,O,dev)
% This function runs the PreExposure and Awiszus Pain Thresholding
% together.
%
% Pre Exposure: uses two low intensity pressure stimuli of 10 and 20 kPa to
% get the participant used to the feeling of the pressure cuff inflating.
%
% ______________________________________________________________________
%
% Awiszus: This function integrates consecutively entered distributions in a quasi-Bayesian fashion.
% It was built for heat pain threshold determination, but will merrily process other input.
% See subfunctions EXAMPLE_CALLER for guidance on how to call it, and EXAMPLE_CALLER_VISUALDEMO
% for a rough graphical demonstration of how it works.
%
% P = Awiszus('init',P);
% This generates a starting distribution (actually the prior) for use in later iterations.
% Expects a P struct with parameters defined substruct P.awiszus
%
% [awPost,awNextX] = Awiszus('update',awP,awPost,awNextX,awResponse);
% P = Awiszus('update',awP,awPost,awNextX,awResponse);
% Responses are expected to be binary. In our original usage, we were judging stimuli to be
% painful (1) or not (0). .dist is actually the old prior, which is updated to become
% the returned .dist.
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


% Define output file
cparFile = fullfile(P.out.dirCalib,[P.out.file.CPAR '_PreExposure.mat']);

abort=0;

% Print to experimenter what is running
fprintf('\n====================================================\nRunning pre-exposure and Awiszus pain thresholding.\n====================================================\n');

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

while ~abort

    cuff = P.calibration.cuff_arm;

    fprintf([P.pain.cuffSide{cuff} ' ARM \n']); %P.pain.stimName{stimType} ' STIMULUS\n--------------------------\n']);

    for trial = 1:(numel(P.pain.preExposure.startSimuli)+P.awiszus.N) % pre-exposure + Awiszus trials

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
        elseif trial == numel(P.pain.preExposure.startSimuli)+1 % first trial of Awiszus procedure starts from the pre-defined population mean
            preExpInt = P.awiszus.mu(cuff);
            preExpPhase = 'Awiszus';
        else % rest of the trials pressure is adjusted according to participant's rating and the Awiszus procedure
            preExpInt = P.awiszus.nextX(cuff);
            preExpPhase = 'Awiszus';
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


        % Next pressure (nextX) updated based on ratings
        if trial <= numel(P.pain.preExposure.startSimuli) % pre-exposure trials no ratings, only to get subject used to the feeling
            preexPainful = NaN;
        else
            P = Awiszus('init',P,cuff);
            preexPainful = QueryPreExPain(P,O);
            P = Awiszus('update',P,preexPainful,cuff);

            if preexPainful
                fprintf('--Stimulus rated as painful. \n');
            elseif ~preexPainful
                fprintf('--Stimulus rated as not painful. \n');
            else
                fprintf('--No valid rating. \n');
            end

        end

        P.awiszus.threshRatings.pressure(cuff,trial) = preExpInt;
        P.awiszus.threshRatings.ratings(cuff,trial) = preexPainful;

    end


    % Pain threshold
    if preexPainful % if last stimulus rated as painful
        P.awiszus.painThresholdFinal(cuff) = P.awiszus.threshRatings.pressure(cuff,trial); % last rated value is the pain threshold
    elseif ~preexPainful && ~any(P.awiszus.threshRatings.ratings(cuff,:)) % not painful and no previous painful ratings
        P.awiszus.painThresholdFinal(cuff) = P.awiszus.threshRatings.pressure(cuff,trial); % last rated value is the pain threshold
    else
        lastPainful = find(P.awiszus.threshRatings.ratings(cuff,:),1,'last');
        P.awiszus.painThresholdFinal(cuff) = P.awiszus.threshRatings.pressure(cuff,lastPainful); % previous painful rated value
        %P.awiszus.painThresholdFinal(cuff) = P.awiszus.threshRatings.pressure(cuff,trial-1); % previous rated value from Awiszus (usually painful)
    end
    save(P.out.file.paramCalib,'P','O');
    fprintf(['\nPain threshold ' P.pain.cuffSide{cuff} ' ARM - ' num2str(P.awiszus.painThresholdFinal(cuff)) ' kPa\n\n']);

    break;
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,abort] = VASTraining(P,O,ratingsection,dev)

abort=0;
strings = GetText;
cuff = P.calibration.cuff_arm;
trial = [];

% Define output file
cparFile = fullfile(P.out.dirCalib,[P.out.file.CPAR '_VAStraining.mat']);

fprintf('\n==========================\nRunning VAS training.\n==========================\n');

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

while ~abort


    if ~O.debug.toggleVisual
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        tCrossOn = Screen('Flip',P.display.w);
    else
        tCrossOn = GetSecs;
    end


    countedDown = 1;
    while GetSecs < tCrossOn + P.pain.calibration.firstTrialWait
        tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
        [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
        if abort; break; end
    end

    if abort; return; end

    %%  Give pressure at pain threshold and see wether they rate 0 on scale
    for paintrial = 1:P.pain.VAStraining.trials

        pressure = P.awiszus.painThresholdFinal;

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
            Screen('Flip',P.display.w);
        end


        % Calculate Stimulus Duration including ramp and plateau
        stimDuration = CalcStimDuration(P,pressure,P.pain.preExposure.sStimPlateauPreExp);

        countedDown = 1;
        tStimStart = GetSecs;


        if P.devices.arduino && P.cpar.init

            abort = UseCPAR('Set',dev,'preExp',P,stimDuration,pressure); % set stimulus
            [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus

        end


        while GetSecs < tStimStart+sum(stimDuration)
            [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
            if abort; return; end
        end

        fprintf(['\nVAS pressure threshold ' num2str(pressure)]);

        fprintf(' concluded.\n');

        if P.devices.arduino && P.cpar.init
            data = cparGetData(dev, data);
            preExpCPARdata = cparFinalizeSampling(dev, data);
            saveCPARData(preExpCPARdata,cparFile,cuff,trial);
        end

        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);
        end

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            Screen('Flip',P.display.w);
        end

        %% Get ratings for scales

        % Display the scale and introduction depending on the ratingsection
        % (1 = excerise, 2 = Painfulness, 3 = unpleasentness, 4 = affective
        % component)

        if ratingsection == 2 % painfulness

            Screen('TextSize',P.display.w,30);

            % Continue after 2 seconds
            WaitSecs(1);
            Screen('Flip',P.display.w);

            % Draw scale
            [abort,finalRating,~,~,~,~] = singleratingScale_bigger(P,2);
            fprintf(['\nFinal rating was ' num2str(finalRating)]);

            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end
            ratingsection = ratingsection +1;
        end

        if ratingsection == 3 % unpleasentness
            Screen('TextSize',P.display.w,30);

            % Continue after 2 seconds
            WaitSecs(1);
            Screen('Flip',P.display.w);

            % Draw scale
            [abort,finalRating,~,~,~,~] = singleratingScale_bigger(P,3);
            fprintf(['\nFinal rating was ' num2str(finalRating)]);


            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            ratingsection = 2;
        end

    end


    % Intertrial interval if not the last stimulus in the block,
    % if last trial then end trial immediately
    if trial ~= P.pain.VAStraining.trials

        fprintf('\nIntertrial interval... ');
        countedDown = 1;
        while GetSecs < tCrossOn + P.pain.VAStraining.durationITI
            tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
            [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
            if abort; break; end
        end

        if abort; return; end

    end


    paintrial = paintrial + 1;

    if paintrial >2
        abort = 1;
        break;
    end
end


if ~abort
    fprintf('\nVAS training finished. \n');
else
    return;
end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [P,abort] = PsychometricScaling(P,O)
% Psychometric scaling
% Present few stimuli above the pain threshold to expose participants to
% a wide range of stimuli to scale their psychological perception of what
% intensity of pain is available

% If participant's pain threshold is high, the steps will be larger
% If the pain detection threshold is low, the steps will be smaller

% Predict which kPa pressure needed to produce which VAS rating with
% FitData

abort=0;

fprintf('\n========================================\nRunning psychometric perceptual scaling.\n========================================\n');

while ~abort

    for cuff = P.calibration.cuff_arm

        fprintf(['\n' P.pain.cuffSide{cuff} ' ARM - ' ]);

        fprintf('Displaying instructions... ');

        if ~O.debug.toggleVisual
            upperHalf = P.display.screenRes.height/2;
            Screen('TextSize', P.display.w, 70);

            if strcmp(P.language,'de')
                [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Kalibrierung: Druckreiz, ' P.pain.cuffSideDe{cuff} ' Arm'], 'center', upperHalf, P.style.white);
            elseif strcmp(P.language,'en')
                [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Calibration: pressure stimuli, the ' P.pain.cuffSide{cuff} ' arm'], 'center', upperHalf, P.style.white);
            end

            Screen('TextSize', P.display.w, 30);
            introTextOn = Screen('Flip',P.display.w);
        else
            introTextOn = GetSecs;
        end

        % Abort Block if neccesary at start
        while GetSecs < introTextOn + P.pain.calibration.blockstopWait
            [abort]=LoopBreaker(P);
            if abort; break; end
        end

        % Wait for input from experiment to continue
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
        if abort; break; end

        WaitSecs(0.2);


        durationITI = P.pain.calibration.sCalibITI;


        if isfield(P.awiszus,'painThresholdFinal')
            painThreshold = P.awiszus.painThresholdFinal;
        else
            painThreshold = P.awiszus.mu;
        end

        stepSize = P.pain.psychScaling.thresholdMultiplier*painThreshold;

        clear scalingPressures
        for pressure = 1:P.pain.psychScaling.trials
            if pressure ~= P.pain.psychScaling.trials
                scalingPressures(pressure) = ceil(painThreshold+pressure*stepSize); %#ok<AGROW>
            else
                scalingPressures(pressure) = ceil(painThreshold+(pressure-2)*stepSize); %#ok<AGROW>
            end
        end

        for trial = 1:P.pain.psychScaling.trials

            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end


            if trial == 1 % first trial no intertrial interval

                fprintf('\nWaiting for the first stimulus to start...\n');
                countedDown = 1;
                while GetSecs < tCrossOn + P.pain.calibration.firstTrialWait
                    tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                    [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                    if abort; break; end
                end

                if abort; return; end
                P.pain.psychScaling.calibStep;
            end

            % Start trial
            fprintf('\n\n=======TRIAL %d of %d=======\n',trial,P.pain.psychScaling.trials);

            % Red fixation cross
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
                Screen('Flip',P.display.w);
            end

            trialPressure = scalingPressures(trial);
            [abort,P] = ApplyStimulusCalibration(P,O,trialPressure,P.pain.psychScaling.calibStep,cuff,trial); % run stimulus
            save(P.out.file.paramCalib,'P','O'); % Save instantiated parameters and overrides after each trial
            if abort; break; end

            % White fixation cross
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            % Intertrial interval if not the last stimulus in the block,
            % if last trial then end trial immediately
            if trial ~= P.pain.psychScaling.trials

                fprintf('\nIntertrial interval... ');
                countedDown = 1;
                while GetSecs < tCrossOn + durationITI
                    tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                    [countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                    if abort; break; end
                end

                if abort; return; end

            end

            if abort; break; end

        end

        if abort; break; end


        if abort; break; end

    end

    break;

end

if ~abort
    fprintf('\nPsychometric perceptual scaling finished. \n');
    abort = 1;
else
    return;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,abort] = TargetRegressionVAS(P,O)

abort=0;

fprintf('\n==========================\nRunning VAS target regression.\n==========================\n');

while ~abort

    for cuff = P.calibration.cuff_arm

        fprintf(['\n' P.pain.cuffSide{cuff} ' ARM - ' ]);


        clear x y ex ey pressureData ratingData nextStim nH


        fprintf('Displaying instructions... ');

        if ~O.debug.toggleVisual
            upperHalf = P.display.screenRes.height/2;
            Screen('TextSize', P.display.w, 70);

            if strcmp(P.language,'de')
                [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Kalibrierung: Druckreiz, ' P.pain.cuffSideDe{cuff} ' Arm'], 'center', upperHalf, P.style.white);
            elseif strcmp(P.language,'en')
                [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Calibration: long pain stimuli, the ' P.presentation.armname_long_en ' arm'], 'center', upperHalf, P.style.white);
            end


            Screen('TextSize', P.display.w, 30);
            introTextOn = Screen('Flip',P.display.w);
        else
            introTextOn = GetSecs;
        end

        % Abort Block if neccesary at start
        while GetSecs < introTextOn + P.pain.calibration.blockstopWait
            [abort]=LoopBreaker(P);
            if abort; break; end
        end

        % Wait for input from experiment to continue
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

        WaitSecs(0.2);


        % define inter trial interval
        durationITI = P.pain.calibration.sCalibITI;


        fprintf('\n')
        if isempty(P.pain.calibration.pressure) || isempty(P.pain.calibration.rating) || numel(P.pain.calibration.pressure(cuff,:)) < P.pain.psychScaling.trials % || ~exist('P.calibration.pressure') || ~exist('P.calibration.rating') %#ok<EXIST>
            fprintf('No valid previous data from psychometric scaling.');
            fprintf('\nTake preset values to continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));

            while 1
                [keyIsDown, ~, keyCode] = KbCheck();
                if keyIsDown
                    if find(keyCode) == P.keys.name.confirm
                        painThreshold = P.awiszus.mu(cuff);
                        P.pain.calibration.VASTargetsFixedPressure = painThreshold + P.pain.calibration.VASTargetsFixedPresetSteps;
                        break;
                    elseif find(keyCode) == P.keys.name.esc
                        abort = 1;
                        break;
                    end
                end
            end

        else
            % Fit previous data and retrieve regression results
            pressureData = P.pain.calibration.pressure(cuff,:);
            ratingData = P.pain.calibration.rating(cuff,:);
            x = pressureData(pressureData>0 | ratingData>0); % take only non-zero data
            y = ratingData(pressureData>0 | ratingData>0); % take only ratings associated with non-zero pressures
            [P.pain.calibration.VASTargetsFixedPressure,~,~,linreg,~,~] = FitData(x,y,P.pain.calibration.VASTargetsFixed,0);  % last vargin, 0 = figure+text, 2 = text only output

            % save created figure
            saveas(gcf,fullfile(P.out.dirCalib,['calibration_02_' lower(P.pain.cuffSide{cuff}) '_arm.fig']))


            if any(P.pain.calibration.VASTargetsFixedPressure < 0) || any(P.pain.calibration.VASTargetsFixedPressure > 100) || linreg(2) <= 0
                fprintf('Invalid fit based on psychometric scaling data!\n');
                fprintf('\nTake preset values to continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));

                while 1
                    [keyIsDown, ~, keyCode] = KbCheck();
                    if keyIsDown
                        if find(keyCode) == P.keys.name.confirm
                            painThreshold = P.awiszus.mu(cuff);
                            P.pain.calibration.VASTargetsFixedPressure = painThreshold + P.pain.calibration.VASTargetsFixedPresetSteps;
                            break;
                        elseif find(keyCode) == P.keys.name.esc
                            abort = 1;
                            break;
                        end
                    end
                end
            end
        end

        %% FIXED INTENSITY VAS TARGETS
        % Iterative procedure where first pressure is based on the
        % psychometric scaling VAS ratings and a few fixed VAS targets are
        % used at first to better estimate the VAS and pressure relationship
        % by fitting a sigmoid function
        fprintf('\n==========================\nFIXED VAS TARGET REGRESSION.\n==========================\n');

        trialsFixed = numel(P.pain.calibration.VASTargetsFixed);

        for trial = 1:trialsFixed

            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            if trial == 1 % first trial no intertrial interval

                fprintf('\nWaiting for the first stimulus to start... ');
                countedDown = 1;
                while GetSecs < tCrossOn + P.pain.calibration.firstTrialWait
                    tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                    [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                    if abort; break; end
                end

                if abort; return; end

            end

            if abort; break; end

            % Start trial
            fprintf('\n\n=======TRIAL %d of %d=======\n',trial,trialsFixed);

            % Red fixation cross
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
                Screen('Flip',P.display.w);
            end

            % Retrieve predicted pressure as current trial pressure to rate
            trialPressure = P.pain.calibration.VASTargetsFixedPressure(trial);

            [abort,P] = ApplyStimulusCalibration(P,O,trialPressure,P.pain.calibration.calibStep.fixedTrials,cuff,trial); % run stimulus
            save(P.out.file.paramCalib,'P','O'); % Save instantiated parameters and overrides after each trial
            if abort; break; end

            % White fixation cross
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            % Intertrial interval if not the last stimulus in the block,
            % if last trial then end trial immediately
            if trial ~= trialsFixed

                fprintf('\nIntertrial interval... ');
                countedDown = 1;
                while GetSecs < tCrossOn + durationITI
                    tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                    [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                    if abort; break; end
                end

                if abort; return; end

            end

            if abort; break; end

        end

        %% ADAPTIVE INTENSITY VAS TARGETS
        % - Stimulus intensities now depend on all previous intensity and rating data –
        % for each new stimulus, the pressure intensity that is applied is defined
        % based on what part of the VAS pain rating scale is less well covered
        % by previous ratings.
        %
        % - After each new stimulus and its pain rating, the regression is done again,
        % and the estimated relationship of pressure intensity and pain ratings is adjusted
        %
        %  -The process continues until the program says that there is enough
        % coverage of the whole VAS from 0 to 100 so that we can reliably take a
        % desired VAS pain intensity for a stimulus and retrieve a suitable pressure intensity
        % to apply on the participant.s arm.

        fprintf('\n==========================\nADAPTIVE VAS TARGET REGRESSION.\n==========================\n');

        % Start trial
        nextStim = NaN;
        varTrial = 3;%0;
        nH = figure;
        while ~isempty(nextStim)

            % White fixation cross
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            if varTrial == 1 % first trial no intertrial interval

                fprintf('\nWaiting for the first stimulus to start... ');
                countedDown = 1;
                while GetSecs < tCrossOn + P.pain.calibration.firstTrialWait
                    tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                    [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                    if abort; break; end
                end

                if abort; return; end

            end

            if abort; break; end

            % Find next stimulus pressure intensity based on previous VAS rating data
            pressureData = P.pain.calibration.pressure(cuff,:);
            ratingData = P.pain.calibration.rating(cuff,:);
            ex = pressureData(pressureData>0 | ratingData>0); % take only non-zero data
            ey = ratingData(pressureData>0 | ratingData>0); % take only ratings associated with non-zero pressures
            linOrSig = 'lin';
            %                 if varTrial<2 % lin is more robust for the first additions; in the worst case [0 X 100], sig will get stuck in a step fct
            %                     linOrSig = 'lin';
            %                 else
            %                     linOrSig = 'sig';
            %                 end
            [nextStim,~,~,~] = CalibValidation(ex,ey,[],[],linOrSig,P.toggles.doConfirmAdaptive,1,1,nH,num2cell([zeros(1,numel(ex)-1) varTrial]),['s' num2str(numel(varTrial)+1)]);

            if isempty(nextStim); break; end

            % Red fixation cross during the trial
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
                Screen('Flip',P.display.w);
            end

            % Apply stimulus
            fprintf('\n=======VARIABLE TRIAL %d=======\n',varTrial);
            [abort,P] = ApplyStimulusCalibration(P,O,nextStim,P.pain.calibration.calibStep.adaptiveTrials,cuff,varTrial); % run stimulus
            varTrial = varTrial+1;
            save(P.out.file.paramCalib,'P','O'); % Save instantiated parameters and overrides after each trial
            if abort; break; end

            % White fixation cross during ITI
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            % Intertrial interval
            fprintf('\nIntertrial interval... ');
            countedDown = 1;
            while GetSecs < tCrossOn + durationITI
                tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                if abort; break; end
            end

            if abort; break; end

        end

        if abort; break; end

        % Get calibration results for the stimulus type
        calibration = GetRegressionResults(P,cuff);
        P.pain.calibration.results = calibration;
        save(P.out.file.paramCalib,'P','O');

        try
            savefig(nH, fullfile(P.out.dirCalib,['calibration_' lower(P.pain.cuffSide{cuff}) '_arm.fig']));
        catch
            fprintf('\nFigure not saved! ');
        end

        if abort; break; end

    end

    break;

end

if ~abort
    % Print to experimenter and participant
    fprintf('C A L I B R A T I O N   F I N I S H E D. \n');
    commandwindow;
    abort = 1;
    sca;
else
    return;
end

end


