%Simple PAM Transmitter

% 2 bit Prefix 
% 8 Data Bits
% 2 bit Suffix
% .5 sec Ts
% Carrier Freq 500 hz

PFbits = 0;
DataBits = 64;
SFbits = 0;
TotalBits = PFbits + DataBits + SFbits;
Ts = .1;
Fc = 500;
Fs = 44100;

Prefix = zeros(PFbits,1);
temp = 1;
for i = 1:PFbits
    Prefix(i,1) = temp;
    temp = temp*(-1);
end

rng(1234)
Data = (2.*round(rand(DataBits,1)))-1;


Suffix = zeros(SFbits,1);
temp = -1;
for i = 1:SFbits
    Suffix(i,1) = temp;
    temp = temp*(-1);
end

signalbits = [Prefix; Data; Suffix];
signal = repelem(signalbits,Fs*Ts);
prefixsig = repelem(Prefix,Fs*Ts);

carrier = zeros(length(signal),1);
for i = 0:length(signal)-1
    carrier(i+1,1) = cos(Fc*(2*pi) * i / Fs);
end

prefixsig = prefixsig.*carrier(1:length(prefixsig));
Tx = signal.*carrier;
longRx = zeros(4*length(Tx),1);
longRx(2000000:2000000+length(Tx)-1) = Tx;
longRx = longRx + .01*randn(length(longRx),1);
sound(Tx,Fs);

cor = xcorr(longRx,prefixsig);

Rx = Tx.*carrier;
