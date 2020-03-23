clear all;
close all;

addpath('../fxns');
addpath('../helpers');

p = ofdm_par_fxn();


h = [1,.9,.8,.7,.6,.5,.4,.3,.2,.1];%, .5];
% if p.upconvert == false
%     for n = 1:length(h)
%         h(n) = h(n) * exp(-1*j*2*pi*p.Fc*(n/p.TX_Fs));
%     end
% end
h = h(1:p.num_taps);
if p.broadband == true
    delay_len = (p.symbol_time * p.tap_delay_factor) * p.TX_Fs;
    h_l = zeros(1,length(h)*delay_len);
    for i = 1:length(h)
        h_l((delay_len*(i-1))+1) = h(i);
    end
    h = h_l;
end
h = h/vecnorm(h);
H = fft(h, 64);
% h = upsample(h,p.us_rate);
H_og = fft([1],64);
freq_offset_eps = .001;
freq_offset = freq_offset_eps * p.delta_fs;

d.sim = true;
d.h = h;
d.H = H;

SNR = 25;

% SNRS =  0:5:50;
% trials = 1:5;
% BERS = zeros(1,length(SNRS));
% for SNR = SNRS
%     avg_ber = 0;
%     for trial = trials

        [bits_gt, syms_gt, ints_gt, signal_bb, signal_bb_ds, signal, detected_syms_gt,...
         detected_syms_gt_ds] = ofdm_tx_fxn(p);

        if p.channel == true
            y = channel_fxn(signal, h, freq_offset, SNR, p.symbol_time);
        else
            y = signal;
        end

        [y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L,H_hat_pilot,syms_eq,bits,ints]= ofdm_rx_fxn(y,p,d);

        ofdm_proc_fxn(bits_gt, syms_gt, ints_gt, signal_bb, signal_bb_ds, signal,...
                detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
                 detected_syms, H_hat_avg, L_hat_avg, L, H_hat_pilot,syms_eq,bits,ints, r, p, d);

%          min_length = min(length(bits_gt),length(bits));
%          avg_ber = avg_ber + (sum((bits_gt(1:min_length) ~= bits(1:min_length)))/min_length);
%     end
%     BERS((SNR/5)+1) = avg_ber/length(trials);
% end
%
% figure; hold on;set(gcf,'color','w');set(gca,'YScale','log');
% grid on; grid minor;
% plot(0:2:20,BERS,'-bo');
% xticks(0:2:20);
% xticklabels(0:2:20);
% xlabel('SNR');
% ylabel('BER')
% title('Bit Error Rates vs SNR');
