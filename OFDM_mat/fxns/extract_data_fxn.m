function [pilots_packet,syms_packet] =extract_data_fxn(data,num_symbols_per_packet,num_carriers,...
                                        num_prefix,num_dead_carriers,num_pilots,M,pilot_idcs,dead_idcs)

    num_data_carriers = num_carriers - num_dead_carriers - num_pilots;

    pilot_mask = false(1,num_carriers);
    pilot_mask(pilot_idcs) = true;
    dead_mask = false(1,num_carriers);
    dead_mask(dead_idcs) = true;
    data_mask = false(1,num_carriers);
    data_mask(~pilot_mask & ~dead_mask) = true;

    pilots_packet = [];
    syms_packet = [];
    for sym_num = 1:num_symbols_per_packet
        start_idx = ((sym_num-1)*(num_carriers+num_prefix))+num_prefix+1;
        end_idx = (sym_num*(num_carriers+num_prefix));
        ofdm_sym = fft(data(start_idx:end_idx),64);%./H;

        sym_data = ofdm_sym(data_mask);
        sym_pilot = ofdm_sym(pilot_mask);


        pilots_packet = [pilots_packet; sym_pilot];
        syms_packet = [syms_packet sym_data];
    end

end
