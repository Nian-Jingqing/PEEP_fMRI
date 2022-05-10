function Continue(P)
[keyIsDown, ~, keyCode] = KbCheck();
if keyIsDown
    if find(keyCode) == P.keys.name.confirm
        Screen('Flip',P.display.w)
    end
end
end