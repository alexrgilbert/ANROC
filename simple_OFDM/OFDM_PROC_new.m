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
num_packets = 20;
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

load tx_variables_3_3_2020_7_30.mat;
load rx_variables_3_3_2020_7_30.mat;

x_bb = downsample(signal_bb(1,1:end), ds_rate);
figure;periodogram(x_bb,[],length(x_bb),BW,'centered');title('Pre-TX: Baseband Downsampled (Post-Proc) Signal Spectrum');
figure;periodogram(signal_bb,[],length(signal_bb),TX_Fs,'centered'); title('Pre-TX: Baseband Upsampled Signal Spectrum');
figure;periodogram(signal,[],length(signal),TX_Fs,'centered'); title('Pre-TX: Upconverted Signal Spectrum');

len_bits = length(bits);

num_symbols = ceil ( len_bits /  (num_data_carriers*max(log2(M),1)) );
num_packets = ceil ( num_symbols /  num_symbols_per_packet );

y = y';

time_axis = 0:(1/RX_Fs):(((length(y)/RX_Fs))-(1/RX_Fs));
time_axis_bb = 0:(1/BW):(((length(y)/(ds_rate*BW)))-(1/BW));

[y_bb_us,y_bb_hp] = downconvert(y, Fc, RX_Fs, BW);
y_bb = downsample(y_bb_us(1,1:end), ds_rate);


figure;periodogram(y,[],length(y),TX_Fs,'centered');title('Post-RX: Upconverted Unfiltered Upsampled Signal Spectrum');
figure;periodogram(y_bb_hp,[],length(y_bb_hp),TX_Fs,'centered');title('Post-RX: Baseband Unfiltered Upsampled Signal Spectrum');
figure;periodogram(y_bb_us,[],length(y_bb_us),TX_Fs,'centered');title('Post-RX: Baseband Filtered Upsampled Signal Spectrum');
figure; periodogram(y_bb,[],length(y_bb),BW,'centered');title('Post-RX: Baseband Filtered Downsampled Signal Spectrum');

[detected_syms,r] = packet_detection_sim_audio(x_stf(1:16), y_bb, (x_stf_len + x_ltf_len - 5));
start_idcs = find(detected_syms);
start_idx = start_idcs(1);

start_idcs_gt = find(detected_syms_gt);
start_idx_gt = start_idcs_gt(1);

figure;plot(abs(y)); hold on;plot(abs(signal));
figure;plot(abs(y_bb(start_idx:end)));
hold on;plot(abs(x_bb(start_idx_gt:end)));
plot(r(start_idx:end));
stem(detected_syms(start_idx:end));
figure; stem(detected_syms); hold on; stem(detected_syms_gt);

if (length(find(detected_syms)) == length(find(detected_syms_gt)))
        find(detected_syms)-find(detected_syms_gt)
end
