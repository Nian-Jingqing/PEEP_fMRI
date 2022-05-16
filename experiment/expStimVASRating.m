function [abort,P,expVAS] = expStimVASRating(P,O,block,cuff,trial,trialPressure,expVAS,mod)


% Define output file path Rating and pressure data
VASFile = fullfile(P.out.dirExp, [P.out.file.VAS '_experiment.mat']);
%expFile = fullfile(P.out.dirExp, [P.out.file.VAS '_exp.csv']);

abort = 0;

while ~abort
         

    for ratingsection = 2
        
        % ratings
        [abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale_bigger(P,ratingsection);
        fprintf(['\nFinal rating was ' num2str(finalRating)]);

        if ~O.debug.toggleVisual
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix1);
            Screen('FillRect', P.display.w, P.style.white, P.fixcross.Fix2);
            WaitSecs(1);
            tCrossOn = Screen('Flip',P.display.w);
        end

        % add to existing VAS file
        if exist(VASFile,'file')
            VASData = load(VASFile);
            expVAS = VASData.expVAS;
        end

        if mod == 1
            mod = 'pressure';

        elseif mod == 2
            mod = 'heat';

        end

        clear experimentData
        experimentData.trialInt = trialPressure;
        experimentData.finalRating = finalRating;
        experimentData.reactionTime = reactionTime;
        experimentData.keyId = keyId;
        experimentData.keyTime = keyTime;
        experimentData.response = response;
        experimentData.modality = mod;



        P.pain.PEEP.pressure(trial) = trialPressure;
        P.pain.PEEP.rating(trial) = finalRating;


        % Save current data to structure
        expVAS(block).block(trial).trial(ratingsection).ratingsection = experimentData;
        P.expVAS = expVAS;

        % Save on every trial
        fprintf([' Saving VAS data trial ' num2str(trial)]);

        % Save structure as .mat
        save(VASFile, 'expVAS');

        % save structure to .csv
        %writetable(struct2table(expVAS), VASFile);

        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);
        end


    end

    break;
end

end

