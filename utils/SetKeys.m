function [P,O] = SetKeys(P,O)

KbName('UnifyKeyNames');
P.keys.keyList                  = KbName('KeyNames');
P.keys.name.abort               = KbName('Escape');
P.keys.name.pause               = KbName('Space');
P.keys.name.confirm             = KbName('Return');
P.keys.notPainful               = KbName('PageUp');
P.keys.painful                  = KbName('PageDown');
P.keys.pulse                    = KbName('5%');

% Use with pointer
P.keys.name.right               = KbName('PageDown');
P.keys.name.left                = KbName('PageUp');
P.keys.name.esc                 = KbName('delete');


end
