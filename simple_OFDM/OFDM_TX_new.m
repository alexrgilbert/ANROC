clear all;
close all;

speakerRange = [20 20e3];
Fc = (diff(speakerRange)/2) + speakerRange(1);
TX_Fs = 48000;
RX_Fs = 48000;
us_rate = ceil(TX_Fs / (diff(speakerRange)/2));
ds_rate = ceil(RX_Fs / (diff(speakerRange)/2));
BW = TX_Fs / us_rate;
M = 2;
num_carriers = 64;
num_packets = 4;
num_train_packets = 2000;
num_dead_carriers = 12;
num_pilots = 4;
num_prefix = 16;
num_symbols_per_packet = 12;
x_stf_len = 160;
x_ltf_len = 160;
delta_fs = BW / 64;
symbol_time = 1 / BW;

[x_stf,x_ltf] = gt_training_fields(x_stf_len,x_ltf_len,delta_fs,symbol_time);

num_data_carriers = (num_carriers-num_dead_carriers-num_pilots);
packet_length = (x_stf_len + x_ltf_len + (num_symbols_per_packet * (num_carriers + num_prefix))) * us_rate;
train_packet_length = (x_stf_len + x_ltf_len) * us_rate;
packet_data_syms_length = (num_symbols_per_packet * num_data_carriers);
packet_data_bits_length = packet_data_syms_length * max(log2(M),1);

random_range = [(train_packet_length / 10) (train_packet_length * 10)];

bits = randi([0,1],1,(num_packets*packet_data_bits_length));
len_bits = length(bits);

num_symbols = ceil ( len_bits /  (num_data_carriers*max(log2(M),1)) );
num_packets = ceil ( num_symbols /  num_symbols_per_packet );

bits = [bits zeros(1,((num_packets * packet_data_bits_length) - len_bits))];

syms = complex(zeros(1,num_packets*packet_data_syms_length),...
                    zeros(1,num_packets*packet_data_syms_length));
signal_bb = complex(zeros(1,20*packet_length),...
            zeros(1,20*packet_length));

detected_syms_gt = zeros(1,((20*(packet_length/us_rate))));
j = 1;
for i = 1:20
   if (mod(i,5) == 2)
       packet_bits = bits(1,(((j-1)*packet_data_bits_length)+1):(j*packet_data_bits_length));
       [x,syms_packet] = packet_generator_sim_audio(M,packet_bits,x_stf_len,...
        x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
        num_prefix,num_dead_carriers,num_pilots);
       signal_bb(((i-1) * packet_length)+1:...
           ((i) * packet_length)) = x;
       syms(((j-1) * packet_data_syms_length)+1:(j * packet_data_syms_length)) = syms_packet;
       detected_syms_gt((((i-1) * (packet_length/us_rate)))+1) = 1;
       j = j+1;
   end

end

signal = upconvert(signal_bb,Fc,TX_Fs);
sound(signal, TX_Fs);

figure;periodogram(signal_bb,[],length(signal_bb),TX_Fs,'centered'); title('signal_bb');
figure;periodogram(signal,[],length(signal),TX_Fs,'centered'); title('signal_bb');

save tx_variables.mat bits syms signal_bb signal detected_syms_gt;
