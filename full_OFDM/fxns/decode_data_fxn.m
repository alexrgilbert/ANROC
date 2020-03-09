function [syms,bits,ints,syms_array] = decode_data_fxn(data,num_symbols_per_packet,num_carriers,...
                                                    num_prefix,num_dead_carriers,num_pilots,M)
    padded_syms = zeros(1,(num_ofdmsymbols*num_carriers));
    syms_array = zeros(num_ofdmsymbols,num_carriers);
    for sym_num = 1:num_ofdmsymbols
            start_index = stf_len + ltf_len +  ((sym_num-1)*(num_carriers+prefix_len))+ prefix_len + 1;
            dest_index = ((sym_num - 1) * num_carriers) + 1;
            padded_syms(1,dest_index:(dest_index + num_carriers - 1)) = fft(rxsig(start_index:(start_index+num_carriers-1)),64) ./ H_hat;
            syms_array(sym_num,:) = fft(rxsig(start_index:(start_index+num_carriers-1)),64) ./ H_hat;
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

%     syms = padded_syms;

    noiseVar = 10.^(-SNR/10);
    bits = qamdemod(syms,M,'gray', ...
            'UnitAveragePower',true,'NoiseVariance',noiseVar);
    ints = qamdemod(syms,M,'gray', ...
            'UnitAveragePower',true,'NoiseVariance',noiseVar,'OutputType','int');
end
