function [P] = kickr_test(P,O,block,int)
% This function extracts the power (and potentially other important
% features) from the wahoo KICKR bike while. Also, it displays the instant
% power (watt) on the screen along with the remaining seconds of cycling. 

%% Settings
% define output file
exerciseFile = fullfile(P.out.dirExp, [P.out.file.BIKE '_exercise_power.mat']);
exerciseFile2 = fullfile(P.out.dirExp, [P.out.file.BIKE '_exercise_all_data.mat']);

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
global bike

% Get bike characteristics
charac = bike.Characteristics;

% Extract the Power Measure
power_measure = characteristic(bike,"Cycling Power","Cycling Power Measurement");

% Create a figure of cycling power against time
figure
axPower = axes('XLim', [0, P.exercise.duration], 'YLim', [0, 500]);
xlabel(axPower, 'time');
ylabel(axPower, 'Power Watt');
title(['Subject: ',num2str(P.protocol.subID),' Block: ',num2str(block)])
hPower = animatedline(axPower, 'Marker', 'o', 'MarkerFaceColor', 'blue');

% Set countdowm for 300 seconds (5 minute) cycling
cyclesSecs = [sort(repmat(1:P.exercise.duration, 1), 'descend') 0];

% Set time to 0
time = 0;
tic

% Define pressure
pressure = P.exercise.constPressure;
fprintf(['Exercise pressure initiated (' num2str(pressure)  ' kPa)... ']);

    % Calculate Stim Duration (Ramp and plateau)
    stimDuration = CalcStimDuration(P,P.exercise.constPressure,P.exercise.duration);

    % Get timing
    P.time.exerciseStart(block) = GetSecs-P.time.scriptStart;

    if P.devices.arduino

        [abort,initSuccess,dev] = InitCPAR; % initialize CPAR
        P.cpar.dev = dev;
        
        if initSuccess

            abort = UseCPAR('Set',dev,'Exercise',P,stimDuration,pressure); % set stimulus
            [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus
            SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.pressureOnset);

        else
            abort = 1;
            return;
        end

        if abort; return; end
        P.time.exerStimStart(block) = GetSecs-P.time.scriptStart;

        %tStimStart = GetSecs;

        % if abort; return; end
        %
        %         while GetSecs < tStimStart+P.exercise.duration
        %             [abort]=LoopBreakerStim(P);
        %             if abort; break; end
        %         end

        %
        %         countedDown = 1;
        %         while GetSecs < tStimStart+P.exercise.duration
        %             [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
        %             if abort; break; end
        %         end


% While the time is smaller than the defined cycling duration
while time < P.exercise.duration

    % Here is our drawing loop
    for i = 1:length(cyclesSecs)

        % continously read out power (and potentially other measures)
        data = read(power_measure);

        % save data in structure
        P.exercise_all_data(block).block(i).data = data;
        P.exercise_all_data(block).block(i).time = time;

        exercise_all_data(block).block(i).data = data;
        exercise_all_data(block).block(i).time = time;

        % extract instant power and converst to uint16
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

        % Print Power to experimeter
        fprintf('Instantaneous power: %.2f watt\n', instantpower);

        % save extracted power for according timepoints
        P.exercise_power(block).block(i).power= instantpower;
        P.exercise_power(block).block(i).time = time;

        % save to saving structure 
        exercise_power(block).block(i).power = instantpower;
        exercise_power(block).block(i).time = time; 

        % Addpoints to the graph and draw
        addpoints(hPower, time, P.exercise_power(block).block(i).power);
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

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Noch ',numberString2,' Sekunden'], 'center',P.display.screenYpixels * 0.25 , P.style.white2);

        if int == 1 % high
            
            % Draw our number to the screen
            DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(P.exercise.highInt)], 'center',P.display.screenYpixels * 0.8 , P.style.white2);

            % Make Watt number red when cycling is above or below 10 Watt
            % of required intensity
            if instantpower < P.exercise.highInt - 10 || instantpower > P.exercise.highInt + 10
                DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(P.exercise.highInt)], 'center',P.display.screenYpixels * 0.8 , P.style.red);
            end
        
        elseif int == 0 %low intensity
            
            DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(P.exercise.lowInt)], 'center',P.display.screenYpixels * 0.8 , P.style.white2);

            if instantpower < P.exercise.lowInt - 10 || instantpower > P.exercise.lowInt + 10
                DrawFormattedText(P.display.w, ['Power: ',numberString,' Watt von ',num2str(P.exercise.lowInt)], 'center',P.display.screenYpixels * 0.8 , P.style.red);
            end
        end

        % Show fixation Cross
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        Screen('Flip',P.display.w);


        WaitSecs(0.9);

        % update counter
        i = i + 1;

        % Update the time based on toc
        time = toc;

        % stop when counter reaches 0 
         if time >= 300
         break;
         end 



    end

end

% save parameters after each block
save(P.out.file.paramExp, 'P', 'O');

% save file as mat
save(exerciseFile, 'exercise_power');
save(exerciseFile2,'exercise_all_data');

% save figure
str_block = num2str(block);
saveas(gcf,[P.out.dirExp,filesep,'block',str_block,'.fig'])

%clear bike

end