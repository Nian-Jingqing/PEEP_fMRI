
clc
close all;
clear all;

% restore the default path to delete other saved paths
restoredefaultpath

% add script base path
addpath('C:\Users\nold\PEEP\Behavioural\Code\peep_functions')


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

% Load Parameters for experiment
[P,O]                   = SetParams(P,O);
KbName('UnifyKeyNames');

    
    % Use with computer keys
    P.keys.name.right               = KbName('RightArrow');
    P.keys.name.left                = KbName('LeftArrow');
    P.keys.name.esc                 = KbName('Escape');  
    P.keys.name.confirm             = KbName('return');
 


% Open Screen
[P,O]                   = SetPTB(P,O);


ratingsection = 2;
[abort,finalRating,reactionTime,keyId,keyTime,response] = singleratingScale_bigger(P,ratingsection);
WaitSecs(10);

Screen('Flip',P.display.w);
sca;