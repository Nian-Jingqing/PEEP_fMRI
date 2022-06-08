function [abort,P] = StartExperimentAt(P)

abort=0;


P.keys.n0                 = KbName('0)'); % | Welcome (Day1)
P.keys.n1                 = KbName('1!'); % | Heat Calib: Preexposure & Awiszus & VAS Training (Day1)



keyN0Str = upper(char(P.keys.keyList(P.keys.n0)));
keyN1Str = upper(char(P.keys.keyList(P.keys.n1)));
keyEscStr = upper(char(P.keys.keyList(P.keys.name.esc)));

fprintf(['Indicate which step you want to start at: ' ...
    '\n%s) Day 2: Warm Up ' ...
    '\n%s) Day 2: 4 x 10 Min Cycling ' ...
    '\n[%s] to abort.\n\n'], ...
    keyN0Str(1),keyN1Str(1),keyEscStr);


while 1
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.n0
            P.startSection=0;
            fprintf('Warm-up\n');
            break;
        elseif find(keyCode) == P.keys.n1
            P.startSection=4;
            fprintf('Cycling\n');
            break;
%         elseif find(keyCode) == P.keys.n2
%             P.startSection=5;
%             fprintf('Start at Heat Calib: VAS Target Regression/Psychometric Scaling (Day 1)\n');
%             break;
%         elseif find(keyCode) == P.keys.n3
%             P.startSection=6;
%             fprintf('Start at Pressure Calib: Pre-exposure & Awiszus & VAS Training (Day 1)\n');
%             break;
%         elseif find(keyCode) == P.keys.n4
%             P.startSection=1;
%             fprintf('Start at Pressure Calib: /VAS Target Regression/Psychometric Scaling (Day 1)\n');
%             break;
%         elseif find(keyCode) == P.keys.n5
%             P.startSection=2;
%             fprintf('Bike Calibration FTP (Day 1)\n');
%             break;
%         elseif find(keyCode) == P.keys.n6
%             P.startSection=3;
%             fprintf('Start at Warm Up (Day 2)\n');
%             break;
%         elseif find(keyCode) == P.keys.n7
%             P.startSection=7;
%             fprintf('Start at Cylcing Experiment (Day 2)\n');
%             break;
      
        elseif find(keyCode) == P.keys.name.esc
            P.startSection=10;
            fprintf('Abort');
            abort=1;
            break;
        end
    end
end

WaitSecs(0.2); % wait in case of a second query immediately after this

end
