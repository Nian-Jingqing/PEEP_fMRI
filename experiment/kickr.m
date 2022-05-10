function [P] = kickr(P,O,block,int)
% This function extracts the power (and potentially other important
% features) from the wahoo KICKR bike while. Also, it displays the instant
% power (watt) on the screen along with the remaining seconds of cycling.

%% Settings
% define output file
exerciseFile = fullfile(P.out.dirExp, [P.out.file.BIKE '_exercise_power.mat']);
exerciseFile2 = fullfile(P.out.dirExp, [P.out.file.BIKE '_exercise_all_data.mat']);
%exerciseFile = fullfile(P.out.dirExp, [P.out.file.VAS '_exercise_power.mat']);
%exerciseFile2 = fullfile(P.out.dirExp, [P.out.file.VAS '_exercise_all_data.mat']);


% add to existing VAS file
if exist(exerciseFile,'file')
    VASData = load(exerciseFile);
    exercise_power = VASData.exercise_power;
end

% add to existing VAS file
if exist(exerciseFile2,'file')
    VASData = load(exerciseFile2);
    exercise_all_data = VASData.exercise_all_data;
end

% Set Screen Textsize
Screen('Textsize',P.display.w,100);

% set the bike to be a global variable
global bike belt

% Get bike characteristics
charac = bike.Characteristics;
charac_belt = belt.Characteristics;

% Extract the Power Measure
power_measure = characteristic(bike,"Cycling Power","Cycling Power Measurement");
hr_measure = characteristic(belt, "heart rate", "heart rate measurement");

% Create a figure of cycling power against time
figure
axPower = axes('XLim', [0, P.exercise.duration], 'YLim', [0, 500]);
xlabel(axPower, 'time');
ylabel(axPower, 'Power (W)/Heart Rate (bpm)');
title(['Subject: ',num2str(P.protocol.subID),' Block: ',num2str(block)])
hPower = animatedline(axPower, 'Marker', 'o', 'MarkerFaceColor', 'blue');
hHeartRate = animatedline(axPower, 'Marker', 'o', 'MarkerFaceColor', 'red');

% Set countdowm for 300 seconds (5 minute) cycling
cyclesSecs = [sort(repmat(1:P.exercise.duration, 1), 'descend') 0];

% Set time to 0
time = 0;
i = 1;
tic

Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
tExerciseStart = Screen('Flip',P.display.w);

% While the time is smaller than the defined cycling duration
while GetSecs < tExerciseStart+P.exercise.duration

    tCodeStart = GetSecs;
    if i > P.exercise.duration
        % Show fixation cross when timer is done
        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            tExerciseEnd = Screen('Flip',P.display.w);
        end

        % save parameters after each block
        save(P.out.file.paramExp, 'P', 'O');

        % save file as mat
        save(exerciseFile, 'exercise_power');
        save(exerciseFile2,'exercise_all_data');

        % save figure
        str_block = num2str(block);
        saveas(gcf,[P.out.dirExp,filesep,'block',str_block,'.fig'])

        WaitSecs(2);
        return;

    end
    % Here is our drawing loop
    %for i = 1:length(cyclesSecs)
    % maybe take out the for loop and instead use i = 1, i = i + 1 to
    % loop throuhg the variable

    %         if cyclesSecs(i) == 0
    %             if ~O.debug.toggleVisual
    %                 Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    %                 Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    %                 cross_on_after = Screen('Flip',P.display.w);
    %
    %             end
    %             WaitSecs(2);
    %
    %             return;
    %
    %         end

    % continously read out power(and potentially other measures)

    tStartSecs = GetSecs;
    data = read(power_measure);

    % continously read out HR
    data_hr = read(hr_measure);


    % save data in structure
    P.exercise_all_data(block).block(i).data = data;
    P.exercise_all_data(block).block(i).HR = data_hr;
    P.exercise_all_data(block).block(i).time = time;
    P.exercise_all_data(block).block(i).time2 = GetSecs - tExerciseStart;

    exercise_all_data(block).block(i).data = data;
    exercise_all_data(block).block(i).HR = data_hr;
    exercise_all_data(block).block(i).time = time;
    exercise_all_data(block).block(i).time2 = GetSecs - tExerciseStart;


    % extract instant power and converst to uint16
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
    fprintf('Instantaneous power: %.2f watt, HR : %.2f\n', instantpower,heartRate);

    % save extracted power for according timepoints
    P.exercise_power(block).block(i).power= instantpower;
    P.exercise_power(block).block(i).HR = heartRate;
    P.exercise_power(block).block(i).time = time;
    P.exercise_power(block).block(i).time2 = GetSecs - tExerciseStart;


    % save to saving structure
    exercise_power(block).block(i).power = instantpower;
    exercise_power(block).block(i).HR = heartRate;
    exercise_power(block).block(i).time = time;
    exercise_power(block).block(i).time2 = GetSecs - tExerciseStart;

    % Addpoints to the graph and draw
    addpoints(hPower, time, P.exercise_power(block).block(i).power);
    addpoints(hHeartRate, time, P.exercise_power(block).block(i).HR);
    drawnow;

    % smooth power display with previous 3 powers
    if i > 3
        instantpower_smoothed = (exercise_power(block).block(i).power ...
            + exercise_power(block).block(i-1).power ...
            + exercise_power(block).block(i-2).power)/3;
    else
        instantpower_smoothed = instantpower;
    end

    % Convert current power to string
    numberString = num2str(instantpower_smoothed,'%.0f');

    % Convert our current number to display into a string
    numberString2 = num2str(cyclesSecs(i));

    % Convert HR to string
    numberString3 = num2str(heartRate);

    % Draw our number to the screen
    DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);

    if int == 1 % high

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von [',num2str(round(P.FTP.results.zones.level4_threshold(1))),' ',num2str(round(P.FTP.results.zones.level4_threshold(2))),'] Watt'], 'center',P.display.screenYpixels * 0.8 , P.style.white2);
        
        % Show HR and desired HR Zone
        DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm von ',num2str(round(mean(P.FTP.results.hr_zones.level4_threshold))),' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);

        % Make Watt number red when cycling is above and below 25 Watt
        % of required intensity
        %if instantpower_smoothed < P.FTP.results.threshold_power - 25 || instantpower_smoothed > P.FTP.results.threshold_power + 25
        %    DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(round(P.FTP.results.threshold_power))], 'center',P.display.screenYpixels * 0.8 , P.style.red);

            % Show HR and desired HR Zone
        %   DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm von [',num2str(round(P.FTP.results.hr_zones.level4_threshold(1))),' ',num2str(round(P.FTP.results.hr_zones.level4_threshold(2))),'] bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);

        %end

    elseif int == 0 %low intensity

        DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(round(P.FTP.results.zones.level1_AR))], 'center',P.display.screenYpixels * 0.8 , P.style.white2);
         
        % Show HR and desired HR Zone
        DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);


        %if instantpower_smoothed < P.FTP.results.zones.level1_AR - 25 || instantpower_smoothed > P.FTP.results.zones.level1_AR + 25
        %    DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(round(P.FTP.results.zones.level1_AR))], 'center',P.display.screenYpixels * 0.8 , P.style.red);


        %    % Show HR and desired HR Zone
       %     DrawFormattedText(P.display.w, ['Herzfrequenz: ',numberString3,' bpm'], 'center',P.display.screenYpixels * 0.9 , P.style.white);

        %end
    end


  
    % Show fixation Cross
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    % Flip Screen every scond
    Screen('Flip',P.display.w);

    tCodeEnd = GetSecs;
    elapsed_time = tCodeStart - tCodeEnd;
    %WaitSecs(1-elapsed_time);
    WaitSecs(0.95);
    % update counter
    i = i + 1;

    % Update the time based on toc
    time = toc;



    %end

end

% Show fixation cross when timer is done
if ~O.debug.toggleVisual
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    cross_on_after = Screen('Flip',P.display.w);

end
WaitSecs(2);


% save parameters after each block
save(P.out.file.paramExp, 'P', 'O');

% save file as mat
save(exerciseFile, 'exercise_power');
save(exerciseFile2,'exercise_all_data');

% save figure
str_block = num2str(block);
saveas(gcf,[P.out.dirExp,filesep,'block',str_block,'.fig'])


end