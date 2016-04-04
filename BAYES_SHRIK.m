function [a,h,v,d] = BAYES_SHRIK (A,H,V,D,level, threshold_mode)

sigman_estimation = median(reshape(abs(D{1}),1,[]))/0.6745;
h = cell(1,level);        % declare store space
v = cell(1,level);
d = cell(1,level);
if nargin == 5 || threshold_mode == 1 % default using soft threshold (1)
    for i = 1:level
        threshold_H = BayesThresholdValue(sigman_estimation,H{i});
        h{i} =  SoftThreshold (H{i}, threshold_H);     % soft threshold H band
        
        threshold_V = BayesThresholdValue(sigman_estimation,V{i});
        v{i} = SoftThreshold (V{i}, threshold_V);     % soft threshold V band
        
        threshold_D = BayesThresholdValue(sigman_estimation,D{i});
        d{i} = SoftThreshold (D{i}, threshold_D);    % soft threshold D band
    end
    %  'soft'   % debug handle
elseif threshold_mode == 0                % hard threshold (0)
    for i = 1:level
        threshold_H = BayesThresholdValue(sigman_estimation,H{i});
        h{i}  = HardThreshold (H{i}, threshold_H);  % hard threshold H band
        
        threshold_V = BayesThresholdValue(sigman_estimation,V{i});
        v{i}  = HardThreshold (V{i}, threshold_V);  % hard threshold V band
        
        threshold_D = BayesThresholdValue(sigman_estimation,D{i});
        d{i}  = HardThreshold (D{i}, threshold_D);  % hard threshold D band
    end
    % 'hard'   % debug handle
end
a = A{level};                                         % final approximation level
end