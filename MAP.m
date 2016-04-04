function [map] = MAP(Y,lambda, sigman)
% MAP function is an handle function used in nlfilter.
% MAP(Y,lambda, noiseV): Y is the small matrix get from the nlfilter function
% passing to this MAP function; 
% lambda is the parameter from the prior, which is defined as the inverse
% of the stand deviation of the estimated variance from the MLE;
% sigman is the sigman coressponding to the noise of the noisy image, which
% is defiened at the very beginning of the main thread. 
% [ml] is the return value to the center pixel where the nlfilter is now. 
% [ml] takes the max value between 0 and a value that
% depends on the Y coefficients, size of the Y (nnz) and lambda, also the variance of
% the additive noise.

% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

%     global i              % debug handle global variable to check the
%     function in nlfilter
%     x = floor(i/512) + 1;
%     y = rem(i, 512);
%     lambda = lambdaMatrix(x,y);
    
    sumY = 8*lambda*sum(sum(Y.^2))/nnz(Y)^2;
    % sumation of the coefficients of Y.^2 scaled by lambda and size of Y
    map = max( 0,  nnz(Y)/lambda/4*( -1 + sqrt(1+sumY) ) - sigman^2 );
    % returned variance estimation of the center position
    
%     i = i +1;          % debug handle
end