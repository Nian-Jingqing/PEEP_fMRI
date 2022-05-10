function [abort,initSuccessBelt,belt] = InitBelt()

abort = 0;
initSuccessBelt = 0;
timer = 0;
fprintf('Waiting to connect HR Belt... ');

while ~initSuccessBelt

    blelist("Timeout",20);


    try % test if Belt is initialized already
        belt = ble("HRM-Pro:677868");
        initSuccessBelt = 1;
        fprintf(' connected.\n');
        return;
    catch
        belt = ble("HRM-Pro:677868");
        initSuccessBelt = 1;
        return;
    end
end


% Wait until a connection has been established

if isempty(belt); abort = 1; else; initSuccessBelt = 1; end

end

