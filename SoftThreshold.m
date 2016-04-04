function [threshed_coefficients] = SoftThreshold (coefficients, threshold_value)
% SoftThreshold is build to be used in other threshold method
% INPUT: coefficients = the coefficients band need to be threshold
% INPUT: threshold_value = the threshold value
% OUTPUT: threshed_coefficients

% Developed by Tiantong, tong.renly@gmail.com

    temp = max((abs(coefficients) - threshold_value), 0);           % temp variable
    % select the value that bigger than the threshold
    threshed_coefficients = temp ./ (temp + threshold_value) .* coefficients;     % soft threshold the coefficients
    % pull down the values by threshold value
end