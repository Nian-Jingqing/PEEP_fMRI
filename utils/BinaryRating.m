function [painful,tThresholdRating]=BinaryRating(P,O,nTrial)

P.textrIndex = GetImg(P);

painful=-1;
upperEight = P.display.screenRes.height*P.display.Ytext;

% await rating within a time frame that leaves enough time to adjust the stimulus
tRatingStart=GetSecs;
fprintf('Not painful [%s] or painful [%s]?\n',P.keys.notPainful,P.keys.painful);

nY = P.display.screenRes.height/8;
if strcmp(P.env.hostname,'stimpc1')
    if strcmp(P.language,'de')
        keyNotPainful = '[linker Knopf]';
        keyPainful = '[rechter Knopf]';
    elseif strcmp(P.language,'en')
        keyNotPainful = '[left button]';
        keyPainful = '[right button]';
    end
else
    keyNotPainful = [ '[linker Knopf]' ];
    keyPainful = [ '[ rechter Knopf]' ];
end
if ~O.debug.toggleVisual
    if strcmp(P.language,'de')
        [P.display.screenRes.width, ~]=DrawFormattedText(P.display.w, ['Nicht schmerzhaft ' keyNotPainful ' oder (mindestens) leicht schmerzhaft ' keyPainful '?'], 'center', upperEight, P.style.white);
    elseif strcmp(P.language,'en')
        [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ['Not painful ' keyNotPainful ' oder (at least) slightly painful ' keyPainful '?'], 'center', upperEight, P.style.white);
    end

    Screen('Flip',P.display.w);
end

%Screen('DrawTexture', P.display.w, P.textrIndex.TextureIndex7, [], [], 0);
%Screen('Flip',P.display.w);

send_trigger(P,O,sprintf('vas_on'));

WaitSecs(P.presentation.sBlank);
%KbQueueRelease;

while 1 % there is no escape...
    [keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if find(keyCode) == P.keys.painful
            painful=1;
            break;
        elseif find(keyCode) == P.keys.notPainful
            painful=0;
            break;
        elseif find(keyCode) == P.keys.name.abort
            painful=-1;
            break;
        end
    end

    nY = P.display.screenRes.height/8;
    if ~O.debug.toggleVisual && GetSecs > tRatingStart+P.presentation.thresholdITIs(nTrial)
        if strcmp(P.language,'de')
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ['Nicht schmerzhaft ' keyNotPainful ' oder (mindestens) leicht schmerzhaft ' keyPainful '?'], 'center', upperEight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ' ', 'center', nY+P.lineheight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ' ', 'center', nY+P.lineheight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, 'Eingabe erforderlich', 'center', nY+P.lineheight, P.style.red);
        elseif strcmp(P.language,'en')
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, ['Not painful ' keyNotPainful ' oder (at least) slightly painful ' keyPainful '?'], 'center', upperEight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, '', 'center', nY+P.lineheight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, '', 'center', nY+P.lineheight, P.style.white);
            [P.display.screenRes.width, nY]=DrawFormattedText(P.display.w, '^ ^ ^ Input required ^ ^ ^', 'center', nY+P.lineheight, P.style.red);
        end

        Screen('Flip',P.display.w);
    end
end

tThresholdRating=GetSecs-tRatingStart;

end
