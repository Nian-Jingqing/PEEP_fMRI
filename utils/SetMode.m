function [subID] = SetMode
% This function prompts you to input the subject ID and the toggleMode will
% be declared dependign on that. subID can range between 1-200 and debug
% mode would subID = 999.
% Input:
%
% - subID:      subject ID (ranging between 1-200 (over 200 set to
% DebugMode and 999 is debugmode automatically)
% 
% Output:
%
% - toggleDebug:    Logical inidcating whether script should be run in
% DebugMode (1) or experimental mode (0)



if nargin == 0
    subID = input(['-----------------------------------------------------\n' ...
        'Please enter subject ID: \n(1-200 = Default, 999 = Debugmode)\n' ...
        '----------------------------------------------------------------\n']);
end

if subID == 999
    O.debug.toggleVisual = 1;
    fprintf('Mode is set to Debugmode.\n')
elseif subID > 200
    fprintf('Are you sure you have that many subjects?\n')
     O.debug.toggleVisual = 1;
else
    O.debug.toggleVisual = 0;
    fprintf('SubID is set to %2.0f and toggle mode disabled.\n', subID)
end