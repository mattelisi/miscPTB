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