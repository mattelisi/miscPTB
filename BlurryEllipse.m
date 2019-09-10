function m=BlurryEllipse(sz,radius,sigma,stretching)
%BLURRYELLIPSE(sz,radius,sigma,stretching) computes a 2-D image of a blurry, white ellipse.
% sz is (scalar) in pixels. (Image must be square.)
% radius in pixels.
% sigma in pixels.
% stretching factors [horizontally vertically] are non-negative real numbers.
% e.g.
% m=BlurryEllipse(64,24,3,[1 .5]); imagesc(m);colormap(gray);axis equal
% (code by Joshua Solomon & Keith May) 
half=floor(sz/2);
f=2*pi*radius/sz;
pr2=-2*(pi*sigma/sz)^2;

[y,x] = meshgrid( -half:half-1, -half:half-1);
r1 = abs(stretching(2)*x + (stretching(1)*1i)*y);
r2 = abs(x+1i*y);
m = besselj(0,f*r1) .* exp(pr2*(r2.^2)).*sqrt(cos(atan2(y,x)).^2/stretching(2)^2+sin(atan2(y,x)).^2/stretching(1)^2);
m=ifftshift(abs(fft2(fftshift(m))));
m=m/max(m(:)); 
