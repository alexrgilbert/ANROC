function [H_hat,L_hat,L,ltf_inv,L_og] = channel_estimator_hw(SNR, x,y)
    % LTF
    L_og = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
    1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];

    ltf = x(161:1:320);
    v = ltf(33:1:96);
    ltf_hat = y(161:1:320);
    v_hat = ltf_hat(33:1:96);

    L_hat = zeros(1,64);
    L = zeros(1,64);
    H_hat = zeros(1,64);


    for k = 1:length(H_hat)
        L_hat_k = 0;
        L_k = 0;
        for n = 1:length(v)
            L_hat_k = L_hat_k + ( (1/8) * v_hat(n) * exp(-2j * pi * (k-1) * (n-1) * (312.5e3) * (50e-9)) );
            L_k = L_k + ( (1/8) * v(n) * exp(-2j * pi * (k-1) * (n-1) * (312.5e3) * (50e-9)) );
        end
        H_hat(k) = L_hat_k / (L_k) ;
        L_hat(k) = L_hat_k;
        L(k) = L_k;
        H_hat((abs(H_hat) > 4)) = complex(1,0);
    end


    ltf_inv = zeros(1,53);
    for time_index = 1:53
       freq_sample = 0;
       for freq_index = 1:160
          freq_sample = freq_sample + (x(160+freq_index) * exp(-1j*2*pi*312.5*(10^3)*50*(10^(-9))*(time_index-27)*(freq_index-1)));
        end
        ltf_inv(time_index) = (1 / sqrt(52)) * freq_sample;
     end

    % figure;plot(L);hold on;plot(real(v));
end
