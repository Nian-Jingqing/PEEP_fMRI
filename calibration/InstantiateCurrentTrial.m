 function P=InstantiateCurrentTrial(P,O,stepId,trialTemp,varargin)

        P.painCalibData.PeriThrN = P.painCalibData.PeriThrN+1;

        P.currentTrial = struct; % reset
        P.currentTrial.N = P.painCalibData.PeriThrN;        
        P.currentTrial.nRating = 1; % currently, CalibHeat contains only one rating scale; cf P11_WindUp for expanding this
        P.currentTrial.ratingId = 11; % 11 = heat/pain VAS
        if P.toggles.doPainOnly      
            P.currentTrial.trialType = 'single'; 
        else
            P.currentTrial.trialType = 'double'; 
        end
        P.currentTrial.stepId = stepId;
        P.currentTrial.temp = trialTemp;

        if nargin>4
            P.currentTrial.targetVAS = varargin{1}; % include predicted VAS in log file (redundancy)
        else
            P.currentTrial.targetVAS = -1;
        end        

        P.currentTrial.sITI = round(P.presentation.sMinMaxPlateauITIs(1) + (P.presentation.sMinMaxPlateauITIs(2)-P.presentation.sMinMaxPlateauITIs(1))*rand,1); % note: this is RANDOM in a range, since it's just the calibration; could revert to balanced sITIs
        P.currentTrial.sCue = round(P.presentation.sMinMaxPlateauCues(1) + (P.presentation.sMinMaxPlateauCues(2)-P.presentation.sMinMaxPlateauCues(1))*rand,1); % note: this is RANDOM in a range, since it's just the calibration; could revert to balanced sCues

        P.log.scaleInitVAS(P.currentTrial.N,1) = randi(P.presentation.scaleInitVASRange); % different starting value for each trial; legacy log

    end