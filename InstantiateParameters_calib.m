function P = InstantiateParameters_calib(P)

%% General settings (should be changed)
P.protocol.subID                = 2; % subject ID
P.protocol.day                  = 1; % Calib Day 1
P.calibration.cuff_arm          = 1; %Arm for pressure CALIBRATION [1 = LEFT, 2 = RIGHT]
P.experiment.cuff_arm           = P.calibration.cuff_arm; % Set calibration and experiment cuff to same arm
P.protocol.session              = 1;
P.subject.age                   = 27; % indicate subjects age
P.subject.gender                = 'f'; % indicate gender f = female, m = male
P.language                      = 'de'; % de or en
P.project.name                  = 'PEEP';
P.project.part                  = 'Pilot-01';
P.pharmacological.day2          = 'NaCl'; % Set wheteher receive Naloxone or NACL on day 2/day3
P.pharmacological.day3          = 'Naloxone';
P.toggles.doPainOnly            = 1; % VAS rating painful from 0 (not 50)
P.toggles.doConfirmAdaptive     = 1; % do adaptive VAS target regression with confirmation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Maybe move this part to main scripts 
P.devices.arduino               = 1; % if '' or [], will not try to use Arduino
P.devices.thermoino             = 1; % if '' or [], will not try to use Arduino
P.devices.SCR                   = 0; % SCR is used set to 1
P.devices.bike                  = []; % indicate whether bike is used
P.devices.belt                  = []; % HR belt
P.devices.trigger               = 0; % 1 single parallel port, arduino; rest undefined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
P.display.white                 = [1 1 1];
P.lineheight                    = 40;
P.display.startY                = 0.5;
P.display.Ytext                 = 0.25;
P.display.textsize_rating       = 30;
P.display.textsize_ratingBIG    = 40;

[~, tmp]                        = system('hostname');
P.env.hostname                  = deblank(tmp);
P.env.hostaddress               = java.net.InetAddress.getLocalHost;
P.env.hostIPaddress             = char(P.env.hostaddress.getHostAddress);

%% Set Paths

if strcmp(P.env.hostname,'stimpc1')
    P.path.scriptBase           = 'C:\Users\user\Desktop\PEEP\fMRI\Code\';
    P.path.experiment           = 'C:\Users\user\Desktop\PEEP\fMRI';
    P.path.PTB                  = 'C:\toolbox\Psychtoolbox';

elseif strcmp(P.env.hostname,'isnb05cda5ba721')
    P.path.scriptBase           = 'C:\Users\user\Desktop\PEEP\fMRI\Code\peep_functions_fMRI';
    P.path.experiment           = fullfile('C:\Data','PEEP-Pressure','data',P.project.name);
    P.path.PTB                  = 'C:\Data\Toolboxes\Psychtoolbox';
    P.path.data                 = '';

elseif strcmp(P.env.hostname,'DESKTOP-V2QJTRM')
    P.path.scriptBase           = 'C:\Users\user\Desktop\PEEP\fMRI\Code\peep_functions_fMRI';
    P.path.experiment           = 'C:\Users\user\Desktop\PEEP\fMRI\';
    P.path.PTB                  = 'C:\toolbox\Psychtoolbox';

elseif strcmp(P.env.hostname,'LAPTOP-41MRBS8P')
    P.path.scriptBase           = 'C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI';
    P.path.experiment           = 'C:\Users\nold\PEEP\fMRI\';
    P.path.PTB                  = 'C:\toolbox\Psychtoolbox';

elseif strcmp(P.env.hostname,'isna0291933759f')
    P.path.scriptBase           = 'C:\Users\user\Desktop\PEEP\fMRI\Code\';
    P.path.experiment           = 'C:\Users\user\Desktop\PEEP\fMRI';
    P.path.PTB                  = 'C:\toolbox\Psychtoolbox';


end

% Creat output paths based on day 2 or 3
if P.protocol.day == 2
    string_day = 'Day2';
    P.out.dirExp = fullfile(P.path.experiment,'Data','LogExperiment',P.project.part,['sub' sprintf('%03d',P.protocol.subID)],string_day);
    P.out.file.paramExp = fullfile(P.out.dirExp,['parameters_sub' sprintf('%03d',P.protocol.subID) '.mat']);

elseif P.protocol.day == 3
    string_day = 'Day3';
    P.out.dirExp = fullfile(P.path.experiment,'Data','LogExperiment',P.project.part,['sub' sprintf('%03d',P.protocol.subID)],string_day);
    P.out.file.paramExp = fullfile(P.out.dirExp,['parameters_sub' sprintf('%03d',P.protocol.subID) '.mat']);

elseif P.protocol.day == 1
    disp('Calibration Day');
    P.out.dirExp = fullfile(P.path.experiment,'Data','LogExperiment',P.project.part,['sub' sprintf('%03d',P.protocol.subID)]);
    P.out.file.paramExp = fullfile(P.out.dirExp,['parameters_sub' sprintf('%03d',P.protocol.subID) '.mat']);

else
    disp('No Day specified');
    P.out.dirExp = fullfile(P.path.experiment,'Data','LogExperiment',P.project.part,['sub' sprintf('%03d',P.protocol.subID)]);
    P.out.file.paramExp = fullfile(P.out.dirExp,['parameters_sub' sprintf('%03d',P.protocol.subID) '.mat']);

end

% Create output paths
%P.out.dirExp = fullfile(P.path.experiment,'Data','LogExperiment',P.project.part,['sub' sprintf('%03d',P.protocol.subID)]);
P.out.dirCalib = fullfile(P.path.experiment,'Data','LogCalibration',P.project.part,['sub' sprintf('%03d',P.protocol.subID)]);
P.out.dirUtils = fullfile(P.path.experiment,'Code','peep_functions_fMRI','utils');
P.out.file.painConditions = fullfile(P.out.dirUtils,"pain_conditions.mat");
%P.out.file.paramExp = fullfile(P.out.dirExp,['parameters_sub' sprintf('%03d',P.protocol.subID) '.mat']);
P.out.file.paramCalib = fullfile(P.out.dirCalib,['parameters_sub' sprintf('%03d',P.protocol.subID) '.mat']);
P.out.file.pressuresCalib = fullfile(P.out.dirCalib,['calib_pressures.mat']);
P.out.file.heatsCalib = fullfile(P.out.dirCalib,['calib_heats.mat']);
P.out.file.painConditions = fullfile(P.out.dirExp,'pain_conditions.mat');
P.out.file.painConditions_heat = fullfile(P.out.dirExp,'pain_conditions_heat.mat');
P.out.file.CPAR = ['sub' sprintf('%03d',P.protocol.subID) '_CPAR'];
P.out.file.THERMODE = ['sub' sprintf('%03d',P.protocol.subID) '_THERMODE'];
P.out.file.VAS = ['sub' sprintf('%03d',P.protocol.subID) '_VAS'];
P.out.file.BIKE = ['sub' sprintf('%03d',P.protocol.subID) '_BIKE'];
P.out.file.FTP = ['sub' sprintf('%03d',P.protocol.subID) '_FTP'];


% Create directory for experimental log
if ~exist(P.out.dirExp,'dir')
    mkdir(P.out.dirExp);
    fprintf('The directory %s was created.\n\n\n',P.out.dirExp);
    %else
    %    error('\nDirectory for saving data exist already %s.\n',P.out.dirExp);
end

% Create directory for calibration log
if ~exist(P.out.dirCalib,'dir')
    mkdir(P.out.dirCalib);
    fprintf('The directory %s was created.\n\n\n',P.out.dirCalib);
    %else
    %    error('\nDirectory for saving data exist already %s.\n',P.out.dirCalib);
end

% Set the arduione device
if P.devices.arduino
    if strcmp(P.env.hostname,'stimpc1')
        P.com.arduino = 'COM12'; % Mario COM11, Luigi COM12
        P.path.arduino = '';
        disp('stimpc1');
    elseif strcmp(P.env.hostname,'DESKTOP-V2QJTRM')
        P.com.arduino = 'COM3';
        P.path.cpar = fullfile('C:\Users\user\Desktop\PEEP\fMRI\Code\peep_functions\CPAR\LabBench.CPAR-master\cpar');
        disp('worklaptop');
    elseif strcmp(P.env.hostname,'isnb05cda5ba721')
        P.com.arduino = 'COM3';
        P.path.cpar = fullfile('C:\Users\user\Desktop\PEEP\fMRI\Code\peep_functions\CPAR\LabBench.CPAR-master\cpar');
        disp('other');
    elseif strcmp(P.env.hostname,'LAPTOP-41MRBS8P')
        P.com.arduino = 'COM5'; % CPAR: depends on PC - work laptop COM3 - experiment laptop COM5
        P.path.cpar = fullfile('C:\Users\nold\PEEP\fMRI\Code\CPAR\LabBench.CPAR-master\cpar');
        disp('experimentlaptop');

    elseif strcmp(P.env.hostname,'isna0291933759f')
        P.com.arduino = 'COM6'; % CPAR: depends on PC - work laptop COM6 - experiment laptop COM5
        P.path.cpar = fullfile('C:\Users\user\Desktop\PEEP\fMRI\Code\CPAR\LabBench.CPAR-master\cpar');
        disp('my_laptop');
    end
end

% Set the Thermode device
if P.devices.thermoino
    if strcmp(P.env.hostname,'stimpc1')
        P.com.thermoino = 'COM12'; % Mario COM11, Luigi COM12
        P.path.thermoino = '';
        disp('stimpc1');
    elseif strcmp(P.env.hostname,'LAPTOP-41MRBS8P')
        P.com.thermoino = 'COM6'; %
        P.path.thermoino = fullfile('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI\thermoino');
        P.com.thermoinoBaud= 115200;
        disp('experimentlaptop');
    elseif strcmp(P.env.hostname,'isna0291933759f')
        P.com.thermoino = 'COM6'; %
        P.com.thermoinoBaud = 115200; % ask Björn about the baud rate
        P.path.thermoino = fullfile('C:\Users\user\Desktop\PEEP\fMRI\Code\');
        disp('my_laptop');
    end
end

%% ----------------------------------------------------------------
%% MRI PARAMETERS 
%% -----------------------------------------------------------------
P.mri.dummy_scans = 5;


%% communcation with spike PC
P.com.port_addresses = [36912,36944]; 
P.com.codes          = [32,64,128; % for port 36912
                         1, 4, 8]; % for port 36944                    
P.com.duration       = 0.005; % wait time between triggers

% BY KARITA: Define outgoing port address
% if strcmp(P.env.hostname,'stimpc1')
%P.com.lpt.CEDAddressThermode = 888; % CHECK IF STILL ACCURATE
% P.com.lpt.CEDAddressSCR     = 36912; % as per new stimPC; used to be =P.com.lpt.CEDAddressThermode;
% else
% P.com.lpt.CEDAddressSCR = 888;
% end
% P.com.lpt.CEDDuration           = 0.005; % wait time between triggers


%% Stimulus parameters CPAR

% Define Arm cuffs
arm_cuff                                = [1 2]; % 1 = left arm CPAR cuff 1, 2 = right arm CPAR cuff 2 - DO NOT EDIT - HARDCODED FOR A REASON
P.pain.preExposure.cuff_left            = arm_cuff(1); % 1: left, 2: right - depends on how cuffs plugged into the CPAR unit and put on participant's arm
P.pain.preExposure.cuff_right           = arm_cuff(2); % hardcoded on purpose!
P.pain.cuffSide                         = {'LEFT' 'RIGHT'}; % cuff 1: left arm, cuff 2: right arm
P.pain.cuffSideDe                       = {'LINKER' 'RECHTER'}; % cuff 1: left arm, cuff 2: right arm

% General CPAR
P.cpar.forcedstart                      = true; % CPAR starts even if VAS rating device of CPAR is not at 0 (otherwise false)
P.cpar.stoprule                         = 'bp';  % CPAR stops only at button press (not when VAS rating with the device reaches the maximum, 'v')
P.cpar.initdone                         = 0;

%%  Pre-exposure
P.pain.preExposure.repeat               = 1; % number of repeats of each stimulus
P.pain.preExposure.pressureIntensity    = [25 30 35 40 45 50 55 60 65 70 75 80 85 90 95]; % preexposure pressure intensities (kPa)
P.pain.preExposure.riseSpeed            = 30; % kPa/s
P.pain.preExposure.pressureRange        = 5.0:1:100.0; % possible pressure range (kPa)
P.pain.preExposure.startSimuli          = [10 20];
P.pain.preExposure.sStimPlateauPreExp   = 15; % duration of the constant pressure plateau after rise time for pre-exposure (part 1)
P.pain.preExposure.sPreexpITI           = 15; % pre-exposure intertrial interval (ITI)
P.pain.preExposure.totalDuration        = P.pain.preExposure.sStimPlateauPreExp/P.pain.preExposure.riseSpeed+P.pain.preExposure.sStimPlateauPreExp; % pre-exposure cue duration (stimulus duration with rise time included)
P.pain.preExposure.sPreexpISI           = 15; %intervall between stimuli 15 seconds

%% Awiszus pain threshold search
P.awiszus.N                             = 6; % number of trials
P.awiszus.X                             = P.pain.preExposure.pressureIntensity(1):1:P.pain.preExposure.pressureIntensity(end);  % kPa range to be covered
P.awiszus.mu                            = 30; % assumed population mean (also become first stimulus to be tested),
P.awiszus.sd                            = 8; % assumed population std, kPa
P.awiszus.sp                            = 1; % assumed individual spread, kPa
P.awiszus.nextX                         = P.awiszus.mu; % first phasic stimulus

%% VAS training
P.pain.VAStraining.nRatings             = 2; % 2 different ratings
P.pain.VAStraining.trials               = 2; % train each scale 2 times
P.pain.VAStraining.durationITI          = 5;
P.pain.VAStraining.durationVAS          = 7; % 7 seconds per rating

%% Psychometric scaling
P.pain.psychScaling.calibStep           = 1;
P.pain.psychScaling.trials              = 4;
P.pain.psychScaling.thresholdMultiplier = 0.25; % multiplier for pain threshold to determine step size for pressure intensities

%% Calibration CPAR
P.pain.calibration.pressure                     = []; % preallocate variables
P.pain.calibration.rating                       = [];
P.pain.calibration.calibStep.fixedTrials        = 2;
P.pain.calibration.calibStep.adaptiveTrials     = 3;


% General Calibration
P.pain.calibration.VASTargetsFixed              = [10,30,90]; 
P.pain.calibration.VASTargetsFixedPresetSteps   = [5,10,20];
P.pain.calibration.VASTargetsVisual             = [10,20,30,40,50,60,70,80];
P.pain.calibration.painTresholdPreset           = 30;
P.pain.calibration.sStimPlateauCalib            = P.pain.preExposure.sStimPlateauPreExp; % duration of stim plateau in seconds
P.pain.calibration.defaultpredPressureLinear     = [10 20 30 40 50 60 70 80]; % default predicted pressures if calibration fails completely


P.pain.calibration.firstTrialWait               = 5;
P.pain.calibration.sCalibITI                    = P.pain.preExposure.sPreexpITI;
P.pain.calibration.sCalibISI                    = P.pain.preExposure.sPreexpISI;
P.pain.calibration.durationVAS                  = P.pain.VAStraining.durationVAS;
P.pain.calibration.blockstopWait                = 2; % 2 seconds for aborting a block at the start

%% Parameters Thermode

P.pain.thermoino.cueing               = 1; % whether pain stimuli and others will be cued (typically by white/red cross)
P.pain.thermoino.sStimPlateauPreexp   = 15;
P.pain.thermoino.sStimPlateau         = 15; % 15 seconds of stimulus plateau
P.pain.thermoino.sCalibITI            = [8 10]; % sum of all segments contributing to the ITI
P.pain.thermoino.sMaxRating           = 7; % Presentation duration of rating scale

P.pain.thermoino.bT                           = 32; % baseline temp
P.pain.thermoino.rS                           = 13; % rise speed
P.pain.thermoino.fS                           = 13; % fall speed
P.pain.thermoino.maxSaveTemp                  = 48; % max temp for calib
P.pain.thermoino.minTemp                      = 40; % min temp for calib

%% Calibration Thermode

% Manual variable definition (hardcoded toggles)
P.toggles.doPainOnly        = 1;
P.toggles.doScaleTransl     = 1; % scale translation from binary via two-dimensional to uni-dimensional (only needed for P.toggles.doPainOnly==1)
P.toggles.doPsyPrcScale     = 1; % psychometric-perceptual scaling; either this is REQUIRED, or numel(step2Range)>2
P.toggles.doFixedInts       = 0;
P.toggles.doPredetInts      = 1;
P.toggles.doAdaptive        = 1; % adaptive procedure to fill up bins
P.toggles.doConfirmAdaptive = 1;

P.pain.calibration.heat                         = []; % preallocate variables
P.pain.calibration.heat.notes{1} = 'Instantiated';
P.pain.calibration.heat.PeriThrN = 1;

   
P.pain.calibration.rating                       = [];
P.pain.calibration.calibStep.fixedTrials        = 2;
P.pain.calibration.calibStep.adaptiveTrials     = 3;

% stimulus parameters
P.presentation.cueing                           = 1; % whether pain stimuli and others will be cued (typically by white/red cross)
P.presentation.sStimPlateauPreexp               = 15;
P.presentation.sStimPlateau                     = 15;
P.presentation.sCalibITI                        = [8 10]; % sum of all segments contributing to the ITI

% General Calibration
P.pain.calibration.VASTargetsFixed              = [10,30,90]; 
P.pain.calibration.VASTargetsFixedPresetSteps   = [5,10,20];
P.pain.calibration.VASTargetsVisual             = [10,20,30,40,50,60,70,80];
P.pain.calibration.painTresholdPreset           = 30;
P.pain.calibration.sStimPlateauCalib            = P.pain.preExposure.sStimPlateauPreExp; % duration of stim plateau in seconds
P.pain.calibration.defaultpredHeatLinear        = [42 42.5 43 43.5 44 44.5 45 45.5]; % default predicted pressures if calibration fails completely


%% Awiszus heat pain threshold search
P.awiszus.thermoino.N                             = 6; % number of trials
P.awiszus.thermoino.X                             = 41.0:0.01:47.0;  % kPa range to be covered
P.awiszus.thermoino.mu                            = 43.0;% assumed population mean (also become first stimulus to be tested),
P.awiszus.thermoino.sd                            =  1.2; % assumed sd of threshold (population level) 
P.awiszus.thermoino.sp                            = 0.4; % assumed spread of threshold (individual level); we started at 0.8
P.awiszus.thermoino.nextX                         = P.awiszus.thermoino.mu; %starting point  
%% for Preexposure (Section 1)
P.pain.preExposure.vec_int                          = [42 43]; % vector of intensities used for preexposure, intended to lead to binary decision "were any of these painful y/n"
P.presentation.sStimPlateauPreexp; % as per InstantiateParameters; modify if desired

%% for Sections >1
P.presentation.sStimPlateau; % as per InstantiateParameters; modify if desired

%% for Thresholding (Section 2)
P.presentation.sMinMaxThreshITIs = [8 12]; % seconds between stimuli; will be randomized between two values - to use constant ITI, use two identical values
P.presentation.sMinMaxThreshCues = [0.5 2]; % jittered time prior to the stimulus that the white cross turns red; can be [0 0] (to turn off red cross altogether), but else MUST NOT BE LOWER THAN 0.5

%% for Sections >2
P.presentation.sMinMaxPlateauITIs = P.presentation.sCalibITI; % overrides the old values from thresholding [9 11]
P.presentation.sMinMaxPlateauCues = [0.5 1]; % should correspond to overrides the old values from thresholding
P.presentation.sMaxRating           = 7; % Presentation duration of rating scale
%% for Validation (Section 6)
P.presentation.NValidationSessions = 0;
P.presentation.n_max_varTrial      = 6;
        
addpath(genpath(P.path.scriptBase))
[P.presentation.thresholdITIs,P.presentation.thresholdCues]=DetermineITIsAndCues(P.awiszus.thermoino.N,P.presentation.sMinMaxThreshITIs,P.presentation.sMinMaxThreshCues);
P.presentation.firstThresholdITI = 1;
P.presentation.firstThresholdCue = max(P.presentation.sMinMaxThreshCues);

P.presentation.firstPlateauITI = 1; % override, no reason for this to be so long
P.presentation.firstPlateauCue = max(P.presentation.sMinMaxPlateauCues);

P.presentation.sPreexpITI = 0;
P.presentation.sPreexpCue = 0;
P.presentation.scaleInitVASRange = [20 81];

% HARDCODED STUFF THAT SHOULD NOT BE HARDCODED
P.plateaus.step1Seq = [0.5 1.0 2.0 1.0]; % FOR USE WITH VARIABLE PROCEDURE

if P.toggles.doFixedInts
    %         P.plateaus.step2Seq = [0.1 0.9 -2.0 0.4 -0.6 -0.2 1.6 -1.2]; % Example sequence for fixed intensities; legacy: PMParam
    %         P.plateaus.step2Seq = [0.1 1.6 -1.2 0.9]; % Example sequence for fixed intensities
    if ~isempty(O.pain.step2Range)
        P.plateaus.step2Seq = O.pain.step2Range;
    end
else
    P.plateaus.step2Seq = []; % in this case, the entire section will be skipped
end

P.plateaus.step3TarVAS = [10 30 90]; % FOR USE WITH FIXED RATING TARGET PROCEDURE
%     if ~isempty(O.pain.step3TarVAS)
%         step3TarVAS = O.pain.step3TarVAS;
%     end

% OPTION TO VALIDATE CALIBRATION RESULTS
% if P.presentation.NValidationSessions>0, n sessions will be performed using step5 info; THESE DATA WILL BE SAVED TO PLATEAULOG, AS WELL!
% (not to plateauResultsLog, however). This is for your convenience, until the time where it shall not be convenient any longer.
% This will include preexposure, because it only makes
P.plateaus.step5SeqF = [20 80]; % these will not be shuffled (F=fixed), intended to be applied after preexposure
P.plateaus.step5SeqR = [10 30:10:70 90]; % these will be shuffled (R=random), and concatenated to step5SeqF
P.plateaus.step5Preexp = [-20 -10 0 0]; % note: negative values can lead to weird stimulus intensities using sigmoid fit

P.plateaus.VASTargets = [30,50,70]; % this is mostly for export/display purposes

P.presentation.sBlank = 0.5;

%% parameters bike calibration: (time in minutes)
P.FTP.parameters.step1.length = 20;
P.FTP.parameters.step2.length_cycle = 1;
P.FTP.parameters.step2.length_recov = 1;
P.FTP.parameters.step2.nTrials = 6;
P.FTP.parameters.step3.length_allout = 5;
P.FTP.parameters.step4.length = 10; % maybe 10 minutes?
P.FTP.parameters.step5.length_allout = 20;
P.FTP.parameters.coolDown = 1;

%% Experiment parameters

%___________________________________________________________________
% TIMING
%--------------------------------
%   
%   12 stimuli (pain) of 15 seconds per block   = 3 min
% + 12 x 15 s ITI  (jitter +/- 2 secs inclduing rating)  = 3 min
% + Exercise 10 min per block + 7 seconds rating = 10 min
% -----------------------------------------------------
% TIME PER BLOCK: 16 Minutes
% TIME BETWEEN CYCLING AND LAYING DOWN: 7 Minutes
% -> 4 blocks = 4x 23~  92 min
%___________________________________________________________________

% General
P.pain.PEEP.nBlocks                              = 4; % number of experimental blocks and exercises
P.pain.PEEP.block                                = 1; % Counter for block wll be updated after each block
P.pain.PEEP.blocks                              = [1,2,3,4];
P.pain.PEEP.nTrials                              = 18; %number of pains per block (4 pains 3 times)
P.pain.PEEP.nStimuli                             = 3; % 3 different pain levels

%% random distribution between 13 and 17 seconds to draw ITI from (CPAR needs 13 seconds to deflate after 70 VAS)
% ITI: 13 -17 seconds, including Rating (7secs):
% 13 - 7 = 6 seconds
% 17 - 7 = 10 seconds
% ITI ranges between 6 and 10 seconds plus the 7 seconds of rating

N                                       = P.pain.PEEP.nBlocks.*P.pain.PEEP.nTrials;
P.project.ITI_rand                      = floor(4 + (11-4).*rand(N,1));
P.project.ITI_start                     = 1;

% VAS rating parameters
P.pain.PEEP.waitforVAS                           = 1; % time to wait until VAS onset after stimulus end
P.pain.PEEP.ratings.durationVAS                  = P.pain.VAStraining.durationVAS; % duration of ratings

% Aerobic Exercise (Cycling)
P.exercise.duration                             = 600; % 100 minutes duration for each exercise block
P.exercise.highIntdefault                       = 300; % default in Watt
P.exercise.lowIntdefault                        = 100; % default in Watt
P.exercise.constPressure                        = 0; % set 5 kPa constant pressure during exercise block to prevent cuff from moving
P.exercise.exercise_conditions                  = [zeros(1,P.pain.PEEP.nBlocks/2) ones(1,P.pain.PEEP.nBlocks/2)]; % randomise exercise condidition (1 = high intensitiy, 0 = low intensitiy)
P.exercise.ordering                             = randperm(P.pain.PEEP.nBlocks);
P.exercise.conditions_rand                      = P.exercise.exercise_conditions(P.exercise.ordering);
P.exercise.condition                            = P.exercise.conditions_rand;
P.exercise.wait                                 = 5; % wait 5 seconds before exercise starts
P.exercise.results                              = [];

% Pressure Pain
P.pain.PEEP.repeat                               = 6; % number of repeats of each stimulus
P.pain.PEEP.pressureIntensity                    = [25 30 35 40 45 50 55 60 65 70 75 80 85 90 95]; % preexposure pressure intensities (kPa)
P.pain.PEEP.riseSpeed                            = P.pain.preExposure.riseSpeed; % kPa/s
P.pain.PEEP.pressureRange                        = P.pain.preExposure.pressureRange; % possible pressure range (kPa)
P.pain.PEEP.sStimPlateauExp                      = P.pain.preExposure.sStimPlateauPreExp; % duration of the constant pressure plateau after rise time for pre-exposure (part 1)
P.pain.PEEP.sExpITI                              = P.pain.preExposure.sPreexpITI; % experiment intertrial interval (ITI)
P.pain.PEEP.sExpISI                              = P.pain.preExposure.sPreexpISI; % experiment intertrial interval (ITI)
P.pain.PEEP.totalDuration                        = P.pain.PEEP.sStimPlateauExp/P.pain.PEEP.riseSpeed +P.pain.PEEP.sStimPlateauExp; % pre-exposure cue duration (stimulus duration with rise time included)
P.pain.PEEP.jitter                               = 0:0.5:2; % jitter for onset of phasic stimuli in seconds
P.pain.PEEP.trialsPerBlock                       = P.pain.PEEP.repeat*P.pain.PEEP.nStimuli;
P.pain.PEEP.pressure                             = [];
P.pain.PEEP.ratings                              = [];


%% Load correct cycle intensities (matrix) for correct subject
goal_N                                  = 99;
conditions                              = [zeros(1,4/2) ones(1,4/2)]; % randomise exercise condidition (1 = high intensitiy, 0 = low intensitiy)

filespec2                                   = strcat("cycle_ints_", P.project.part, ".mat");
P.out.file.cycleIntensities                 = fullfile(P.out.dirUtils,filespec2);

if exist(P.out.file.cycleIntensities,'file')
    load(P.out.file.cycleIntensities,'exercise_conditions_all_subjects');
else
    unique_permutations = unique(perms(conditions),'rows');
    numel_uperm = size(unique_permutations,1);
    repetitions = ceil(goal_N/numel_uperm);
    conditions_list = repmat(unique_permutations, [repetitions 1]);
    exercise_conditions_all_subjects = conditions_list(randperm(goal_N),:);
%    save(['C:\Users\nold\PEEP\fMRI\Code\peep_functions\utils\cycle_ints_',P.project.part],'exercise_conditions_all_subjects');
end

P.exercise.condition = exercise_conditions_all_subjects(P.protocol.subID,:);


% % Create matrix for random order of painconditions and each exercise block


% %% Load correct pressure pains (matrix) for correct subject
% %P.out.dirUtils = fullfile(P.path.experiment,'utils');
% filespec = strcat("pain_conditions_cpar_", P.project.part, ".mat");
% P.out.file.painConditions = fullfile(P.out.dirUtils,filespec);
% load(P.out.file.painConditions,'painconditions_all_subjects_cpar');
% P.pain.PEEP.painconditions_mat = painconditions_all_subjects_cpar(:,:,P.protocol.subID);
% 
% 
% if exist(P.out.file.painConditions,'file')
%     load(P.out.file.painConditions,'painconditions_all_subjects_cpar');
% else
% 
%     for n = 1:100
% 
%         for i = 1:4
% 
%             painconditions                       = repelem([3,5,7],3); % Different intensitiy conditions 1 = low (10 VAS), 3 = low-mid (30 VAS), 5 = high mid (50 VAS), 7 = high (70 VAS). Repeat each condition 12 times per block
%             painconditions_ordering              = painconditions (randperm(length(painconditions)));
%             painconditions_mat(i,:)              = painconditions_ordering;
% 
%         end
% 
%         painconditions_all_subjects_cpar(:,:,n) = painconditions_mat(:,:);
% 
%      %   save(['C:\Users\nold\PEEP\fMRI\Code\peep_functions\utils\pain_conditions_',P.project.part],'painconditions_all_subjects');
% 
%     end
% 
%     P.pain.PEEP.painconditions_mat = painconditions_all_subjects_cpar(:,:,P.protocol.subID);
% 
% end
% 
% %% Load correct thermode pains (matrix) for correct subject
% %P.out.dirUtils = fullfile(P.path.experiment,'Code','utils');
% filespec = strcat("pain_conditions_thermode_", P.project.part, ".mat");
% P.out.file.painConditions_heat = fullfile(P.out.dirUtils,filespec);
% load(P.out.file.painConditions_heat,'painconditions_all_subjects_thermode');
% P.pain.PEEP.thermode.painconditions_mat = painconditions_all_subjects_thermode(:,:,P.protocol.subID);
% 
% 
% if exist(P.out.file.painConditions_heat,'file')
%     load(P.out.file.painConditions_heat,'painconditions_all_subjects_thermode');
% else
% 
%     for n = 1:100
% 
%         for i = 1:4
% 
%             painconditions                       = repelem([3,5,7],3); % Different intensitiy conditions 1 = low (10 VAS), 3 = low-mid (30 VAS), 5 = high mid (50 VAS), 7 = high (70 VAS). Repeat each condition 12 times per block
%             painconditions_ordering              = painconditions (randperm(length(painconditions)));
%             painconditions_mat(i,:)              = painconditions_ordering;
% 
%         end
% 
%         painconditions_all_subjects_thermode(:,:,n) = painconditions_mat(:,:);
% 
%      %   save(['C:\Users\nold\PEEP\fMRI\Code\peep_functions\utils\pain_conditions_',P.project.part],'painconditions_all_subjects');
% 
%     end
% 
%     P.pain.PEEP.thermode.painconditions_mat = painconditions_all_subjects_thermode(:,:,P.protocol.subID);
% 
% end

% Load cpar and thermode matrix for pain intensities depending on Day!!! 

if P.protocol.day == 2
    
    filespec = strcat("pain_conditions_cpar_thermode_", P.project.part, "_day2.mat");
    P.out.file.painConditions = fullfile(P.out.dirUtils,filespec);

    if exist(P.out.file.painConditions,'file')
        load(P.out.file.painConditions,'painconditions_all_subjects_cpar_thermode');
    else


    end

    P.pain.PEEP.painconditions_mat = painconditions_all_subjects_cpar_thermode(:,:,P.protocol.subID);

    fprintf('Pain Conditions for Day 2 Loaded');

elseif P.protocol.day == 3

    filespec = strcat("pain_conditions_cpar_thermode_", P.project.part, "_day3.mat");
    P.out.file.painConditions = fullfile(P.out.dirUtils,filespec);

    if exist(P.out.file.painConditions,'file')
        load(P.out.file.painConditions,'painconditions_all_subjects_cpar_thermode');
    else


    end

    P.pain.PEEP.painconditions_mat = painconditions_all_subjects_cpar_thermode(:,:,P.protocol.subID);

    fprintf('Pain Conditions for Day 3 Loaded');

end

end
