function ShowInstantpower(P,O,bike)
% This function displays the instantpower in Watt to the participant as
% extracted from the Wahoo KICKR bike
%
% Author: Janne Nold
% based on the script by Alexandra Tinnermann
% Last modified: 28.10.21

% Increase the textsize of the countdown
Screen('TextSize', P.display.w, 100);


if P.devices.bike

    % Create a figure of cycling power against time
    figure
    axPower = axes('XLim', [0, P.exercise.duration], 'YLim', [0, 500]);
    xlabel(axPower, 'time');
    ylabel(axPower, 'Power Watt');
    hPower = animatedline(axPower, 'Marker', 'o', 'MarkerFaceColor', 'green');

    % Set time to 0
    time = 0;
    i = 1;
    tic

    power_measure = characteristic(bike,"Cycling Power","Cycling Power Measurement");

    while time < startExercise + P.exercise.duration

        data = read(power_measure); % continously read out power
        instantpower = double(typecast(uint8(data(3:4)), 'uint16'));

        fprintf('Instantaneous power: %.2f watt\n', instantpower);
        P.exercise_results(block).block(i).power= instantpower;
        P.exercise_results(block).block(i).time = time;

        % Update the time based on toc
        time = toc;

        % Addpoints to the graph and draw
        addpoints(hPower, time, P.exercise_results(block).block(i).power);
        drawnow;
       

        % Convert our current number to display into a string
        power_numberString = num2str(instantpower);

        % Draw our number to the screen
        DrawFormattedText(P.display.w, ['Power in Watt: ',power_numberString], 'center',P.display.screenYpixels * -0.25 , P.style.white2);

        Screen('Flip',P.display.w);
        % update counter
        i = i + 1;


    end

end

end



