function [abort,P,exerciseVAS]=ApplyStimulusExercise(P,O,pressure,cuff,block,exerciseVAS,int)

exerciseFile = fullfile(P.out.dirExp, [P.out.file.VAS '_exercise.mat']);

abort = 0;


while ~abort


    % Get timing
    P.time.exerciseStart(block,1) = GetSecs-P.time.scriptStart;

    % Count down for the duration of pressure
    P = kickr(P,O,block,int);
    %P = kickr_test(P,O,block,int);
    Screen('Flip',P.display.w);



    if abort; return; end
    P.time.exerStimStart(block,1) = GetSecs-P.time.scriptStart;


    % Rating for exercise intensity
    fprintf('\nVAS... ');
    tVASStart = GetSecs;
    P.time.exerciseStimVASStart(block,1) = GetSecs-P.time.scriptStart;
 %   SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);

    % Continue after 1 seconds
    WaitSecs(1);
    Screen('Flip',P.display.w);

    if ~O.debug.toggleVisual
        [abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale_bigger(P,1);
        fprintf(['\nFinal rating was ' num2str(finalRating)]);
    end

    P.time.exerciseStimVASEnd(block,1) = GetSecs-P.time.scriptStart;
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
    save(exerciseFile, 'exerciseVAS');
    fprintf([' Saving exercise VAS data block ' num2str(block)]);
    % save paramters
    save(P.out.file.paramExp, 'P', 'O');



    %Get Timing of VAS rating Exercise
    P.time.exerciseStimVASEnd(block,1) = GetSecs-P.time.scriptStart;

    trial = [];

    break;

end

    if ~abort
        fprintf(' Exercise Block concluded. \n');

    else
        return;
    end

    if abort; return; end

end
