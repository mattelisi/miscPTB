function movingDots_vonMises(scr,dots,duration)
% Animates a field of moving dots based on parameters defined in the 'dots'
% structure over a period of seconds defined by 'duration'.
%
% The 'dots' structure must have the following parameters:
%
%   nDots            Number of dots in the field
%   speed            Speed of the dots (degrees/second)
%   direction        Direction 0-360 clockwise from upward
%   lifetime         Number of frames for each dot to live
%   apertureSize     [x,y] size of elliptical aperture (degrees)
%   center           [x,y] Center of the aperture (degrees)
%   color            Color of the dot field [r,g,b] from 0-255
%   size             Size of the dots (in pixels)
%
% Note that this function do NOT create Shadlen-style moving dots stimuli
% with coherence. Instead it does Dakin-style moving dots stimuli where
% dots directions are drawn from a vonMises distribution. Thus the 'dots'
% structure requires also the following fields
%
%   mu               mean of direction distribution (in radians)
%   k                concentration parameter (in radians)
%
% 'dots' can be an array of structures so that multiple fields of dots can
% be shown at the same time.  The order that the dots are drawn is
% scrambled across fields so that one field won't occlude another.
%
% mod. Matteo Lisi 2019

%Calculate total number of dots across fields
nDots = sum([dots.nDots]);

%Zero out the color and size vectors
colors = zeros(3,nDots);
sizes = zeros(1,nDots);

% 'Shuffle' black and white colors
for i=1:length(dots)
    dots(i).color = dots(i).color(randperm(nDots),:);
end

%Generate a random order to draw the dots so that one field won't occlude
%another field.
order=  randperm(nDots);

%% Intitialize the dot positions and define some other initial parameters
count = 1;
for i=1:length(dots) %Loop through the fields
    
    %Calculate the left, right top and bottom of each aperture (in degrees)
    l(i) = dots(i).center(1)-dots(i).apertureSize(1)/2;
    r(i) = dots(i).center(1)+dots(i).apertureSize(1)/2;
    b(i) = dots(i).center(2)-dots(i).apertureSize(2)/2;
    t(i) = dots(i).center(2)+dots(i).apertureSize(2)/2;
    
    %Generate random starting positions
    dots(i).x = (rand(1,dots(i).nDots)-.5)*dots(i).apertureSize(1) + dots(i).center(1);
    dots(i).y = (rand(1,dots(i).nDots)-.5)*dots(i).apertureSize(2) + dots(i).center(2);
    
    %Create a direction vector for a given coherence level
    direction = circ_vmrnd(dots(i).mu, dots(i).k, dots(i).nDots)/pi*180;
    
    %Calculate dx and dy vectors in real-world coordinates
    dots(i).dx = dots(i).speed*sin(direction*pi/180) * scr.fd;
    dots(i).dy = -dots(i).speed*cos(direction*pi/180) * scr.fd;
    dots(i).life = ceil(rand(1,dots(i).nDots)*dots(i).lifetime);
    
    %Fill in the 'colors' and 'sizes' vectors for this field
    id = count:(count+dots(i).nDots-1);  %index into the nDots length vector for this field
    %colors(:,order(id)) = repmat(dots(i).color(:),1,dots(i).nDots);
    colors(:,order(id)) = dots(i).color';
    sizes(order(id)) = repmat(dots(i).size,1,dots(i).nDots);
    count = count+dots(i).nDots;
end

%Zero out the screen position vectors and the 'goodDots' vector
pixpos.x = zeros(1,nDots);
pixpos.y = zeros(1,nDots);
goodDots = zeros(1,nDots);

%Calculate total number of temporal frames
nFrames = round(duration/scr.fd);

%% Loop through the frames
tFlip = GetSecs;
for frameNum=1:nFrames
    count = 1;
    for i=1:length(dots)  %Loop through the fields
        
        %Update the dot position's real-world coordinates
        dots(i).x = dots(i).x + dots(i).dx;
        dots(i).y = dots(i).y + dots(i).dy;
        
        %Move the dots that are outside the aperture back one aperture width.
        dots(i).x(dots(i).x<l(i)) = dots(i).x(dots(i).x<l(i)) + dots(i).apertureSize(1);
        dots(i).x(dots(i).x>r(i)) = dots(i).x(dots(i).x>r(i)) - dots(i).apertureSize(1);
        dots(i).y(dots(i).y<b(i)) = dots(i).y(dots(i).y<b(i)) + dots(i).apertureSize(2);
        dots(i).y(dots(i).y>t(i)) = dots(i).y(dots(i).y>t(i)) - dots(i).apertureSize(2);
        
        %Increment the 'life' of each dot
        dots(i).life = dots(i).life+1;
        
        %Find the 'dead' dots
        deadDots = mod(dots(i).life,dots(i).lifetime)==0;
        
        %Replace the positions of the dead dots to random locations
        dots(i).x(deadDots) = (rand(1,sum(deadDots))-.5)*dots(i).apertureSize(1) + dots(i).center(1);
        dots(i).y(deadDots) = (rand(1,sum(deadDots))-.5)*dots(i).apertureSize(2) + dots(i).center(2);
        
        %Calculate the index for this field's dots into the whole list of
        %dots.  Using the vector 'order' means that, for example, the first
        %field is represented not in the first n values, but rather is
        %distributed throughout the whole list.
        id = order(count:(count+dots(i).nDots-1));
        
        %Calculate the screen positions for this field from the real-world coordinates
        %pixpos.x(id) = angle2pix(display,dots(i).x)+ display.resolution(1)/2;
        %pixpos.y(id) = angle2pix(display,dots(i).y)+ display.resolution(2)/2;
        pixpos.x(id) = round(dots(i).x);
        pixpos.y(id) = round(dots(i).y);
        
        %Determine which of the dots in this field are outside this field's
        %elliptical aperture
        goodDots(id) = (dots(i).x-dots(i).center(1)).^2/(dots(i).apertureSize(1)/2)^2 + ...
            (dots(i).y-dots(i).center(2)).^2/(dots(i).apertureSize(2)/2)^2 < 1;
        count = count+dots(i).nDots;
    end
    
    %Draw all fields at once
    Screen('DrawDots',scr.main,[pixpos.x(logical(goodDots));pixpos.y(logical(goodDots))], sizes(logical(goodDots)), colors(:,logical(goodDots)),[0,0],1);
    
    % add additional (task specific) drawing here, if any

    %% Flip
    tFlip = Screen('Flip', scr.main, tFlip+scr.fd);
    
end
end

%% local functions
function alpha = circ_vmrnd(theta, kappa, n)
% alpha = circ_vmrnd(theta, kappa, n)
%   Simulates n random angles from a von Mises distribution, with preferred 
%   direction thetahat and concentration parameter kappa.
%
%   Input:
%     [theta    preferred direction, default is 0]
%     [kappa    width, default is 1]
%     [n        number of samples, default is 10]
%
%     If n is a vector with two entries (e.g. [2 10]), the function creates
%     a matrix output with the respective dimensionality.
%
%   Output:
%     alpha     samples from von Mises distribution
%
%
%   References:
%     Statistical analysis of circular data, Fisher, sec. 3.3.6, p. 49
%
% Circular Statistics Toolbox for Matlab
% By Philipp Berens and Marc J. Velasco, 2009
% velasco@ccs.fau.edu
% default parameter
if nargin < 3
    n = 10;
end
if nargin < 2
    kappa = 1;
end
if nargin < 1
    theta = 0;
end
if numel(n) > 2
  error('n must be a scalar or two-entry vector!')
elseif numel(n) == 2
  m = n;
  n = n(1) * n(2);
end  
% if kappa is small, treat as uniform distribution
if kappa < 1e-6
    alpha = 2*pi*rand(n,1);
    return
end
% other cases
a = 1 + sqrt((1+4*kappa.^2));
b = (a - sqrt(2*a))/(2*kappa);
r = (1 + b^2)/(2*b);
alpha = zeros(n,1);
for j = 1:n
  while true
      u = rand(3,1);
      z = cos(pi*u(1));
      f = (1+r*z)/(r+z);
      c = kappa*(r-f);
      if u(2) < c * (2-c) || ~(log(c)-log(u(2)) + 1 -c < 0)
         break
      end
      
  end
  alpha(j) = theta +  sign(u(3) - 0.5) * acos(f);
  alpha(j) = angle(exp(1i*alpha(j)));
end
if exist('m','var')
  alpha = reshape(alpha,m(1),m(2));
end
end
