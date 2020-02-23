%Simple PAM Transmitter

% 2 bit Prefix
% 8 Data Bits
% 2 bit Suffix
% .5 sec Ts
% Carrier Freq 500 hz

% PFbits = 0;
% DataBits = 64;
% SFbits = 0;
% TotalBits = PFbits + DataBits + SFbits;
% Ts = .1;
Fc = 500;
Fs = 44100;

bits_per_sym = 2;
M = bits_per_sym;
num_carriers = 32;
num_prefix = 8;
num_ofdmsymbols = 12;
bits = randi([0,1],1,(num_ofdmsymbols*num_carriers*max(log2(M),1)));

x_len = packet_generator_audio(bits_per_sym,bits);
msg_len = length(x_len);
x_full = zeros(20*msg_len,1);
for i = 1:20
    if (mod(i,4) == 2)
        x_full(((i-1) * msg_len)+1:(i * msg_len)) = packet_generator_audio(bits_per_sym);
    end
end
% Prefix = zeros(PFbits,1);
% temp = 1;
% for i = 1:PFbits
%     Prefix(i,1) = temp;
%     temp = temp*(-1);
% end
%
% rng(1234)
% Data = (2.*round(rand(DataBits,1)))-1;
%
%
% Suffix = zeros(SFbits,1);
% temp = -1;
% for i = 1:SFbits
%     Suffix(i,1) = temp;
%     temp = temp*(-1);
% end
%
% signalbits = [Prefix; Data; Suffix];
% signal = repelem(signalbits,Fs*Ts);
% prefixsig = repelem(Prefix,Fs*Ts);
signal = x_full;
carrier_i = zeros(length(signal),1);
for i = 0:length(signal)-1
    carrier_i(i+1,1) = sqrt(2)*cos(Fc*(2*pi) * i / Fs);
end

carrier_q = zeros(length(signal),1);
for i = 0:length(signal)-1
    carrier_q(i+1,1) = -sqrt(2)*sin(Fc*(2*pi) * i / Fs);
end

% prefixsig = prefixsig.*carrier(1:length(prefixsig));

Tx = (real(signal).*carrier_i) + ((imag(signal).*carrier_q));
% longRx = zeros(4*length(Tx),1);
% longRx(2000000:2000000+length(Tx)-1) = Tx;
% longRx = longRx + .01*randn(length(longRx),1);
sound(Tx,Fs);

% cor = xcorr(longRx,prefixsig);

% Rx = Tx.*carrier;
