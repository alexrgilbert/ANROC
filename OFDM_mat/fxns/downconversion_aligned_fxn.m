function [y_bb_us,y_bb_hp,y_bb] = downconversion_aligned_fxn(y,p)
    addpath('../helpers');

    [x_stf,~] = gt_training_fields(p.x_stf_len,p.x_ltf_len,p.delta_fs,p.symbol_time);

    if p.upconvert == true
        [y_bb_us_full,y_bb_hp_full] = downconvert(y, p.Fc, p.RX_Fs, p.BW,p.filter_complex);
    else
        y_bb_us_full = y;
        y_bb_hp_full = y;
    end

    y_bb_full = downsample(y_bb_us_full, p.ds_rate);

    if p.align_downconversion == true

        [detected_syms,~] = packet_detection_fxn(x_stf(1:(p.x_stf_len/10)), y_bb_full, (p.x_stf_len + p.x_ltf_len - 5),p.detection_peaks,p.thresh_factor);
        detected_syms_idcs = find(detected_syms);
        start_idx = detected_syms_idcs(1);
        start_idx_us = (ceil((start_idx-1)*p.ds_rate)+1);

        if p.upconvert == true
            [y_bb_us,y_bb_hp] = downconvert(y(start_idx_us:end), p.Fc, p.RX_Fs, p.BW,p.filter_complex);
        else
            y_bb_us = y(start_idx_us:end); y_bb_hp = y(start_idx_us:end);
        end

        y_bb = downsample(y_bb_us, p.ds_rate);


        if p.freq_correct == true
            [freq_offset] = frequency_offset_estimator_fxn(y_bb(1:p.x_stf_len),p.x_stf_len - (p.x_stf_len/10),(p.x_stf_len/10),p.symbol_time);
            y_bb = y_bb .* ((exp(-j*2*pi*(1/p.symbol_time)*freq_offset)).^(1:length(y_bb)));
        end
    else
        y_bb_us = y_bb_us_full;
        y_bb_hp = y_bb_hp_full;
        y_bb = y_bb_full;
    end
end
