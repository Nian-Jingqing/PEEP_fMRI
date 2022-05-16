function [abort,P,expVAS]=ApplyStimulusPain_heat(P,O,trialTemp,block,trial,expVAS,mod)
       
        % be sure to never go higher than 49°C and never lower than
        % baseline, otherwise the "cold" can hurt as well
        if trialTemp > P.pain.thermoino.maxSaveTemp   
            trialTemp = P.pain.thermoino.maxSaveTemp;
        elseif trialTemp < P.pain.thermoino.bT 
            trialTemp = P.pain.thermoino.bT;
        end

        abort=0;
        [stimDuration]=CalcStimDuration_heat(P,trialTemp,P.presentation.sStimPlateau);
        
        if P.pain.calibration.heat.PeriThrN==1 % Turn on the fixation cross for the first trial (no ITI to cover this)
            InitialTrial(P,O);
        elseif P.pain.calibration.heat.PeriThrN == 4
            InitialTrial(P,O);
        end  
        
        fprintf('%1.1f°C stimulus initiated.',trialTemp); 

        tHeatOn = GetSecs;
        countedDown=1;
        send_trigger(P,O,sprintf('stim_on'));
        
        if P.devices.thermoino        
            UseThermoino('Trigger'); % start next stimulus
            UseThermoino('Set',trialTemp); % open channel for arduino to ramp up      
            
            while GetSecs < tHeatOn + sum(stimDuration(1:2))
                [countedDown]=CountDown(GetSecs-tHeatOn,countedDown,'.');
                [abort]=LoopBreaker(P);
                if abort; break; end            
            end            
            
            fprintf('\n');
            UseThermoino('Set',P.pain.thermoino.bT); % open channel for arduino to ramp down              
            
            if ~abort
                while GetSecs < tHeatOn + sum(stimDuration)
                    [countedDown]=CountDown(GetSecs-tHeatOn,countedDown,'.');
                    [abort]=LoopBreaker(P);
                    if abort; return; end            
                end      
            else
                return;
            end
        else
            send_trigger(P,O,sprintf('stim_on'));
            
            while GetSecs < tHeatOn + sum(stimDuration)
                [countedDown]=CountDown(GetSecs-tHeatOn,countedDown,'.');
                [abort]=LoopBreaker(P);
                if abort; return; end            
            end
        end                
        fprintf(' concluded.\n');

                % VAS Rating and Output
        if ~O.debug.toggleVisual
            cuff = 0;
            [abort,P,expVAS] = expStimVASRating(P,O,block,cuff,trial,trialTemp,expVAS,mod);
        end


    end