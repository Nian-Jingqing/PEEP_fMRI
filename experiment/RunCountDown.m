function RunCountDown(P,O)

Screen('TextSize', P.display.w, 100);
presSecs = [sort(repmat(1:3, 1), 'descend') 0];

% Here is our drawing loop
t = 0;

while t < 3
    for i = 1:length(presSecs)

        % Convert our current number to display into a string
        numberString = num2str(presSecs(i));

        % Draw our number to the screen
        DrawFormattedText(P.display.w, numberString, 'center', 'center', P.style.white2);

        % Flip to the screen
        Screen('Flip', P.display.w);

        WaitSecs(1);
        t = t + 1;

    end


end

DrawFormattedText(P.display.w, 'Los!', 'center', 'center',P.style.white2,[],[],[],2,[]);
Screen('Flip',P.display.w);
WaitSecs(1);
end




