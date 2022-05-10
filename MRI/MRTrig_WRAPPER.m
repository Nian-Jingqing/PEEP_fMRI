% This is an example script to understand logging triggers provided by the 
% MR scanner at the start of each scan happening at TR intervals. It includes
% two major components:
% 1. Initialization and reading of a keyboard queue (PTB's KbQueue), which is 
%    the only essential function.
% 2. A delay loop ("Ready mode") useful for a controlled start of the experiment,
%    when a number of dummy scans >= 0 are received.
%
% Version: 1.0
% Authors: Björn Horing, bjoern.horing@gmail.com (compilation and structuring of
%          file collection, nothing creative)
%          Selim Onat (several subfunctions, e.g. KbQueueDump)
%          Several others (presumably)
% Date: 2021-09-14
%
% Dependencies: Psychtoolbox

%% Demo control variables
forceInput = 1; % for actual experimental script, set to 0 or remove forceInput from line
% tStart = MRTrig_Start(P,forceInput); 
% note that ListenChar(2) deactivates keyboard output even after an error is thrown;
% you can deactivate it again by using Ctrl+C ONCE, even in debug mode

%% SETTINGS of parameter (and log!) variable P
P = struct;
P.path.x = 'D:\Documents\projects\GENERIC';
P.path.save = [P.path.x filesep 'exampleLog.mat']; % use valid path
if ~exist(P.path.x,'dir');mkdir(P.path.x);end
P.mri.nDelay = 5;
P.mri.nTrigger = 0;
P.keys.trigger = KbName('5%');
P.keys.triggerKeyList = zeros(1,256); % create keyboard filter
P.keys.triggerKeyList(P.keys.trigger) = 1; % allow only MR triggers to enter queue
P.devices.input = [];
P.log.nevents = 0; % example
P.log.events = {}; % example
P.log.nfMRIEvents = 0;
P.log.fMRIEvents = {};

%% INITIALIZATION PART 1
% Important! After this section, DO NOT use ListenChar anymore! It is INCOMPATIBLE with KbQueue!
ListenChar(2); % switch keyboard input to listen only
clear functions; % necessary to get ListenChar (GetChar) to work with KbQueue

%%
% Your own initializations, like PTB parameters
% It's important you do this AFTER you clear functions, or things will break
%

%% ENTER READY MODE
% At this point, the script will be held until a N==P.mri.nDelay have been received.
tStart = MRTrig_Start(P,forceInput); % REMOVE FORCEINPUT AGAIN, just for testing purposes
P.log.mriExpStartTime = tStart(end); % this variable will be subtracted from all timings, as real start of the experiment
for t = 1:numel(tStart) % loop through timings from all logged triggers, and enrich var P with trigger info
    P = MRTrig_Log(P,  'events'  ,tStart(t),['Dummy' num2str(t)]); % suggestion for general log usable 
                                                                    % for ALL events (e.g. cues, onsets, ITIs)
    P = MRTrig_Log(P,'fMRIEvents',tStart(t),['Dummy' num2str(t)]); % log triggers in parameter variable
end
% now enter the last trigger again as proper start of the experiment
P = MRTrig_Log(P,  'events'  ,P.log.mriExpStartTime,'FirstMRPulse_ExpStart');
P = MRTrig_Log(P,'fMRIEvents',P.log.mriExpStartTime,'FirstMRPulse_ExpStart');

%% INITIALIZATION PART 2
KbQueueCreate(P.devices.input,P.keys.triggerKeyList); % initialize queue
KbQueueStart; % start queue (will be flushed before the respective waiting loops)  

%% THIS IS YOUR EXPERIMENT OR TRIAL LOOP!
nTrials = 2; 
for n = 1:nTrials

    %
    % YOUR 
    %
    % EXPERIMENTAL
    %
    % SCRIPT
    %
    % GOES
    %
    % HERE
    % 
    
    % After each trial is concluded, read the KbQueue and save its contents.
    % THIS IS JUST A SUGGESTION how to save these variables (namely, in var P
    % that is being expanded with each trial info and then saved).    
    [~,tKeys] = MRTrig_ReadQueue(P); % get contents of KbQueue
    KbQueueFlush; % set KbQueue up for next trial
    
    for t = 1:numel(tKeys) % loop through timings from all logged triggers, and enrich var P with trigger info
    	P.mri.nTrigger = P.mri.nTrigger + 1;
        P = MRTrig_Log(P,  'events'  ,tKeys(t),sprintf('Trigger %04d',P.mri.nTrigger));
        P = MRTrig_Log(P,'fMRIEvents',tKeys(t),sprintf('Trigger %04d',P.mri.nTrigger));
    end
    
    save(P.path.save,'P'); % this is executed AFTER EVERY TRIAL
end

%%
% Don't forget to include at least 10 seconds lead out recording for
% BOLD signal to (effectively) reach baseline.
%

%% final readout, roughly same snippet as during the loop
[listKeys,tKeys] = MRTrig_ReadQueue(P); % get contents of KbQueue
KbQueueRelease(P.devices.input); % replaces KbQueueFlush bc we don't need queue anymore
ListenChar(0); % these functions would normally be located in some cleanup subfunction

for t = 1:numel(tKeys) % loop through timings from all logged triggers, and enrich var P with trigger info
    P.mri.nTrigger = P.mri.nTrigger + 1;
    P = MRTrig_Log(P,  'events'  ,tKeys(t),sprintf('Trigger %04d',P.mri.nTrigger));
    P = MRTrig_Log(P,'fMRIEvents',tKeys(t),sprintf('Trigger %04d',P.mri.nTrigger));
end

save(P.path.save,'P'); % final save

