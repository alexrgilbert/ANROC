%Simple PAM Transmitter

% 2 bit Prefix 
% 8 Data Bits
% 2 bit Suffix
% .5 sec Ts
% Carrier Freq 500 hz

PFbits = 2;
DataBits = 8;
SFbits = 2;
TotalBits = PFbits + DataBits + SFbits;
Ts = .5;
Fc = 500;
Fs = 8192;

Prefix = zeros(PFbits,1);
temp = 1;
for i = 1:PFbits
    Prefix(i,1) = temp;
    temp = temp*(-1);
end

Data = (2.*round(rand(DataBits,1)))-1;


Suffix = zeros(SFbits,1);
temp = -1;
for i = 1:SFbits
    Suffix(i,1) = temp;
    temp = temp*(-1);
end

signalbits = [Prefix; Data; Suffix];
signal = repelem(signalbits,Fs*Ts);

carrier = zeros(length(signal),1);
for i = 0:length(signal)-1
    carrier(i+1,1) = cos(Fc*(2*pi) * i / Fs);
end

Tx = signal.*carrier;

sound(Tx,Fs);

Rx = Tx.*carrier;
