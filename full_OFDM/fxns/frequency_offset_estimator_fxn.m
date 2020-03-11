function [freq_offset] = frequency_offset_estimator_fxn(y,k,N,symbol_time)

% (y_stf,symbol_time)

% k = stf_len - stf_iter_len
% N = stf_iter_len

    y_conj = conj(y);
    freq_offset = 0;
    for idx = 1:k
        freq_offset = freq_offset + angle(y_conj(1,idx+N)*y(1,idx)) / (2*pi*N*symbol_time);
    end
    freq_offset = -freq_offset / k;
end
