function [bootstrap_std] = estimator_std(Y, bootstarp_num)

Y_vector = reshape(Y,[],1);
% y = bootci(bootstarp_num,@std,Y_vector);
% NUM =length(Y_vector);
% temp = zeros(1,bootstarp_num);
% for i = 1:bootstarp_num
%     y = datasample(Y_vector,NUM);
%     temp(1,i) = var(y);
% end
% bootstrap_std = median(y);
% Y_vector = reshape(Y,[],1);
y = datasample(Y_vector,bootstarp_num);
bootstrap_std = std(y);
end