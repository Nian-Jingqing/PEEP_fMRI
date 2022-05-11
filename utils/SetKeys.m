function [P,O] = SetKeys(P,O)

KbName('UnifyKeyNames');
P.keys.keyList                  = KbName('KeyNames');
P.keys.name.abort               = KbName('Escape');
P.keys.name.pause               = KbName('Space');
P.keys.name.confirm             = KbName('Return');

% Use with computer keys
P.keys.name.right               = KbName('RightArrow');
P.keys.name.left                = KbName('LeftArrow');
P.keys.name.esc                 = KbName('Escape');

P.keys.painful                  = KbName('RightArrow');
P.keys.notPainful               = KbName('LeftArrow');

% Use in the scanner
%P.keys.confirm                  = KbName('2@'); % yellow button (down)
%P.keys.name.left               = KbName('3#'); % green button
%P.keys.name.right               = KbName('1!'); % blue button
%P.keys.painful                 = KbName('3#'); % green button
%P.keys.notPainful               = KbName('1!'); % blue button

% Use with pointer
%P.keys.name.right               = KbName('PageDown');
%P.keys.name.left                = KbName('PageUp');
P.keys.name.esc                 = KbName('delete');

P.keys.name.trigger             = KbName('5');
end
