function [P,O] = SetKeys(P,O)

KbName('UnifyKeyNames');
P.keys.keyList                  = KbName('KeyNames');


if P.debug == 0 % Use with pointer
    P.keys.name.abort               = KbName('Escape');
    P.keys.name.pause               = KbName('Space');
    P.keys.name.confirm             = KbName('Return');
    P.keys.notPainful               = KbName('PageUp');
    P.keys.painful                  = KbName('PageDown');
    P.keys.pulse                    = KbName('5%');

    P.keys.name.right               = KbName('PageDown');
    P.keys.name.left                = KbName('PageUp');
    P.keys.name.esc                 = KbName('delete');

elseif P.debug == 1 % Use with keyboard

    disp('D E B U G    M O D E');
    P.keys.name.abort               = KbName('Escape');
    P.keys.name.pause               = KbName('Space');
    P.keys.name.confirm             = KbName('Return');
    P.keys.notPainful               = KbName('LeftArrow');
    P.keys.painful                  = KbName('RightArrow');
    P.keys.pulse                    = KbName('5%');

    P.keys.name.right               = KbName('RightArrow');
    P.keys.name.left                = KbName('LeftArrow');
    P.keys.name.esc                 = KbName('delete');
end 
end
