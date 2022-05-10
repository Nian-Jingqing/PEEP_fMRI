% This is an example script to understand _sending_ triggers through a
% a parallel port interface, using a legacy Cogent routine. Intended for
% use with the PRISMA console room infrastructure, particularly Spike.
%
% Version: 1.0
% Authors: Björn Horing, bjoern.horing@gmail.com (compilation and structuring, nothing creative)
% Date: 2021-09-14

%% Example settings
% Ports intended for Spike trigger channels (6, 7, 8, i.e. bits 32, 64, 128) 
% need to correspond to Spike settings in order to make sense.
P = struct;

% ADDRESS and general definitions; nota bene, if you only use ONE address or 
% want to access P.com.lpt(1), P.com.lpt is sufficient!
P.com.lpt(1).CEDDuration = 0.005; % wait time between triggers so nothing gets swallowed; only needed once
P.com.lpt(1).address    = 36912; % hardware address of the scanner's LPT1, e.g. psychophysiology PC, digitimer
% P.com.lpt(2).address  = 36944; % hardware address of the scanner's LPT2 (custom connections)
% P.com.lpt(3).address  = 49200; % hardware address of the scanner's LPT3 (custom connections)

% PORT definitions
% Note: At the scanner consoles, EXTERNAL DEVICES can be flexibly attached to the available LPT interface
%       (see LPTConfig.jpg) via BNC.
% Note: You can set multiple ports to HIGH at once by using simple bit addition, e.g.
%       40 (i.e. 8+32) would trigger ports 4 and 6; 104 would trigger 4, 6, 7;
%       255 triggers ALL ports simultaneously
% P.com.lpt(1).YOURDEVICE1       = 1; % port 1
% P.com.lpt(1).YOURDEVICE2       = 2; % port 2
% P.com.lpt(1).YOURDEVICE3       = 4; % port 3
P.com.lpt(1).Digitimer  = 8; % port 4
P.com.lpt(1).UNKNOWN    = 16; % port 5 (VERIFY)
P.com.lpt(1).USOnset    = 32; % port 6 (Spike channel 6 - VERIFY)
P.com.lpt(1).CSOnset    = 64; % port 7 (Spike channel 7 - VERIFY)
P.com.lpt(1).ITIOnset   = 128; % port 8 (Spike channel 8 - VERIFY)

%% Initialization of Cogent drivers
% If you are using the MRTrig function collection, make sure that you do this
% AFTER the clear functions; required for KbQueue/ListenChar; see MRTrig_WRAPPER.m
LPT('init',P);

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
% AND
% 
% SOMETIMES
%
% YOU
%
%% ... include triggering whenever needed, for example...
% ... when you display a US...
LPT('trigger',P,P.com.lpt.address,P.com.lpt.USOnset); % P.com.lpt==P.com.lpt(1)

% ... when you want to trigger an external device (thermode, additional digitimer or such)...
% Of course, you would need to connect it to the respective port first.
LPT('trigger',P,P.com.lpt.address,P.com.lpt.YOURDEVICE1); % P.com.lpt==P.com.lpt(1)
