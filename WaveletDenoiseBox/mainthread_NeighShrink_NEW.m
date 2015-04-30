%% [NEW METHOD] Neigh Shrink 
% based on papaer:
% G.Y. Chen, T.D. Bui, A Krzyzak, “Image denoising using neighboring wavelet coefficients”, 
% proceedings of IEEE international conference on Acoustics, speech and signal processing ’
% 04, pp. 917-920, 2004.

% developed by Tiantong, tong.renly@gmail.com

original_image = imread('lena.tiff');
sigman = 10;
level_num =3;
wavelet = 'db8';
noisy_image = addingNoise(original_image,sigman,true);
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%%
windows = [3,5];
[a_new,h_new,v_new,d_new,window_mask] = NEIGH_SHRINK_ADAPTIVE (A,H,V,D,numel(noisy_image),windows,sigman);
denoised_image_new = image_denois(a_new, h_new, v_new, d_new, size(noisy_image),wavelet);
psnr_new_out=PSNR(original_image, denoised_image_new)

%% window selection map
L = 3;
figure
imshow((window_mask{1,L}==1), [0,4]);
%% PSNR
[a,h,v,d] = NEIGH_SHRINK (A,H,V,D,numel(noisy_image),3,sigman);
denoised_image = image_denois(a, h, v, d, size(noisy_image), wavelet);
psnr_out=PSNR(original_image, denoised_image)
%% visual results
figure
imshow(denoised_image,[0,255]),title('Neigh Shrink');
%% new result plot
figure
imshow(denoised_image_new,[0,255]),title('Neigh_N_e_w Shrink');










