function [a,h,v,d] = SURE_SHRINK (A,H,V,D,level,sigman,threshold_mode)
% SURE_SHRINK function take the subband coefficients and the
% noise information, returns the thresholding value which follows the
% principle of SURE to minimize the SURE risk

% Based on paper: D.L. Donoho, I.M. Johnstone, “Adapting to unknown smoothness via wavelet shrinkage”, Journal of the
% American Statistical Association, vol. 90(432), pp. 1200-1224, 1995

% Developed by Tiantong, tong.renly@gmail.com 2015

h = cell(1,level);        % declare store space
v = cell(1,level);
d = cell(1,level);
if nargin == 6 || threshold_mode == 1 % default using soft threshold (1)
    for i = 1:level
        threshold_H = SureShrinkThresholdValue(H{i},sigman);
        h{i} = SoftThreshold (H{i}, threshold_H);     % soft threshold H band
        
        threshold_V = SureShrinkThresholdValue(V{i},sigman);
        v{i} = SoftThreshold (V{i}, threshold_V);     % soft threshold V band
        
        threshold_D = SureShrinkThresholdValue(D{i},sigman);
        d{i} = SoftThreshold (D{i}, threshold_D);    % soft threshold D band
    end
elseif threshold_mode == 0                % hard threshold (0)
    for i = 1:level
         threshold_H = SureShrinkThresholdValue(H{i},sigman);
         h{i}  = HardThreshold (H{i}, threshold_H);  % hard threshold H band
         
         threshold_V = SureShrinkThresholdValue(V{i},sigman);
         v{i}  = HardThreshold (V{i}, threshold_V);  % hard threshold V band
         
         threshold_D = SureShrinkThresholdValue(D{i},sigman);
         d{i}  = HardThreshold (D{i}, threshold_D);  % hard threshold D band
    end
end

a = A{level};                                         % final approximation level
end