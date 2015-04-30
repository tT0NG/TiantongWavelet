function [threshold, sigman_x,sigman_y] = BayesThresholdValue(sigman_estimation,subband) 
% compute the sigmanhat by eaquation (20) based on paper Adaptive Wavelet 
% Thresholding for Image Denoising and Compression, S. Grace Chang, Bin
% Yu, Martin Vetterli, IEEE TRANSACTIONS ON IMAGE PROCESSING, 
% VOL. 9, NO. 9, SEPTEMBER 2000

% Developed by Tiantong, tong.renly@gmail.com 2015 

% sigman_y
sigman_y = sum(sum(subband.^2))/numel(subband);

% sigman_x
temp = sqrt(max((sigman_y - sigman_estimation^2), 0));
% temp term 
if temp == 0 % if the results = zero
    sigman_x = max(max(subband));
    % sigman_x = the max value of the subband
    % this will leads to earse all the coefficients in the subband
else
    sigman_x = temp;
    % O.W. 
end
threshold = sigman_estimation^2/sigman_x;
% define the thresholding value by equation (19) 
end
