function [P,O] = SetCyclingInt(P,O)
% Functions prompts user to input the calibrated cycling intensities
% (high and low). If no intensity is provided, default values are used.


%abort=0;

%while ~abort

    P.exercise.highInt = input('\nIndicate HIGH Intensity level for cycling (Watt)\n');
    WaitSecs(0.5);
    P.exercise.lowInt = input('\nIndidcate LOW Intensity level for cycling (Watt)\n');
    WaitSecs(0.5);

%     [keyIsDown, ~, keyCode] = KbCheck();
%     if keyIsDown
%         if find(keyCode) == P.keys.name.esc
%             fprintf('Abort');
%             abort=1;
%             break;
%         end
%     end
% end
end


% if isfield(P,'exercise.highInt') == 0 || isfield(P,'exercise.lowInt') == 0
%     P.exercise.highInt = P.exercise.highIntdefault;
%     P.exercise.lowInt = P.exercise.lowIntdefault;
%     fprintf('Cycling intensities set to default')
% end