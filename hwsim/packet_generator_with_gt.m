function [x,bits_int,syms,num_carriers,prefix_len,num_ofdmsymbols,ltf_len,stf_len] = packet_generator_with_gt(mod_order)

    % STF
    S = (1 / sqrt(2)) * [0, 0, (1 + 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, ...
    0, 0, 0, 0, (-1 - 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0];

    x_stf = zeros(1,160);
    for time_index = 1:length(x_stf)
        time_sample = 0;
        for freq_index = 1: length(S)
            time_sample = time_sample + (S(freq_index) * exp(1j*2*pi*312.5*(10^3)*50*(10^(-9))*(time_index-1)*(freq_index-27)));
        end
        x_stf(time_index) = (1 / sqrt(12)) * time_sample;
    end

    % LTF
    L = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0, ...
    1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];

    x_ltf = zeros(1,160);
    for time_index = 1:length(x_ltf)
        time_sample = 0;
        for freq_index = 1: length(L)
            time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*312.5*(10^3)*50*(10^(-9))*(time_index-1)*(freq_index-27)));
        end
        x_ltf(time_index) = (1 / sqrt(52)) * time_sample;
    end

    M = mod_order;
    num_carriers = 64;
    num_prefix = 16;
    num_ofdmsymbols = 12;

    % Data
    bits = randi([0,1],1,(num_ofdmsymbols*(num_carriers-12)*log2(M)));
    syms = (qammod(bits',M,'gray','InputType','bit','UnitAveragePower',true))';
    bits_int = qamdemod(syms,M,'gray','UnitAveragePower',true);

    padded_syms = complex(zeros(1,(num_ofdmsymbols*num_carriers)),...
                          zeros(1,(num_ofdmsymbols*num_carriers)));
    for ofdmsymbol_index = 1:num_ofdmsymbols
        symbol_start = (ofdmsymbol_index-1)*(num_carriers-12) + 1;
        padded_symbol_start = (ofdmsymbol_index-1)*num_carriers + 1;
        padded_syms((padded_symbol_start+2-1):(padded_symbol_start+27-1)) = ...
            syms(symbol_start:(symbol_start+26-1));
        padded_syms((padded_symbol_start+39-1):(padded_symbol_start+num_carriers-1)) = ...
            syms(symbol_start+27-1:(symbol_start+num_carriers-12-1));
    end

%     figure;
%     refpts = qammod((0:(M-1))',M,'gray','UnitAveragePower',true);
%     plot(syms,'co');
%     hold on;
%     plot(refpts,'r*');
% %         text(real(refpts)+0.1,imag(refpts),num2str((0:3)'))
%     xlabel('In-Phase');
%     ylabel('Quadrature');
%     legend('syms','refpts', ...
%         'Reference constellation','location','nw');

    x_data = complex(zeros(1,(num_ofdmsymbols*(num_carriers + num_prefix))),...
                     zeros(1,(num_ofdmsymbols*(num_carriers + num_prefix))));


    for ofdmsymbol_index = 1:num_ofdmsymbols
        symbol_start = (ofdmsymbol_index-1)*(num_carriers) + 1;
        ofdmsymbol_start = (ofdmsymbol_index-1)*(num_carriers + num_prefix) + 1;
        x_data((ofdmsymbol_start+num_prefix):(ofdmsymbol_start+num_prefix+num_carriers-1)) = ...
            ifft(padded_syms(symbol_start:(symbol_start+num_carriers-1)));
        x_data((ofdmsymbol_start):(ofdmsymbol_start+num_prefix-1)) = ...
            x_data((ofdmsymbol_start+num_carriers):(ofdmsymbol_start+num_carriers+num_prefix-1));
    end




    ltf_len = length(x_ltf);
    stf_len = length(x_stf);
    prefix_len = num_prefix;


    x = [x_stf x_ltf x_data];

end
