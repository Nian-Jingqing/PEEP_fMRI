function [abort,initSuccessBike,bike] = InitKICKR()

abort = 0;
initSuccessBike = 0;
timer = 0;
fprintf('Waiting to connect KICKR... ');

while ~initSuccessBike

    blelist("Timeout",20);


    try % test if KICKR is initialized already
        bike = ble("KICKR BIKE 35A3");
        initSuccessBike = 1;
        fprintf(' connected.\n');
        return;
    catch
        bike = ble("KICKR BIKE 35A3");
        initSuccessBike = 1;
        return;
    end
end


% Wait until a connection has been established

if isempty(bike); abort = 1; else; initSuccessBike = 1; end

end

