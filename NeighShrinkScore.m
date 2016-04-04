function [variance] = NeighShrinkScore(Y)

Y_vector = reshape(Y,[],1);
% boci = bootstrp(100,@var,Y_vector);
% variance = median(boci);
% y = datasample(Y_vector,size(Y_vector,1)*10);
% variance = std(y);
variance = std(Y_vector);

end