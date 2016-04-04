% Bayesian shirk METHOD MAINTHREAD
% developed by Tiantong, tong.renlt@gmail.com
original_image = imread('lena.tiff');
sigman = 15;
level_num =4;
wavelet = 'db4';
noisy_image = addingNoise(original_image,sigman,true);
%%
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%%
% this equation comes from the reference paper, equation(16)
[a,h,v,d] = BAYES_SHRIK (A,H,V,D,level_num);
% [a,h,v,d] = BAYES_SHRIK (A,H,V,D,level_num, 0);
% ^ using hard threshold mode
denoised_image = image_denois(a, h, v, d, size(noisy_image), wavelet);

figure
imshow(noisy_image,[0,255]),title('Noisy Image');
figure
imshow(denoised_image,[0,255]),title('BayesShrik');
