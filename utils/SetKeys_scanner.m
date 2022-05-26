function [P,O] = SetKeys_scanner(P,O)

KbName('UnifyKeyNames');
P.keys.keyList                  = KbName('KeyNames');
P.keys.name.abort               = KbName('Escape');
P.keys.name.pause               = KbName('Space');
P.keys.name.confirm             = KbName('Return');
P.keys.name.esc                 = KbName('delete');

% Normal Keys
% P.keys.name.left               = KbName('LeftArrow'); % green button
% P.keys.name.right               = KbName('RightArrow'); % blue button
% P.keys.painful                 = KbName('RightArrow'); % green button
% P.keys.notPainful               = KbName('LeftArrow'); % blue button

%Use in the scanner
P.keys.name.left               = KbName('3#'); % green button
P.keys.name.right               = KbName('1!'); % blue button
P.keys.painful                 = KbName('3#'); % green button
P.keys.notPainful               = KbName('1!'); % blue button
P.keys.pulse                    = KbName('5%');



end
