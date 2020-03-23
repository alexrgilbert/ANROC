function [x,x_upsampled,syms,syms_int] = packet_generator_sim_audio(M,bits,x_stf_len,...
    x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
    num_prefix,num_dead_carriers,num_pilots)

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
        end
        x_ltf(time_index) = (1 / sqrt(52)) * time_sample;
    end

    x_ltf(1) = .5 * x_ltf(1);

    % Data
    if (~isempty(bits))

        syms = (qammod(bits',M,'gray','InputType','bit','UnitAveragePower',true))';
        syms_int = qamdemod(syms,M,'gray','UnitAveragePower',true);

        pilot = complex((1/sqrt(2)),(1/sqrt(2)));

        pilot_syms = complex(zeros(1,(num_symbols_per_packet*(num_carriers-num_dead_carriers))),...
                              zeros(1,(num_symbols_per_packet*(num_carriers-num_dead_carriers))));

        for ofdmsymbol_index = 1:num_symbols_per_packet
            symbol_start = (ofdmsymbol_index-1)*(num_carriers-num_dead_carriers-num_pilots) + 1;
            pilot_symbol_start = (ofdmsymbol_index-1)*(num_carriers-num_dead_carriers) + 1;
            pilot_syms((pilot_symbol_start):(pilot_symbol_start+5)) = ...
                syms(symbol_start:(symbol_start+5));
            pilot_syms(pilot_symbol_start+6) = pilot;
            pilot_syms((pilot_symbol_start+7):(pilot_symbol_start+21)) = ...
                syms(symbol_start+6:(symbol_start+20));
            pilot_syms(pilot_symbol_start+22) = pilot;
            pilot_syms((pilot_symbol_start+23):(pilot_symbol_start+37)) = ...
                syms(symbol_start+21:(symbol_start+35));
            pilot_syms(pilot_symbol_start+38) = pilot;
            pilot_syms((pilot_symbol_start+39):(pilot_symbol_start+47)) = ...
                syms(symbol_start+36:(symbol_start+44));
            pilot_syms(pilot_symbol_start+48) = pilot;
            pilot_syms((pilot_symbol_start+49):(pilot_symbol_start+51)) = ...
                syms(symbol_start+45:(symbol_start+47));
        end

        padded_syms = complex(zeros(1,(num_symbols_per_packet*(num_carriers))),...
                              zeros(1,(num_symbols_per_packet*(num_carriers))));

        for ofdmsymbol_index = 1:num_symbols_per_packet
            symbol_start = (ofdmsymbol_index-1)*(num_carriers-num_dead_carriers) + 1;
            padded_symbol_start = (ofdmsymbol_index-1)*(num_carriers) + 1;
            padded_syms((padded_symbol_start+2-1):(padded_symbol_start+27-1)) = ...
                pilot_syms(symbol_start:(symbol_start+26-1));
            padded_syms((padded_symbol_start+39-1):(padded_symbol_start+(num_carriers)-1)) = ...
                pilot_syms(symbol_start+27-1:(symbol_start+num_carriers-num_dead_carriers-1));
        end



        x_data = complex(zeros(1,(num_symbols_per_packet*(num_carriers + num_prefix))),...
                         zeros(1,(num_symbols_per_packet*(num_carriers + num_prefix))));

        for ofdmsymbol_index = 1:num_symbols_per_packet
            symbol_start = (ofdmsymbol_index-1)*(num_carriers) + 1;
            ofdmsymbol_start = (ofdmsymbol_index-1)*(num_carriers + num_prefix) + 1;
            x_data((ofdmsymbol_start+num_prefix):(ofdmsymbol_start+num_prefix+num_carriers-1)) = ...
                ifft(padded_syms(symbol_start:(symbol_start+num_carriers-1)));
            x_data((ofdmsymbol_start):(ofdmsymbol_start+num_prefix-1)) = ...
                x_data((ofdmsymbol_start+num_carriers):(ofdmsymbol_start+num_carriers+num_prefix-1));

            x_data(ofdmsymbol_start) = .5 * x_data(ofdmsymbol_start);
            x_data(ofdmsymbol_start+num_carriers+num_prefix-1) = .5 * x_data(ofdmsymbol_start+num_carriers+num_prefix-1);

        end

        x = [x_stf x_ltf x_data];
    else
        x = [x_stf x_ltf];
        syms = [];
        syms_int = [];
    end

    x_upsampled = upsample(x,us_rate);

end
