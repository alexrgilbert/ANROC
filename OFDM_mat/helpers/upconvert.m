function [signal] = upconvert(signal_bb,Fc,TX_Fs)

    carrier_i = zeros(1,length(signal_bb));
    carrier_q = zeros(1,length(signal_bb));
    for n = 0:length(signal_bb)-1
        carrier_i(1,n+1) = sqrt(2)*cos(Fc*(2*pi) * n / TX_Fs);
        carrier_q(1,n+1) = -sqrt(2)*sin(Fc*(2*pi) * n / TX_Fs);
    end

    signal = (real(signal_bb).*carrier_i) + ((imag(signal_bb).*carrier_q));

end
