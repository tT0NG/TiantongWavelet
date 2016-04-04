function [threshold_value] = SureShrinkThresholdValue(subband, sigman)
% SureShrinkThresholdValude function take the subband coefficients and the
% noise information, returns the thresholding value which follows the
% principle of SURE to minimize the SURE risk

% Based on paper: D.L. Donoho, I.M. Johnstone, “Adapting to unknown smoothness via wavelet shrinkage”, Journal of the
% American Statistical Association, vol. 90(432), pp. 1200-1224, 1995

% Developed by Tiantong, tong.renly@gmail.com 2015

subband_vector = reshape(subband,1,[]);
% reshape the subband coefficients as a vector
num = length(subband_vector);
% the total number of the coefficients
candidates = sort(abs(subband_vector)-sigman).^2;
% sorting the threshold candidates in descending order
sum_term  = cumsum(candidates);
%cumulative sum
SURE_risks = (num-(2*(1:num))+sum_term)/num;
% compute the SURE risk for each canidates
[~,index] = min(SURE_risks);
% find the candidates that minimize the SURE risk
threshold_value = sqrt(candidates(index));
% return the best choice
end