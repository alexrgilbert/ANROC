function [detected_syms,r_mag] = packet_detection_sim_audio(z_stf, y, buffer_len)
    len = length(y);
    r = zeros(1,len);
    y_conj = complex(zeros(1,(len+length(z_stf)-1)),...
                      zeros(1,(len+length(z_stf)-1)));
    y_conj(1,1:len) = conj(y);
    for corr_start = 1:len
        r(corr_start) = sum(y_conj(1,corr_start:1:(corr_start+length(z_stf)-1)).*z_stf);
    end
    r_mag = abs(r);
    mean_r = mean(r_mag);
    std_r = std(r_mag);
    thresh_r = mean_r + (2*std_r);
    possible_peaks = (r_mag > thresh_r);

    detected_syms = zeros(1,len);
    buffer = 0;
    for search_index = 1:(len-(16*8))
        if (buffer == 0)
            if(sum(possible_peaks(search_index:16:(search_index+(16*8)))) == 9)
                detected_syms(search_index) = 1;
                buffer = buffer_len;
            end
        else
            buffer = buffer - 1;
        end
    end
    %figure;stem(detected_syms);title('detection points');

end
