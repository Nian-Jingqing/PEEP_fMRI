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
addpath('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI')

% Query where to start experiment
[abort, startSection] = StartCalibrationAt;

abort  = 0;

while ~abort
    %% ----------------- Thermode Calibration .--------------------------------

    if startSection == 1
    [abort,P,O,calibrated_heats] = calib_heat(P,O);
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
        QuickCleanup(P,dev);
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



