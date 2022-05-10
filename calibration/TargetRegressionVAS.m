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