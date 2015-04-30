function [threshold_factor] = NeighShrinkFactor(Y, lambda)
% NeighShrinkFactor takes the coefficients from the window, then compute
% the shrink factor at this certain location with respect to the lambda,
% which is the universial thresholding value, as compute in the Visu Shrink
% INPUT Y = coefficients from the window
% INPUT lambda = universial thresholding value
% OUTPUT threshold_factor = as defined in reference paper shrink factor equation 

threshold_factor = max((1 -  (lambda^2/sum(sum(Y.^2) ))) ,0);
% the max keep the threshold factor always as non-negitive
end