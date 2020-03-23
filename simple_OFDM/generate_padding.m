function [padding_downsampled,padding_len_downsampled,padding,padding_len] = generate_padding(range,us_rate)
    padding_len_downsampled = floor((diff(range) * rand) + range(1));
    padding_downsampled = zeros(1,padding_len_downsampled);
    padding = upsample(padding_downsampled,us_rate);
    padding_len = length(padding);
end
