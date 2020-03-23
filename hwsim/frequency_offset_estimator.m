function freq_offset = frequency_offset_estimator(stf, y)
    len = length(y);
    y_conj = complex(zeros(1,(length(stf))),...
                      zeros(1,(length(stf))));
    y_conj(1,1:160) = conj(y(1,(1:160)));
    freq_offset = 0;
    for idx = 1:143
        freq_offset = freq_offset + angle(y_conj(1,idx+16)*y(1,idx)) / (32*pi*50e-9);
    end
    freq_offset = -freq_offset / 144;


end
