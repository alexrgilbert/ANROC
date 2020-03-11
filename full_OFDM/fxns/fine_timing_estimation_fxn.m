function [m_max] = fine_timing_estimation_fxn(y,k,N,start_idx,m_range)

% (y_stf,symbol_time)

% k = stf_len - stf_iter_len
% N = stf_iter_len


    y_conj = conj(y);
    time_offset = 0;
    m_max = 0;
    corr_max = 0;

    for m = -m_range:m_range
        corr = 0;
        for idx = (start_idx+m):((start_idx+m)+k)
            corr = corr + (y_conj(1,idx+N)*y(1,idx)) ;

        end
        corr = abs(corr)
        if corr > corr_max
            m_max = m;
            corr_max = corr;
        end
    end
end
