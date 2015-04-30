% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

original_image = imread('lena.tiff');
sigman = 30;
level_num =6;
wavelet = 'db8';
noisy_image = addingNoise(original_image,sigman,true);
%% multilevel DWT
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%% MLE
window_size = 3; 
[a, h, v, d, lambda] = MLE_MMSE(A,H,V,D, level_num, sigman,window_size); % the MLE will also return the lambda value
denoised_image_MLE = image_denois(a, h, v, d, size(noisy_image), wavelet);
% MAP
[a, h, v, d] = MAP_MMSE(A,H,V,D, level_num, sigman,window_size, lambda);
denoised_image_MAP = image_denois(a, h, v, d, size(noisy_image), wavelet);
%% plot image and noise
figure; 
subplot(2,2,1);imshow(rgb2gray(original_image)),title('gray scale Lena');
subplot(2,2,2);imshow(uint8(noisy_image)),title(['with AWGN, mean = 0, variance = ',num2str(sigman)]);
subplot(2,2,3);imshow(denoised_image_MLE,[0,255]),title(['denoised image use MLE with level = ', num2str(level_num),', window size = ',num2str(window_size)]);
subplot(2,2,4);imshow(denoised_image_MAP,[0,255]),title(['denoised image use MAP with level = ', num2str(level_num),', window size = ',num2str(window_size)]);



%% plot the wavelet transform
[cA,cH,cV,cD] = dwt2(rgb2gray(original_image),'db1');
figure;
subplot(2,2,1),imshow(uint8(wcodemat(cA,255))),title('LL')
subplot(2,2,2),imshow(uint8(wcodemat(cH,255))),title('HL')
subplot(2,2,3),imshow(uint8(wcodemat(cV,255))),title('LH')
subplot(2,2,4),imshow(uint8(wcodemat(cD,255))),title('HH')
de = [wcodemat(A{level_num},255) wcodemat(V{level_num},255); 
          wcodemat(H{level_num},255) wcodemat(D{level_num},255) ];
for i = (level_num-1) : -1: 1
    i
    de = [de wcodemat(V{i},255);
               wcodemat(H{i},255) wcodemat(D{i},255)];
end
figure
imshow(de,[0,255]);
