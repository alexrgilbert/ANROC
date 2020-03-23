function detected = packet_detection(z_stf, y)
    len = length(y)
    r = zeros(1,160);
    y_conj = complex(zeros(1,(160+length(z_stf)-1)),...
                      zeros(1,(160+length(z_stf)-1)));
    y_conj(1,1:160) = conj(y(1,(1:160)));
    for corr_start = 1:160
        r(corr_start) = sum(y_conj(1,corr_start:1:(corr_start+length(z_stf)-1)).*z_stf);
    end
    r_mag = abs(r);
    mean_r = mean(r_mag);
    std_r = std(r_mag);
    thresh_r = mean_r + (2*std_r);
    possible_peaks = (r_mag > thresh_r);
%     figure;
%     plot(1:1:length(r_mag),r_mag);
%     figure;
%     plot(1:1:length(possible_peaks),possible_peaks);
    detected_syms = zeros(len,1);
    detected = false;
    for search_index = 1:(len-420*4)
        if(sum(possible_peaks(search_index:420:(search_index+(420*4)))) == 5)
            detected = true;
            detected_syms(search_index) = 1
        end
    end
    stem(detected_syms)

end
