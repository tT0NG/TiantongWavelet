function [a,h,v,d] = NEIGH_SHRINK (A,H,V,D,size,window_size,sigman)
% NEIGH_SHRINK function take the subband coefficients and the
% noise information, returns the thresholding value which follows the
% principle of SURE to minimize the SURE risk

% based on papaer:
% G.Y. Chen, T.D. Bui, A Krzyzak, “Image denoising using neighboring wavelet coefficients”,
% proceedings of IEEE international conference on Acoustics, speech and signal processing ’
% 04, pp. 917-920, 2004.

% developed by Tiantong, tong.renly@gmail.com
level = numel(H);
h = cell(1,level);        % declare store space
v = cell(1,level);
d = cell(1,level);

total_num = size^2;
lambda = sqrt(2*log(total_num))*sigman;
% lambda = the universal threshold value
% compute as Visu Shrink



for i = 1:level
    threshold_H = NeighShrinkThresholdValue(H{i}, lambda, window_size);
    h{i} = H{i}.*threshold_H;     % soft threshold H band
    
    threshold_V = NeighShrinkThresholdValue(V{i}, lambda, window_size);
    v{i} = V{i}.*threshold_V;     % soft threshold V band
    
    threshold_D = NeighShrinkThresholdValue(D{i}, lambda, window_size);
    d{i} = D{i}.* threshold_D;    % soft threshold D band
end


a = A{level};                                         % final approximation level
end