function [freq_offset] = frequency_offset_estimator_fxn(y_stf,symbol_time)
    stf_len = length(y_stf);
    stf_iter_len = stf_len / 10;
    y_stf_conj = conj(y_stf);
    freq_offset = 0;
    for idx = 1:(stf_len-stf_iter_len)
        freq_offset = freq_offset + angle(y_stf_conj(1,idx+stf_iter_len)*y_stf(1,idx)) / (32*pi*symbol_time);
    end
    freq_offset = -freq_offset / (stf_len-stf_iter_len);
end
