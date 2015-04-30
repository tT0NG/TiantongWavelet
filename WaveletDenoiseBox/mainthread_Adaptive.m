% Developed by Tiantong, tong.renly@gmail.com 2015
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

original_image = imread('lena.tiff');
sigman =15;
level_num =3;
wavelet = 'db8';
noisy_image = addingNoise(original_image,sigman,true);
%% multilevel DWT
[A,H,V,D] = multiLevelDWT(noisy_image,level_num, wavelet);
%% adaptive  estimation
windows = [3,5];
%%
[a, h, v, d, window_idx] = ADAPTIVE_MMSE(A,H,V,D, level_num, sigman, windows,200); % the MLE will also return the lambda value
%% denoise image
denoised_image = image_denois(a, h, v, d, size(noisy_image),wavelet);
figure
subplot(1,2,1), imshow(noisy_image,[0,255]),title('Noisy Image');
subplot(1,2,2), imshow(denoised_image,[0,255]),title('Adaptive Estimator');
%% estimator selection map
figure
imshow(window_idx{1,1},[0,4]);
%% window_level = 1; % window size level
window_level = 1;
for window_size = windows % for every size of estimator
    % using boostraping method get the statistical characteristics of
    % the estimator, return the variance of every estimator at every location
    std{window_level} = nlfilter(sqrt(D{1}), [window_size window_size], @(Y)estimator_std(Y, 10000));
    ['window level ',num2str(window_size),' @wavelet level ',num2str(i),' -Done-']
    % debug handle
    window_level = window_level + 1;
end
%%
for window_level = 1:4
    temp(window_level,:) = reshape(std{window_level},1,[]);
end
for x = 1:numel(A{1})
    % select the var estimator with the minimum variance
    [var(x), idx(x)] = min(temp(:,x));     % h
end
% reshape the estimator index vector to matrix
idx = reshape(idx,size(A{1}));
%% estimator selection map
figure
imshow(idx==1);