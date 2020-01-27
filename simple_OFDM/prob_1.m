function done = prob_1()

    SNRs = 0:2:20;
    p_detected = zeros(length(SNRs));
    mod = 1;
    x = packet_generator(mod);
    h = [1];
    freq_offset = 0;
    z_stf = x(1,1:16);
    figure;
    plot(1:1:length(z_stf),abs(z_stf));
    figure;
    plot(1:1:length(z_stf),angle(z_stf));
    for SNR = 0:2:20
        detected = 0;
        for trial = 1:1000
            y = channel(x, h, freq_offset, SNR);
            detected = detected + packet_detection(z_stf, y);
        end
        p_detected((SNR/2) + 1) = detected / 1000;
    end
    figure;
    plot(SNRs, p_detected);

    done = true;
end