function [P] = DoAwiszus_heat(P,O)

        painful=[];

        P.time.threshStart=GetSecs;

        P = Awiszus_heat('init',P); 

        % iteratively increase or decrease the target temperature to approximate pain threshold    
        P.awiszus.thermoino.nextX = P.awiszus.thermoino.mu; % start with assumed population mean
        for awn = 1:P.awiszus.thermoino.N
            P.awiszus.thermoino.nextX = round(P.awiszus.thermoino.nextX,1); % al gusto

            [abort]=DisplayStimulus(P,O,awn,P.awiszus.thermoino.nextX);            
            if abort; break; end
            [painful,tThresholdRating]=BinaryRating(P,O,awn);
            P.awiszus.thermoino.threshRatings(awn,1) = P.awiszus.thermoino.nextX;
            P.awiszus.thermoino.threshRatings(awn,2) = painful;

            if ~O.debug.toggle
                if painful==0
                    awstr = 'not painful';
                elseif painful==1
                    awstr = 'painful';
                elseif painful==-1 
                    break; % yeah let's not do that anymore...
                end
            else 
                awstr = 'painful';
                painful=1;
            end
            fprintf('Stimulus rated %s.\n',awstr);

            P = Awiszus_heat('update',P,painful); % awP,awPost,awNextX,painful      
            [abort]=WaitRemainingITI(P,O,awn,tThresholdRating);
            if abort; break; end
        end

        if abort;QuickCleanup(P);return;end        
        
        P.pain.calibration.heat.AwThrTemps = P.awiszus.thermoino.threshRatings(:,1);
        P.pain.calibration.heat.AwThrResponses = P.awiszus.thermoino.threshRatings(:,2);        
        P.pain.calibration.heat.AwThr = P.awiszus.thermoino.nextX; 

        if painful==-1
            fprintf('No rating provided for temperature %1.1f. Please restart program. Resuming at the current break point not yet implemented.\n',P.pain.calibration.heat.AwThr);
            return;
        else
            %save([P.out.dir P.out.file], 'P');
            save(P.out.file.paramCalib,'P','O');
            fprintf('\n\nThreshold determined around %1.1f°C, after %d trials.\nThreshold data and results saved under %s%s.mat.\n',P.pain.calibration.heat.AwThr,P.awiszus.thermoino.N,P.out.file.paramCalib);        
        end

        P.time.threshEnd=GetSecs;

    end