function [detected_syms,r_mag] = packet_detection_fxn(z_stf, y, buffer_len, detection_peaks)

    addpath('../helpers');

    len = length(y);
    z_stf_len = length(z_stf);
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
    thresh_r = mean_r + (2.5*std_r);
    possible_peaks = (r_mag > thresh_r);

    detected_syms = zeros(1,len);
    buffer = 0;
    for search_index = 1:(len-(z_stf_len*(detection_peaks-1)))
        if (buffer == 0)
            if(sum(possible_peaks(search_index:z_stf_len:(search_index+(z_stf_len*(detection_peaks-1))))) == detection_peaks)
                detected_syms(search_index) = 1;
                buffer = buffer_len;
            end
        else
            buffer = buffer - 1;
        end
    end

end
