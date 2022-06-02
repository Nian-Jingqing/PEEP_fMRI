function [P,abort] = VASTraining(P,O,ratingsection,dev)

abort=0;
strings = GetText;
cuff = P.calibration.cuff_arm;
trial = [];

% Define output file
cparFile = fullfile(P.out.dirCalib,[P.out.file.CPAR '_VAStraining.mat']);

fprintf('\n==========================\nRunning VAS training.\n==========================\n');

% Give experimenter chance to abort if neccesary
fprintf('\nContinue [%s], or abort [%s].\n',upper(char(P.keys.keyList(P.keys.name.confirm))),upper(char(P.keys.keyList(P.keys.name.esc))));

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
if abort; return; end

WaitSecs(0.2);

while ~abort


    if ~O.debug.toggleVisual
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
        Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
        tCrossOn = Screen('Flip',P.display.w);
    else
        tCrossOn = GetSecs;
    end


    countedDown = 1;
    while GetSecs < tCrossOn + P.pain.calibration.firstTrialWait
        tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
        [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
        if abort; break; end
    end

    if abort; return; end

    %%  Give pressure at pain threshold and see wether they rate 0 on scale
    for paintrial = 1:P.pain.VAStraining.trials

        pressure = P.awiszus.painThresholdFinal;

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.red, P.fixcross.Fix2);
            Screen('Flip',P.display.w);
        end


        % Calculate Stimulus Duration including ramp and plateau
        stimDuration = CalcStimDuration(P,pressure,P.pain.preExposure.sStimPlateauPreExp);

        countedDown = 1;
        tStimStart = GetSecs;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.pressureOnset);

        if P.devices.arduino && P.cpar.init

            abort = UseCPAR('Set',dev,'preExp',P,stimDuration,pressure); % set stimulus
            [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus

        end


        while GetSecs < tStimStart+sum(stimDuration)
            [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
            if abort; return; end
        end
        
        fprintf(['\nVAS pressure threshold ' num2str(pressure)]);

        fprintf(' concluded.\n');

        if P.devices.arduino && P.cpar.init
            data = cparGetData(dev, data);
            preExpCPARdata = cparFinalizeSampling(dev, data);
            saveCPARData(preExpCPARdata,cparFile,cuff,trial);
        end

        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);
        end

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            Screen('Flip',P.display.w);
        end

        %% Get ratings for scales

        % Display the scale and introduction depending on the ratingsection
        % (1 = excerise, 2 = Painfulness, 3 = unpleasentness, 4 = affective
        % component)

        if ratingsection == 2 % painfulness

            Screen('TextSize',P.display.w,30);

            % Continue after 2 seconds
            WaitSecs(1);
            Screen('Flip',P.display.w);

            % Draw scale
            [abort,finalRating,~,~,~,~] = singleratingScale_bigger(P,2);
            fprintf(['\nFinal rating was ' num2str(finalRating)]);

            if ~O.debug.toggleVisual
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
                Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
                tCrossOn = Screen('Flip',P.display.w);
            else
                tCrossOn = GetSecs;
            end
            %ratingsection = ratingsection +1;
        end

%         if ratingsection == 3 % unpleasentness
%             Screen('TextSize',P.display.w,30);
% 
%             % Continue after 2 seconds
%             WaitSecs(1);
%             Screen('Flip',P.display.w);
% 
%             % Draw scale
%             [abort,finalRating,~,~,~,~] = singleratingScale_bigger(P,3);
%             fprintf(['\nFinal rating was ' num2str(finalRating)]);
%             
% 
%             if ~O.debug.toggleVisual
%                 Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
%                 Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
%                 tCrossOn = Screen('Flip',P.display.w);
%             else
%                 tCrossOn = GetSecs;
%             end
% 
%             ratingsection = 2;
%         end

% 
%         if ratingsection == 4 % affective component
%             Screen('TextSize',P.display.w,30);
% 
%             % Continue after 2 seconds
%             WaitSecs(2);
% 
%             % Draw scale
%             [abort,finalRating,~,~,~,~] = singleratingScale(P,4);
%             fprintf(['\nFinal rating was ' num2str(finalRating)]);
% 
%             if ~O.debug.toggleVisual
%                 Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
%                 Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
%                 tCrossOn = Screen('Flip',P.display.w);
%             else
%                 tCrossOn = GetSecs;
%             end
% 
%             ratingsection = 2;
        end


        % Intertrial interval if not the last stimulus in the block,
        % if last trial then end trial immediately
        if trial ~= P.pain.VAStraining.trials

            fprintf('\nIntertrial interval... ');
            countedDown = 1;
            while GetSecs < tCrossOn + P.pain.VAStraining.durationITI
                tmp=num2str(SecureRound(GetSecs-tCrossOn,0));
                [abort,countedDown] = CountDown(P,GetSecs-tCrossOn,countedDown,[tmp ' ']);
                if abort; break; end
            end

            if abort; return; end

        end


       paintrial = paintrial + 1;

        if paintrial >2
            abort = 1;
            break;
        end
end


if ~abort
    fprintf('\nVAS training finished. \n');
else
    return;
end

end






