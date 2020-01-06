function [binary] = int16tobinary(int16input)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
zeromin = int16input + 32768;
binary = de2bi(zeromin,16);
end

