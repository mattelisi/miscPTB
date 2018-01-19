function[texture, mu_x, sd_x] = makeBlobCloudPatch(win,visual,n,sigma,width, blobsigma)
% make a texture of a Gaussian "pixels' cloud"
% width should be even number or bad things may happen
%
% Matteo Lisi 2017

if nargin < 6
    blobsigma = 1;
end

halfWidthOfGrid = width / 2;
widthArray = 1:width;  
[x, y] = meshgrid(widthArray, widthArray);

% color codes
white = visual.white;
bg = visual.bgColor;
colDiff = abs(white-bg);

% samples
z = repmat([halfWidthOfGrid halfWidthOfGrid],n,1) + randn(n,2)*sigma;

% if you want specific variance-covariance matrix
% z = round(repmat([0 0],n,1) + randn(n,2)*chol([sigma 0; 0 sigma])); 

% correct points outside texture area
z(z>width) =  width - 2*blobsigma;
z(z<=0) = 2*blobsigma;

imagematrix = repmat(bg,width,width);
for i = 1:n
    imagematrix = imagematrix + colDiff * (1/(2*blobsigma)) * exp(-(((x - z(i,1)).^ 2) + ((y - z(i,2)).^ 2)) / (blobsigma ^ 2));
end
%imshow(uint8(imagematrix), [0 255])
%surf(imagematrix); shading flat;view(3)

mu_x = mean(z(:,1));
sd_x = std(z(:,1));
    
texture = Screen('MakeTexture', win, uint8(imagematrix)); 
end