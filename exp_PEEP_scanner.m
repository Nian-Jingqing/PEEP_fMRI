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
addpath('C:\Users\user\Desktop\PEEP\Behavioural\Code\peep_functions_new_paradigm')


%% ------------------ Experiment Preparations -------------------------

% Instantiate Parameters and Overrides
P                       = InstantiateParameters;
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

%% ----------------- Initialise SCR ---------------------------------------
%
%
%
%

%% ----------------- Initial pressure cuff -----------------------------

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                          Block 1a: Calibration Pressure Cuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step 0: General Welcome

if P.startSection < 1
    ShowIntroduction(P,0);
end

%% Step 1: Pre Exposure and Awiszus Method

if P.startSection < 2
    ShowIntroduction(P,1);
    [P,abort] = PreExposureAwiszus(P,O,dev);
end

%%  Step 2: VAS Training

if P.startSection < 3
    load(P.out.file.paramCalib,'P','O');
    ShowIntroduction(P,2);

    for i = 2:P.pain.VAStraining.nRatings
        [P,abort] = VASTraining(P,O,i,dev);
        i = i + 1;
    end

end

%% Step 3: Calibration: Psychometric Scaling

if P.startSection < 4
    load(P.out.file.paramCalib,'P','O');
    ShowIntroduction(P,3);
    [P,abort] = PsychometricScaling(P,O);

end

%% Step 4: Calibration: VAS Target Regresion

if  P.startSection < 5
    load(P.out.file.paramCalib,'P','O');
    [P,abort] = TargetRegressionVAS(P,O);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Block 1b: Bike Calibration FTP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if P.startSection ==5
    load(P.out.file.paramCalib,'P','O');
    [FTP,P] = calibBike_FTP(P,O,bike,belt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                              Block 2: Experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step 1: Warm up and Pre exposure

if P.startSection == 8
    load(P.out.file.paramCalib,'P','O');
    [P,O] = WarmUp(P,O);
    PreExposure(P,O,dev);
end

%% Step 2: Cycling and Pain

if P.startSection == 9
    load(P.out.file.paramCalib,'P','O');
    ShowIntroduction(P,4);
    RunExperiment(P,O,dev);
end

%% Goodbye/End Experiment

ShowIntroduction(P,5);

if abort
    QuickCleanup(P,dev);
    return;
else
    ListenChar(0);
    fprintf('\nE X P E R I M E N T    C O M P L E T E\n');
    sca;

end


%%%%%%%
% END %
%%%%%%%


