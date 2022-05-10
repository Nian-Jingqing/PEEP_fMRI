function [P,O] = WarmUp(P,O,bike,belt)

global bike belt

% Get bike characteristics
charac = bike.Characteristics;
charac_belt = belt.Characteristics;

% Extract the Power Measure
power_measure = characteristic(bike,"Cycling Power","Cycling Power Measurement");
hr_measure = characteristic(belt, "heart rate", "heart rate measurement");

abort = 0;
while ~abort
    %% --------------- Warm-up 10 Minute Main experiment --------------------

    % set textsize for screen
    Screen('Textsize',P.display.w,100);

    % Display to participant what is happening
    DrawFormattedText(P.display.w, 'Einfahren \n\n10 Minuten\n\n~100 Watt', 'center', P.display.screenYpixels * 0.25, P.style.white);
    Screen('Flip',P.display.w);

    % Wait for input from experiment to continue
    fprintf('\nWarm-up: Continue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));
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



    % Set countdowm for 10 minute light cycling
    cyclesSecs = [sort(repmat(1:600, 1), 'descend') 0];


    i = 1;
    tstartWarmup = GetSecs;

    while GetSecs < tstartWarmup + length(cyclesSecs)


        % continously read out power(and potentially other measures)
        data = read(power_measure);
        data_hr = read(hr_measure);

        % extract instant power and convert to uint16
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

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


        % Print Power to experimeter
        fprintf('\nInstantaneous power: %.2f watt, HR: %.2f', instantpower,heartRate);

        % save warmup data
        P.warmup(i).power= instantpower;
        P.warmup(i).hr = heartRate;

        % smooth power display with previous 3 powers
        if i > 3
            instantpower_smoothed = (P.warmup(i).power  ...
                + P.warmup(i-1).power  ...
                + P.warmup(i-2).power) /3;
        else
            instantpower_smoothed = instantpower;
        end

        % Convert current power to string
        numberString = num2str(instantpower_smoothed,'%.0f');
        numberString2 = num2str(cyclesSecs(i));
        numberString3 = num2str(heartRate);

        % Draw our number to the screen
        % include 60 seconds of intense cycling after 5 minutes and 7
        % minutes warm up
        if cyclesSecs(i) <= 300 && cyclesSecs(i) >= 240 %after 5 minutes of cycling
            DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.red);
            DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt (~100 Watt)'], 'center',P.display.screenYpixels * 0.8 , P.style.red);
            DrawFormattedText(P.display.w, ['HR: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.red);


        elseif cyclesSecs(i) <= 180 && cyclesSecs(i) >= 120 % after 7 minutes of cycling
            DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.red);
            DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt (~100 Watt)'], 'center',P.display.screenYpixels * 0.8 , P.style.red);
            DrawFormattedText(P.display.w, ['HR: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.red);


        else % show in white for the remaining time 
            DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);
            DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt (~100 Watt)'], 'center',P.display.screenYpixels * 0.8 , P.style.white);
            DrawFormattedText(P.display.w, ['HR: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);
        end

        % Show fixation Cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);

        WaitSecs(0.98);

        % update counter
        i = i + 1;


    end

    save(P.out.file.paramCalib, 'P', 'O');
    %     fprintf('\nWARM-UP and Pre exposure finished. \n');
    %     sca;
    return;
end

end

