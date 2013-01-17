function [ JF ] = denoise(frame)

PSF = fspecial('gaussian', 7, 10);
Blurred = imfilter(frame, PSF, 'symmetric', 'conv');

UNDERPSF = ones(size(PSF) - 4);
[J1 P1] = deconvblind(Blurred, UNDERPSF);

OVERPSF = padarray(UNDERPSF, [4 4], 'replicate', 'both');
[J2 P2] = deconvblind(Blurred, OVERPSF);

INITPSF = padarray(UNDERPSF, [2 2], 'replicate', 'both');
[J3 P3] = deconvblind(Blurred, INITPSF);

WEIGHT = edge(frame, 'sobel', .3);
se = strel('disk', 2);
WEIGHT = 1 - double(imdilate(WEIGHT, se));

WEIGHT([1:3 end-[0:2]],:) = 0;
WEIGHT(:,[1:3 end-[0:2]]) = 0;

[J P] = deconvblind(Blurred,INITPSF,30,[],WEIGHT);

P1 = 2;
P2 = 2;
FUN = @(PSF) padarray(PSF(P1+1:end-P1,P2+1:end-P2),[P1 P2]);

[JF PF] = deconvblind(Blurred,OVERPSF,30,[],WEIGHT,FUN);
