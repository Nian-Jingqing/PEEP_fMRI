function fixcross = SetFixCross(ptb)

% horizontal bar
fixcross.Fix1                   = [ptb.display.midpoint(1)-ptb.style.sizeCross ...
    ptb.style.startY-ptb.style.widthCross ptb.display.midpoint(1)+ptb.style.sizeCross ptb.style.startY+ptb.style.widthCross];

%vertical bar
fixcross.Fix2                   = [ptb.display.midpoint(1)-ptb.style.widthCross ...
    ptb.style.startY-ptb.style.sizeCross ptb.display.midpoint(1)+ptb.style.widthCross ptb.style.startY+ptb.style.sizeCross];

end
