% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

% initialization
sigman = 15; % noise std
% clean_image = (read_raw('barbara',512,512))';         % read image
clean_image = rgb2gray(imread('lena.tiff'));
noisy_image = double(clean_image) +  sigman*randn(512);    % add noise
imshow(uint8(noisy_image))
subplot(1,2,1);imshow(clean_image),title('gray scale Lena');
subplot(1,2,2);imshow(uint8(noisy_image)),title(['with AWGN, mean = 0, variance = ',num2str(sigman)]);

%%
% wavelet transform
[A,H,V,D] = swt2(noisy_image,1,'db8');
% signle step of wavelet transform
h_raw = reshape(H,1,[]);
[hist_h_raw,bin_h_raw] = hist(h_raw,700);
sumArea =  sum(hist_h_raw*(range(bin_h_raw)/size(bin_h_raw,2)));
figure
plot(bin_h_raw,hist_h_raw/sumArea),title('histgram of HH band Wavelet Coefficients');
%%
% normalized histgram can be well approximated by normal distribution
localD = stdfilt(H,ones(5));       
% local standard deviations
% using 5 pixels window
% M = nlfilter(H, [1 3], @mean);
Hh = (H)./localD;            % scale the coefficients by J
% this will normalize the coefficients by the local deviations
h = reshape(Hh,1,[]);        % vecterlize
[hist_h,bin] = hist(h,500);  % histgram
sumArea =  sum(hist_h*(range(bin)/size(bin,2)));
% computet the total area of
% the histgram
figure; 
plot(bin,hist_h/sumArea,'LineWidth',0.2); % plot histgram
hold on
y = -4:0.1:4;
mu = 0;
sigma = 1;
f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
% plot Normal Gaussian
plot(y,f,'r--','LineWidth',1.5),title('Scaled coefficients and Normal Distribution')
legend('histgram of scaled coefficients', 'Normal Gaussian p.d.f');
% plot scaled coefficients histgram and normal distribution together
hold off

%%
[YA,YH,YV,YD] = swt2(noisy_image,1,'db8');
% single step wavelet transform
% assume the correlation of variances of neighboring coefficients are high
M = 7;
% window size = 7
varianceEsitimatorMLE = nlfilter(YH, [M M], @(Y)ML(Y, sigman));
% using sliding window function with the MAP handle function
% the parameter passed in the MAP handle function is the a Matrix Y
% Y matrix has the size of M*M
vMLE = reshape(varianceEsitimatorMLE,1,[]); % coefficients vector
[vMLE_h, vMLE_bin] = hist(vMLE,600); % counting histgram
sumArea =  sum(vMLE_h*(range(vMLE_bin)/size(vMLE_bin,2)));
logvMLE_h = log10(vMLE_h/sumArea);
% taking log (10 base) of the histgram
for i= 1:size(vMLE_bin,2)-1
     if vMLE_h(i) == 0
        logvMLE_h(i) = logvMLE_h(i-1);
        % padding inf value with value before
     end
end
figure
plot(double(vMLE_bin(1:2:end)),logvMLE_h(1:2:end),'-'),title('histgram of variance MLE');
% plot histgram
%%
[YA,YH,YV,YD] = swt2(noisy_image,1,'db8');
% assume the correlation of variances of neighboring coefficients are high
M = 7;
% window size
lambda = 1/std2(varianceEsitimatorMLE);
% lambda equares the inverse of the stander derivition of the variance
% learned from MLE of certain band
varianceEsitimatorMAP = nlfilter(YH, [M M], @(Y)MAP(Y,lambda, sigman));
% using sliding window function with the MAP handle function
% the parameter passed in the MAP handle function is the a Matrix Y
% Y matrix has the size of M*M
%%
vMAP = reshape(varianceEsitimatorMAP,1,[]); % coefficients vector
[vMAP_h, vMAP_bin] = hist(vMAP,600);        % counting histgram
sumArea =  sum(vMAP_h*(range(vMAP_bin)/size(vMAP_bin,2)));
logvMAP_h = log10(vMAP_h/sumArea);
% taking log (10 base) of the histgram
for i= 1:size(vMAP_bin,2)-1
     if vMAP_h(i) == 0
        logvMAP_h(i) = logvMAP_h(i-1);
        % padding the inf value with the value before it
     end
end
figure
plot(double(vMAP_bin(1:2:end)),logvMAP_h(1:2:end),'-'),title('histgram of MAP variance');
% plot histgram

















