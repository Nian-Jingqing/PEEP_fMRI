 function preexPainful = QueryPreexPain_heat(P,O,preExpInts)

 Screen('Textsize',P.display.w,50);

        if strcmp(P.env.hostname,'stimpc1') 
            if strcmp(P.language,'de')
                keyNotPainful = 'den [linken Knopf]';
                keyPainful = 'den [rechten Knopf]';
            elseif strcmp(P.language,'en')
                keyNotPainful = 'the [left button]';
                keyPainful = 'the [right button]';            
            end
        else 
            if strcmp(P.language,'de')
                keyNotPainful = ['die Taste [' upper(char(P.keys.keyList(P.keys.notPainful))) ']'];
                keyPainful =  ['die Taste [' upper(char(P.keys.keyList(P.keys.painful))) ']'];                
            elseif strcmp(P.language,'en')
                keyNotPainful = ['the key [' upper(char(P.keys.keyList(P.keys.notPainful))) ']'];
                keyPainful =  ['the key [' upper(char(P.keys.keyList(P.keys.painful))) ']'];                            
            end
        end            

        upperEight = P.display.screenRes.height/8;

        if length(preExpInts)>1
            fprintf('Were any of these %d stimuli painful [%s], or none [%s]?\n',length(preExpInts),upper(char(P.keys.keyList(P.keys.painful))),upper(char(P.keys.keyList(P.keys.notPainful))));
            if ~O.debug.toggleVisual
                if strcmp(P.language,'de')
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, 'War einer dieser Reize (mindestens) LEICHT SCHMERZHAFT für Sie?', 'center', upperEight, P.style.white);            
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['Falls ja, drücken Sie bitte ' keyPainful '.'], 'center', upperEight+P.lineheight, P.style.white);            
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['Falls nein, drücken Sie bitte ' keyNotPainful '.'], 'center', upperEight+P.lineheight + 5, P.style.white);            
                elseif strcmp(P.language,'en')
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, 'Was one of these stimuli (at least) SLIGHTLY PAINFUL for you?', 'center', upperEight, P.style.white);            
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['If yes, please press ' keyPainful '.'], 'center', upperEight+P.lineheight, P.style.white);            
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['If no, please press ' keyNotPainful '.'], 'center', upperEight+P.lineheight, P.style.white);                        
                end
            end
        else
            fprintf('Was this stimulus painful [%s], or not painful [%s]?\n',upper(char(P.keys.keyList(P.keys.painful))),upper(char(P.keys.keyList(P.keys.notPainful))));
            if ~O.debug.toggleVisual
                if strcmp(P.language,'de')
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, 'War dieser Reiz (mindestens) LEICHT SCHMERZHAFT für Sie?', 'center', upperEight, P.style.white);
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['Falls ja, drücken Sie bitte ' keyPainful '.'], 'center', upperEight+P.lineheight, P.style.white);            
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['Falls nein, drücken Sie bitte ' keyNotPainful '.'], 'center', upperEight+P.lineheight+5, P.style.white);            
                elseif strcmp(P.language,'en')
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, 'Was this stimulus (at least) SLIGHTLY PAINFUL for you?', 'center', upperEight, P.style.white);
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['If yes, please press ' keyPainful '.'], 'center', upperEight+P.lineheight, P.style.white);            
                    [P.display.screenRes.width, upperEight]=DrawFormattedText(P.display.w, ['If no, please press ' keyNotPainful '.'], 'center', upperEight+P.lineheight, P.style.white); 
                end
            end
        end

        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);
        end

        while 1        
            [keyIsDown, ~, keyCode] = KbCheck();        
            if keyIsDown
                if find(keyCode) == P.keys.painful
                    preexPainful=1;
                    break;
                elseif find(keyCode) == P.keys.notPainful
                    preexPainful=0;
                    break;                
                end
            end        
        end

        WaitSecs(0.2);

        if ~O.debug.toggleVisual
            Screen('Flip',P.display.w);
        end

    end
