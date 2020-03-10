function noise_var = noise_estimator_fxn(stfs,ltfs)
    stf_var_i = 2*var(real(stfs(:,17:144)),1,1);
    stf_var_q = 2*var(imag(stfs(:,17:144)),1,1);
    stf_var = (stf_var_i + stf_var_q)/2;
    stf_var = mean(stf_var);
    -10*log10(stf_var)

    ltf_var_i = 2*var(real(ltfs(:,17:144)),1,1);
    ltf_var_q = 2*var(imag(ltfs(:,17:144)),1,1);
    ltf_var = (ltf_var_i + ltf_var_q)/2;
    ltf_var = mean(ltf_var);
    -10*log10(ltf_var)

    noise_var = (stf_var + ltf_var)/2;
    -10*log10(noise_var)
end


% var ((sqrt(noise_power/2)*w_i) + (sqrt(noise_power/2)*w_q)) =
% noise_power/2 * var(w_i + w_q)
% 2*var(w_i) = noise_power
% 2*var(w_q) = noise_power
% noise_power = 1 / (10 ^ (SNR / 10));

% pilot_var_i = 2*var(real(pilots),0,1);
%     pilot_var_q = 2*var(imag(pilots),0,1);
%     pilot_var = (pilot_var_i + pilot_var_q)/2;
%     pilot_var = mean(pilot_var);
%     -10*log10(pilot_var)
