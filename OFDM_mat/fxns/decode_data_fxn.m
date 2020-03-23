function [data_eq,bits,ints] = decode_data_fxn(data,num_packets,num_symbols_per_packet,num_carriers,...
                                                    num_pilots,num_dead_carriers,H_hat,noise_var,M,pilot_idcs,dead_idcs)

    num_data_carriers = num_carriers - num_pilots - num_dead_carriers;

    pilot_mask = false(1,num_carriers);
    pilot_mask(pilot_idcs) = true;
    dead_mask = false(1,num_carriers);
    dead_mask(dead_idcs) = true;
    data_mask = false(1,num_carriers);
    data_mask(~pilot_mask & ~dead_mask) = true;
    H_hat_data = H_hat(data_mask);

    num_symbols = num_packets * num_symbols_per_packet;
    data_eq = [];
    for sym_num = 1:num_symbols
        start_idx = ((sym_num-1)*num_data_carriers)+1;
        end_idx = (sym_num*num_data_carriers);
        data_eq = [data_eq ((data(start_idx:end_idx))./H_hat_data)];
    end

    bits = qamdemod(data_eq,M,'gray', ...
            'UnitAveragePower',true,'NoiseVariance',noise_var,'OutputType','integer');

    ints = qamdemod(data_eq,M,'gray', ...
            'UnitAveragePower',true,'NoiseVariance',noise_var,'OutputType','integer');


%     padded_syms = zeros(1,(num_ofdmsymbols*num_carriers));
%     syms_array = zeros(num_ofdmsymbols,num_carriers);
%     for sym_num = 1:num_ofdmsymbols
%             start_index = stf_len + ltf_len +  ((sym_num-1)*(num_carriers+prefix_len))+ prefix_len + 1;
%             dest_index = ((sym_num - 1) * num_carriers) + 1;
%             padded_syms(1,dest_index:(dest_index + num_carriers - 1)) = fft(rxsig(start_index:(start_index+num_carriers-1)),64) ./ H_hat;
%             syms_array(sym_num,:) = fft(rxsig(start_index:(start_index+num_carriers-1)),64) ./ H_hat;
%     end
%
%     syms = complex(zeros(1,(num_ofdmsymbols*(num_carriers-12))),...
%                           zeros(1,(num_ofdmsymbols*(num_carriers-12))));
%     for ofdmsymbol_index = 1:num_ofdmsymbols
%         symbol_start = (ofdmsymbol_index-1)*(num_carriers-12) + 1;
%         padded_symbol_start = (ofdmsymbol_index-1)*num_carriers + 1;
%         syms(symbol_start:(symbol_start+26-1)) = ...
%             padded_syms((padded_symbol_start+2-1):(padded_symbol_start+27-1));
%         syms(symbol_start+27-1:(symbol_start+num_carriers-12-1)) = ...
%             padded_syms((padded_symbol_start+39-1):(padded_symbol_start+num_carriers-1));
%     end
%
% %     syms = padded_syms;
%
%     bits = qamdemod(syms,M,'gray', ...
%             'UnitAveragePower',true,'NoiseVariance',noise_var);
%     ints = qamdemod(syms,M,'gray', ...
%             'UnitAveragePower',true,'NoiseVariance',noise_var,'OutputType','int');
end
