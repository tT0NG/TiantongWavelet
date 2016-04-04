function [a, h, v, d, mask_output] = ADAPTIVE_MMSE(A,H,V,D, level, sigman, windows,bootstarp_num)
% MLE_MMSE will take the multilevel wavelet transform coefficients then
% using MLE estimation to estimate the variance of the coefficients on
% certain position with respect to the coefficients in the window.
% Also the function will return a lambda data set comtains the inverse
% ofthe stand deviation of the estimated variance of a give band

% INPUT A,H,V,D = the average, horizontal, vertical, diagonal coefficients
% set, this data is store in cell
% INPUT level = the total number DWT levels
% INPUT window_size = the local neighborhood to form the estimate of the
% varicance of the coefficient on the center position of the window
% OUTPUT a,h,v,d = the linear MMSE estimation output
% OUTPUT lambda =  = the inverse of the standard deviation of wavelet
% coefficients of a give band


% Developed by Tiantong, tong.renly@gmail.com 2015
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

windows_num = size(windows,2);

h = cell(1,level);              % declare the store space
v = cell(1,level);
d = cell(1,level);
mask_output = cell(windows_num,level);

thetah = cell(windows_num, level);  % declare the store space
thetav = cell(windows_num, level);
thetad = cell(windows_num, level);

for i = 1:level
    window_level = 1;   % window size level
    for window_size = windows % for every size of estimator
        % compute the estimation from every estimator at every location
        % store the results in cells
        thetah{window_level,i} =nlfilter(H{i}, [window_size window_size], @(Y)estimator(Y, sigman));
        thetav{window_level,i} =nlfilter(V{i}, [window_size window_size], @(Y)estimator(Y, sigman));
        thetad{window_level,i} =nlfilter(D{i}, [window_size window_size], @(Y)estimator(Y, sigman));
        %         ['window level ',num2str(window_size),' @wavelet level ',num2str(i),' -Done-']
        window_level = window_level + 1;
    end
end
% '-----------------Estimation done-------------------'
% '---------Estimation Boostraping Starts-----------'
% compute the std of each estimator at every location of every level
for i = 1:level
    window_level = 1; % window size level
    for window_size = windows % for every size of estimator
        % using boostraping method get the statistical characteristics of
        % the estimator, return the variance of every estimator at every location
        stdh{window_level,i} = nlfilter(sqrt(thetah{window_level,i}), [window_size window_size], @(Y)estimator_std(Y, bootstarp_num));
        stdv{window_level,i} = nlfilter(sqrt(thetav{window_level,i}), [window_size window_size], @(Y)estimator_std(Y, bootstarp_num));
        stdd{window_level,i} = nlfilter(sqrt(thetad{window_level,i}), [window_size window_size], @(Y)estimator_std(Y, bootstarp_num));
        %         ['window level ',num2str(window_size),' @wavelet level ',num2str(i),' -Done-']
        % debug handle
        window_level = window_level + 1;
    end
end
% '----------Estimation Boostraping done-----------'
% '------------Estimation Selection Starts------------'
for  i = 1:level
    % vectorlize the std matrix for easy select the min estimator
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
%     % reshape the estimator index vector to matrix
%     idx{1,i} = reshape(idx{1,i},size(H{i}));
%     idx{2,i} = reshape(idx{2,i},size(H{i}));
%     idx{3,i} = reshape(idx{3,i},size(H{i}));
    %     ['for level ',num2str(i),' ---estimator selection done---'] % debug handles
    
    
    
    var_H = zeros(size(H{i}));
    var_V = zeros(size(V{i}));
    var_D = zeros(size(D{i}));

    for window_level = 1:windows_num
          var_H = var_H + thetah{window_level,i}.*reshape(maskh(window_level,:),size(H{i}));
          var_V = var_V + thetav{window_level,i}.*reshape(maskv(window_level,:),size(V{i}));
          var_D = var_D + thetad{window_level,i}.*reshape(maskd(window_level,:),size(D{i}));
          mask_output{window_level,i} = reshape(maskd(window_level,:),size(D{i}));
    end
    % using the selected var estimator to MMSE, get the estimation of the
    % coefficients
    h{i}=  MMSE(H{i}, var_H, sigman);
    v{i}=  MMSE(V{i}, var_V, sigman);
    d{i}=  MMSE(D{i}, var_D, sigman);
    % clear the temporary register for next wavelet level
    clear maskh
    clear maskv
    clear maskd
    
    clear temph
    clear tempv
    clear tempd
end
% take the last level of Average as a
a = A{level};
% '------------FINISH------------'
end