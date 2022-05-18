function ShowIntroduction(P,section)
% This function shows the general introduction to the experiment parts. The
% different blocks refer to:
%
% Block 0: Welcome/General Introductions
% Block 1: Pre Exposure and Awiazus Instructions
% Block 2: VAS training
% Block 3: Calibration Psychometric Scaling
% Block 4: Calibration Target Regression
% Block 5: Experiment Introduction
% Block 6: Goodbye
%
% Author: Janne Nold
% Last modified: 28.10.21


%% import the text and images
strings = GetText;
P.textrIndex = GetImg(P);

%% Show fixation cross at start and get Screen FLip interval
Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
tITIStart =  Screen('Flip',P.display.w);


%% Run Introduction based on block provided in function call
Screen('Textsize',P.display.w,70);

if section == 0 % general welcome

    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);

    WaitSecs(1);

    % Draw text
    DrawFormattedText(P.display.w,strings.welcome,'center','center',P.style.white2);
    Screen('Flip',P.display.w);

    %show the messages at the experimenter screen
    fprintf('=========================================================\n');
    fprintf('Showing General Introduction\n');
    fprintf('=========================================================\n');

    %wait for button press to continue
    KbStrokeWait;

    DrawFormattedText(P.display.w,strings.introduction1,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.introduction2,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

% -------------- Pre exposure and awiszus ------------------------------
Screen('Textsize',P.display.w,70);

elseif section == 1 

    %show the messages at the experimenter screen
    fprintf('=========================================================\n');
    fprintf('Showing Pre Exposure and Awiszus Introduction\n');
    fprintf('=========================================================\n');

    DrawFormattedText(P.display.w,strings.preExposure1,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.preExposure2,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end
    WaitSecs(0.4);


    DrawFormattedText(P.display.w,strings.preExposure3,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex7, [], [], 0);
    Screen('Flip', P.display.w);

    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);


    DrawFormattedText(P.display.w,strings.preExposure4,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.4);

% -------------------------- VAS Training -------------------------------
Screen('Textsize',P.display.w,70);

elseif section == 2 
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);

    WaitSecs(1);

    %show the messages at the experimenter screen
    fprintf('=========================================================\n');
    fprintf('Showing VAS training Introduction\n');
    fprintf('=========================================================\n');

    DrawFormattedText(P.display.w,strings.vastraining0,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.vastraining01,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.vastraining1,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex21, [], [], 0);
    Screen('Flip', P.display.w);

    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);


    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex22, [], [], 0);
    Screen('Flip', P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

%     Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex23, [], [], 0);
%     Screen('Flip', P.display.w);
%     while 1
%         [keyIsDown, ~, keyCode] = KbCheck();
%         if keyIsDown
%             if find(keyCode) == P.keys.name.right
%                 break;
%             end
%         end
%     end
% 
%     WaitSecs(0.4);


    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex24, [], [], 0);
    Screen('Flip', P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);


    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex25, [], [], 0);
    Screen('Flip', P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);


    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex26, [], [], 0);
    Screen('Flip', P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.vastraining6,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.vastraining7,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.4);

% -----------------Calibration ------------------------------------------
Screen('Textsize',P.display.w,70);

elseif section == 3 

    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);

    WaitSecs(1);

    %show the messages at the experimenter screen
    fprintf('=========================================================\n');
    fprintf('Showing Calibration Introduction\n');
    fprintf('=========================================================\n');

    DrawFormattedText(P.display.w,strings.calibration1,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.calibration2,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

     
    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex26, [], [], 0);
    Screen('Flip', P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);


    DrawFormattedText(P.display.w,strings.calibration4,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.4);

% ------------------- Exercise and pain ---------------------------
Screen('Textsize',P.display.w,70);

elseif section == 4 

    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
    Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
    Screen('Flip',P.display.w);

    WaitSecs(1);

    fprintf('=========================================================\n');
    fprintf('Showing Experiment Introduction\n');
    fprintf('=========================================================\n');

    DrawFormattedText(P.display.w,strings.experiment1,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex9, [], [], 0);
    Screen('Flip', P.display.w);

    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex3, [], [], 0);
    Screen('Flip', P.display.w);

    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);


    DrawFormattedText(P.display.w,strings.experiment3,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.right
                break;
            end
        end
    end

    WaitSecs(0.4);

    DrawFormattedText(P.display.w,strings.experiment7,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.4);

elseif section == 5 % MR wait
                
    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex31, [], [], 0);        
    Screen('Flip', P.display.w);

    WaitSecs(0.4);


elseif section == 6 % main intro
                
    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex41, [], [], 0);        
    Screen('Flip', P.display.w);

%     while 1
%         [keyIsDown, ~, keyCode] = KbCheck();
%         if keyIsDown
%             if find(keyCode) == P.keys.name.confirm
%                 break;
%             end
%         end
%     end

    WaitSecs(5);


elseif section == 61 % main intro
                
    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex42, [], [], 0);        
    Screen('Flip', P.display.w);

%     while 1
%         [keyIsDown, ~, keyCode] = KbCheck();
%         if keyIsDown
%             if find(keyCode) == P.keys.name.right
%                 break;
%             end
%         end
%     end

    WaitSecs(5);

    Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex43, [], [], 0);        
    Screen('Flip', P.display.w);

%     while 1
%         [keyIsDown, ~, keyCode] = KbCheck();
%         if keyIsDown
%             if find(keyCode) == P.keys.name.right
%                 break;
%             end
%         end
%     end

    WaitSecs(5);


    DrawFormattedText(P.display.w,strings.experiment7,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.4);


elseif section == 7 %Goodbye

    Screen('TextSize',P.display.w, 70);
    DrawFormattedText(P.display.w,strings.goodbye1,'center','center',P.style.white2);
    Screen('Flip',P.display.w);
    while 1
        [keyIsDown, ~, keyCode] = KbCheck();
        if keyIsDown
            if find(keyCode) == P.keys.name.confirm
                break;
            end
        end
    end

    WaitSecs(0.4);

end


end
