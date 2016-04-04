%% Neigh Shrink 
% based on papaer:
% G.Y. Chen, T.D. Bui, A Krzyzak, “Image denoising using neighboring wavelet coefficients”, 
% proceedings of IEEE international conference on Acoustics, speech and signal processing ’
% 04, pp. 917-920, 2004.

% developed by Tiantong, tong.renly@gmail.com

original_image = imread('lena.tiff');
sigman = 15;
level_num =6;
wavelet = 'db8';
window_size = 3;
noisy_image = addingNoise(original_image,sigman,true);
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%%
[a,h,v,d] = NEIGH_SHRINK (A,H,V,D,numel(noisy_image),window_size,sigman);
denoised_image = image_denois(a, h, v, d, size(noisy_image), wavelet);
figure
subplot(1,2,1), imshow(noisy_image,[0,255]),title('Noisy Image');
subplot(1,2,2), imshow(denoised_image,[0,255]),title('NeighShrink');













