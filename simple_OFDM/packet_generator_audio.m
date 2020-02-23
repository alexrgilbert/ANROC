function x = packet_generator(bits_per_sym)

    us_rate = 2.25

    % STF
    S = (1 / sqrt(2)) * [0, 0, (1 + 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, ...
    0, 0, 0, 0, (-1 - 1j), 0, 0, 0, (-1 - 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0, 0, (1 + 1j), 0, 0];

    x_stf = zeros(1,4410);
    for time_index = 1:length(x_stf)
        time_sample = 0;
        for freq_index = 1: length(S)
            time_sample = time_sample + (S(freq_index) * exp(1j*2*pi*1250*(1/44100)*(time_index-1)*(freq_index-27)));
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
            time_sample = time_sample + (L(freq_index) * exp(1j*2*pi*625*22.68*(10^(-6))*(time_index-1)*(freq_index-27)));
        end
        x_ltf(time_index) = (1 / sqrt(52)) * time_sample;
    end

    M = bits_per_sym;
    num_carriers = 32;
    num_prefix = 8;
    num_ofdmsymbols = 12;

    % Data
    bits = randi([0,1],1,(num_ofdmsymbols*num_carriers*max(log2(M),1)));
    syms = (pskmod(bits',M));%,'gray','InputType','bit','UnitAveragePower',true))';

%     figure;
%     refpts = pskmod((0:(M-1))',M);
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
            ifft(syms(symbol_start:(symbol_start+num_carriers-1)));
        x_data((ofdmsymbol_start):(ofdmsymbol_start+num_prefix-1)) = ...
            x_data((ofdmsymbol_start+num_carriers):(ofdmsymbol_start+num_carriers+num_prefix-1));
    end

    x = [x_stf x_ltf x_data];


    us_len = us_rate*length(x);
    x_upsampled = complex(zeros(1,us_len),...
                        zeros(1,us_len));
    for i = 1:(us_len)
        downsampled_idx = floor((i-1)/2.25)+1;
        x_upsampled(1,i) = x(1,downsampled_idx)
    end

end
