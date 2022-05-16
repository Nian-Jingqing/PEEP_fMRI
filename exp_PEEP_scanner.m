%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experimental Script PEEP Behavioural
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --------------------- General Preparations ----------------------------

clc
close all;
clear all;

% restore the default path to delete other saved paths
restoredefaultpath

% add script base path
addpath('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI')


%% ------------------ Experiment Preparations -----------------------------


% Instantiate Parameters and Overrides
P                       = InstantiateParameters_scanner; % rename to InstantiateParameters_scanner
O                       = InstantiateOverrides;


% Add paths
if P.devices.arduino
    addpath(genpath(P.path.cpar));
end

addpath(genpath(P.path.scriptBase));
addpath(genpath(P.path.PTB));
addpath(fullfile(P.path.PTB,'PsychBasic','MatlabWindowsFilesR2007a'));

% Clear global functions
clear mex global functions;
commandwindow;


%% ----------------- Initial pressure cuff --------------------------------

if P.devices.arduino
    [abort,initSuccess,dev] = InitCPAR; % initialize CPAR

    if initSuccess
        P.cpar.init = initSuccess;
        P.cpar.dev = dev;
    else
        warning('\nCPAR initialization not successful, aborting!');
        abort = 1;
    end
    if abort
        QuickCleanup(P,dev);
        return;
    end
end

%% ---------------- Initialise Parameters and Screen -------------------

% Load Parameters for experiment
[P,O]                   = SetParams(P,O);
[P,O]                   = SetKeys(P,O);

% Open Screen
[P,O]                   = SetPTB(P,O);

% Get timing at script start
P.time.stamp            = datestr(now,30);
P.time.scriptStart      = GetSecs;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                              Experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RunExperiment_pain(P,O,dev);


%% Goodbye/End Experiment

ShowIntroduction(P,7);

if abort
    QuickCleanup(P,dev);
    return;
else
    ListenChar(0);
    fprintf('\nR U N    C O M P L E T E\n');
    sca;

end


%%%%%%%
% END %
%%%%%%%


