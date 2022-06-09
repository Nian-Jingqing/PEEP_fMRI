%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experimental Script PEEP Cycling
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
P                       = InstantiateParameters_bike;
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

% Load parameters if there
if exist(P.out.file.paramExp,'file')
    load(P.out.file.paramExp,'P');
else
    warning('No cycling parameters file P loaded (Block 1)');
end


if abort; QuickCleanup(P,dev); return; end

% Open Screen
[P,O]                   = SetPTB(P,O);

% Get timing at script start9
P.time.stamp            = datestr(now,30);
P.time.scriptStart      = GetSecs;


% ========================================================================
%%                              Cycling Experiment
% ========================================================================

if P.pain.PEEP.cyclingBlock == 1
    [P,O] = WarmUp(P,O);
end


%% Cycling


RunExperiment_cycling(P,O);


%% Goodbye/End Experiment

ListenChar(0);
fprintf('\nC Y C L I N G    C O M P L E T E\n');
sca;



%%%%%%%
% END %
%%%%%%%


