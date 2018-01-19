function t_sacc = waitForSaccade(scr,const,visual, t0, maxRT)
% This function pause program until a saccade is detected, 
% or maxRT (in sec) is elapsed. It compute iteratively the speed at each 
% new sample, using an 1-st order low pass filter to filter out some noise.
%
% return estimated time of saccade onset
% 
% Matteo Lisi, 2017

% parameters
alpha = 0.7; % 0 < alpha < 1; adjust 
vthrs = 30 * visual.ppd; % velocity threshold, converted in pixels
sp = 1/1000; % sampling period

% get first sample
[x_,y_] = getCoord(scr, const);
[x,y] = getCoord(scr, const);
v = sqrt((x-x_)^2+(y-y_)^2) / sp;
[x_,y_] = deal(x,y);

% loop until speed exceed vthrs | elapsed time > maxRT
while v<vthrs && (GetSecs-t0)<maxRT
    if Eyelink('NewFloatSampleAvailable') || const.TEST
        [x,y] = getCoord(scr, const);
        v = alpha*(sqrt((x-x_)^2+(y-y_)^2)/sp) + (1-alpha)*v;
        [x_,y_] = deal(x,y);
    end
end
t_sacc = GetSecs - 0.01; % subtract 

