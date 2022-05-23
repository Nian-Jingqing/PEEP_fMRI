%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experimental Script PEEP Scanner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --------------------- General Preparations ----------------------------

clc
close all;
clear all;

% restore the default path to delete other saved paths
restoredefaultpath

% add script base path
addpath('C:\Users\nold\PEEP\fMRI\Code\peep_functions_fMRI')
%addpath(genpath('D:\nold\PEEP\fMRI\Code\peep_functions_fMRI'))% for stim pc

%% ------------------ Experiment Preparations -----------------------------

% Instantiate Parameters and Overrides if they do not already exist
P                       = InstantiateParameters_scanner; % rename to InstantiateParameters_scanner
O                       = InstantiateOverrides;

% Load parameters if there
if exist(P.out.file.paramExp,'file')
    load(P.out.file.paramExp,'P');    
else 
    warning('No experimental parameters file P loaded');
end

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

%% ----------------- Create Logfiles --------------------------------------
P = make_logfiles(P);

if P.pain.PEEP.block == 1
   P = log_meta_data(P);
end


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


