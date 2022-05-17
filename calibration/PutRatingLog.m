 % save rating and other info for this trial
    function P = PutRatingLog(P)   
                
        n = P.pain.calibration.heat.PeriThrN;
        P.pain.calibration.heat.PeriThrStimType(n) = P.currentTrial.stepId; % legacy plateauLog(:,8);
        P.pain.calibration.heat.PeriThrStimOffs(n) = P.currentTrial.temp-P.pain.calibration.heat.AwThr; % legacy plateauLog(:,3);
        P.pain.calibration.heat.PeriThrStimTemps(n) = P.currentTrial.temp; % legacy plateauLog(:,4);
        P.pain.calibration.heat.PeriThrStimRatings(n) = P.currentTrial.finalRating; % legacy plateauLog(:,5);
        P.pain.calibration.heat.PeriThrReactionTime(n) = P.currentTrial.reactionTime; % legacy plateauLog(:,7);
        P.pain.calibration.heat.PeriThrResponseGiven(n) = P.currentTrial.response; % legacy plateauLog(:,6);
        P.pain.calibration.heat.PeriThrRatingTime(n) = GetSecs; % legacy plateauLog(:,11);
        P.pain.calibration.heat.PeriThrStimTarVAS(n) = P.currentTrial.targetVAS; % legacy plateauLog(:,12);
        P.pain.calibration.heat.PeriThrStimScaleInitVAS(n) = P.log.scaleInitVAS(P.currentTrial.N,1); % legacy plateauLog(:,13);
        % check if ITIs are worth saving here

        save(P.out.file.paramCalib, 'P');                
        
    end


