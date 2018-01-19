function[texture] = makeGaborTex(win,visual,tiltInDegrees,spatialFreq, contrast, sigma, phase, widthOfGrid)
%
% Prepare a Gabor 
% 
% NB. in this version tilt in degrees is intended clockwise from vertical
%

tiltInRadians = (-tiltInDegrees) * pi / 180; % The tilt of the grating in radians.
radiansPerPixel = spatialFreq * (2 * pi); % = (periods per pixel) * (2 pi radians per period)
halfWidthOfGrid = widthOfGrid / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

black = visual.black;
white = visual.white;
gray = visual.bgColor; % (black + white) / 2;
if round(gray)==white
	gray=black;
end
  
absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
[x, y] = meshgrid(widthArray, widthArray);
a=cos(tiltInRadians)*radiansPerPixel;
b=sin(tiltInRadians)*radiansPerPixel; 
gratingMatrix = sin(a*x + b*y + phase);
circularGaussianMaskMatrix = exp(-((x .^ 2) + (y .^ 2)) / (sigma ^ 2));
imageMatrix = gratingMatrix .* circularGaussianMaskMatrix;
grayscaleImageMatrix = uint8(gray + contrast*(absoluteDifferenceBetweenWhiteAndGray * imageMatrix));
texture = Screen('MakeTexture', win, grayscaleImageMatrix); 

