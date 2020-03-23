function [x,x_upsampled,syms,syms_int] = packet_generator_fxn(M,bits,x_stf_len,...
    x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
    num_prefix,num_dead_carriers,num_pilots,pilot,pilot_idcs,dead_idcs)

    addpath('../helpers');

    % STF
    S = (1 / sqrt(2)) * [0, 0, (1 + 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, ...
    0, 0, 0, 0, (-1 - 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0];

    x_stf = zeros(1,x_stf_len);
    for time_index = 1:x_stf_len
        time_sample = 0;
        for freq_index = 1: length(S)
            time_sample = time_sample + (S(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1)*(freq_index-27)));
        end
        x_stf(time_index) = (1 / sqrt(12)) * time_sample;
    end

    x_stf(1) = .5 * x_stf(1);

    % LTF
    L = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
    1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];


    x_ltf = zeros(1,x_ltf_len);
    for time_index = 1:x_ltf_len
        time_sample = 0;
        for freq_index = 1: length(L)
            time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1)*(freq_index-27)));
            % time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1-num_prefix)*(freq_index-27)));
            % time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1-(2*num_prefix))*(freq_index-27)));
        end
        x_ltf(time_index) = time_sample * (1 / sqrt(52));
    end

    x_ltf(1) = .5 * x_ltf(1);

    % Data
    if (~isempty(bits))

        syms = (qammod(bits',M,'gray','InputType','bit','UnitAveragePower',true))';
        syms_int = qamdemod(syms,M,'gray','UnitAveragePower',true);



        num_data_carriers = num_carriers - num_dead_carriers - num_pilots;

        pilot_mask = false(1,num_carriers);
        pilot_mask(pilot_idcs) = true;
        dead_mask = false(1,num_carriers);
        dead_mask(dead_idcs) = true;
        data_mask = false(1,num_carriers);
        data_mask(~pilot_mask & ~dead_mask) = true;

        x_data = [];

        for sym_num = 1:num_symbols_per_packet
            ofdm_sym = complex(zeros(1,num_carriers),zeros(1,num_carriers));

            start_idx = ((sym_num-1)*num_data_carriers)+1;
            end_idx = (sym_num*num_data_carriers);

            ofdm_sym(data_mask) = syms(start_idx:end_idx);
            ofdm_sym(pilot_mask) = pilot;

%             ofdm_sym_s = complex(zeros(1,52),zeros(1,52));
%             ofdm_sym_s = ofdm_sym;
%             ofdm_sym_ifft = complex(zeros(1,64),zeros(1,64));
%             for time_index = 1:64
%                 time_sample = 0;
%                 for freq_index = 1: 64
%                     time_sample = time_sample + (ofdm_sym_s(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1)*(freq_index-33)));
%                     % time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1-num_prefix)*(freq_index-27)));
%                     % time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*delta_fs*symbol_time*(time_index-1-(2*num_prefix))*(freq_index-27)));
%                 end
%                 ofdm_sym_ifft(time_index) = time_sample * (1 / (64));
%             end

            ofdm_sym_ifft = ifft(ofdm_sym,64);

            prefix_start_idx = num_carriers - num_prefix + 1;
            prefix_end_idx = num_carriers;
            full_ofdm_sym = [ofdm_sym_ifft(prefix_start_idx:prefix_end_idx) ofdm_sym_ifft];
            full_ofdm_sym(1) = .5 * full_ofdm_sym(1);
            full_ofdm_sym(end) = .5 * full_ofdm_sym(end);

            x_data = [x_data full_ofdm_sym];
        end


        x = [x_stf x_ltf x_data];
    else
        x = [x_stf x_ltf];
        syms = [];
        syms_int = [];
    end

    x_upsampled = upsample(x,us_rate);

end
