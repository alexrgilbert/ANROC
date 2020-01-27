function detected = packet_detection(z_stf, y)
    r = zeros(1,160);
    y_conj = complex(zeros(1,(160+length(z_stf)-1)),...
                      zeros(1,(160+length(z_stf)-1)));
    y_conj(1,1:160) = conj(y(1,(1:160)));
    for corr_start = 1:160
        r(corr_start) = sum(y_conj(1,corr_start:1:(corr_start+length(z_stf)-1)).*z_stf);     
    end
    r_mag = abs(r);
    mean_r = mean(r);
    std_r = std(r);
    thresh_r = mean_r + (2*std_r);
    possible_peaks = (r_mag > thresh_r);
%     figure;
%     plot(1:1:length(r_mag),r_mag);
%     figure;
%     plot(1:1:length(possible_peaks),possible_peaks);

    detected = false;
    for search_index = 1:32
        if(sum(possible_peaks(search_index:16:(search_index+(8*16)))) == 9)
            detected = true;
        end
    end

end