function H_hat = channel_estimator(SNR, x, h, freq_offset, k)
    % LTF
    L = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
    1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];

    y = channel(x, h, freq_offset, SNR);
    y_ltf = y((160+1):1:320);
    v = y_ltf(33:1:96);

%     L_hat = zeros(1,length(L));
%     for freq_index = 1:length(L_hat)
%         freq_sample = 0;
%         for time_index = 1: (length(v))
%             freq_sample = freq_sample + (v(time_index) * exp(-1j*2*pi*312.5*(10^3)*50*(10^(-9))*(freq_index-27)*(time_index-1)));
%         end
%         L_hat(freq_index) = (1 / 8) * freq_sample;
%     end
%     display(size(L_hat));
%     display(size(L));

    L_hat = complex(0,0);
%     for freq_index = 1:length(L_hat)
    freq_sample = 0;
    for time_index = 1: (length(v))
        freq_sample = freq_sample + (v(time_index) * exp(-1j*2*pi*312.5*(10^3)*50*(10^(-9))*(k)*(time_index-1)));
    end
    L_hat = (1 / 8) * freq_sample;
%     end


    H_hat = L_hat / L(k + 26 + 1);
end