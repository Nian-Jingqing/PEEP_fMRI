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