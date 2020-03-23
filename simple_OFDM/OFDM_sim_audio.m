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
num_train_packets = 20;
num_dead_carriers = 12;
num_pilots = 4;
num_prefix = 16;
num_symbols_per_packet = 12;
x_stf_len = 160;
x_ltf_len = 160;
delta_fs = BW / 64;
symbol_time = 1 / BW;

[x_stf,x_ltf] = gt_training_fields(x_stf_len,x_ltf_len,delta_fs,symbol_time);

h = [1,0.5,.7];
h = h/vecnorm(h);
H = fft(h, 64);
H_og = fft([1],64);
freq_offset_eps = .000;
freq_offset = freq_offset_eps * delta_fs;

SNR = 20;

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
signal_bb_downsampled = complex(zeros(1,20*(packet_length/us_rate)),...
    zeros(1,20*(packet_length/us_rate)));

% detected_syms_gt = zeros(1,((20*(packet_length/us_rate)) + (100*(train_packet_length/us_rate))));
% j = 1;
% for i = 1:120
%    if (i > 100)
%        packet_bits = bits(1,(((j-1)*packet_data_bits_length)+1):(j*packet_data_bits_length));
%        [x,syms] = packet_generator_sim_audio(M,packet_bits,x_stf_len,...
%         x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
%         num_prefix,num_dead_carriers,num_pilots);
%        signal_bb(((100) * (train_packet_length))+((i-101) * packet_length)+1:...
%            ((100) * (train_packet_length))+((i-100) * packet_length)) = x;
%        syms(((j-1) * packet_data_syms_length)+1:(j * packet_data_syms_length)) = syms;
%        detected_syms_gt((((100) * (train_packet_length/us_rate))+((i-101) * (packet_length/us_rate)))+1) = 1;
%        j = j+1;
%    else
%        packet_bits = [];
%        [x,~] = packet_generator_sim_audio(M,packet_bits,x_stf_len,...
%         x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
%         num_prefix,num_dead_carriers,num_pilots);
%        signal_bb(((i-1) * train_packet_length)+1:((i) * train_packet_length)) = x;
%        detected_syms_gt((((i-1) * (train_packet_length/us_rate)))+1) = 1;
%    end
%
% end
% j = 1;
% syms = complex(zeros(1,num_packets*packet_data_syms_length),...
%                     zeros(1,num_packets*packet_data_syms_length));
% signal_bb = complex(zeros(1,packet_length),...
%             zeros(1,packet_length));
% packet_bits = bits(1,(((j-1)*packet_data_bits_length)+1):(j*packet_data_bits_length));
% [x,syms] = packet_generator_sim_audio(M,packet_bits,x_stf_len,...
% x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
% num_prefix,num_dead_carriers,num_pilots);
% signal_bb(((j-1) * packet_length)+1:(j * packet_length)) = x;
% syms(((j-1) * packet_data_syms_length)+1:(j * packet_data_syms_length)) = syms;
H_hat_avg = complex(zeros(1,64),zeros(1,64));
cnt = 0;
for i = 1:num_train_packets
    packet_bits = [];
    [x_downsampled,x,~] = packet_generator_sim_audio(M,packet_bits,x_stf_len,...
    x_ltf_len,delta_fs,symbol_time,us_rate,num_symbols_per_packet,num_carriers,...
    num_prefix,num_dead_carriers,num_pilots);

    signal = upconvert(x,Fc,TX_Fs);

    if i == 1
        figure;periodogram(x,[],length(signal_bb),TX_Fs,'centered'); title('signal_bb');
        figure;periodogram(signal,[],length(signal),TX_Fs,'centered'); title('signal_bb');
    end

    [signal_extended, start_idx, start_idx_ds, post_len_ds] =...
         extend_rng(signal, random_range,us_rate);
    % detected_syms_gt = zeros(1, (floor(length(signal_extended)/us_rate)));
    % detected_syms_gt(floor((start_idx-1)/us_rate)+1) = 1;
    detected_syms_gt = zeros(1,start_idx_ds + length(x_downsampled) - 1 + post_len_ds);
    detected_syms_gt(start_idx_ds) = 1;
% % %     signal_extended = signal;
% % %     detected_syms_gt = zeros(1,length(x_downsampled));
% % %     detected_syms_gt(1) = 1;



    y = channel(signal_extended, h, freq_offset, SNR, symbol_time);

    [y_bb_us,y_bb_hp] = downconvert(y, Fc, RX_Fs, BW);
    y_bb = downsample(y_bb_us(1,1:(end-(length(h)-1))), ds_rate);

    if i == 1
        figure;periodogram(y_bb_hp,[],length(y_bb_hp),TX_Fs,'centered');title('y_bb_hp');
        figure;periodogram(y_bb_us,[],length(y_bb_us),TX_Fs,'centered'); title('y_bb_us');
        x_bb = downsample(x(1,1:end), ds_rate);
        figure;periodogram(x_bb,[],length(x_bb),BW,'centered');title('x_bb');
        figure; periodogram(y_bb,[],length(y_bb),BW,'centered');title('y_bb');
    end

    [detected_syms,r] = packet_detection_sim_audio(x_stf(1:16), y_bb, (x_stf_len + x_ltf_len - 5));

    if (i == 1 )%|| (sum(detected_syms ~= detected_syms_gt) > 0))
        figure;plot(abs(y_bb(1:end))); hold on;plot([zeros(1,floor(start_idx/us_rate)-1) abs(x_bb(1:end))]); plot(r); stem(detected_syms);
% % %         figure;plot(abs(y_bb(1:end))); hold on;plot([abs(x_bb(1:end))]); plot(r); stem(detected_syms);
        figure; stem(detected_syms - detected_syms_gt);
    end
    if (length(find(detected_syms)) == length(find(detected_syms_gt)))
            find(detected_syms)-find(detected_syms_gt)
    end

    ltf_idx = find(detected_syms) + x_stf_len;
    y_ltf = y_bb(ltf_idx:(ltf_idx + x_ltf_len - 1));

    [H_hat,L_hat,L] = channel_estimator_sim_audio(SNR,delta_fs,symbol_time,x_ltf,y_ltf);

    if (sum(detected_syms ~= detected_syms_gt) == 0)
        cnt = cnt + 1;
        H_hat_avg = H_hat_avg + (H_hat / num_train_packets);
    end

end

if SNR == SNR%100))
    figure;
    xlabel('Frequency (delta_fs)');
    title('Channel Estimate vs Actual');
    stem(1:1:length(H),abs(H),'r');
    hold on;
    stem(1:1:length(H_hat_avg),abs(H_hat_avg),'c');
    stem(1:1:length(H),angle(H),'y');
    stem(1:1:length(H_hat_avg),angle(H_hat_avg),'g');
    stem(1:1:length(L_hat),abs(L_hat),'b');
    stem(1:1:length(L_hat),angle(L_hat),'k');
    stem(1:1:length(L_hat),abs(L),'m');
    stem(1:1:length(L_hat),angle(L),'r');
    legend('Actual Magnitude','Estimated Magnitude', ...
             'Actual Phase', 'Estimated Phase',...
             'L magnitude', 'L Phase',...
             'L hat magnitude', 'L hat phase');
end

cnt


% signal = upconvert(signal_bb,Fc,TX_Fs);



% figure;periodogram(signal_bb,[],length(signal_bb),TX_Fs,'centered')
% figure;periodogram(signal,[],length(signal),TX_Fs,'centered')
%
% y = channel(signal, h, freq_offset, SNR, symbol_time);
%
% [y_bb_us,y_bb_hp] = downconvert(y, Fc, RX_Fs, BW);
% y_bb = downsample(y_bb_us(1,1:(end-(length(h)-1))), ds_rate);
%
% figure;periodogram(y_bb_hp,[],length(y_bb_hp),TX_Fs,'centered');
% figure;periodogram(y_bb_us,[],length(y_bb_us),TX_Fs,'centered');
% x_bb = downsample(signal_bb(1,1:end), ds_rate);
% figure;periodogram(x_bb,[],length(x_bb),BW,'centered');
% figure; periodogram(y_bb,[],length(y_bb),BW,'centered')
%
% [detected_syms,r] = packet_detection_sim_audio(x_stf(1:16), y_bb, (x_stf_len + x_ltf_len - 5));
% figure;plot(abs(y_bb(1:end))); hold on;plot(abs(x_bb(1:end))); plot(r); stem(detected_syms);
% figure; stem(detected_syms - detected_syms_gt); find(detected_syms)-find(detected_syms_gt)
