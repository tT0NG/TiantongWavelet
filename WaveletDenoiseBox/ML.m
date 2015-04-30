function [ml] = ML(Y,sigman)
% ML function is an handle function used in nlfilter.
% [ml] = ML(Y,sigman): Y is the small matrix get from the nlfilter function
% passing to this ML function; sigman is the sigman coressponding to the
% noise of the noisy image, which is defiened at the very beginning of the
% main thread. [ml] is the return variance estiamation value to the center pixel where the
% nlfilter is now. [ml] taking the max value between 0 and a value that
% depends on the Y coefficients, size of the Y (nnz), also the variance of
% the additive noise.

% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

    ml = max(0 , sum(sum(Y.^2))/nnz(Y) - sigman^2);
    % nnz(Y);           % debug handle

end