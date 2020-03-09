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
    padded_syms_packet = [];
    for sym_num = 1:num_symbols_per_packet
        start_idx = ((sym_num-1)*(num_data_carriers+num_prefix))+num_prefix+1;
        end_idx = (sym_num*(num_data_carriers+num_prefix));
        length(data(start_idx:end_idx))
        ofdm_sym = fft(data(start_idx:end_idx),64);

        sym_data = ofdm_sym(data_mask);
        pilot_data = ofdm_sym(pilot_mask);

        
        pilot_packet
    end

    padded_syms = zeros(1,(num_ofdmsymbols*num_carriers));
    syms_array = zeros(num_ofdmsymbols,num_carriers);

    padded_syms_packet = [];
    for sym_num = 1:num_symbols_per_packet
            start_index = ((sym_num-1)*(num_carriers+num_prefix))+num_prefix+1;
            end_index = ((sym_num)*(num_carriers+num_prefix));
            padded_syms_packet = [padded_syms_packet fft(data(start_index:end_index),64)];
    end

    for sym_num = 1:num_symbols_per_packet
            start_index = ((sym_num-1)*(num_carriers))+2;
        end_index = start_index + 27;%((sym_num)*(num_carriers+num_prefix));
            padded_syms_packet = [padded_syms_packet fft(data(start_index:end_index),64)];
    end

    syms = complex(zeros(1,(num_ofdmsymbols*(num_carriers-12))),...
                          zeros(1,(num_ofdmsymbols*(num_carriers-12))));
    for ofdmsymbol_index = 1:num_ofdmsymbols
        symbol_start = (ofdmsymbol_index-1)*(num_carriers-12) + 1;
        padded_symbol_start = (ofdmsymbol_index-1)*num_carriers + 1;
        syms(symbol_start:(symbol_start+26-1)) = ...
            padded_syms((padded_symbol_start+2-1):(padded_symbol_start+27-1));
        syms(symbol_start+27-1:(symbol_start+num_carriers-12-1)) = ...
            padded_syms((padded_symbol_start+39-1):(padded_symbol_start+num_carriers-1));
    end
end
