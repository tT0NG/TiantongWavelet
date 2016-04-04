function [threshold_value] = NeighShrinkThresholdValue(subband, lambda, window_size)
% SureShrinkThresholdValude function take the subband coefficients and the
% noise information, returns the thresholding value which follows the
% principle of SURE to minimize the SURE risk

% Based on paper: D.L. Donoho, I.M. Johnstone, “Adapting to unknown smoothness via wavelet shrinkage”, Journal of the
% American Statistical Association, vol. 90(432), pp. 1200-1224, 1995

% Developed by Tiantong, tong.renly@gmail.com 2015

threshold_value =nlfilter(subband, [window_size window_size], @(Y)NeighShrinkFactorNew(Y, lambda));

end