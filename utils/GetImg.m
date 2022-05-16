function textrIndex = GetImg(P)
% This function loads all the neccesary Images for the introduction. It
% transforms the images into textures as a prior step based on the function
% makeTxtrFromImg.m. The input are the PsychToolBox parameters which have
% been defined in a previous function 


% make textures from images of VAS rating scales to be later used for instructions
%[textrIndex.TextureIndex1, textrIndex.imgsize1] = makeTxtrFromImg('C:\Users\user\Desktop\PEEP\Behavioural\Code\peep_functions\utils\img\paradigm_JPG.png','PNG',P);
%[textrIndex.TextureIndex2, textrIndex.imgsize2] = makeTxtrFromImg('C:\Users\user\Desktop\PEEP\Behavioural\Code\peep_functions\utils\img\paradigm_JPG.jpg','JPG',P);
[textrIndex.TextureIndex3, textrIndex.imgsize3] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\paradigm_JPG2.jpg']),'JPG',P);
[textrIndex.TextureIndex4, textrIndex.imgsize4] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\pain_VAS.jpg']),'JPG',P);
[textrIndex.TextureIndex5, textrIndex.imgsize5] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\unpleasent_VAS.jpg']),'JPG',P);
[textrIndex.TextureIndex6, textrIndex.imgsize6] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\affect_VAS.jpg']),'JPG',P);
[textrIndex.TextureIndex7, textrIndex.imgsize7] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\awiszus_query.jpg']),'JPG',P);
[textrIndex.TextureIndex8, textrIndex.imgsize8] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VASintro_pain.jpg']),'JPG',P);
[textrIndex.TextureIndex9, textrIndex.imgsize9] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\paradigm_JPG.jpg']),'JPG',P);

% VAS training 
[textrIndex.TextureIndex21, textrIndex.imgsize21] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VAStraining1.jpg']),'JPG',P);
[textrIndex.TextureIndex22, textrIndex.imgsize22] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VAStraining2.jpg']),'JPG',P);
[textrIndex.TextureIndex23, textrIndex.imgsize23] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VAStraining3.jpg']),'JPG',P);
[textrIndex.TextureIndex24, textrIndex.imgsize24] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VAStraining4.jpg']),'JPG',P);
[textrIndex.TextureIndex25, textrIndex.imgsize25] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VAStraining5.jpg']),'JPG',P);
[textrIndex.TextureIndex26, textrIndex.imgsize26] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\VAStraining6.jpg']),'JPG',P);
%[textrIndex.TextureIndex27, textrIndex.imgsize27] = makeTxtrFromImg('C:\Users\user\Desktop\PEEP\Behavioural\Code\peep_functions\utils\img\VAStraining7.jpg','JPG',P);

% MR Wait
[textrIndex.TextureIndex31, textrIndex.imgsize31] = makeTxtrFromImg(fullfile([P.path.scriptBase,'\utils\img\wait_MR.jpg']),'JPG',P);