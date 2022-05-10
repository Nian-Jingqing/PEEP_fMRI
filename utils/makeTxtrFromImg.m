function [TextureIndex, imgsize] = makeTxtrFromImg(imgfile, imgtype, P)
% function [TextureIndex, imgsize] = makeTxtrFromImg(imgfile, imgtype, PTBParams)
%
% DESCRIPTION: takes the path name of an image file (e.g., 'FrootLoops.jpg',
% the image type (e.g. 'JPG'), and the PTBParams structure (which contains
% information about the screen window to which to draw). It then creates a
% PsychToolBox-compatible "texture" that can be drawn onto the display.
% Returns the texture identifier (TextureIndex) which can be used to refer
% to the texture, as well as the image size (in pixels) which can be
% helpful if one wants to resize the image on the screen at some point.
%
% Author: Cendri Hutcherson
% Last modified: May 27, 2018


    ImageInfo = imread(imgfile, imgtype);
    imgsize = size(ImageInfo);
    TextureIndex = Screen('MakeTexture',P.display.w,ImageInfo);