% =======================================================================
%% Block 1a: Calibration Heat Thermode
% =======================================================================

function [abort,P,O,calibrated_heats] = calib_heat(P,O)


% restore the default path to delete other saved paths
restoredefaultpath

% add script base path
addpath('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI')


%% ------------------ Experiment Preparations -------------------------

% Instantiate Parameters and Overrides
P                       = InstantiateParameters_calib;
O                       = InstantiateOverrides;


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
if abort; QuickCleanup(P,dev); return; end

% Open Screen
[P,O]                   = SetPTB(P,O);

% Get timing at script start
P.time.stamp            = datestr(now,30);
P.time.scriptStart      = GetSecs;

%% Step 3: Pre Exposure and Awiszus Method + VAS Training

%   if P.startSection < 1
ShowIntroduction(P,1);
[P,abort] = PreExposureAwiszus_heat(P,O);

% VAS Training
load(P.out.file.paramCalib,'P','O');
ShowIntroduction(P,2);

for i = 2:P.pain.VAStraining.nRatings
    [P,abort] = VASTraining(P,O,i,dev);
    i = i + 1;
end
%   end


%% Step 4: Calibration: Psychometric Scaling

% % if P.startSection < 2
% load(P.out.file.paramCalib,'P','O');
% ShowIntroduction(P,3);
% [P,abort] = PsychometricScaling(P,O);
% 
% % end
% 
% %% Step 5: Calibration: VAS Target Regresion
% 
% %if  P.startSection < 3
% load(P.out.file.paramCalib,'P','O');
% [P,abort] = TargetRegressionVAS(P,O);
% 
% %  end



end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P,abort]=PreExposureAwiszus_heat(P,O)
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
%thermodeFile = fullfile(P.out.dirCalib,[P.out.file.CPAR '_PreExposure.mat']);

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



    for trial = 1:(numel(P.pain.preExposure.vec_int)+P.awiszus.N) % pre-exposure + Awiszus trials

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            tCrossOn = Screen('Flip',P.display.w);                      % gets timing of event for PutLog
        else
            tCrossOn = GetSecs;
        end

        fprintf('Displaying fixation cross... ');
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.ITIOnset);

        while GetSecs < tCrossOn + P.pain.preExposure.sPreexpITI
            [abort]=LoopBreaker(P);
            if abort; break; end
        end

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
            Screen('Flip',P.display.w);
        end

        if trial <= numel(P.pain.preExposure.vec_int) % pure pre-exposure to get used to the feeling
            preExpInt = P.pain.preExposure.vec_int(trial);
            preExpPhase = 'pre-exposure';
            preexPainful = 0;
        elseif trial == numel(P.pain.preExposure.vec_int)+1 % first trial of Awiszus procedure starts from the pre-defined population mean
            preExpInt = P.awiszus.thermoino.mu;
            preExpPhase = 'Awiszus';
        else % rest of the trials pressure is adjusted according to participant's rating and the Awiszus procedure
            preExpInt = P.awiszus.thermoino.nextX;
            preExpPhase = 'Awiszus';
        end
        fprintf('\n%1.1f kPa %s stimulus initiated.\n',preExpInt,preExpPhase);


        % Calculate Stimulus Duration including ramp and plateau
        stimDuration = CalcStimDuration(P,preExpInt,P.pain.preExposure.sStimPlateauPreExp);

        countedDown = 1;
        tHeatOn = GetSecs;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.pressureOnset);

        if P.devices.thermoino
            UseThermoino('Trigger'); % start next stimulus
            UseThermoino('Set',preExpInt); % open channel for arduino to ramp up

            while GetSecs < tHeatOn + sum(stimDuration)
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

            fprintf(' concluded.\n');

            %         if P.devices.arduino && P.cpar.init
            %             data = cparGetData(dev, data);
            %             %preExpCPARdata = cparFinalizeSampling(dev, data);
            %             %saveCPARData(preExpCPARdata,cparFile,cuff,trial);
            %         end

            if ~O.debug.toggleVisual
                Screen('Flip',P.display.w);
            end
            SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);

            % Next pressure (nextX) updated based on ratings
            if trial <= numel(P.pain.preExposure.vec_int) % pre-exposure trials no ratings, only to get subject used to the feeling
                preexPainful = NaN;
            else
                P = Awiszus_heat('init',P);
                preexPainful = QueryPreExPain_heat(P,O);
                P = Awiszus_heat('update',P,preexPainful);

                if preexPainful
                    fprintf('--Stimulus rated as painful. \n');
                elseif ~preexPainful
                    fprintf('--Stimulus rated as not painful. \n');
                else
                    fprintf('--No valid rating. \n');
                endP.awiszus.threshRatings.pressure

            end

            P.awiszus.threshRatings.heat(trial) = preExpInt;
            P.awiszus.threshRatings.ratings(trial) = preexPainful;

        end


        % Pain threshold
        if preexPainful % if last stimulus rated as painful
            P.awiszus.painThresholdFinal= P.awiszus.threshRatings.heat(trial); % last rated value is the pain threshold
        elseif ~preexPainful && ~any(P.awiszus.threshRatings.ratings) % not painful and no previous painful ratings
            P.awiszus.painThresholdFinal= P.awiszus.threshRatings.heat(trial); % last rated value is the pain threshold
        else
            lastPainful = find(P.awiszus.threshRatings.ratings,1,'last');
            P.awiszus.painThresholdFinal= P.awiszus.threshRatings.heat(lastPainful); % previous painful rated value
            %P.awiszus.painThresholdFinal(cuff) = P.awiszus.threshRatings.pressure(cuff,trial-1); % previous rated value from Awiszus (usually painful)
        end
        save(P.out.file.paramCalib,'P','O');
        fprintf(['\nPain threshold ' num2str(P.awiszus.painThresholdFinal) ' kPa\n\n']);

        break;
    end


end

end

end
