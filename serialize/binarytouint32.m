function [int32] = binarytouint32(binary)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
powers=2.^(0:31);
int32=sum(powers.*binary);
end

