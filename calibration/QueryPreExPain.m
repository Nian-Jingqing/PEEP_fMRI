function preexPainful = QueryPreExPain(P,O)
% This functions queries the painfulnes of pre exposure stimuli defined in
% params.preExp.pressure.Int. Increases when participant declares pressure
% as "not painful" (right key), abort when participant declares pressure as
% "painful" (left key).
% Used in the context of the function RunPreExposure.m
%
% Input:
%   - P: Takes the settings defined in P
%   - keys: uses keys defined in keys.m for response
%   - toggleMode
%
% Output:
%   - preexPainful: Logical (0/1) of whether pressure intensiy declared as painful
%
%
% Author: based on script by Karita Ojala
% Last modified: 02.11.21

P.textrIndex = GetImg(P);
%% Pre-define key names

%if strcmp(P.env.hostname,'stimpc1')
if strcmp(P.language,'de')
    keyNotPainful = 'den [rechten Knopf]';
    keyPainful = 'den [linken Knopf]';
end
%else

%end

%% Create the frame where instruction and anchor strings should be displayed

% axesRect = [P.display.xCenter - P.rating.scaleWidth/2; P.display.yCenter - P.rating.lineWidth/2; P.display.xCenter + P.rating.scaleWidth/2; P.display.yCenter + P.rating.lineWidth/2];
% instructionStrings  = { 'War dieser Druckreiz SCHMERZHAFT für Sie?', '' };
% anchorStrings       = { '<', 'Ja', '>' 'Nein' };
% 
% for i = 1:length(anchorStrings)
%     [~, ~, textBox] = DrawFormattedText(P.display.w,char(anchorStrings(i)),0,0,P.style.backgr);
%     textWidths(i)=(textBox(3)-textBox(1))/2;
% end


%% Display Scale and Text
Screen('TextSize', P.display.w, P.display.textsize_ratingBIG);

% DrawFormattedText(P.display.w, instructionStrings{1}, 'center',P.display.yCenter-100, P.rating.scaleColor);
% DrawFormattedText(P.display.w, instructionStrings{2}, 'center',P.display.yCenter-70, P.rating.scaleColor);
% Screen('DrawText',P.display.w,anchorStrings{1},axesRect(1)-textWidths(1),P.rating.yCenter25,P.rating.scaleColor);
% Screen('DrawText',P.display.w,anchorStrings{2},axesRect(1)-textWidths(2),P.rating.yCenter25+P.rating.textSize,P.rating.scaleColor);
% Screen('DrawText',P.display.w,anchorStrings{3},axesRect(3)-textWidths(3),P.rating.yCenter25,P.rating.scaleColor);
% Screen('DrawText',P.display.w,anchorStrings{4},axesRect(3)-textWidths(4),P.rating.yCenter25+P.rating.textSize,P.rating.scaleColor);

Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex7, [], [], 0);

fprintf('Was this stimulus painful [%s], or not painful [%s]?\n',upper(char(P.keys.keyList(P.keys.name.right))),upper(char(P.keys.keyList(P.keys.name.left))));
Screen('Flip',P.display.w);


%% Check whether left or right key is pressed and set preexpainful (0/1)

while 1
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown

        % Display to experimenter which key is pressed
        pressed = find(keyCode, 1, 'first');
        fprintf('%s\n',char(P.keys.keyList(pressed)));

        % if left key pressed
        if find(keyCode) == P.keys.name.right
            preexPainful=1;
            break;

        % if right key pressed
        elseif find(keyCode) == P.keys.name.left
            preexPainful=0;
            break;
        end
    end
end

WaitSecs(0.2);

if ~O.debug.toggleVisual
    Screen('Flip',P.display.w);
end

end