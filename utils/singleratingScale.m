function [abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale(P,ratingsection)

%% key settings
abort = 0;

KbName('UnifyKeyNames');
keys        = P.keys;
lessKey     = P.keys.name.left; % yellow button
moreKey     = P.keys.name.right; % red button
confirmKey  = P.keys.name.confirm;
escapeKey   = P.keys.name.esc;

window      = P.display.w;
windowRect  = P.display.windowrect;
durRating   = P.pain.VAStraining.durationVAS;

if isempty(window); error('Please provide window pointer for likertScale!'); end
if isempty(windowRect); error('Please provide window rect for likertScale!'); end
if isempty(durRating); error('Duration length of rating has to be specified!'); end

%% Default values

tempCursorStart             = randi([31 71]);
currentRating               = tempCursorStart;
ratings                     = currentRating;
finalRating                 = 0;
reactionTime                = 0;
response                    = 0;
numberOfSecondsRemaining    = durRating;
keyTime                     = 0;
keyId                       = 0;
nRatingSteps                = 101;
scaleWidth                  = 700;
textSize                    = P.display.textsize_rating;
lineWidth                   = 6;
scaleColor                  = [255 255 255];
activeColor                 = [255 0 0];
defaultRating               = 1;
backgroundColor             = P.style.backgr;
startY                      = P.style.startY;


%% Calculate rects

activeAddon_width           = 1.5;
activeAddon_height          = 20;
[xCenter, yCenter]          = RectCenter(windowRect);
yCenter                     = startY;
axesRect                    = [xCenter - scaleWidth/2; yCenter - lineWidth/2; xCenter + scaleWidth/2; yCenter + lineWidth/2];
lowLabelRect                = [axesRect(1),yCenter-20,axesRect(1)+6,yCenter+20];
highLabelRect               = [axesRect(3)-6,yCenter-20,axesRect(3),yCenter+20];
midLabelRect                = [xCenter-3,yCenter-20,xCenter+3,yCenter+20];
midlLabelRect               = [xCenter-3-scaleWidth/4,yCenter-20,xCenter+3-scaleWidth/4,yCenter+20];
midhLabelRect               = [xCenter-3+ scaleWidth/4,yCenter-20,xCenter+3+scaleWidth/4,yCenter+20];
ticPositions                = linspace(xCenter - scaleWidth/2,xCenter + scaleWidth/2-lineWidth,nRatingSteps);
activeTicRects              = [ticPositions-activeAddon_width;ones(1,nRatingSteps)*yCenter-activeAddon_height;ticPositions + lineWidth+activeAddon_width;ones(1,nRatingSteps)*yCenter+activeAddon_height];

Screen('TextSize',window,textSize);
Screen('TextColor',window,[255 255 255]);
Screen('TextFont', window, 'Arial');



%%%%%%%%%%%%%%%%%%%%%%% loop while there is time %%%%%%%%%%%%%%%%%%%%%
% tic; % control if timing is as long as durRating

startTime = GetSecs;
while numberOfSecondsRemaining  > 0

    Screen('FillRect',window,backgroundColor);
    Screen('FillRect',window,activeColor,[activeTicRects(1,1)+3 activeTicRects(2,1)+ 5 activeTicRects(3,currentRating)-3 activeTicRects(4,1)-5]);
    Screen('FillRect',window,scaleColor,lowLabelRect);
    Screen('FillRect',window,scaleColor,highLabelRect);
    Screen('FillRect',window,scaleColor,midLabelRect);
    Screen('FillRect',window,scaleColor,midlLabelRect);
    Screen('FillRect',window,scaleColor,midhLabelRect);

    if ratingsection == 1
        % Draw text for Exercise Rating (BORG Scale, Convert Scale)
        DrawFormattedText(window, 'Bitte bewerten Sie, wie anstrengend das Fahrradfahren war!', 'center',yCenter-100, scaleColor);
        DrawFormattedText(window, '(maximal 7 Sekunden Zeit)', 'center',yCenter-70, scaleColor);

        Screen('DrawText',window,'überhaupt nicht',axesRect(1)-17,yCenter+25,scaleColor);
        Screen('DrawText',window,'anstrengend (6)',axesRect(1)-40,yCenter+50,scaleColor);

        Screen('DrawText',window,'maximale',axesRect(3)-55,yCenter+25,scaleColor);
        Screen('DrawText',window,'Anstrengung (20)',axesRect(3)-40,yCenter+50,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);



    elseif ratingsection == 2

        % Draw text for Painfulness
        DrawFormattedText(window, 'Wie SCHMERZHAFT war der letzte Druckreiz?', 'center',yCenter-100, scaleColor);
        DrawFormattedText(window, '(maximal 7 Sekunden Zeit)', 'center',yCenter-70, scaleColor);

        Screen('DrawText',window,'minimaler',axesRect(1)-17,yCenter+25,scaleColor);
        Screen('DrawText',window,'Schmerz',axesRect(1)-40,yCenter+50,scaleColor);

        Screen('DrawText',window,'kaum aushaltbarer',axesRect(3)-55,yCenter+25,scaleColor);
        Screen('DrawText',window,'Schmerz',axesRect(3)-40,yCenter+50,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);




    elseif ratingsection == 3
        % Draw text for unpleasentness
        DrawFormattedText(window, 'Wie UNANGENEHM war der letzte Druckreiz?', 'center',yCenter-100, scaleColor);
        DrawFormattedText(window, '(maximal 7 Sekunden Zeit)', 'center',yCenter-70, scaleColor);

        Screen('DrawText',window,'gar nicht',axesRect(1)-17,yCenter+25,scaleColor);
        Screen('DrawText',window,'unangenehm',axesRect(1)-40,yCenter+50,scaleColor);

        Screen('DrawText',window,'extrem',axesRect(3)-55,yCenter+25,scaleColor);
        Screen('DrawText',window,'unangenehm',axesRect(3)-40,yCenter+50,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);





    elseif ratingsection == 4
        % Draw text for affective component
        DrawFormattedText(window, 'Wie DEUTLICH haben Sie den letzten Druckreiz wahrgenommen?', 'center',yCenter-100, scaleColor);
        DrawFormattedText(window, '(maximal 7 Sekunden Zeit)', 'center',yCenter-70, scaleColor);

        Screen('DrawText',window,'gar',axesRect(1)-17,yCenter+25,scaleColor);
        Screen('DrawText',window,'nicht',axesRect(1)-40,yCenter+50,scaleColor);

        Screen('DrawText',window,'extrem',axesRect(3)-55,yCenter+25,scaleColor);
        Screen('DrawText',window,'deutlich',axesRect(3)-40,yCenter+50,scaleColor);

        Screen('Flip', window);
        Screen('TextSize',window,textSize);






    end


     %% Set the Response and keys pressed

    [keyIsDown,secs,keyCode] = KbCheck; % this checks the keyboard very, very briefly.

    if keyIsDown % only if a key was pressed we check which key it was
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.buttonPress); % log key/button press as a marker
        if keyCode(moreKey) % if it was the key we named key1 at the top then...
            currentRating = currentRating + 1; %original: currentRating = currentRating + 1;
            if currentRating > nRatingSteps
                currentRating = nRatingSteps;
            end
            ratings(end+1) = currentRating;
            keyTime(end+1) = secs - startTime;
            keyId(end+1) = 1;
            finalRating = currentRating;
            reactionTime = secs - startTime;
            response = 1;
        elseif keyCode(lessKey)
            currentRating = currentRating - 1; %original currentRating = currentRating - 1;
            if currentRating < 1
                currentRating = 1;
            end
            ratings(end+1) = currentRating;
            keyTime(end+1) = secs - startTime;
            keyId(end+1) = -1;
            finalRating = currentRating;
            reactionTime = secs - startTime;
            response = 1;
            %         elseif keyCode(confirmKey)
            %             finalRating = currentRating;
            %             fprintf('Rating %d\n',finalRating);
            %             reactionTime = secs - startTime;
            %             response = 1;
            %             break;
        elseif keyCode(escapeKey)
            abort = 1;
            break;
        end
    end

    keyId(end+1) = 0;
    keyTime(end+1) = 0;

    numberOfSecondsElapsed   = (GetSecs - startTime);
    numberOfSecondsRemaining = durRating - numberOfSecondsElapsed;

end

% if ~keyIsDown
%     fprintf('No response!');
%     keyTime(end+1) = NaN;
%     keyId(end+1) = 0;
%     ratings(end+1) = NaN;
% end

end

% % If there are button presses but no confirmation (response) the
% % finalrating is the current rating minus 1 step
% if  nrbuttonpresses && ~response
%     finalRating = currentRating - 1;
%     reactionTime = P.rating.durRating;
% end
%
%
%
% % if there were no buttonpresses or no confirmation key pressed display the
% % following
% if  nrbuttonpresses == 0
%     reactionTime = P.rating.durRating;
%     fprintf('Rating %d (NO RESPONSE, NOT CONFIRMED)\n',finalRating)
%     confirmation = 0;
% elseif response == 0
%     fprintf('Rating %d (NOT CONFIRMED)\n',finalRating)
% end

%end

%% Set Marker for CED and BrainVision Recorder
function SendTrigger(P,address,port)
% Send pulse to CED for SCR, thermode, digitimer
% [handle, errmsg] = IOPort('OpenSerialport',num2str(port)); % gives error
% msg on grahl laptop
if P.devices.trigger
    outp(address,port);
    WaitSecs(P.com.lpt.CEDDuration);
    outp(address,0);
    WaitSecs(P.com.lpt.CEDDuration);
end

end