function [ITIs,cues] = DetermineITIsAndCues(nStims,mMITIJ,mMCJ)
        
        ITIs = [];
        cues = [];
        
        if isempty(nStims) || ~nStims            
            return;
        end
        
        nITIJitter                      = (max(mMITIJ)-min(mMITIJ))/(nStims-1); % yields the increment size required for length(sequence) trials
        sITIJitter                      = min(mMITIJ):nITIJitter:max(mMITIJ);
        nCueJitter                      = (max(mMCJ)-min(mMCJ))/(nStims-1); % yields the increment size required for length(sequence) trials
        sCueJitter                      = min(mMCJ):nCueJitter:max(mMCJ);
        
        if isempty(sITIJitter) sITIJitter(nStims)=mean(mMITIJ); end % then max(mMITIJ)==min(mMITIJ)
        if isempty(sCueJitter) sCueJitter(nStims)=mean(mMCJ); end % then max(mMCJ)==min(mMCJ)
        
        % construct ITI list matching the stimulus sequence        
        ITIs = sITIJitter(randperm(length(sITIJitter)));
        cues = sCueJitter(randperm(length(sCueJitter)));       
        
    end