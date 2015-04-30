function [a, h, v, d] = MAP_MMSE(A,H,V,D, level, sigman,window_size, lambda)
% MAP_MMSE will take the multilevel wavelet transform coefficients then
% using MAP estimation to estimate the variance of the coefficients on
% certain position with respect to the coefficients in the window.

% INPUT A,H,V,D = the average, horizontal, vertical, diagonal coefficients
% set, this data is store in cell
% INPUT level = the total number DWT levels
% INPUT window_size = the local neighborhood to form the estimate of the
% varicance of the coefficient on the center position of the window
% INPUT lambda = the inverse of the standard deviation of wavelet
% coefficients that were initially denoised by using MLE_MMSE
% OUTPUT a,h,v,d = the linear MMSE estimation output

% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

h = cell(1,level);
v = cell(1,level);
d = cell(1,level);
for i = 1:level
varh =nlfilter(H{i}, [window_size window_size], @(Y)MAP(Y, lambda{i}(1), sigman)); h{i}=  MMSE(H{i}, varh, sigman); 
varv =nlfilter(V{i}, [window_size window_size], @(Y)MAP(Y, lambda{i}(2), sigman)); v{i}=  MMSE(V{i}, varv, sigman); 
vard =nlfilter(D{i}, [window_size window_size], @(Y)MAP(Y, lambda{i}(3), sigman)); d{i}=  MMSE(D{i}, vard, sigman); 
end
a = A{level};
end