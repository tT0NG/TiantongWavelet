function [a, h, v, d] = HARD_THRESHOLD(A,H,V,D, level, T)
% HARD_THRESHOLD will take the noisy image then aply thresholding on the
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
    h{i}=(abs(H{i}) > T).*H{i};
    v{i}=(abs(V{i}) > T).*V{i};
    d{i}=(abs(D{i}) > T).*D{i};
end
a = A{level};                                         % final approximation level
end