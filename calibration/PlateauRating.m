% obtain rating for this trial
function P=PlateauRating(P,O)

if ~O.debug.toggleVisual
    % brief blank screen prior to rating
    tBlankOn = Screen('Flip',P.display.w);
else
    tBlankOn = GetSecs;
end
while GetSecs < tBlankOn + 0.5 end

% VAS
fprintf('VAS... ');

send_trigger(P,O,sprintf('vas_on'));

if P.toggles.doPainOnly
   P = VASScale_v6(P,O);
    %[abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale_bigger(P,2);
else
   P = VASScale_v6(P,O);
   %[abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale_bigger(P,2);
end

P = PutRatingLog(P);

if ~O.debug.toggleVisual
    Screen('Flip',P.display.w);
end

end