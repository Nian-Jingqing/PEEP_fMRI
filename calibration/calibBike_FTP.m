%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calibration Bike based on functional threshold power (FTP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [FTP,P] = calibBike_FTP(P,O,bike,belt)
% The functional threshold power test (based on Allen and Coggan, 2010;
% applied by Valenzuela et al., 2018)
% is a value that indicates the anaerob
% threshold and provides the needed wattage and target HR for different intensity zones
% which someone has to maintain to stay below that threshold.
% Here we use the short 20 - minute version which incorporates different
% steps:

%-----------------------------------------------------------------------
% Step 1: 20-minutes Light warm up pedaling at 100 Watt
% Step 2: 3 x 1-minute effort at 100 RPM (1 minute revoery light pedaling
% in between)
% Step 3: 5 minute all out
% Step 4: 10 minutes light pedaling at 100 Watt
% Step 5: 20 minute all out (MAIN!)
% Step 6: Cool Down
%----------------------------------------------------------------------

% Input:
% P, O : Paramters
% bike: BLE device bike ergometer
% belt: BLE device heart rate

% Output:
% FTP: 95% of 20 minute test, Wattage that should be upheld in main test
% P: Paramters
% Other FTP values and levels

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define output file
FTPfile = fullfile(P.out.dirCalib, [P.out.file.FTP '_FTP.mat']);

% add to existing VAS file
if exist(FTPfile,'file')
    FTPdata = load(FTPfile);
    FTP_calib = FTPdata.FTP_calib;
end

% set textsize for screen
Screen('Textsize',P.display.w,100);

% set the bike to be a global variable
global bike belt

% Get bike characteristics
charac = bike.Characteristics;
charac_belt = belt.Characteristics;

% Extract the Power Measure
FTP_power_measure = characteristic(bike,"Cycling Power","Cycling Power Measurement");
FTP_hr_measure = characteristic(belt, "heart rate", "heart rate measurement");


abort = 0;
while ~abort

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Estimated Watt and HR according to age
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Calculate estimated Watt depending on Age and different levels of
    % exercise to give participant an idea about what they should be able to
    % do. HR calculation based on Tanaka et al. 2001 HRmax = 208- 0.7 * age

    % Get user input for HR rest
    P.exercise.HRrest = input("\nHR rest: ");
    P.exercise.HRmax = 208 - (0.7*P.subject.age);

    % Calculate theoretical 70% of HR max based on formula by Karvonen et
    % al. (1957) used by Naugle et al. (2014) to determine 70% of max HR for
    % endurance
    P.exercise.targetHR_theoretical = ((220 - P.subject.age) - P.exercise.HRrest) .* 0.7 + P.exercise.HRrest;


    % Wait for input from experiment to continue
    fprintf(['HRmax: ',num2str(P.exercise.HRmax),' bpm\n Target HR:',num2str(P.exercise.targetHR_theoretical),' \nGender: ',P.subject.gender,'\n Age: ',num2str(P.subject.age),'\n CONFIRM or ABORT\n']);
    WaitSecs(0.2);

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





    %% -------------- Step 1: 20 minutes light pedaling at 100 Watt----------

    % Display to participant what is happening
    DrawFormattedText(P.display.w, 'Schritt 1: Entspannt fahren\n\n20 Minuten\n\n~100 Watt', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    % Wait for input from experiment to continue
    fprintf('\nStep 1: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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



    % Set countdowm for 20 minute light cycling
    clear cyclesSecs
    cyclesSecs = [sort(repmat(1:P.FTP.parameters.step1.length*60, 1), 'descend') 0];

    % Set time to 0
    time = 0;
    tic

    % Here is our drawing loop
    for i = 1:length(cyclesSecs)

        if cyclesSecs(i) == 0
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                cross_on_after = Screen('Flip',P.display.w);

            end
            WaitSecs(2);

            break;

        end

        % continously read out power(and potentially other measures)
        data = read(FTP_power_measure);

        % continously read out HR
        data_hr = read(FTP_hr_measure);

        % identify value format for HR data and convert accordingly
        flag = uint8(data_hr(1));
        heartRateValueFormat = bitget(flag, 1);
        if heartRateValueFormat == 0
            % Heart rate format is uint8
            heartRate = data_hr(2);
        else
            % Heart rate format is uint16
            heartRate = double(typecast(uint8(data_hr(2:3)), 'uint16'));
        end

        % extract instant power and convert to uint16
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

        % Print Power to experimeter
        fprintf('Instantaneous power: %.2f watt, HR: %.2f\n', instantpower,heartRate);

        % save extracted power for according timepoints
        P.FTP.step1(i).power= instantpower;
        P.FTP.step1(i).HR = heartRate;
        P.FTP.step1(i).time = time;

        % save to saving structure
        FTP_calib.step1(i).power = instantpower;
        FTP_calib.step1(i).HR = heartRate;
        FTP_calib.step1(i).time = time;

        % smooth power display with previous 3 powers
        if i > 3
            instantpower_smoothed = (FTP_calib.step1(i).power  ...
                + FTP_calib.step1(i-1).power  ...
                + FTP_calib.step1(i-2).power) /3;
        else
            instantpower_smoothed = instantpower;
        end

        % Convert current power to string
        numberString = num2str(instantpower_smoothed,'%.0f');

        % Convert our current number to display into a string
        numberString2 = num2str(cyclesSecs(i));
        numberString3 = num2str(heartRate);

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);
        DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt (~100 Watt)'], 'center',P.display.screenYpixels * 0.8 , P.style.white);
        DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);


        % Show fixation Cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);


        WaitSecs(1);

        % update counter
        i = i + 1;

        % Update the time based on toc
        time = toc;
    end


    %% Saving Results Step 1

    % save parameters after each step
    save(P.out.file.paramCalib, 'P', 'O');

    % save file as mat
    save(FTPfile, 'FTP_calib');

    % clear all parameters for next step
    clear instantpower_smoothed
    clear heartRate
    clear instantpower
    clear time
    clear cyclesSecs

    %% ------------Step 2: 3 x 1 minute 100 RPM ( 1min recovery in between)-----------

    % Display what is happening
    DrawFormattedText(P.display.w, 'Schritt 2: 3 x 1 Minute "All-out"', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    % give experimenter chance to continue
    fprintf('\nStep 2: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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

    % Set countdowm for 3 x 1 minute intense cylcing
    cyclesSecs = [sort(repmat(1:P.FTP.parameters.step2.length_cycle*60, 1), 'descend') 0];
    recoverySecs = [sort(repmat(1:P.FTP.parameters.step2.length_recov*60, 1), 'descend') 0];

    for nTrials = 1:P.FTP.parameters.step2.nTrials

        % Set time to 0
        time = 0;
        tic

        if mod(nTrials,2) == 1

            % Here is our drawing loop
            for i = 1:length(cyclesSecs)

                if cyclesSecs(i) == 0
                    if ~O.debug.toggleVisual
                        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                        cross_on_after = Screen('Flip',P.display.w);

                    end
                    WaitSecs(2);

                    break;

                end

                % continously read out power(and potentially other measures)
                data = read(FTP_power_measure);

                % continously read out HR
                data_hr = read(FTP_hr_measure);

                % identify value format for HR data and convert accordingly
                flag = uint8(data_hr(1));
                heartRateValueFormat = bitget(flag, 1);
                if heartRateValueFormat == 0
                    % Heart rate format is uint8
                    heartRate = data_hr(2);
                else
                    % Heart rate format is uint16
                    heartRate = double(typecast(uint8(data_hr(2:3)), 'uint16'));
                end


                % extract instant power and convert to uint16
                instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

                % Print Power to experimeter
                fprintf('Instantaneous power: %.2f watt, HR: %.2f\n', instantpower,heartRate);

                % save extracted power for according timepoints
                P.FTP.step2(nTrials).trial(i).power= instantpower;
                P.FTP.step2(nTrials).trial(i).HR = heartRate;
                P.FTP.step2(nTrials).trial(i).time = time;

                % save to saving structure
                FTP_calib.step2(nTrials).trial(i).power = instantpower;
                FTP_calib.step2(nTrials).trial(i).HR = heartRate;
                FTP_calib.step2(nTrials).trial(i).time = time;

                % smooth power display with previous 3 powers
                if i > 3
                    instantpower_smoothed = (FTP_calib.step2(nTrials).trial(i).power  ...
                        + FTP_calib.step2(nTrials).trial(i-1).power  ...
                        + FTP_calib.step2(nTrials).trial(i-2).power) /3;
                else
                    instantpower_smoothed = instantpower;
                end

                % Convert current power to string
                numberString = num2str(instantpower_smoothed,'%.0f');

                % Convert our current number to display into a string
                numberString2 = num2str(cyclesSecs(i));
                numberString3 = num2str(heartRate);

                % Draw our number to the screen
                DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.red);
                DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt, gib alles!'], 'center',P.display.screenYpixels * 0.8 , P.style.red);
                DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.red);

                % Show fixation Cross
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                Screen('Flip',P.display.w);

                WaitSecs(1);

                % update counter
                i = i + 1;

                % Update the time based on toc
                time = toc;
            end

        else  % Recovery

            % Here is our drawing loop
            for i = 1:length(recoverySecs)

                if recoverySecs(i) == 0
                    if ~O.debug.toggleVisual
                        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                        cross_on_after = Screen('Flip',P.display.w);

                    end
                    WaitSecs(2);

                    break;

                end

                % continously read out power(and potentially other measures)
                data = read(FTP_power_measure);

                % continously read out HR
                data_hr = read(FTP_hr_measure);

                % identify value format for HR data and convert accordingly
                flag = uint8(data_hr(1));
                heartRateValueFormat = bitget(flag, 1);
                if heartRateValueFormat == 0
                    % Heart rate format is uint8
                    heartRate = data_hr(2);
                else
                    % Heart rate format is uint16
                    heartRate = double(typecast(uint8(data_hr(2:3)), 'uint16'));
                end


                % extract instant power and convert to uint16
                instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

                % Print Power to experimeter
                fprintf('Instantaneous power: %.2f watt, HR: %.2f\n', instantpower,heartRate);

                % save extracted power for according timepoints
                P.FTP.step2(nTrials).trial(i).power= instantpower;
                P.FTP.step2(nTrials).trial(i).HR = heartRate;
                P.FTP.step2(nTrials).trial(i).time = time;

                % save to saving structure
                FTP_calib.step2(nTrials).trial(i).power = instantpower;
                FTP_calib.step2(nTrials).trial(i).HR = heartRate;
                FTP_calib.step2(nTrials).trial(i).time = time;

                % smooth power display with previous 3 powers
                if i > 3
                    instantpower_smoothed = (FTP_calib.step2(nTrials).trial(i).power  ...
                        + FTP_calib.step2(nTrials).trial(i-1).power  ...
                        + FTP_calib.step2(nTrials).trial(i-2).power) /3;
                else
                    instantpower_smoothed = instantpower;
                end

                % Convert current power to string
                numberString = num2str(instantpower_smoothed,'%.0f');

                % Convert our current number to display into a string
                numberString2 = num2str(recoverySecs(i));
                numberString3 = num2str(heartRate);

                % Draw our number to the screen
                DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);
                DrawFormattedText(P.display.w, 'Erholung/Pause! ', 'center',P.display.screenYpixels * 0.8 , P.style.white);
                DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);

                % Show fixation Cross
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                Screen('Flip',P.display.w);

                WaitSecs(1);

                % update counter
                i = i + 1;

                % Update the time based on toc
                time = toc;


            end

        end
    end


    %% Saving Results Step 2

    % save parameters after each step
    save(P.out.file.paramCalib, 'P', 'O');

    % save file as mat
    save(FTPfile, 'FTP_calib');

    % clear variables for next step
    clear instantpower_smoothed
    clear heartRate
    clear instantpower
    clear time
    clear cyclesSecs


    %% ---------------  Step 3: 5 min all out-----------------------------------

    % Display to participant what is happening
    DrawFormattedText(P.display.w, 'Schritt 3: "All-out"\n\n5 Minuten', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    fprintf('\nStep 3: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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

    % Set countdowm for 5 min all out
    cyclesSecs = [sort(repmat(1:P.FTP.parameters.step3.length_allout*60, 1), 'descend') 0];

    % Set time to 0
    time = 0;
    tic

    % Here is our drawing loop
    for i = 1:length(cyclesSecs)

        if cyclesSecs(i) == 0
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                cross_on_after = Screen('Flip',P.display.w);

            end
            WaitSecs(2);

            break;

        end

        % continously read out power(and potentially other measures)
        data = read(FTP_power_measure);

        % continously read out HR
        data_hr = read(FTP_hr_measure);

        % identify value format for HR data and convert accordingly
        flag = uint8(data_hr(1));
        heartRateValueFormat = bitget(flag, 1);

        if heartRateValueFormat == 0
            % Heart rate format is uint8
            heartRate = data_hr(2);
        else
            % Heart rate format is uint16
            heartRate = double(typecast(uint8(data_hr(2:3)), 'uint16'));
        end

        % extract instant power and converst to uint16
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

        % Print Power to experimeter
        fprintf('Instantaneous power: %.2f watt, HR: %.2f\n', instantpower,heartRate);

        % save extracted power for according timepoints
        P.FTP.step3(i).power= instantpower;
        P.FTP.step3(i).HR = heartRate;
        P.FTP.step3(i).time = time;

        % save to saving structure
        FTP_calib.step3(i).power = instantpower;
        FTP_calib.step3(i).HR = heartRate;
        FTP_calib.step3(i).time = time;

        % smooth power display with previous 3 powers
        if i > 3
            instantpower_smoothed = (FTP_calib.step3(i).power  ...
                + FTP_calib.step3(i-1).power  ...
                + FTP_calib.step3(i-2).power) /3;
        else
            instantpower_smoothed = instantpower;
        end

        % Convert current power to string
        numberString = num2str(instantpower_smoothed,'%.0f');

        % Convert our current number to display into a string
        numberString2 = num2str(cyclesSecs(i));
        numberString3 = num2str(heartRate);

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.red);
        DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt, gib alles!'], 'center',P.display.screenYpixels * 0.8 , P.style.red);
        DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.red);

        % Show fixation Cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);

        WaitSecs(0.9);

        % update counter
        i = i + 1;

        % Update the time based on toc
        time = toc;
    end

    %% Saving Results Step 3

    % save parameters after each step
    save(P.out.file.paramCalib, 'P', 'O');

    % save file as mat
    save(FTPfile, 'FTP_calib');

    % clear variables for next step
    clear instantpower_smoothed
    clear heartRate
    clear instantpower
    clear time
    clear cyclesSecs

    %% --------------------- Step 4: 10 minutes light pedaling---------------------

    % Display to participant what is happening
    DrawFormattedText(P.display.w, 'Schritt 4: Entspannt fahren\n\n10 Minuten\n\n~100 Watt', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    % Continue or abort
    fprintf('\nStep 4: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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

    % Set countdowm for 5 minute cycling
    cyclesSecs = [sort(repmat(1:P.FTP.parameters.step4.length*60, 1), 'descend') 0];

    % Set time to 0
    time = 0;
    tic

    % Here is our drawing loop
    for i = 1:length(cyclesSecs)

        if cyclesSecs(i) == 0
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                cross_on_after = Screen('Flip',P.display.w);

            end
            WaitSecs(2);
            break;
        end

        % continously read out power(and potentially other measures)
        data = read(FTP_power_measure);

        % continously read out HR
        data_hr = read(FTP_hr_measure);

        % identify value format for HR data and convert accordingly
        flag = uint8(data_hr(1));
        heartRateValueFormat = bitget(flag, 1);

        if heartRateValueFormat == 0
            % Heart rate format is uint8
            heartRate = data_hr(2);
        else
            % Heart rate format is uint16
            heartRate = double(typecast(uint8(data_hr(2:3)), 'uint16'));
        end

        % extract instant power and converst to uint16
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

        % Print Power to experimeter
        fprintf('Instantaneous power: %.2f watt, HR: %.2f\n', instantpower,heartRate);

        % save extracted power for according timepoints
        P.FTP.step4(i).power= instantpower;
        P.FTP.step4(i).HR = heartRate;
        P.FTP.step4(i).time = time;

        % save to saving structure
        FTP_calib.step4(i).power = instantpower;
        FTP_calib.step4(i).HR = heartRate;
        FTP_calib.step4(i).time = time;

        % smooth power display with previous 3 powers
        if i > 3
            instantpower_smoothed = (FTP_calib.step4(i).power  ...
                + FTP_calib.step4(i-1).power  ...
                + FTP_calib.step4(i-2).power) /3;
        else
            instantpower_smoothed = instantpower;
        end

        % Convert current power to string
        numberString = num2str(instantpower_smoothed,'%.0f');

        % Convert our current number to display into a string
        numberString2 = num2str(cyclesSecs(i));
        numberString3 = num2str(heartRate);

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);
        DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt (~100 Watt)'], 'center',P.display.screenYpixels * 0.8 , P.style.white);
        DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);

        % Show fixation Cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);

        WaitSecs(0.9);

        % update counter
        i = i + 1;

        % Update the time based on toc
        time = toc;

    end


    %% Saving Results Step 4

    % save parameters after each step
    save(P.out.file.paramCalib, 'P', 'O');

    % save file as mat
    save(FTPfile, 'FTP_calib');


    % clear variables for next step
    clear instantpower_smoothed
    clear heartRate
    clear instantpower
    clear time
    clear cyclesSecs

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Main: 20 minutes all out
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Display to participant what is happening
    DrawFormattedText(P.display.w, 'Schritt 5: Hauptteil\n\n"All-out"\n\n20Minuten', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    % Continue or abort input
    fprintf('\nMain: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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

    Screen('Flip',P.display.w);

    % Set countdowm for 20 minute cycling
    cyclesSecs = [sort(repmat(1:P.FTP.parameters.step5.length_allout*60, 1), 'descend') 0];

    % Set time to 0
    time = 0;
    tic

    % Here is our drawing loop
    for i = 1:length(cyclesSecs)

        if cyclesSecs(i) == 0
            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                cross_on_after = Screen('Flip',P.display.w);
            end
            WaitSecs(2);

            break;
        end

        % continously read out power(and potentially other measures)
        data = read(FTP_power_measure);

        % continously read out HR
        data_hr = read(FTP_hr_measure);

        % identify value format for HR data and convert accordingly
        flag = uint8(data_hr(1));
        heartRateValueFormat = bitget(flag, 1);

        if heartRateValueFormat == 0
            % Heart rate format is uint8
            heartRate = data_hr(2);
        else
            % Heart rate format is uint16
            heartRate = double(typecast(uint8(data_hr(2:3)), 'uint16'));
        end

        % extract instant power and converst to uint16
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

        % Print Power to experimeter
        fprintf('Instantaneous power: %.2f watt, HR: %.2f\n', instantpower,heartRate);

        % save extracted power for according timepoints
        P.FTP.step5(i).power= instantpower;
        P.FTP.step5(i).HR = heartRate;
        P.FTP.step5(i).time = time;

        % save to saving structure
        FTP_calib.step5(i).power = instantpower;
        FTP_calib.step5(i).HR = heartRate;
        FTP_calib.step5(i).time = time;

        % smooth power display with previous 3 powers
        if i > 3
            instantpower_smoothed = (FTP_calib.step5(i).power  ...
                + FTP_calib.step5(i-1).power  ...
                + FTP_calib.step5(i-2).power) /3;
        else
            instantpower_smoothed = instantpower;
        end

        % Convert current power to string
        numberString = num2str(instantpower_smoothed,'%.0f');

        % Convert our current number to display into a string
        numberString2 = num2str(cyclesSecs(i));
        numberString3 = num2str(heartRate);

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.red);
        DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt'], 'center',P.display.screenYpixels * 0.8 , P.style.red);
        DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.red);

        % Show fixation Cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);

        WaitSecs(0.9);

        % update counter
        i = i + 1;

        % Update the time based on toc
        time = toc;

    end

    %% Saving Results Main All out
    % save parameters after each step
    save(P.out.file.paramCalib, 'P', 'O');

    % save file as mat
    save(FTPfile, 'FTP_calib');

    % Calculate FTP: 95% of average power of 20 minutes all out
    P.FTP.results.threshold_power = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.95;
    P.FTP.results.mean_power = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5));
    FTP = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.95;
    P.FTP.results.target_HR =  [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.95,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*1.05];

    %Calculate Zones for HR and FTP (based on https://www.bikeradar.com/advice/fitness-and-training/training-zones/)
    P.FTP.results.zones.level1_AR = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.55;
    P.FTP.results.zones.level2_endurance = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.56,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.75];
    P.FTP.results.zones.level3_tempo =  [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.76,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.90];
    P.FTP.results.zones.level4_threshold = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.91,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.06];
    P.FTP.results.zones.level5_VO2max = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.06,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.20];
    P.FTP.results.zones.level6_AnCap = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.21,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.50];
    P.FTP.results.zones.level7 = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.51;

    % retrieve target HR for different power zones
    P.FTP.results.hr_zones.level1_AR = (sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.68;
    P.FTP.results.hr_zones.level2_endurance = [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.69,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.83];
    P.FTP.results.hr_zones.level3_tempo =  [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.84,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.94];
    P.FTP.results.hr_zones.level4_threshold =  [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.95,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*1.05];
    P.FTP.results.hr_zones.level5_VO2max = (sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*1.06;

    save(P.out.file.paramCalib, 'P', 'O');


    % save in FTP_calib_file
    % Calculate FTP: 95% of average power of 20 minutes all out
    FTP_calib.results.threshold_power = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.95;
    FTP_calib.results.mean_power = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5));
    FTP = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.95;
    FTP_calib.results.target_HR =  [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.95,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*1.05];

    %Calculate Zones for HR and FTP (based on https://www.bikeradar.com/advice/fitness-and-training/training-zones/)
    FTP_calib.results.zones.level1_AR = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.55;
    FTP_calib.results.zones.level2_endurance = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.56,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.75];
    FTP_calib.results.zones.level3_tempo =  [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.76,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.90];
    FTP_calib.results.zones.level4_threshold = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*0.91,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.06];
    FTP_calib.results.zones.level5_VO2max = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.06,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.20];
    FTP_calib.results.zones.level6_AnCap = [(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.21,(sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.50];
    FTP_calib.results.zones.level7 = (sum(cat(1,FTP_calib.step5.power))/length(FTP_calib.step5))*1.51;

    % retrieve target HR for different power zones
    FTP_calib.results.hr_zones.level1_AR = (sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.68;
    FTP_calib.results.hr_zones.level2_endurance = [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.69,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.83];
    FTP_calib.results.hr_zones.level3_tempo =  [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.84,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.94];
    FTP_calib.results.hr_zones.level4_threshold =  [(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*0.95,(sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*1.05];
    FTP_calib.results.hr_zones.level5_VO2max = (sum(cat(1,FTP_calib.step5.HR))/length(FTP_calib.step5))*1.06;
    
    % save file as mat
    save(FTPfile, 'FTP_calib');

    %% Cool Down

    % Display to participant what is happening
    DrawFormattedText(P.display.w, 'Schritt 6: Cool Down!', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    % Continue or abort input
    fprintf('\nCool Down: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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

    % Show fixation cross
    DrawFormattedText(P.display.w, 'Cool Down!', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    cross_on_after = Screen('Flip',P.display.w);

    WaitSecs(P.FTP.parameters.coolDown);
    fprintf('\nCalibration Bike finished. \n');
    sca;
    return;



end


clear bike
clear belt
end

