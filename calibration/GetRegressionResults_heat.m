function [P,calibration] = GetRegressionResults_heat(P)
  
        if P.toggles.doPainOnly
            thresholdVAS = 0;
        else
            thresholdVAS = 50;
        end
        x = P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>1 & P.pain.calibration.heat.PeriThrStimType<5);
        y = P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>1 & P.pain.calibration.heat.PeriThrStimType<5);
        [predTempsLin,predTempsSig,predTempsRob,betaLin,betaSig,betaRob] = FitData(x,y,[thresholdVAS P.plateaus.VASTargets],0); 

        painThresholdLin = predTempsLin(1);
        painThresholdSig = predTempsSig(1);
        predTempsLin(1) = []; % remove threshold temp, retain only VASTargets
        predTempsSig(1) = []; % remove threshold temp, retain only VASTargets
        
        if betaLin(2)<0 
            warning(sprintf('\n\n********************\nNEGATIVE SLOPE. This is physiologically highly implausible. Exclude participant.\n********************\n'));
        end        
            
        % construct regression results output file

        calibration.fitData.heat.interceptLinear = betaLin(1); % lin intercept
        calibration.fitData.heat.slopeLinear = betaLin(2); % lin slope
        calibration.fitData.heat.interceptSigmoid = betaSig(1); % sig intercept
        calibration.fitData.heat.slopeSigmoid = betaSig(2); % sig slope
        calibration.fitData.heat.painThresholdAwiszus = P.pain.calibration.heat.AwThr; % as per Awiszus thresholding
        calibration.fitData.heat.predHeatLinear = painThresholdLin; % as per linear regression for VAS 50 (pain threshold)
        calibration.fitData.heat.predHeatSigmoid = painThresholdSig; % as per nonlinear regression for VAS 50 (pain threshold)


        fprintf('\n\n==========REGRESSION RESULTS==========\n');
        fprintf('>>> Linear intercept %1.1f, slope %1.1f. <<<\n',betaLin);        
        fprintf('>>> Sigmoid intercept %1.1f, slope %1.1f. <<<\n',betaSig);        
        fprintf('To achieve VAS50, use %1.1f%°C (lin) or %1.1f°C (sig).\n',painThresholdLin,painThresholdSig);
        fprintf('This yields for\n');

        for vas = 1:numel(P.plateaus.VASTargets)        
            fprintf('- VAS%d: %1.1f°C (lin), %1.1f°C (sig)\n',P.plateaus.VASTargets(vas),predTempsLin(vas),predTempsSig(vas)); 
        end
        
        save(P.out.file.paramCalib, 'P');         
        
        % Save as individual structure
        save('calibration_heat',calibration);
    end
    