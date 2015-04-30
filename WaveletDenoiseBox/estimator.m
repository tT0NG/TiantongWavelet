function [estimation_var] = estimator(Y,sigman)

% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

    estimation_var = max(0 , sum(sum(Y.^2))/numel(Y) - sigman^2);
    % nnz(Y);           % debug handle

end