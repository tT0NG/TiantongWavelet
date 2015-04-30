function [threshed_coefficients] = HardThreshold (coefficients, threshold_value)
% HardThreshold is build to be used in other threshold method
% INPUT: coefficients = the coefficients band need to be threshold
% INPUT: threshold_value = the threshold value
% OUTPUT: threshed_coefficients

% Developed by Tiantong, tong.renly@gmail.com     
  
    threshed_coefficients=(abs(coefficients) > threshold_value).*coefficients;% soft threshold the coefficients
    % select the coefficients that are greater than threshold value
end