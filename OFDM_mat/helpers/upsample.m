function [x_upsampled] = upsample(x,us_rate)
    us_len = us_rate*length(x);
    x_upsampled = complex(zeros(1,us_len),...
                        zeros(1,us_len));
    for i = 1:(us_len)
        downsampled_idx = floor((i-1)/us_rate)+1;
        x_upsampled(1,i) = x(1,downsampled_idx);
    end
end