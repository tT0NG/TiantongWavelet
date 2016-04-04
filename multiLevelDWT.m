function [A,H,V,D] = multiLevelDWT (image,level, func)
% multiLevelDWT will take the given image and level number, applying Wavelet 
% decomposition on the image by calling the MATLAB build in function dwt2
% multiple time.
% INPUT image = the image material, can be grayscale or color image
% INPUT level = the level number of te desired decomposition times
% INPUT func = the string contains the wavelet name, such as 'db1' or 'haar',  ... ,'db8', ... , 'db45'
% OUTPU A,H,V,D = the wavelet transform coefficients, stored in cell

% Developed by Tiantong, tong.renly@gmail.com 2015 
% Based on paper: Low-Complexity Image Denoising Based on Statistical Modeling of Wavelet Coefficients K.M, I.K,K.R IEEE Signal Processing Letters, Dec.1999


if isa(image,'double')
    image_LL = image;
end
if isa(image,'uint8') && size(image,3) == 3 
    image_LL = rgb2gray(image);
end
A=cell(1,level);
H=cell(1,level);
V=cell(1,level);
D=cell(1,level);

[C,S] = wavedec2(image,level,func);
pointer = 0;
% S          % debug handle
level_numel = S(1,1)*S(1,2);
A{level} = reshape(C(1:(S(1,1)*S(1,2))),S(1,:));
pointer = pointer + level_numel;
for idx = 1:level
    level_numel = S(idx+1,1)*S(idx+1,2);

    temp = C(pointer+1:pointer+level_numel);
%     level_numel    %  debug handles
%     size(temp)      %  these two number should agree with each other 
    H{level+1-idx} = reshape(temp,S(idx+1,:));
    pointer = pointer + level_numel;

    temp = C(pointer+1:pointer+level_numel);
    V{level+1-idx} = reshape(temp,S(idx+1,:));
    pointer = pointer + level_numel;
    
    temp = C(pointer+1:pointer+level_numel);
    D{level+1-idx} = reshape(temp,S(idx+1,:));
    pointer = pointer + level_numel;
end
% pointer     % debug handles
% size(C,2)   % debug handles 
% these two number should agree with each other
% return the A H V D in cell
% A only have one cell locate at {1,level}
% H V D all have cell(1,level)
end