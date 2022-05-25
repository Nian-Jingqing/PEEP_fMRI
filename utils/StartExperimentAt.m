function [abort,P] = StartExperimentAt(P)

abort=0;


P.keys.n0                 = KbName('0)'); % | Welcome (Day1)
P.keys.n1                 = KbName('1!'); % | Heat Calib: Preexposure & Awiszus & VAS Training (Day1)
P.keys.n2                 = KbName('2@'); % | Heat Calib:Calibration/Psychometric Scaling (Day1)
P.keys.n3                 = KbName('3#'); % | Heat Calib: Calibration/VAS Target Regression (Day1)

P.keys.n4                 = KbName('4$'); % | pressure Calib:  Preexposure & Awiszus & VAS Training (Day1)
P.keys.n5                 = KbName('5%'); % | pressure Calib:  Calibration/Psychometric Scaling (Day1)
P.keys.n6                 = KbName('6^'); % | pressure Calib: Calibration/VAS Target Regression (Day1)

P.keys.n7                 = KbName('7&'); % | Bike FTP Calibration (Day1)

P.keys.n8                 = KbName('8*'); % | Warm Up (Day 2)
P.keys.n9                 = KbName('9('); % | 4 x 10 Minutes Cycling (Day 2)


keyN0Str = upper(char(P.keys.keyList(P.keys.n0)));
keyN1Str = upper(char(P.keys.keyList(P.keys.n1)));
keyN2Str = upper(char(P.keys.keyList(P.keys.n2)));
keyN3Str = upper(char(P.keys.keyList(P.keys.n3)));
keyN4Str = upper(char(P.keys.keyList(P.keys.n4)));
keyN5Str = upper(char(P.keys.keyList(P.keys.n5)));
keyN6Str = upper(char(P.keys.keyList(P.keys.n6)));
keyN7Str = upper(char(P.keys.keyList(P.keys.n7)));
keyN8Str = upper(char(P.keys.keyList(P.keys.n8)));
keyN9Str = upper(char(P.keys.keyList(P.keys.n9)));
keyEscStr = upper(char(P.keys.keyList(P.keys.name.esc)));

fprintf(['Indicate which step you want to start at: ' ...
    '\n%s) General Welcome ' ...
    '\n%s) Heat Calib: Pre-exposure & Awiszus & VAS training ' ...
    '\n%s) Heat Calib: Psychometric Scaling VAS Target Regression' ...
    '\n%s) Pressure Calib: Pre-exposure & Awiszus & VAS training ' ...
    '\n%s) Pressure Calib: Psychometric Scaling VAS Target Regression ' ...
    '\n%s) Bike FTP Calibration (Day1)'...
    '\n%s) Day 2: Warm Up ' ...
    '\n%s) Day 2: 4 x 10 Min Cycling ' ...
    '\n[%s] to abort.\n\n'], ...
    keyN0Str(1),keyN1Str(1),keyN2Str(1),keyN3Str(1),keyN4Str(1),keyN5Str(1),keyN6Str(1),keyN7Str(1),keyEscStr);


while 1
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.n0
            P.startSection=0;
            fprintf('Start at General Welcome (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n1
            P.startSection=4;
            fprintf('Start at Heat Calib: Pre-exposure & Awiszus & VAS Training (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n2
            P.startSection=5;
            fprintf('Start at Heat Calib: VAS Target Regression/Psychometric Scaling (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n3
            P.startSection=6;
            fprintf('Start at Pressure Calib: Pre-exposure & Awiszus & VAS Training (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n4
            P.startSection=1;
            fprintf('Start at Pressure Calib: /VAS Target Regression/Psychometric Scaling (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n5
            P.startSection=2;
            fprintf('Bike Calibration FTP (Day 1)\n');
            break;
        elseif find(keyCode) == P.keys.n6
            P.startSection=3;
            fprintf('Start at Warm Up (Day 2)\n');
            break;
        elseif find(keyCode) == P.keys.n7
            P.startSection=7;
            fprintf('Start at Cylcing Experiment (Day 2)\n');
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
