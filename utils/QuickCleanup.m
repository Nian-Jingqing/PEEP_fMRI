function QuickCleanup(P,varargin)

fprintf('\n\nAborting... ');

Screen('CloseAll');
close all

if numel(varargin) == 1
    dev = varargin{1};

    if ~isempty(dev)
        cparStopSampling(dev);
        cparStop(dev);
        clear dev
        fprintf('CPAR device was stopped.\n');
    else
        fprintf('CPAR already stopped or dev does not exist.\n');
    end


end

% load(P.out.file.param,'P');

sca; % close window; also closes io64
ListenChar(0); % use keys again
commandwindow;
end
