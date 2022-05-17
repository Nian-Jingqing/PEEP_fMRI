function [abort,P,expVAS]=ApplyStimulusPain(P,O,trialPressure,cuff,block,trial,expVAS,mod)

% Define output file path CPAr Data
cparFile = fullfile(P.out.dirExp,[P.out.file.CPAR '_experiment.mat']);

abort = 0;
while ~abort

    % Print to experimenter
    fprintf(['Stimulus initiated at ' num2str(trialPressure) ' kPa...\n']);

    % Calculate the stimulus duration
    stimDuration = CalcStimDuration(P,trialPressure,P.pain.PEEP.sStimPlateauExp);

    % Get the timing of pain start in specific exercise block and trial
    P.time.painStart(block,trial) = GetSecs-P.time.scriptStart;


    % If the Arduino is used
    if P.devices.arduino

        clear data
        [abort,initSuccess,dev] = InitCPAR; % initialize CPAR
        P.cpar.dev = dev;

        % Save instantiates parameters and override 
        save(P.out.file.paramExp, 'P', 'O');
        
        if initSuccess

            abort = UseCPAR('Set',dev,'Experiment',P,stimDuration,trialPressure); % set stimulus
            [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus

            SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.pressureOnset);

        else
            abort = 1;
            return;
        end
        if abort; return; end

        % Get Timing 
        P.time.painStimStart(block,trial) = GetSecs-P.time.scriptStart;
        tStimStart = GetSecs;

        % Count down for the duration of pressure
        countedDown = 1;
        while GetSecs < tStimStart+sum(stimDuration)
            [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
            if abort; break; end
        end

        % Possibility to abort while duration of pressure
        while GetSecs < tStimStart+sum(stimDuration)
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end

        % VAS
        fprintf('\nVAS... ');
        tVASStart = GetSecs;
        P.time.expStimVASStart(block,trial) = GetSecs-P.time.scriptStart;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);


        % VAS Rating and Output
        if ~O.debug.toggleVisual
            [abort,P,expVAS] = expStimVASRating(P,O,block,cuff,trial,trialPressure,expVAS,mod);
        end

        
        % Get Timing
        P.time.expStimVASEnd(block,trial) = GetSecs-P.time.scriptStart;
        if abort; return; end

        while GetSecs < tVASStart+P.pain.calibration.durationVAS
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end

        % Save CPAR Data
        data = cparGetData(dev, data);
        expCPARData = cparFinalizeSampling(dev, data);
        saveCPARData(expCPARData,cparFile,block,trial); % save data for this trial
        fprintf('\nSaving CPAR data... ')

        if abort; return; end

      

    else % If no Arduino is indicated
        % Count down for the duration of pressure
        countedDown = 1;
        while GetSecs < tStimStart+sum(stimDuration)
            [countedDown] = CountDown(P,GetSecs-tStimStart,countedDown,'.');
            if abort; break; end
        end


        while GetSecs < tStimStart+sum(stimDuration)
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end


        % VAS
        fprintf('\nVAS... ');
        tVASStart = GetSecs;
        P.time.calibStimVASStart(calibStep,trial) = GetSecs-P.time.scriptStart;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);
        ratingsection = 1;


        if ~O.debug.toggleVisual
            [abort,P,expVAS] = expStimVASRating(P,O,block,cuff,trial,trialPressure,expVAS);
        end
        
        P.time.calibStimVASEnd(calibStep,trial) = GetSecs-P.time.scriptStart;
        if abort; return; end

        while GetSecs < tVASStart+P.pain.calibration.durationVAS
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end

        if abort; return; end

    end
    break;
end


if ~abort
    fprintf(' Experiment Pain trial concluded. \n');
else
    return;
end

end
