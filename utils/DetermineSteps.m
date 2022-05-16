    function P=DetermineSteps(P)
        
        P.plateaus.step1Order = P.pain.calibration.heat.AwThr+P.plateaus.step1Seq;
        P.plateaus.step2Order = P.pain.calibration.heat.AwThr+P.plateaus.step2Seq;
        
        % display plateaus for protocol creation and as sanity check
        fprintf('\nPrepare protocol using %1.1f°C as threshold with the following specifications:\n--\n',P.pain.calibration.heat.AwThr);
        for nTrial = 1:length(P.plateaus.step2Order)
            fprintf('Step %02d: %1.1f°C\n',nTrial,P.plateaus.step2Order(nTrial));
        end
        fprintf('--\nRepeat, awTT is %1.1f°C\n',P.pain.calibration.heat.AwThr);
        
    end