% SOFT & HARD Thresholding main thread
% Developed by Tiantong, tong.renly@gmail.com 2015 
original_image = imread('lena.tiff');
sigman = 30;
level_num =6;
wavelet = 'db8';
noisy_image = addingNoise(original_image,sigman,true);
%%
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
[a, h, v, d] = SOFT_THRESHOLD(A,H,V,D, level_num, 30);
[a2, h2, v2, d2] = HARD_THRESHOLD(A,H,V,D, level_num, 60);
denoised_image = image_denois(a, h, v, d, size(noisy_image), wavelet);
denoised_image2 = image_denois(a2, h2, v2, d2, size(noisy_image), wavelet);
psnr = PSNR(original_image, denoised_image);
figure
imshow(noisy_image,[0,255]),title('Noisy Image');
figure
imshow(denoised_image,[0,255]),title('SOFT');
figure
imshow(denoised_image2,[0,255]),title('HARD');