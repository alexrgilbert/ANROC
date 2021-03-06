function [H_hat,L_hat,L] = channel_estimator_fxn(delta_fs,symbol_time, x_ltf,y_ltf,num_carriers,num_dead_carriers)

    addpath('../helpers');

    v = x_ltf(33:1:96);
    v_hat = y_ltf(33:1:96);

    H_hat = zeros(1,64);
    L_hat = zeros(1,64);
    L = zeros(1,64);

    for k = 1:length(H_hat)
        L_hat_k = 0;
        L_k = 0;
        for n = 1:length(v)
            L_hat_k = L_hat_k + ( (1/8) * v_hat(n) * exp(-2j * pi * (k-1)...
                        * (n-1) * delta_fs * symbol_time) );
            L_k = L_k + ( (1/8) * v(n) * exp(-2j * pi * (k-1) * (n-1)...
                                * delta_fs * symbol_time) );
        end
        H_hat(k) = L_hat_k / (L_k) ;
        L_hat(k) = L_hat_k;
        L(k) = L_k;
    end
    nulls = (abs(H_hat) > 4);
    % H_hat_valid = circshift(H_hat(~nulls),-((num_carriers - num_dead_carriers)/2));
    % H_hat_valid = fliplr(H_hat(~nulls));
    % H_hat(~nulls) = H_hat_valid;
    H_hat(nulls) = complex(0,0);
end
