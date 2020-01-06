function [int16] = binarytoint16(binaryinput)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%int16 = bi2de(binaryinput,16) %- 32768;
powers=2.^(0:15);
int16=sum(powers.*binaryinput)-32768;
end

