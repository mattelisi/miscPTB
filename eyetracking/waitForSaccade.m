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

% get first sample
[x_,y_, t_] = getCoordT(scr, const);
[x,y, t] = getCoordT(scr, const);
v = sqrt((x-x_)^2+(y-y_)^2) / (t - t_);
[x_,y_, t_] = deal(x,y, t);

% loop until speed exceed vthrs | elapsed time > maxRT
while v<vthrs && (GetSecs-t0)<maxRT
    if Eyelink('NewFloatSampleAvailable') || const.TEST
        [x,y, t] = getCoordT(scr, const);
        v = alpha*(sqrt((x-x_)^2+(y-y_)^2)/(t - t_)) + (1-alpha)*v;
        [x_,y_, t_] = deal(x,y, t);
    end
end
t_sacc = GetSecs;

end

function [x,y,t] =getCoordT(wPtr,const)
%
% collect real or simulated eye position data
% this function returns also the time of the sample 
% for approximate online calculation of speed
%

if const.TEST
    [x,y]=GetMouse(wPtr.main); % gaze position simulate by mouse position
else
    evt = Eyelink('newestfloatsample');
    t = GetSecs;
    x = evt.gx(const.recEye);
    y = evt.gy(const.recEye);
    
end
end
