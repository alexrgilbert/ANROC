function [signal_extended, start_idx, start_idx_ds,post_len_ds] =...
     extend_rng(signal, range,us_rate)
    pre_len_ds = floor((diff(range) * rand) + range(1));
    post_len_ds = floor((diff(range) * rand) + range(1));

    pre_pad_ds = zeros(1,pre_len_ds);
    pre_pad = upsample(pre_pad_ds,us_rate);
    pre_len = length(pre_pad);

    post_pad_ds = zeros(1,post_len_ds);
    post_pad = upsample(post_pad_ds,us_rate);
    post_len = length(post_pad);

    start_idx_ds = pre_len_ds + 1;

    signal_extended = zeros(1, pre_len + length(signal) + post_len);
    start_idx = pre_len + 1;
    signal_extended(start_idx:start_idx+length(signal)-1) = signal;
end
