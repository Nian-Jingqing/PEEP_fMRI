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
P                       = InstantiateParameters_calib;
O                       = InstantiateOverrides;


% Add paths CPAR
if P.devices.arduino
    addpath(genpath(P.path.cpar));
end

% Add paths Thermoino
if P.devices.thermoino
    try
        P.presentation.thermoinoSafetyDelay = 0.1; % thermoino safety delay for short plateaus; 0.1 seems robust
        addpath(P.path.thermoino)
    catch
        warning('Thermoino scripts not found in %s. Aborting.',P.path.thermoino);
        return;
    end
end

addpath(genpath(P.path.scriptBase));
addpath(genpath(P.path.PTB));
addpath(fullfile(P.path.PTB,'PsychBasic','MatlabWindowsFilesR2007a'));

% Clear global functions
clear mex global functions;
commandwindow;


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

% Connect to Belt
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

% ======================================================================
%% Block 1a: Calibration Thermode
%======================================================================

%% Step 0: General Welcome

if P.startSection < 1
    ShowIntroduction(P,0);
end


%% Step 1: Pre Exposure and Awiszus Method + VAS Training

 if P.devices.thermoino

    if P.startSection < 2

        %   [abort]=ShowInstruction(P,1);
        if abort;QuickCleanup(P);return;end

        [abort,preexPainful_heat]=Preexposure_heat(P,O); % sends four triggers, waits ITI seconds after each

        if abort;QuickCleanup(P);return;end

   else
        preexPainful_heat = 1; % then we start with the conservative assumption that the top preexposure temp was experienced as painful
   end


    %% Awiszus Method

    if preexPainful_heat==0
        P.awiszus.thermoino.mu = 44.0;
    else
        P.awiszus.thermoino.mu = 43.0;
    end
    fprintf('\nReady FIRST THRESHOLD at %1.1f°C.\n',P.awiszus.mu);

    %         [abort]=ShowInstruction(P,O,2,1);
    if abort;QuickCleanup(P);return;end
    P = DoAwiszus_heat(P,O);
%else
%   P = GetAwiszus(P);


        %% VAS Training
        %load(P.out.file.paramCalib,'P','O');
        
        
        %ShowIntroduction(P,2);

        %for i = 2:P.pain.VAStraining.nRatings
        %    [P,abort] = VASTraining(P,O,i,dev);
        %    i = i + 1;
        %end

    %% Step 2: Calibration

    if P.startSection < 3

        load(P.out.file.paramCalib,'P','O');
        P=DetermineSteps(P);
        [P.presentation.plateauITIs,P.presentation.plateauCues]=DetermineITIsAndCues(numel(P.plateaus.step2Order),P.presentation.sMinMaxPlateauITIs,P.presentation.sMinMaxPlateauCues); % DEPRECATED, use if balanced ITIs/Cues are desired; currently, everything is random within the range defined by P.presentation.sMinMaxPlateau*
        P.presentation.firstPlateauITI = 5; % override, no reason for this to be so long
        P.presentation.firstPlateauCue = max(P.presentation.sMinMaxPlateauCues);

        WaitSecs(0.2);

        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);
        end

        P.time.plateauStart=GetSecs;

        [abort,P]=TrialControl(P,O);
        if abort;QuickCleanup(P);return;end

        %%%%%%%%%%%%%%%%%%%%%%%
        % REPORTING
        P.time.scriptEnd=GetSecs;
        PrintDurations(P); % simple output function to see how long the calibration took

        %%%%%%%%%%%%%%%%%%%%%%%
        % LEAD OUT
        %ShowInstruction(P,O,4);

        sca;
        ListenChar(0);

        if nargout>1
            varargout{1} = P.pain.calibration.heat;
        end

    end
    %     %%%%%%%%%%%%%%%%%%%%%%%
    %     % END
    %     %%%%%%%%%%%%%%%%%%%%%%%

end

% =======================================================================
%% Block 1b: Calibration Pressure Cuff
% =======================================================================

if P.devices.arduino
    
    %% Step 3: Pre Exposure and Awiszus Method + VAS Training

    if P.startSection < 4
        ShowIntroduction(P,1);
        [P,abort] = PreExposureAwiszus(P,O,dev);

        % VAS Training
        load(P.out.file.paramCalib,'P','O');
        ShowIntroduction(P,2);

        for i = 2:P.pain.VAStraining.nRatings
            [P,abort] = VASTraining(P,O,i,dev);
            i = i + 1;
        end
    end


    %% Step 4: Calibration: Psychometric Scaling

    if P.startSection < 5
        load(P.out.file.paramCalib,'P','O');
        ShowIntroduction(P,3);
        [P,abort] = PsychometricScaling(P,O);

    end

    %% Step 5: Calibration: VAS Target Regresion

    if  P.startSection < 6
        load(P.out.file.paramCalib,'P','O');
        [P,abort] = TargetRegressionVAS(P,O);

    end



end

% ======================================================================
%%  Block 2: Bike Calibration FTP
% ======================================================================

if P.devices.bike

    if P.startSection == 6
        load(P.out.file.paramCalib,'P','O');
        [FTP,P] = calibBike_FTP(P,O,bike,belt);
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


