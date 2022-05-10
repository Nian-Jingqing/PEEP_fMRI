function [P,O] = SetPTB(P,O)
% Sets the parameters related to the PTB toolbox. Including
% fontsizes, font names.
% It also opens the PTB Screen window.
%
% Author: Janne Nold
% based on the script by Björn Höring
% Last modified: 28.10.21


%%  Set Style parameters

P.style.fontname                = 'Ariel';
P.style.fontsize                = 30;
P.style.linespace               = 20;
P.style.white                   = [255 255 255];
P.style.red                     = [255 0 0];
P.style.blue                    = [0 0 255];
P.style.black                   = [0 0 0];
P.style.backgr                  = [70 70 70];
P.style.lineheight              = 40;

Screen('Preference', 'SkipSyncTests', 1);% Skip sync tests for demo purposes only
Screen('Preference', 'DefaultFontSize', P.style.fontsize);
Screen('Preference', 'DefaultFontName', P.style.fontname);
Screen('Preference', 'TextAntiAliasing', 2);                          % Enable textantialiasing high quality
Screen('Preference', 'VisualDebuglevel', 0);                          % 0 disable all visual alerts
Screen('Preference', 'SuppressAllWarnings', 0);

%% Set style parameters fixation cross

P.style.widthCross                  = 4;
P.style.sizeCross                   = 40;
P.style.xCoordsCross                = [-P.style.sizeCross  P.style.sizeCross  0 0];
P.style.yCoordsCross                = [0 0 -P.style.sizeCross  P.style.sizeCross];
P.style.allCoordsCross              = [P.style.xCoordsCross; P.style.yCoordsCross];


%%  Set Screen PTB

screens                            =  Screen('Screens');                       % Find the number of the screen to be opened
P.display.screenNumber           =  max(screens);                            % The maximum is the second monitor
P.display.screenRes              = Screen('resolution',P.display.screenNumber);
P.style.startY                   = P.display.screenRes.height/2;
fprintf('Resolution of the screen is %dx%d...\n',P.display.screenRes.width,P.display.screenRes.height);


%% General Settings for the Rating (maybe transfer to P function??)

P.rating.durRating                   = 5; % change to 6 seconds?
P.rating.defaultRating               = 50;
P.rating.scaleType                   = 'single';
P.rating.nRating                     = 1;
P.rating.nRatingSteps                = 101;
P.rating.scaleWidth                  = 700;
P.rating.textSize                    = 30;
P.rating.lineWidth                   = 6;
P.rating.scaleColor                  = [255 255 255];
P.rating.first_flip                  = 1;
P.rating.startTime                   = GetSecs;
P.rating.numberOfSecondsRemaining    = P.rating.durRating;
P.rating.textsize_rating             = 27; % textsize of labels
P.rating.length_rating               = 700;
P.rating.width_rating                = 30;
P.rating.width_cursor                = 9;
P.rating.color_Cursor                = [255 0 0];


%%  Open a graphics window using P

%PsychDebugWindowConfiguration;
[P.display.w, P.display.windowrect] = Screen('OpenWindow', P.display.screenNumber, P.style.backgr);
Screen('Flip',P.display.w);


[P.display.screenXpixels, P.display.screenYpixels]    = Screen('WindowSize', P.display.w);
P.display.ifi                                           = Screen('GetFlipInterval', P.display.w);
P.display.slack                                         = Screen('GetFlipInterval',P.display.w)./2;
[P.display.width,P.display.height]                    = Screen('WindowSize', P.display.screenNumber);
[P.display.xCenter, P.display.yCenter]                = RectCenter(P.display.windowrect);
P.display.midpoint                                      = [P.display.width/2, P.display.height/2];
P.display.center                                        = [P.display.windowrect(3) P.display.windowrect(4)]/2;
P.display.nominalframerate                              = Screen('NominalFrameRate', P.display.w);
P.style.white2                                          = WhiteIndex(P.display.screenNumber );
P.style.black2                                          = BlackIndex(P.display.screenNumber );
P.rating.yCenter25                                      = P.display.yCenter+25;

% Set fixation cross and add to structure
P.fixcross.Fix1                   = [P.display.midpoint(1)-P.style.sizeCross ...
    P.style.startY-P.style.widthCross P.display.midpoint(1)+P.style.sizeCross P.style.startY+P.style.widthCross];
P.fixcross.Fix2                   = [P.display.midpoint(1)-P.style.widthCross ...
    P.style.startY-P.style.sizeCross P.display.midpoint(1)+P.style.widthCross P.style.startY+P.style.sizeCross];


% Make lines smooth
Screen('BlendFunction', P.display.w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%Make everything transparent for debugging purposes. Otherwise hide cursor.
if O.debug.toggleVisual == 1
    commandwindow;
    PsychDebugWindowConfiguration(0, 0.5);
    %        else
    %            HideCursor(p.display.screenNumber);
end

%set priority to max - this will favor computational demands of the
%P before other background processes
Priority(MaxPriority(P.display.w));




end