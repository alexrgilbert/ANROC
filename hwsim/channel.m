function y = channel(x, h, freq_offset, SNR, symbol_time)

    noise_power = 1 / (10 ^ (SNR / 10));

    y = conv(x,h);
    offsets = 1:1:length(y);
    offsets = (exp(1j * 2 * pi * freq_offset * symbol_time)).^(offsets);
    y = y.*offsets;

    w = sqrt(noise_power/2)*(randn(1,length(y)) + (1j*randn(1,length(y))));

    y = y+ w;


end
