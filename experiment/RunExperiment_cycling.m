function [abort] = RunExperiment_cycling(P,O)
% This function inititates the 10 minute cycling on screen with a fixation
% cross a countdown (600 - 0). It will not have any output apart from
% the seconds the exercise lasted.
%
% Author: Janne Nold
% based on the script by Björn Höring, Uli Bromberg, Lukas Neugebauer
% Last modified: 02.12.21

% Retrieve text
strings = GetText;
abort = 0;
fprintf('\n==========================\nRunning Experiment.\n==========================\n');


%% Run through exercise and pain blocks (6 blocks)
expVAS = [];
exerciseVAS = [];

ShowIntroduction(P,4);

for block = P.pain.PEEP.cyclingBlock

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

            fprintf(['Block ' num2str(P.pain.PEEP.blocks(block))]);

            if ~O.debug.toggleVisual
                upperHalf = P.display.screenRes.height/2;
                Screen('TextSize', P.display.w, 70);

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


            %% ------------------Exercise -----------------------------

            if ~O.debug.toggleVisual
                upperHalf = P.display.screenRes.height/2;
                Screen('TextSize', P.display.w, 100);

                % Display on screen which arm and what is happening
                if strcmp(P.language,'de')
                    [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Block ' num2str(P.pain.PEEP.blocks(block))], 'center', upperHalf, P.style.white);
                    Screen('Flip',P.display.w);
                    WaitSecs(3);

                    % Display to participant whether high or low intensity
                    % cycling
                    if P.exercise.condition(block) == 1
                        int = 1;

                        % save the condition in log file
                        P.exercise.results(block).condition = 1;
                        [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w,'Hohe Intensität', 'center', upperHalf, P.style.white);

                    elseif P.exercise.condition(block) == 0
                        int = 0;

                        % save the condition in log file
                        P.exercise.results(block).condition = 0;
                        [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, 'Niedrige Intensität', 'center', upperHalf, P.style.white);

                    end
                    Screen('Flip',P.display.w);
                    WaitSecs(3);
                end

                Screen('TextSize', P.display.w, 30);
                introTextOn = Screen('Flip',P.display.w);

            end

            % Ready... Exercise Intro
            Screen('TextSize',P.display.w, 50);
            DrawFormattedText(P.display.w, strings.exercise1, 'center', 'center',P.style.white2,[],[],[],2,[]);
            Screen('Flip',P.display.w);

            tWaitCycle = GetSecs;

            % Wait 5 Seconds before starting the cycling
            countedDown = 1;
            while GetSecs < tWaitCycle + P.exercise.wait
                tmp=num2str(SecureRound(GetSecs-tWaitCycle,0));
                [abort,countedDown] = CountDown(P,GetSecs-tWaitCycle,countedDown,[tmp ' ']);
                if abort; break; end
            end


            % Run Countdown for participant (3...2...1..0... Los!)
            fprintf('\nRunning Countdown....\n');
            RunCountDown(P);
            Screen('Flip',P.display.w);


            % Display Exercise Start at experimenter screen
            fprintf('=========================================================\n');
            fprintf('Exercise Start\n');
            fprintf('=========================================================\n');

            % Get Timing
            tStartCycle = GetSecs;
            P.time.startCycle(block) = tStartCycle - P.time.scriptStart;

            % Apply Exercise Stimulus
            [abort,P,exerciseVAS] = ApplyStimulusExercise(P,O,P.exercise.constPressure,cuff,block,exerciseVAS,int); % run stimulus
            save(P.out.file.paramExp,'P','O'); % Save instantiated parameters and overrides after each trial (includes timing information)
            if abort; break; end

            % Get the end time of exercise block
            tEndCycle = GetSecs;
            P.time.tEndCycle(block) = tEndCycle - P.time.scriptStart;
            %
            %              % Update Block Number
            %              P.pain.PEEP.cyclingBlock = P.pain.PEEP.cyclingBlock + 1;
            %              save(P.out.file.paramExp,'P','O');


            if abort; break; end


            %% Pause/Interval



            %display fixation cross
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            Screen('Flip',P.display.w);
            WaitSecs(1);


            if block > 4
                abort = 1;
                break;
            end


        end


    end
end

end











