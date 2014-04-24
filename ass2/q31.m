I = imread('pout.tif');
intImage = integralImage(I);

horiH = integralKernel([1 1 4 3; 1 4 4 3], [-1, 1]); % horizontal filter
vertH = horiH.';

imtool(horiH.Coefficients, 'InitialMagnification','fit');

horiResponse = integralFilter(intImage, horiH);
vertResponse = integralFilter(intImage, vertH);

figure; imshow(horiResponse, []); title('Horizontal edge responses');
figure; imshow(vertResponse, []); title('Vertical edge responses');