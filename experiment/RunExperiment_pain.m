function [abort] = RunExperiment_pain(P,O,dev) % add dev!!!
% This function inititates alternating heat and pressure pain at different
% intensitiis (30,50,70 VAS).
%
% MRI pulses,events and button pressess will be logged.
%
% Author: Janne Nold
% based on the script by Björn Höring, Uli Bromberg Lukas Neugebauer
% Last modified: 02.12.21

abort = 0;
fprintf('\n==========================\nRunning Experiment.\n==========================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start Experiment. Send Trigger to SCR PC and logfile 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist(P.out.file.paramExp,'file')
    load(P.out.file.paramExp,'P');

else
    fprintf('No experimental parameters file loaded (BLOCK 1!)');
end
%% Retrieve predicted pressure intensity levels from calibration

% retrieve predicted pressures (linear)
% if isfield(P.pain.calibration.results.fitData,'predPressureLinear')
%     predPressure = P.pain.calibration.results.fitData.predPressureLinear;
%
%     % Load externat scrutcute for pressure pain here
% else
warning('No predicted pressures found, using DEFAULT instead');
predPressure = P.pain.calibration.defaultpredPressureLinear;
%end


% Medium Low Pressure
P.pain.PEEP.VASindex = P.pain.calibration.VASTargetsVisual == 30;
preVAS = predPressure(P.pain.PEEP.VASindex);
med_low_pressure = preVAS;

% Medium High Pressure
P.pain.PEEP.VASindex = P.pain.calibration.VASTargetsVisual == 50;
preVAS = predPressure(P.pain.PEEP.VASindex);
med_high_pressure = preVAS;

% High High Pressure
P.pain.PEEP.VASindex = P.pain.calibration.VASTargetsVisual == 70;
preVAS = predPressure(P.pain.PEEP.VASindex);
high_high_pressure = preVAS;


%% Retrieve predicted heat intensity levels from calibration

% retrieve predicted pressures (linear)
% if isfield(P.pain.calibration.thermode.results.fitData,'predHeatLinear')
%     predHeat = P.pain.calibration.thermode.results.fitData.predHeatLinear;

% Load predicted heat externatl strucutre here
%else
warning('No predicted Heat found, using DEFAULT instead');
predHeat = P.pain.calibration.defaultpredHeatLinear;
%end


% Medium Low Heat
P.pain.PEEP.thermode.VASindex = P.pain.calibration.VASTargetsVisual == 30;
preVAS = predHeat(P.pain.PEEP.thermode.VASindex);
med_low_heat = preVAS;

% Medium High Heat
P.pain.PEEP.thermode.VASindex = P.pain.calibration.VASTargetsVisual == 50;
preVAS = predHeat(P.pain.PEEP.thermode.VASindex);
med_high_heat = preVAS;

% High High Heat
P.pain.PEEP.thermode.VASindex = P.pain.calibration.VASTargetsVisual == 70;
preVAS = predHeat(P.pain.PEEP.thermode.VASindex);
high_high_heat = preVAS;



%% Run through exercise and pain blocks (4 blocks)
expVAS = [];

for block = P.pain.PEEP.block

    while ~abort

        % White Fixcross
        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            tCrossOn = Screen('Flip',P.display.w);
        else
            tCrossOn = GetSecs;
        end


        for cuff = P.experiment.cuff_arm

%             if ~O.debug.toggleVisual
%                 upperHalf = P.display.screenRes.height/2;
%                 Screen('TextSize', P.display.w, 70);
%                 introTextOn = Screen('Flip',P.display.w);
%             else
%                 introTextOn = GetSecs;
%             end


            % Abort Block if neccesary at start
            while GetSecs < introTextOn + 2 % make this longer to be able to interrupt if neccesary
                [abort]=LoopBreaker(P);
                if abort; break; end
            end



            %% ------------------ Pain ----------------------------

            % Gleich geht es weiter (show to participant)
            ShowIntroduction(P,5);

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

            % White Fixcross
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end

            ShowIntroduction(P,6);

            % Give two pre exposure stimuli Pressure
            fprintf('=========================================================\n');
            fprintf('\nPre Exposure: Pressure\n');
            fprintf('=========================================================\n');
            WaitSecs(2);

            PreExposure(P,O,dev);
            WaitSecs(0.5);

            % Give two pre exposure stimuli Heat
            fprintf('=========================================================\n');
            fprintf('\nPre Exposure: Heat\n');
            fprintf('=========================================================\n');

            [abort,~] = Preexposure_heat(P,O);
            WaitSecs(0.5);

            % -------------------------------------------------------------
            % Pain Block Start
            %--------------------------------------------------------------
            ShowIntroduction(P,61);

            % Display Exercise Start at experimenter screen
            fprintf('=========================================================\n');
            fprintf('\nPain Start\n');
            fprintf('=========================================================\n');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Start SCANNER HERE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
%             fprintf('\nContinue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
% 
%             while 1
%                 [keyIsDown, ~, keyCode] = KbCheck();
%                 if keyIsDown
%                     if find(keyCode) == P.keys.name.confirm
%                         break;
%                     elseif find(keyCode) == P.keys.name.esc
%                         abort = 1;
%                         break;
%                     end
%                 end
%             end
%             if abort; return; end

            %Gleich geht es weiter (show to participant)
            ShowIntroduction(P,5);
            WaitSecs(5);

            % ------------------------------------
            % WAIT DUMMY SCANS
            %--------------------------------------

            % Wait for 5 scanner pulses
            [t0_scan,secs] = wait_dummy_scans(P);

            KbQueueRelease(); % to make sure
            KbQueueCreate();
            KbQueueStart();

            % ------------------------------------
            % Log Time in struct
            % ------------------------------------
            P.mri.mriExpStart = GetSecs;
            P.mri.mriBlockStart(block) = GetSecs;
         
            % Loop through the number of pain trials per block
            clear trial

            for trial = 1:P.pain.PEEP.trialsPerBlock

                % Get timing for trial Start
                P.mri.mriTrialStart(trial) = GetSecs;

                fprintf('\n\n======= BLOCK %d, PAIN TRIAL %d =======\n',block,trial);

                % retrieve pressure intensitiy from matrix according to level (3,5,7)

                if strcmp(P.pain.PEEP.painconditions_mat(block,trial) , "3_1") % mid low intensity pressure

                    %retrieve pressure calibrated for 30 VAS
                    pressure = med_low_pressure;
                    mod = 1;
                    fprintf(['\nPain: Medium-Low Intensity 30 VAS at ',num2str(pressure), ' kPa\n']);

                elseif strcmp(P.pain.PEEP.painconditions_mat(block,trial) , "5_1") % mid high intensity pressure

                    %retrieve pressure calibrated for 50 VAS
                    pressure = med_high_pressure;
                    mod = 1;
                    fprintf(['\nPain: Medium-High Intensity 50 VAS at ',num2str(pressure), ' kPa\n']);

                elseif strcmp(P.pain.PEEP.painconditions_mat(block,trial) , "7_1") % high high intensity pressure

                    %retrieve pressure calibrated for 70 VAS
                    pressure = high_high_pressure;
                    mod = 1;
                    fprintf(['\nPain: High-High Intensity 70 VAS at ',num2str(pressure), ' kPa\n']);

                elseif strcmp(P.pain.PEEP.painconditions_mat(block,trial) , "3_2") % mid high intensity pressure

                    %retrieve heat calibrated for 30 VAS
                    heat = med_low_heat;
                    mod = 2;
                    fprintf(['\nPain: Medium-High Intensity 30 VAS at ',num2str(heat), ' °C\n']);

                elseif strcmp(P.pain.PEEP.painconditions_mat(block,trial) , "5_2") % high high intensity pressure

                    %retrieve heat calibrated for 50 VAS
                    heat = med_high_heat;
                    mod = 2;
                    fprintf(['\nPain: Med-High Intensity 50 VAS at ',num2str(heat), ' °C\n']);

                elseif strcmp(P.pain.PEEP.painconditions_mat(block,trial) , "7_2") % high high intensity pressure

                    %retrieve heat calibrated for 70 VAS
                    heat = high_high_heat;
                    mod = 2;
                    fprintf(['\nPain: High-High Intensity 70 VAS at ',num2str(heat), ' °C\n']);

                end

                % Red fixation cross
                if ~O.debug.toggleVisual
                    Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
                    Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
                    red_fix_on = Screen('Flip',P.display.w);
                end

                %P = log_all_event(P, red_fix_on, 'red_cross_on',trial);

                % --------------------------------
                % Select which pain and apply
                % ---------------------------------
                if mod == 1 % Pressure Pain
                    [abort,P,expVAS] = ApplyStimulusPain(P,O,pressure,cuff,block,trial,expVAS,mod);

                   
                elseif mod == 2 % Heat Pain
                    [abort,P,expVAS] = ApplyStimulusPain_heat(P,O,heat,block,trial,expVAS,mod);
                end

                if abort; break; end

                % --------------------------------
                % Log rating and event
                % ---------------------------------
                P = log_event(P,trial,expVAS(block).block(trial).trial(2).ratingsection.modality,intensity_VAS, ...
                    expVAS(block).block(trial).trial(2).ratingsection.trialInt,expVAS(block).block(trial).trial(2).ratingsection.response,resp_onset, ...
                    expVAS(block).block(trial).trial(2).ratingsection.finalRating,expVAS(block).block(trial).trial(2).ratingsection.reactionTime);

                % White fixation cross
                if ~O.debug.toggleVisual
                    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                    tCrossOn = Screen('Flip',P.display.w);
                else
                    tCrossOn = GetSecs;
                end

                % Save instantiated parameters and overrides after each trial
                save(P.out.file.paramExp,'P','O');

                %------------------------------------------
                % Log MRI triggers and button presses
                % -------------------------------------
                P = log_pulses_buttons(P,t0_scan,trial);
               
                % ------------------------------------------
                % Log events and button presses
                % -----------------------------------------
                 KbQueueRelease(); % essential or KbTriggerWait below won't work


                % Wait for xx ITI before continuing
                iti = P.project.ITI_rand(P.project.ITI_start);
                fprintf(['\nITI: ',num2str(iti), ' seconds'])
                WaitSecs(iti);
                tITIafterRating = GetSecs;

                % Calculate ITI after 7 sec rating:
                tITI = tITIafterRating - tCrossOn;
                P.experiment.tITI(block,trial) = tITI;

                % update trial counter
                P.project.ITI_start = P.project.ITI_start + 1;
                trial = trial + 1;

                
            end



        end

        %display fixation cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);
        WaitSecs(1);


        P.pain.PEEP.block = P.pain.PEEP.block + 1;
        save(P.out.file.paramExp,'P','O');

        % Update Block number for each run
        if P.pain.PEEP.block > 4
            abort = 1;
            break;
        end

        return;

    end % for while loop

end %for block

end % for function











