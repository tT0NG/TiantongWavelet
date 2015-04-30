% SURE_SHRINK main thread
% Based on paper: D.L. Donoho, I.M. Johnstone, “Adapting to unknown smoothness via wavelet shrinkage”, Journal of the
% American Statistical Association, vol. 90(432), pp. 1200-1224, 1995

% Developed by Tiantong, tong.renly@gmail.com 2015 

original_image = imread('lena.tiff');
sigman = 25;
level_num =6;
wavelet = 'db8';
noisy_image = addingNoise(original_image,sigman,true);
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%%
[a,h,v,d] = SURE_SHRINK (A,H,V,D,level_num,sigman);
% [a,h,v,d] = SURE_SHRINK (A,H,V,D,level_num,sigman,0);
% ^ using hard threshold mode
denoised_image = image_denois(a, h, v, d, size(noisy_image), wavelet);
figure
subplot(1,2,1), imshow(noisy_image,[0,255]),title('Noisy Image');
subplot(1,2,2), imshow(denoised_image,[0,255]),title('SUREShrink');













