%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experimental Script PEEP Calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --------------------- General Preparations ----------------------------

clc
close all;
clear all;

% restore the default path to delete other saved paths
restoredefaultpath

% add script base path
addpath(genpath('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI'));

P = InstantiateParameters_calib;
O = InstantiateOverrides;

addpath(genpath(P.path.scriptBase));
addpath(genpath(P.path.PTB));
addpath(fullfile(P.path.PTB,'PsychBasic','MatlabWindowsFilesR2007a'));

% Clear global functions
clear mex global functions;
commandwindow;


%% ---------------- Initialise Parameters and Keys -------------------

% Load Parameters for experiment
[P,O]                   = SetParams(P,O);
[P,O]                   = SetKeys(P,O);

abort  = 0;

% Query where to start experiment
[abort, startSection] = StartCalibrationAt(P);

while ~abort

    %% ----------------- Thermode Calibration .--------------------------------

    if startSection == 1
    [abort,P,O] = calib_heat(P,O);
    sca;
    end 

    %% ----------------- Pressure Cuff Calibration .---------------------------

    if startSection == 2
    [abort,P,O,calibrated_pressures] = calib_pressure(P,O);
    sca;

    end 
    %% ----------------- Bike FTP Calibration ---------------------------------

    if startSection == 3
    [abort, P,FTP] = calib_bike(P,O);
    sca;

    end 

    if abort
        QuickCleanup(P);
        return;
    else
        ListenChar(0);
        fprintf('\nC A L I B R A T I O N    C O M P L E T E\n');
        sca;
    end

end

%%%%%%%
% END %
%%%%%%%



