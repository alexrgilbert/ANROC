function p = ofdm_par_fxn()

    addpath('../helpers');

    p.save_suffix = datestr(now,'_dd_mm_yyyy_HH_MM_SS');
    p.speakerRange = [20 20e3];
    p.Fc = (diff(p.speakerRange)/2) + p.speakerRange(1);
    p.TX_Fs = 48000;
    p.RX_Fs = 48000;
    p.us_rate = ceil(p.TX_Fs / (diff(p.speakerRange)/2));
    p.ds_rate = ceil(p.RX_Fs / (diff(p.speakerRange)/2));
    p.BW = p.TX_Fs / p.us_rate;
    p.M = 2;
    p.num_carriers = 64;
    p.num_packets = 4;
    p.num_train_packets = 20;
    p.num_dead_carriers = 12;
    p.num_pilots = 4;
    p.num_prefix = 16;
    p.num_symbols_per_packet = 12;
    p.x_stf_len = 160;
    p.x_ltf_len = 160;
    p.ltf_subchannels = 64;
    p.delta_fs = p.BW / 64;
    p.symbol_time = 1 / p.BW;
    p.random_range = [((p.x_stf_len + p.x_ltf_len) * 2) ((p.x_stf_len + p.x_ltf_len) * 10)];
    p.detection_peaks = 9;
    p.thresh_factor = 2;
    p.random_start_flag = true;
    p.upconvert = false;%%%
    p.filter_complex = true;
    p.upsample = false;%%%
    p.channel = true;%%%
    p.num_taps = 1;
    if p.upsample == false
        p.us_rate = 1;
        p.ds_rate = 1;
    end

    p.plot_spectrum = true;
    p.plot_signal = true;
    p.plot_comparison = true;
    p.print_detection = true;
    p.plot_channel_estimation = true;

end
