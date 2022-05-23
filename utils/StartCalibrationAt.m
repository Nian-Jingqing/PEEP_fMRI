function [abort,startSection] = StartCalibrationAt


P.keys.n0                 = KbName('0)'); % | Welcome (Day1)
P.keys.n1                 = KbName('1!'); % | Thermode Calib
P.keys.n2                 = KbName('2@'); % | Pressure Calib
P.keys.n3                 = KbName('3#'); % | Bike Calib

keyN0Str = upper(char(P.keys.keyList(P.keys.n0)));
keyN1Str = upper(char(P.keys.keyList(P.keys.n1)));
keyN2Str = upper(char(P.keys.keyList(P.keys.n2)));
keyN3Str = upper(char(P.keys.keyList(P.keys.n3)));
keyEscStr = upper(char(P.keys.keyList(P.keys.name.esc)));

fprintf(['Indicate which step you want to start at: ' ...
    '\n%s) General Welcome ' ...
    '\n%s) Thermode Calibration ' ...
    '\n%s) Pressure Calibration ' ...
    '\n%s) Bike Calibration ' ...
    '\n[%s] to abort.\n\n'], ...
    keyN0Str(1),keyN1Str(1),keyN2Str(1),keyN3Str(1),keyEscStr);


while 1
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.n0
            startSection=0;
            fprintf('Start at General Welcome (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n1
            startSection=1;
            fprintf('Start at Thermode Calib \n');
            break;
        elseif find(keyCode) == P.keys.n2
            startSection=2;
            fprintf(' Start at Pressure Calib \n');
            break;
        elseif find(keyCode) == P.keys.n3
            startSection=3;
            fprintf(' Start at Bike Calib \n');
            break;
       
        elseif find(keyCode) == P.keys.name.esc
            % P.startSection=10;
            fprintf('Abort');
            abort=1;
            break;
        end
    end
end

WaitSecs(0.2); % wait in case of a second query immediately after this

end