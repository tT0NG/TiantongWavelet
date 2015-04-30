function [X_estmation] = MMSE(Y, varEst, sigman)
% mmse fuction takes the estiamtion cariance and the noisy observation
% with sigman to get estimation of X. 
% INPUT: Y = noisy observation
%              varEst =  variance estimation value
%             sigman = the noise of the noisy image, which is defiened at the very beginning of the main thread.
% OUTPU: X_estmation = the estimate coefficients

% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

    scale = varEst./(varEst + sigman^2); % the scale defined from MMSE method
    X_estmation = Y.*scale;                      
end