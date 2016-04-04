function [a, h, v, d] = SOFT_THRESHOLD(A,H,V,D, level, T)
% SOFT_THRESHOLD will take the noisy image then aply thresholding on the
% wavelet coefficients
% INPUT A,H,V,D = the coefficients bands, stored in cells
% INPUT level = the total wavelet levels
% INPUT T = threshold
% OUTPUT a, h, v, d = thresholded coefficients

% Developed by Tiantong, tong.renly@gmail.com 2015 

h = cell(1,level);        % declare store space
v = cell(1,level);
d = cell(1,level);
for i = 1:level
    temp = max(abs(H{i} - T), 0);        % temp variable
    h{i} = temp ./ (temp + T) .* H{i};     % threshold H band
    temp = max(abs(V{i} - T), 0);
    v{i} = temp ./ (temp + T) .* V{i};     % threshold V band
    temp = max(abs(D{i} - T), 0);
    d{i} = temp ./ (temp + T) .* D{i};    % threshold D band
end
a = A{level};                                         % final approximation level
end