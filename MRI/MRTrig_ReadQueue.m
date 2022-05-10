% Reads events accumulated in KbQueue.
% See MRTrig_WRAPPER for additional information.
%
% Important: Return arguments are sorted chronologically from oldest to newest!

function [listKeys,tKeys] = MRTrig_ReadQueue(P) 
           
    listKeys = [];
    tKeys = [];
    pressed = [];
    %fprintf('there are %03d events\n',KbEventAvail(p_input_device));
    while KbEventAvail(P.devices.input)
        [evt, n] = KbEventGet(P.devices.input);
        n = n + 1;
        listKeys(n) = evt.Keycode;
        pressed(n) = evt.Pressed;
        tKeys(n) = evt.Time;
     %   fprintf('Event is: %d\n',keycode(n));
    end
    listKeys(~pressed) = []; % remove all release events
    tKeys(~pressed) = []; % remove all release events
    %fprintf('there are %03d events found...\n',length(keycode));    

    listKeys = listKeys(end:-1:1); % sort keypresses ascending (much faster than flip)
    tKeys = tKeys(end:-1:1); % sort timestamps ascending (much faster than flip)
