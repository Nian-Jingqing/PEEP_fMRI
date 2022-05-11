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


%% ------------------ Experiment Preparations -------------------------

% Instantiate Parameters and Overrides
P                       = InstantiateParameters;
O                       = InstantiateOverrides;


addpath(genpath(P.path.scriptBase));
addpath(genpath(P.path.PTB));
addpath(fullfile(P.path.PTB,'PsychBasic','MatlabWindowsFilesR2007a'));

% Clear global functions
clear mex global functions;
commandwindow;


%% -------------------- Initialise KICKR bike ----------------------------

% set bike ble as global
global bike

% Connect to KICKR Bike
if P.devices.bike

    [abort,initSuccessBike,bike] = InitKICKR();

    if abort
        QuickCleanup(P,dev);
        clear bike;
        return;
    end

end

%% ---------------- Initialise Heartrate Belt --------------------------
% set bike ble as global
global belt

% Connect to KICKR Bike
if P.devices.belt

    [abort,initSuccessBelt,belt] = InitBelt();

    if abort
        QuickCleanup(P,dev);
        clear belt;
        return;
    end

end

%% ---------------- Initialise Parameters and Screen -------------------

% Load Parameters for experiment
[P,O]                   = SetParams(P,O);
[P,O]                   = SetKeys(P,O);

% Query where to start experiment
[abort, P] = StartExperimentAt(P);
if abort; QuickCleanup(P,dev); return; end

% Open Screen
[P,O]                   = SetPTB(P,O);

% Get timing at script start
P.time.stamp            = datestr(now,30);
P.time.scriptStart      = GetSecs;


% ========================================================================
%%                              Cycling Experiment
% ========================================================================

%% Step 8: Warm up and Pre exposure

if P.startSection == 8
    load(P.out.file.paramCalib,'P','O');
    [P,O] = WarmUp(P,O);
end

%% Step 9: Cycling 

if P.startSection == 9
    load(P.out.file.paramCalib,'P','O');
    ShowIntroduction(P,4);
    RunExperiment_cycling(P,O);
end

%% Goodbye/End Experiment

ListenChar(0);
fprintf('\nC Y C L I N G    C O M P L E T E\n');
sca;



%%%%%%%
% END %
%%%%%%%

