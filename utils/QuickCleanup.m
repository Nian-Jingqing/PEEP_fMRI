function QuickCleanup(P,dev)

fprintf('\n\nAborting... ');

Screen('CloseAll');
close all

% load(P.out.file.param,'P');

if ~isempty(dev)
    cparStopSampling(dev);
    cparStop(dev);
    clear dev
    fprintf('CPAR device was stopped.\n');
else
    fprintf('CPAR already stopped or dev does not exist.\n');
end

sca; % close window; also closes io64
ListenChar(0); % use keys again
commandwindow;
end