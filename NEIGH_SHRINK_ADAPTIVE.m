function [a,h,v,d, mask_output] = NEIGH_SHRINK_ADAPTIVE (A,H,V,D,image_size,windows,sigman)
% NEIGH_SHRINK function take the subband coefficients and the
% noise information, returns the thresholding value which follows the
% principle of SURE to minimize the SURE risk

% based on papaer:
% G.Y. Chen, T.D. Bui, A Krzyzak, “Image denoising using neighboring wavelet coefficients”,
% proceedings of IEEE international conference on Acoustics, speech and signal processing ’
% 04, pp. 917-920, 2004.

% developed by Tiantong, tong.renly@gmail.com
level = numel(H);
windows_num = numel(windows);

h = cell(1,level);        % declare store space
v = cell(1,level);
d = cell(1,level);
mask_output = cell(windows_num,level);

total_num = image_size^2;
% lambda = the universal threshold value
% compute as Visu Shrink

for i = 1:level
    window_level = 1;   % window size level
    for window_size = windows % for every size of estimator
        % compute the estimation from every estimator at every location
        % store the results in cells
        lambda = sqrt(2*log(numel(H{i}) ))*sigman;
        thresh{window_level,i} =NeighShrinkThresholdValue(H{i}, lambda, window_size);
        thresv{window_level,i} =NeighShrinkThresholdValue(V{i}, lambda, window_size);
        thresd{window_level,i} =NeighShrinkThresholdValue(D{i}, lambda, window_size);
        %         ['window level ',num2str(window_size),' @wavelet level ',num2str(i),' -Done-']
        window_level = window_level + 1;
    end
end

for i = 1:level
    window_level = 1; % window size level
    for window_size = windows % for every size of estimator
        % using boostraping method get the statistical characteristics of
        % the estimator, return the variance of every estimator at every location
        G = fspecial('gaussian',[window_size, window_size],0.7);
        H_blur = imfilter(thresh{window_level,i},G,'same');
        V_blur = imfilter(thresv{window_level,i},G,'same');
        D_blur = imfilter(thresd{window_level,i},G,'same');
        
        stdh{window_level,i} = nlfilter(H_blur, [window_size window_size], @(Y)NeighShrinkScore(Y));
        stdv{window_level,i} = nlfilter(V_blur, [window_size window_size], @(Y)NeighShrinkScore(Y));
        stdd{window_level,i} = nlfilter(D_blur, [window_size window_size], @(Y)NeighShrinkScore(Y));
           
%         stdh{window_level,i} = nlfilter(thresh{window_level,i}, [window_size window_size], @(Y)NeighShrinkScore(Y));
%         stdv{window_level,i} = nlfilter(thresv{window_level,i}, [window_size window_size], @(Y)NeighShrinkScore(Y));
%         stdd{window_level,i} = nlfilter(thresd{window_level,i}, [window_size window_size], @(Y)NeighShrinkScore(Y));
        %         ['window level ',num2str(window_size),' @wavelet level ',num2str(i),' -Done-']
        % debug handle
        window_level = window_level + 1;
        clear G
    end
end

for i = 1:level
%         i
%         size(H{i})
    for window_level = 1:windows_num
        temph(window_level,:) = reshape(stdh{window_level,i},1,[]);
        tempv(window_level,:) = reshape(stdv{window_level,i},1,[]);
        tempd(window_level,:) = reshape(stdd{window_level,i},1,[]);
    end
    
    for x = 1:numel(H{i})
        % select the var estimator with the minimum variance
        maskh(:,x) = temph(:,x) == min(temph(:,x));
        maskv(:,x) = tempv(:,x) == min(tempv(:,x));
        maskd(:,x) = tempd(:,x) == min(tempd(:,x));
    end
    threshold_H = zeros(size(H{i}));
    threshold_V = zeros(size(V{i}));
    threshold_D = zeros(size(D{i}));

    for window_level = 1:windows_num
          threshold_H = threshold_H + thresh{window_level,i}.*reshape(maskh(window_level,:),size(H{i}));
          threshold_V = threshold_V + thresh{window_level,i}.*reshape(maskv(window_level,:),size(V{i}));
          threshold_D = threshold_D + thresh{window_level,i}.*reshape(maskd(window_level,:),size(D{i}));
          mask_output{window_level,i} = reshape(maskd(window_level,:),size(D{i}));
    end
    
    h{i} = H{i}.*threshold_H;     % threshold H band
    v{i} = V{i}.*threshold_V;     % threshold V band
    d{i} = D{i}.*threshold_D;    % threshold D band
   
    
    
    clear maskh
    clear maskv
    clear maskd
    
    clear temph
    clear tempv
    clear tempd
end
a = A{level};                                         % final approximation level
end