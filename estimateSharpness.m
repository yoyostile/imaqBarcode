function sharpness = estimateSharpness(I)
I = double(rgb2gray(I));
[Ix, Iy] = gradient(I);

S = sqrt(Ix.*Ix + Iy.*Iy);
sharpness = sum(sum(S))./(numel(Ix));