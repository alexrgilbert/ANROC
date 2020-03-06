function [y_bb,y_bb_hp] = downconvert(y, Fc, RX_Fs, BW)

    carrier_i = zeros(1,length(y));
    carrier_q = zeros(1,length(y));
    for i = 0:length(y)-1
        carrier_i(1,i+1) = sqrt(2)*cos(Fc*(2*pi) * i / RX_Fs);
        carrier_q(1,i+1) = -sqrt(2)*sin(Fc*(2*pi) * i / RX_Fs);
    end

    y_bb_i = real(y .* carrier_i);
    y_bb_q = real(y .* carrier_q);

    y_bb_hp = complex(y_bb_i, y_bb_q);

    y_bb = lowpass(y_bb_hp,BW/2,RX_Fs);

end
