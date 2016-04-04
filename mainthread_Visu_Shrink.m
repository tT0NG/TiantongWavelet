% VisuShrink based on: 
% David L. Donoho. “De-noising by soft-thresholding.” 
% IEEE Trans. on Information Theory, Vol 41, No. 3, May 1995.

% Developed by Tiantong, tong.renly@gmail.com 2015 


original_image = imread('lena.tiff');
sigman = 30;
level_num =6;
wavelet = 'db8';
noisy_image = addingNoise(original_image,sigman,true);
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%%
[a,h,v,d] = VISU_SHRINK (A,H,V,D,level_num,sigman, 0.7,1);
%%
% ^ using soft threshold mode
% [a,h,v,d] = VISU_SHRINK (A,H,V,D,level_num,sigman, 0.25,0);
% ^ using hard threshold mode
% since the threshold value usually too big
% mutiple the factor around 1/4 to reduce the threshold value
denoised_image = image_denois(a, h, v, d, size(noisy_image),wavelet);
% image denoise
figure
subplot(1,2,1), imshow(noisy_image,[0,255]),title('Noisy Image');
subplot(1,2,2), imshow(denoised_image,[0,255]),title('VisuShrink');
