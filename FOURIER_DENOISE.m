function [denoised_image] = FOURIER_DENOISE(noisy_image, T)
% FOURIERDENOISE will take the noisy image then aply thresholding on the
% 2d-dft coefficients
% INPUT noisy_image = noise image
% INPUT T = threshold
% OUTPUT denoised_image
% coefficient_hist, original_dft, noise_dft
% OUTPUT coefficient_hist = histgram of original and noise dft
% coefficients' maganitude
% OUTPUT original_dft = plot of the original dft scaled by log(1+x) to
% display the details
% OUTPUT noise_dft

% Developed by Tiantong, tong.renly@gmail.com 2016
%%
% T= 30000; % 1e4
F = fft2(noisy_image);
dF = (abs(F)> T).*F;
denoised_image = ifft2(dF);
% imshow(uint8(denoise_image))

% %%
% OF = fft2(rgb2gray(original_image));
% % imshow(wcodemat(uint8(abs(F)),255))
% OF2=log(1+fftshift(OF));
% figure(),subplot(1,2,1),imshow(abs(OF2),[])
% % ,'InitialMagnification','fit')
% F = fft2(noisy_image);
% % imshow(wcodemat(uint8(abs(F)),255))
% F2=log(1+fftshift(F));
% subplot(1,2,2),imshow(abs(F2),[])
% % ,'InitialMagnification','fit')
% figure(),hold on,
% [h1, x1] = hist(reshape(abs(F2),1,[]),1000);
% c1 = x1(h1 == max(h1));
% bar(x1-c1(1),h1);
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','r','EdgeColor','r')
% [h2,x2]= hist(reshape(abs(OF2),1,[]),x1);
% c2 = x2(h2 == max(h2));
% bar(x2-c2(1),h2);
% hold off