function test_pixel_dependence(pixel_size, grating_size , side)
%
% Display vertical and horizontal white and black bars
% used to visually check for "contamination" between neighbouring pixels
% 
% - launch the script, and walk away from the screen until you cannot
%   distinguish the grating anymore. If the monitor is OK you should see similar
%   shades of grey, regardless of the grating orientation. If not, increase pixel_size
%   and repeat, until you find the minimum correct size for which pixel luminance 
%   is really independent from the luminance of neighbouring pixels.
% 
% Matteo Lisi, 2017

% parameters
if nargin < 3
    side = round(rand(1));
end
if nargin < 2
    grating_size = 400;
end
if nargin < 1
    pixel_size = 2;
end

contrast = 1;


% open screen
scr.allScreens = Screen('Screens');
scr.expScreen  = max(scr.allScreens);
Screen('Preference', 'SkipSyncTests', 1);
[scr.main,scr.rect] = Screen('OpenWindow',scr.expScreen, [0.5 0.5 0.5],[],32,2,0,0);
[scr.xres, scr.yres]    = Screen('WindowSize', scr.main);       % heigth and width of screen [pix]
[scr.centerX, scr.centerY] = WindowCenter(scr.main);
scr.fd = Screen('GetFlipInterval',scr.main);    % frame duration [s]
WaitSecs(2);
Screen('Flip', scr.main);

% colors
visual.black = BlackIndex(scr.main);
visual.white = WhiteIndex(scr.main);
visual.bgColor = ceil((visual.black + visual.white) / 2);
absoluteDifference = abs(visual.white - visual.bgColor);
b = uint8(visual.bgColor + contrast*absoluteDifference);
d = uint8(visual.bgColor - contrast*absoluteDifference);
Screen('FillRect', scr.main,visual.bgColor);
Screen('Flip', scr.main);

%
rect_left  = [scr.centerX-grating_size-10, scr.centerY-grating_size/2, scr.centerX-10, scr.centerY+grating_size/2];
rect_right = [scr.centerX+10, scr.centerY-grating_size/2, scr.centerX+grating_size+10, scr.centerY+grating_size/2];
src_rect = [0, 0, grating_size ,grating_size];

% gratings
rep_tile = ceil(grating_size/(pixel_size*2));
hor_tile = [b,b;d,d];
ver_tile = [d,b;d,b];

hor = repmat(repelem(hor_tile, pixel_size, pixel_size),rep_tile,rep_tile);
ver = repmat(repelem(ver_tile, pixel_size, pixel_size),rep_tile,rep_tile);

hor_text = Screen('MakeTexture', scr.main, hor);
ver_text = Screen('MakeTexture', scr.main, ver);

% drawtextures
Screen('FillRect', scr.main,visual.bgColor);
if side
    Screen('DrawTexture', scr.main, hor_text, src_rect, rect_left);
    Screen('DrawTexture', scr.main, ver_text, src_rect, rect_right);
else
    Screen('DrawTexture', scr.main, ver_text, src_rect, rect_left);
    Screen('DrawTexture', scr.main, hor_text, src_rect, rect_right);
end
Screen('Flip', scr.main);

SitNWait;
sca;

end

function SitNWait(keyName)

% Matteo Lisi, 2012

% wait for a particular key to be pressed
% if keyName is not provided, any key will do

if nargin == 1
    specificKey = KbName(keyName);
    anyFlag = 0;
else
    anyFlag = 1;
end

sitFlag = 1;
while sitFlag
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if keyIsDown
        response = find(keyCode);
        response = response(1);
        if anyFlag || response == specificKey
            sitFlag = 0;
        end
    end
end
% now wait for the key to come up again
while KbCheck; end
if response == KbName('delete');
    error('Program execution terminated, by your command');
end
end