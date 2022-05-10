% For sending triggers to a parallel port interface, using a legacy Cogent routine.
% See LPT_WRAPPER for additional information.
%
% Version: 1.0
% Authors: Björn Horing, bjoern.horing@gmail.com (compilation and structuring, nothing creative)
%          Unknown (actual functions)
% Date: 2021-09-14
%
% Dependencies: /cogent etc for triggering/*.*, namely
% config_io.m config_io32.m io64.mexw65 outp.m outp32.m

function LPT(action,P,address,port)

    switch lower(action)
        
        case 'init'
            
            if ~isempty(regexp(computer('arch'),'64','ONCE'))
                config_io;
            elseif ~isempty(regexp(computer('arch'),'32','ONCE')) % this should be verified for 32 bit PCs, I recall that it worked at sometime though
                config_io32;
            end 
            for a = 1:numel(P.com.lpt)
                LPT('trigger',P,P.com.lpt(a).address,0); % just to make sure ALL pins are LOW
            end
                
        case 'trigger' % formerly subfunction SendTrigger
            
            if ~isempty(regexp(computer('arch'),'64','ONCE'))
                outp(address,port); % set pin to HIGH
                WaitSecs(P.com.lpt.CEDDuration);
                outp(address,0); % set pin to LOW again
                WaitSecs(P.com.lpt.CEDDuration);
            elseif ~isempty(regexp(computer('arch'),'32','ONCE')) % this should be verified for 32 bit PCs, I recall that it worked at sometime though
                outp32(address,port); % set pin to HIGH
                WaitSecs(P.com.lpt.CEDDuration);            
                outp32(address,0); % set pin to LOW again
                WaitSecs(P.com.lpt.CEDDuration);
            end                
            
        otherwise
            
            error('Unknown action.')
            
    end
