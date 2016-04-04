function out=PSNR(original_image, denoised_image)
%psnr(a,b)
%calculates PSNR in dB for two images in the same format (0...255)
%in rect. matrices a and b.


if isa(original_image, 'uint8')
     if size(original_image,3) == 3
         original_image = double(rgb2gray(original_image));
     else
         original_image = double(original_image);
     end
end

[M,N] = size(denoised_image);
if (original_image==denoised_image)
    out = inf;
    return
end
out=10*log10(255*255*M*N/sum(sum((original_image-denoised_image).*(original_image-denoised_image))));
end