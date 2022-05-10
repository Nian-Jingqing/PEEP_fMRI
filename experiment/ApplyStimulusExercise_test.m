function [abort,P,exerciseVAS]=ApplyStimulusExercise_test(P,O,pressure,cuff,block,dev,exerciseVAS,int)

cparFile = fullfile(P.out.dirExp,[P.out.file.CPAR '_exercise.mat']);
exerciseFile = fullfile(P.out.dirExp, [P.out.file.VAS '_exercise.mat']);

abort = 0;

% Define pressure
pressure = P.exercise.constPressure;

while ~abort
% 
%     fprintf(['Exercise pressure initiated (' num2str(pressure)  ' kPa)... ']);
% 
%     % Calculate Stim Duration (Ramp and plateau)
%     stimDuration = CalcStimDuration(P,P.exercise.constPressure,P.exercise.duration);
% 
%     % Get timing
%     P.time.exerciseStart(block) = GetSecs-P.time.scriptStart;
% 
%     if P.devices.arduino
% 
%         [abort,initSuccess,dev] = InitCPAR; % initialize CPAR
%         P.cpar.dev = dev;
%         
%         if initSuccess
% 
%             abort = UseCPAR('Set',dev,'Exercise',P,stimDuration,pressure); % set stimulus
%             [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus
%             SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.pressureOnset);
% 
%             % Count down for the duration of pressure
%             %P = kickr(P,O,block,int);
%             P = kickr_test(P,O,block,int);
%             Screen('Flip',P.display.w);
% 
%         else
%             abort = 1;
%             return;
%         end
% 
%         if abort; return; end
%         P.time.exerStimStart(block) = GetSecs-P.time.scriptStart;
% 
%         %tStimStart = GetSecs;
% 
%         % if abort; return; end
%         %
%         %         while GetSecs < tStimStart+P.exercise.duration
%         %             [abort]=LoopBreakerStim(P);
%         %             if abort; break; end
%         %         end
% 
%         %
%         %         countedDown = 1;
%         %         while GetSecs < tStimStart+P.exercise.duration
%         %             [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
%         %             if abort; break; end
%         %         end

        % Rating for exercise intensity
        fprintf('\nVAS... ');
        tVASStart = GetSecs;
        P.time.exerciseStimVASStart(block) = GetSecs-P.time.scriptStart;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);

        if ~O.debug.toggleVisual
            [abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale(P,1);
             fprintf(['\nFinal rating was ' num2str(finalRating)]);
        end

        P.time.exerciseStimVASEnd(block) = GetSecs-P.time.scriptStart;
        if abort; return; end

        while GetSecs < tVASStart+P.pain.calibration.durationVAS
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end

        % add to existing VAS file
        if exist(exerciseFile,'file')
            VASData = load(exerciseFile);
            exerciseVAS= VASData.exerciseVAS;
        end

        % Save exercise Data
        clear exerciseData
        exerciseData.trialPressure = pressure;
        exerciseData.finalRating = finalRating;
        exerciseData.reactionTime = reactionTime;
        exerciseData.keyId = keyId;
        exerciseData.keyTime = keyTime;
        exerciseData.response = response;
        exerciseData.block = block;
        exerciseData.intensity = int;

        % add data to structure (safety)
        P.exercise.results(block).pressure = pressure;
        P.exercise.results(block).condition = P.exercise.condition(block);
        P.exercise.results(block).rating = finalRating;


        % Save current data to structure
        P.exerciseVAS(block).exerciseVAS = exerciseData;
        exerciseVAS(block).exerciseVAS = exerciseData;

        % Save on every trial
        fprintf([' Saving exercise VAS data block ' num2str(block)]);

        % Save structure as .mat
        save(exerciseFile, 'exerciseVAS');

        % save structure to .csv
        %writetable(struct2table(exerciseVAS), exerciseFile);

        %Get Timing of VAS rating Exercise
        P.time.exerciseStimVASEnd(block) = GetSecs-P.time.scriptStart;

        if abort; return; end

        trial = [];

        if P.devices.arduino
            data = cparGetData(dev, data);
            trialData = cparFinalizeSampling(dev, data);
            saveCPARData(trialData,cparFile,block,trial); % save data for this trial
            fprintf(' Saving CPAR data... ')
        end

    end

    % save paramters
    save(P.out.file.paramExp, 'P', 'O');

    if abort; return; end


    break;

end

if ~abort
    fprintf(' Exercise Block concluded. \n');
else
    return;
end

end