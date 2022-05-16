 function [abort,P]=TrialControl(P,O)

        abort=0;
        plateauLog = [];

        %SEGMENT -1 (yeah yeah): SCALE TRANSLATION; data NOT saved
        if P.startSection<4
            if P.toggles.doScaleTransl && P.toggles.doPainOnly
                P.toggles.doPainOnly = 0; % this is the whole point here, to translate the y/n binary via the two-dimensional VAS to the unidimensional

%                [abort]=ShowInstruction(P,O,7,1);            
                if abort;QuickCleanup(P);return;end  

                step0Order = [P.pain.calibration.heat.AwThr P.pain.calibration.heat.AwThr+0.2 P.pain.calibration.heat.AwThr-0.2]; % provide some perithreshold intensities
                fprintf('\n=================================');
                fprintf('\n========SCALE TRANSLATION========\n');
                for nStep0Trial = 1:numel(step0Order)
                    fprintf('\n=======TRIAL %d of %d=======\n',nStep0Trial,numel(step0Order));
                    [abort]=ApplyStimulus_heat(P,O,step0Order(nStep0Trial));
                    if abort; return; end
                    P=InstantiateCurrentTrial(P,O,-1,step0Order(nStep0Trial),-1);
                    P=PlateauRating(P,O);
                    [abort]=ITI(P,O,P.currentTrial.reactionTime);
                    if abort; return; end
                end

                P.toggles.doPainOnly = 1; % RESET
                
%                [abort]=ShowInstruction(P,O,8,1);            
                if abort;QuickCleanup(P);return;end                  
                WaitSecs(0.5);

            end
        end        

        if P.startSection<6
%            [abort]=ShowInstruction(P,O,3,1);            
            if abort;QuickCleanup(P);return;end  
        end
        
%        SEGMENT 0: RATING TRAINING; data NOT saved
        if P.startSection<5
            step0Order = repmat(P.pain.calibration.heat.AwThr,1,2);
            fprintf('\n=================================');
            fprintf('\n=========RATING TRAINING=========\n');
            for nStep0Trial = 1:numel(step0Order)
                fprintf('\n=======TRIAL %d of %d=======\n',nStep0Trial,numel(step0Order));
                [abort]=ApplyStimulus_heat(P,O,step0Order(nStep0Trial));
                if abort; return; end
                P=InstantiateCurrentTrial(P,O,0,step0Order(nStep0Trial));
                P=PlateauRating(P,O);
                [abort]=ITI(P,O,P.currentTrial.reactionTime);
                if abort; return; end
            end
            
            if any(P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType==0)>25) % 25 being an arbitrary threshold
                fprintf('\nSb rated training stimuli at threshold (%1.1f°C) that should be rated VAS~0\nat',P.pain.calibration.heat.AwThr)
                fprintf('\t%d',P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType==0));
                fprintf('\n');
                fprintf('This does not impact the regression, but could be a sign of poor understanding of the instructions.\n');
                fprintf('Reinstruct if desired, then continue [%s] or abort [%s] (for new calibration)?\n',upper(char(P.keys.keyList(P.keys.resume))),upper(char(P.keys.keyList(P.keys.abort))));
                commandwindow;

                while 1
                    abort=0;
                    [keyIsDown, ~, keyCode] = KbCheck();
                    if keyIsDown
                        if find(keyCode) == P.keys.name.abort
                            abort=1;
                            return;
                        elseif find(keyCode) == P.keys.name.confirm
                            break;
                        end
                    end         
                end
                
                WaitSecs(0.5);
            end
        end
        
        if P.startSection<6 % from this point on, data will be saved and integrated into regression analyses
            % SEGMENT 1: PSYCHOMETRIC-PERCEPTUAL SCALING
            if P.toggles.doPsyPrcScale
                fprintf('\n=================================');
                fprintf('\n=PSYCHOMETRIC-PERCEPTUAL SCALING=\n');
                for nStep1Trial = 1:numel(P.plateaus.step1Order)
                    fprintf('\n=======TRIAL %d of %d=======\n',nStep1Trial,numel(P.plateaus.step1Order));
                    [abort]=ApplyStimulus_heat(P,O,P.plateaus.step1Order(nStep1Trial));
                    if abort; return; end
                    P=InstantiateCurrentTrial(P,O,1,P.plateaus.step1Order(nStep1Trial));
                    P=PlateauRating(P,O);
                    [abort]=ITI(P,O,P.currentTrial.reactionTime);
                    if abort; return; end
                end
            end

%             % SEGMENT 2: FIXED INTENSITIES
%             if P.toggles.doFixedInts
%                 fprintf('\n===============================');
%                 fprintf('\n=======FIXED INTENSITIES=======\n');
%                 for nStep2Trial = 1:length(P.plateaus.step2Order)
%                     fprintf('\n=======TRIAL %d of %d=======\n',nStep2Trial,length(P.plateaus.step2Order));
%                     [abort]=ApplyStimulus(P,O,P.plateaus.step2Order(nStep2Trial));
%                     if abort; return; end                    
%                     P=InstantiateCurrentTrial(P,O,2,P.plateaus.step2Order(nStep2Trial));
%                     P=PlateauRating(P,O);
%                     if nStep2Trial<length(P.plateaus.step2Order)
%                         [abort]=ITI(P,O,P.currentTrial.reactionTime);
%                         if abort; return; end
%                     end
%                 end        
%             end

            % SEGMENT 3: PRE-ESTIMATED INTENSITIES
            if P.toggles.doPredetInts         
                fprintf('\n===============================');
                fprintf('\n=====FIXED TARGET RATINGS======\n');

                x = P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>0); % could restrict to ==1, but the more info the better
                y = P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>0);
                [P.plateaus.step3Order,~] = FitData(x,y,P.plateaus.step3TarVAS,2);
                
                if any(P.plateaus.step3Order > 49 | P.plateaus.step3Order < 41)
                    % find too high stimuli
                    idx_2high = find(P.plateaus.step3Order > 49); 
                    if ~isempty(idx_2high)
                        fprintf('suggested temperatures too high (> 49.0°C), will be replaced automatically with 49.0°C');
                        if ~(length(idx_2high) >= 2)
                           P.plateaus.step3Order(idx_2high) = P.pain.maxSaveTemp; 
                        elseif length(idx_2high) == 2
                            P.plateaus.step3Order(idx_2high) = [P.pain.maxSaveTemp - 1,  P.pain.maxSaveTemp];
                        else
                            P.plateaus.step3Order(idx_2high) = [P.pain.maxSaveTemp - 2,  P.pain.maxSaveTemp - 1,  P.pain.maxSaveTemp];
                        end
                    end
                    
                    % find too low stimuli
                    idx_2low  = find(P.plateaus.step3Order < 40);
                    
                    if ~(length(idx_2low) >= 2)
                        fprintf('suggested temperatures too low (< 40.0°C), will be replaced automatically with 40°C');
                        P.plateaus.step3Order(idx_2low) = P.pain.minTemp; 
                    elseif length(idx_2low) == 2
                        P.plateaus.step3Order(idx_2low) = [P.pain.minTemp, P.pain.minTemp+0.5];
                    else
                        P.plateaus.step3Order(idx_2low) = [P.pain.minTemp, P.pain.minTemp+0.5, P.pain.minTemp+1];
                    end
                end

                P = BetterGuess(P); % option to change FTRs if regression was off...
                for nStep3Trial = 1:length(P.plateaus.step3Order)
                    fprintf('\n=======TRIAL %d of %d=======\n',nStep3Trial,length(P.plateaus.step3Order));
                    [abort]=ApplyStimulus_heat(P,O,P.plateaus.step3Order(nStep3Trial));
                    if abort; return; end
                    P=InstantiateCurrentTrial(P,O,3,P.plateaus.step3Order(nStep3Trial),P.plateaus.step3TarVAS(nStep3Trial));
                    P=PlateauRating(P,O);
                    [abort]=ITI(P,O,P.currentTrial.reactionTime);
                    if abort; return; end            
                end
            end

            % SEGMENT 4: ADAPTIVE PROCEDURE
            if P.toggles.doAdaptive
                fprintf('\n===============================');
                fprintf('\n====VARIABLE TARGET RATINGS====\n');
                nextStim = 1; % just so it isn't empty... 
                varTrial = 0;
                nH = figure;
                while ~isempty(nextStim)                        
                    ex = P.pain.calibration.heat.PeriThrStimTemps(P.pain.calibration.heat.PeriThrStimType>1);
                    ey = P.pain.calibration.heat.PeriThrStimRatings(P.pain.calibration.heat.PeriThrStimType>1);
                    if varTrial<2 % lin is more robust for the first additions; in the worst case [0 X 100], sig will get stuck in a step fct
                        linOrSig = 'lin';
                    else
                        linOrSig = 'sig';
                    end
                    [nextStim,~,tValidation,targetVAS] = CalibValidation(ex,ey,[],[],linOrSig,P.toggles.doConfirmAdaptive,1,0,nH,num2cell([zeros(1,numel(ex)-1) varTrial]),['s' num2str(numel(varTrial)+1)]);
                    if ~isempty(nextStim)           
                        varTrial = varTrial+1;
                        fprintf('\n=======VARIABLE TRIAL %d=======\n',varTrial);
                        [abort]=ApplyStimulus_heat(P,O,nextStim);            
                        if abort; return; end
                        % note: ITI could additionally subtract tValidation!
                        P=InstantiateCurrentTrial(P,O,4,nextStim,P.currentTrial.targetVAS);
                        P=PlateauRating(P,O);
                        [abort]=ITI(P,O,P.currentTrial.reactionTime); % +tValidation
                        if abort; return; end
                    end
                    if varTrial == P.presentation.n_max_varTrial
                        break
                    end
                end      
            end

            calibration = GetRegressionResults_heat(P);
              calibration = GetRegressionResults(P,cuff);
         P.pain.calibration.heat.results = calibration;
        else
            P = GetExistingCalibData(P);
            calibration = GetRegressionResults_heat(P);
%             if isempty(plateauLog)
%                 error('Calibration data not found at %s. Aborting.',P.out.dir);
%             end
        end
            
 end