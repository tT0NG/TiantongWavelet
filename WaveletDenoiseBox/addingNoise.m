function [noisy_image] = addingNoise (original_image, sigman,plot_option)
% initialization function: [noisyImage] = addingNoise (original_image,
% sigman) takes the original image then adding Gaussian noise with stand
% deviation of sigman, follow the formula Y = X+n
% sigman = noise std usually [10, 15, 20, 25]
% plot_option = True, will plot the results by saperate figure
% Developed by Tiantong, tong.renly@gmail.com 2015
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999
if size(original_image,3) == 3
    image = rgb2gray(original_image);
else
    image = double(original_image);
end

noisy_image = double(image) +  sigman*randn(size(image));
% add Gaussian noise with std of sigman
if plot_option
    figure; % plot image and noise
    subplot(1,2,1);imshow(image),title('gray scale Lena');
    subplot(1,2,2);imshow(uint8(noisy_image)),title(['with AWGN, mean = 0, variance = ',num2str(sigman)]);
end
end