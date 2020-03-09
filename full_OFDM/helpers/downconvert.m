function [y_bb,y_bb_hp] = downconvert(y, Fc, RX_Fs, BW, filter_complex)

    carrier_i = zeros(1,length(y));
    carrier_q = zeros(1,length(y));
    for n = 0:length(y)-1
        carrier_i(1,n+1) = sqrt(2)*cos(Fc*(2*pi) * n / RX_Fs);
        carrier_q(1,n+1) = -sqrt(2)*sin(Fc*(2*pi) * n / RX_Fs);
    end


    if filter_complex == true
        y_bb_i = real(y .* carrier_i);
        y_bb_q = real(y .* carrier_q);

        y_bb_hp = complex(y_bb_i, y_bb_q);
        y_bb = lowpass(y_bb_hp,BW/2,RX_Fs);
    else

        y_bb_i_hp = real(y .* carrier_i);
        y_bb_i_lp = lowpass(y_bb_i_hp,BW/2,RX_Fs);

        y_bb_q_hp = real(y .* carrier_q);
        y_bb_q_lp = lowpass(y_bb_q_hp,BW/2,RX_Fs);

        y_bb_hp = complex(y_bb_i_hp, y_bb_q_hp);

        % y_bb = lowpass(y_bb_hp,BW/2,RX_Fs);
        y_bb = complex(y_bb_i_lp, y_bb_q_lp);
    end

end
