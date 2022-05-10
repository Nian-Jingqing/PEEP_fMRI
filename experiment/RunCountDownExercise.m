function [numberString,t] = RunCountDownExercise(P,O,t)
% This function runs a countdowm from a certain number to 0 for the amount
% of seconds same as the number provided
%
% Author: Janne Nold
% based on the script by Alexandra Tinnermann
% Last modified: 28.10.21

% Increase the textsize of the countdown
%Screen('TextSize', P.display.w, 100);

%% Setting for countdown
% Set countdowm for 300 mintue cycling
cyclesSecs = [sort(repmat(1:P.exercise.duration, 1), 'descend') 0];
%t = 0;

%while t < P.exercise.duration

    % Here is our drawing loop
    for l = 1:length(cyclesSecs)

        % Convert our current number to display into a string
        numberString = num2str(cyclesSecs(l));

        % Draw our number to the screen
        %DrawFormattedText(P.display.w, numberString, 'center',P.display.screenYpixels * 0.25 , P.style.white2);

%         % Show fixation Cross
%         Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
%         Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
%         Screen('Flip',P.display.w);

        WaitSecs(1);
        t = t + 1;

    end
end




