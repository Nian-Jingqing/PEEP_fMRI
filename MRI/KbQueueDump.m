function [keycode, secs] = KbQueueDump
    %[keycode, secs] = KbQueueDump
    %   Will dump all the events accumulated in the queue.
    keycode = [];
    secs    = [];
    pressed = [];
    fprintf('there are %03d events\n',KbEventAvail());
    while KbEventAvail()
        [evt, n]   = KbEventGet();
        n          = n + 1;
        keycode(n) = evt.Keycode;
        pressed(n) = evt.Pressed;
        secs(n)    = evt.Time;
    end
    i           = pressed == 1;
    keycode(~i) = [];
    secs(~i)    = [];
    fprintf('there are %03d events found...\n',length(keycode));
end