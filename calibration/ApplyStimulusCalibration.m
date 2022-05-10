function [abort,P]=ApplyStimulusCalibration(P,O,trialPressure,calibStep,cuff,trial,dev)

cparFile = fullfile(P.out.dirCalib,[P.out.file.CPAR '_calibration.mat']);

abort = 0;

while ~abort
    
    fprintf(['Stimulus initiated at ' num2str(trialPressure) ' kPa...\n']);

  
    % Calculate the stimulus duration
    stimDuration = CalcStimDuration(P,trialPressure,P.pain.calibration.sStimPlateauCalib);

    % Get the timing of calibration start
    P.time.calibStart(calibStep,trial) = GetSecs-P.time.scriptStart;
 

    % If the Arduino is used
    if P.devices.arduino
        
        clear data
        [abort,initSuccess,dev] = InitCPAR; % initialize CPAR
        P.cpar.dev = dev;
        save(P.out.file.paramCalib, 'P', 'O');
        if initSuccess

            abort = UseCPAR('Set',dev,'Calibration',P,stimDuration,trialPressure); % set stimulus
            [abort,data] = UseCPAR('Trigger',dev,P.cpar.stoprule,P.cpar.forcedstart); % start stimulus

            SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.pressureOnset);

        else
            abort = 1;
            return;
        end
        if abort; return; end
        P.time.calibStimStart(calibStep,trial) = GetSecs-P.time.scriptStart;
        
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
        P.time.calibStimVASStart(calibStep,trial) = GetSecs-P.time.scriptStart;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);
        if ~O.debug.toggleVisual; [abort,P] = calibStimVASRating(P,O,calibStep,cuff,trial,trialPressure); end
        P.time.calibStimVASEnd(calibStep,trial) = GetSecs-P.time.scriptStart;
        if abort; return; end
        
        while GetSecs < tVASStart+P.pain.calibration.durationVAS
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end
        
  
        data = cparGetData(dev, data);
        calibCPARData = cparFinalizeSampling(dev, data);
        saveCPARData(calibCPARData,cparFile,calibStep,trial); % save data for this trial
        fprintf('\nSaving CPAR data... ')
        
        if abort; return; end
        
    else
        
        countedDown = 1;
        tStimStart = GetSecs;
        P.time.calibStart(calibStep,trial) = tStimStart-P.time.scriptStart;
        while GetSecs < tStimStart+stimDuration
            tmp=num2str(SecureRound(GetSecs-tStimStart,0));
            [abort,countedDown]=CountDown(P,GetSecs-tStimStart,countedDown,[tmp ' ']);
            if abort; break; end
            if mod((countedDown/30), 1) == 0; fprintf('\n'); end % add line every 30 seconds
        end
        
        if abort; return; end
        
        % VAS
        fprintf(' VAS... ');
        tVASStart = GetSecs;
        P.time.calibStimVASStart(calibStep,trial) = GetSecs-P.time.scriptStart;
        SendTrigger(P,P.com.lpt.CEDAddressSCR,P.com.lpt.VASOnset);
        if ~O.debug.toggleVisual; [abort,P] = calibStimVASRating(P,O,calibStep,cuff,trial,trialPressure); end
        P.time.calibStimVASEnd(calibStep,trial) = GetSecs-P.time.scriptStart;
        if abort; return; end
        
        while GetSecs < tVASStart+P.presentation.Calibration.durationVAS
            [abort]=LoopBreakerStim(P);
            if abort; break; end
        end
        
        if abort; return; end
         
    end
    
    break;
    
end

if ~abort
    fprintf(' Calibration trial concluded. \n');
else
    return;
end

end