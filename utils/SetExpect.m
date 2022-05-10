function [abort,P] = SetExpect(P)

abort=0;

P.keys.nP                 = KbName('p'); % | P Placebo
P.keys.nC                 = KbName('c'); % | C Control
P.keys.nN                 = KbName('n'); % | N Nocebo

keyPStr = upper(char(P.keys.keyList(P.keys.nP )));
keyCStr = upper(char(P.keys.keyList(P.keys.nC)));
keyNStr = upper(char(P.keys.keyList(P.keys.nN)));
keyEscStr = upper(char(P.keys.keyList(P.keys.name.esc)));

fprintf(('Please enter the manipulation mode (Placebo = P; Nocebo = N; Control = C;) \n%s) p = placebo \n%s) n = nocebo \n%s) c = control \n[%s] to abort.\n\n'), ...
    keyPStr(1),keyNStr(1),keyCStr(1),keyEscStr);

while 1
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.nP
            fprintf('Mode Set to Placebo.\n');
            P.expectation = 'Placebo';
            break;
        elseif find(keyCode) == P.keys.nN
            fprintf('Mode Set to Nocebo\n');
            P.expectation = 'Nocebo';
            break;
        elseif find(keyCode) == P.keys.nC
            fprintf('Mode Set to Control\n');
            P.expectation = 'Control';
            break;
        elseif find(keyCode) == P.keys.name.esc
            fprintf('Abort');
            abort=1;
            break;
        end
    end
end

WaitSecs(0.2); % wait in case of a second query immediately after this

end

