function [a,h,v,d] = VISU_SHRINK (A,H,V,D,level,sigman, factor, threshold_mode)
% VISU_SHRINK function take the subband coefficients and the
% noise information, returns the thresholding value asymptotically
% yields a mean square error (MSE) estimate as M tends to infinity.

% Based on: David L. Donoho. “De-noising by soft-thresholding.”
% IEEE Trans. on Information Theory, Vol 41, No. 3, May 1995.

% Developed by Tiantong, tong.renly@gmail.com 2015

h = cell(1,level);        % declare store space
v = cell(1,level);
d = cell(1,level);
num = 0;
for i = 1:level
    num = num + size(H{i},1)*size(H{i},2);
    num = num + size(V{i},1)*size(V{i},2);
    num = num + size(D{i},1)*size(D{i},2);    
end
total_num = num;
% the total number of coefficients
threshold_value = sqrt(2*log(total_num))*sigman;
% global threshold value
threshold_value = threshold_value*factor;
% threshold value reduced by a factor
if nargin == 7 || threshold_mode == 1 % default using soft threshold (1)
    for i = 1:level
        h{i} = SoftThreshold (H{i}, threshold_value);     % soft threshold H band
        v{i} = SoftThreshold (V{i}, threshold_value);     % soft threshold V band
        d{i} = SoftThreshold (D{i}, threshold_value);     % soft threshold D band
    end
elseif threshold_mode == 0                % hard threshold (0)
    for i = 1:level
         h{i}  = HardThreshold (H{i}, threshold_value);
         v{i}  = HardThreshold (V{i}, threshold_value);
         d{i}  = HardThreshold (D{i}, threshold_value);
    end
end
a = A{level};                                         % final approximation level
end