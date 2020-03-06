clear all;
close all;

addpath('../fxns');

p = ofdm_par_fxn();

h = [1,.7,.5,.3,.1];%, .5];
h = h(1:p.num_taps);
h = h/vecnorm(h);
H = fft(h, 64);
H_og = fft([1],64);
freq_offset_eps = .000;
freq_offset = freq_offset_eps * p.delta_fs;

d.sim = true;
d.h = h;
d.H = H;

SNR = 200;

[bits, syms, syms_int, signal_bb, signal_bb_ds, signal, detected_syms_gt,...
 detected_syms_gt_ds] = ofdm_tx_fxn(p);

if p.channel == true
    y = channel_fxn(signal, h, freq_offset, SNR, p.symbol_time);
else
    y = signal;
end

[y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L]= ofdm_rx_fxn(y,p,d);

ofdm_proc_fxn(bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, r, p, d);
