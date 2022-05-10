% See MRTrig_WRAPPER for additional information.

function P = MRTrig_Log(P,subStruct,tEvent,eventInfo)        

    e = P.log.(['n' subStruct]) + 1;
    P.log.(['n' subStruct]) = e;
    P.log.(subStruct)(e,1) = {e};
    P.log.(subStruct)(e,2) = {tEvent};
    P.log.(subStruct)(e,3) = {tEvent-P.log.mriExpStartTime};
    P.log.(subStruct)(e,4) = {eventInfo};
    