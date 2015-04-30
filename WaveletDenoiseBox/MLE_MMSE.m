function [a, h, v, d, lambda] = MLE_MMSE(A,H,V,D, level, sigman,window_size)
% MLE_MMSE will take the multilevel wavelet transform coefficients then
% using MLE estimation to estimate the variance of the coefficients on
% certain position with respect to the coefficients in the window.
% Also the function will return a lambda data set comtains the inverse
% ofthe stand deviation of the estimated variance of a give band

% INPUT A,H,V,D = the average, horizontal, vertical, diagonal coefficients
% set, this data is store in cell
% INPUT level = the total number DWT levels
% INPUT window_size = the local neighborhood to form the estimate of the
% varicance of the coefficient on the center position of the window
% OUTPUT a,h,v,d = the linear MMSE estimation output
% OUTPUT lambda =  = the inverse of the standard deviation of wavelet
% coefficients of a give band


% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999


h = cell(1,level);              % declare the store space
v = cell(1,level);
d = cell(1,level);
lambda = cell(1,level);
for i = 1:level
varh =nlfilter(H{i}, [window_size window_size], @(Y)ML(Y, sigman)); h{i}=  MMSE(H{i}, varh, sigman); 
varv =nlfilter(V{i}, [window_size window_size], @(Y)ML(Y, sigman)); v{i}=  MMSE(V{i}, varv, sigman); 
vard =nlfilter(D{i}, [window_size window_size], @(Y)ML(Y, sigman)); d{i}=  MMSE(D{i}, vard, sigman); 
lambda{i} = [1/std2(varh), 1/std2(varv), 1/std2(vard)];
% return the lambda for LAWMAP
end
a = A{level};
end