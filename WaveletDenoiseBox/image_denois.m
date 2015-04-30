function [denoised_image] = image_denois(a, h, v, d, original_size, func)



% Developed by Tiantong, tong.renly@gmail.com 2015
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999

level = size(d,2);
%------S index matrix------%
S = [size(d{level})];
for i = 1:level
    S = [S; size(d{level+1-i})];
end
S = [S; original_size];

%------C coefficients -------%
C = [reshape(a,1,[])];
for i = level:-1:1
    C = [C, reshape(h{i},1,[]),  reshape(v{i},1,[]), reshape(d{i},1,[])];
end
% size(C)
% original_size       % these two number should agree with each other
%----------IDWT----------%
%func
denoised_image = waverec2(C,S,func);

end