clear all;
close all;

addpath('../fxns');

p = ofdm_par_fxn();

h = [1,.7,.5];%, .5];
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

y = channel_fxn(signal, h, freq_offset, SNR, p.symbol_time);

[y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L]= ofdm_rx_fxn(y,p,d);

ofdm_proc_fxn(bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, r, p, d);

 %
 % Columns 1 through 17
 %
 %    -1.5599   -3.1416    3.1416    0.0000    0.0000   -3.1416   -3.1416   -3.1416   -3.1416   -3.1416   -3.1416    0.0000   -3.1416    0.0000   -3.1416   -3.1416    0.0000
 %     0.5933    3.1416   -3.1416   -0.0000   -0.0000    3.1416    3.1416    3.1416    3.1416    3.1416    3.1416   -0.0000    3.1416   -0.0000    3.1416    3.1416   -0.0000
 %
 %
 %   Columns 18 through 34
 %
 %     0.0000   -3.1416   -3.1416   -3.1416   -3.1416   -3.1416   -3.1416    0.0000   -3.1416    0.0000    2.4159    0.0808    1.0299    0.7182   -0.4913    0.5537    0.6968
 %    -0.0000   -3.1416    3.1416    3.1416    3.1416    3.1416   -3.1416   -0.0000    3.1416   -0.0000   -0.8478   -3.0043   -2.7149   -0.1271   -0.5324   -2.4592   -0.3132
 %
 %
 %   Columns 35 through 51
 %
 %     0.3491   -2.1292    1.7961   -0.2645   -0.0000    3.1416    3.1416    0.0000    0.0000    3.1416   -3.1416   -3.1416   -3.1416    3.1416    0.0000    3.1416   -0.0000
 %     1.2158    1.7260    2.9075    0.8275    0.0000    3.1416    3.1416    0.0000    0.0000    3.1416   -3.1416   -3.1416    3.1416    3.1416   -0.0000    3.1416   -0.0000
 %
 %
 %   Columns 52 through 64
 %
 %     3.1416   -0.0000   -0.0000   -3.1416    3.1416    0.0000    0.0000   -0.0000    0.0000    0.0000   -3.1416   -0.0000   -3.1416
 %     3.1416   -0.0000   -0.0000   -3.1416   -3.1416   -0.0000    0.0000   -0.0000   -0.0000    0.0000    3.1416    0.0000    3.1416
 %
 % Columns 1 through 17
 %
 %    0.5933    3.1416   -3.1416   -0.0000   -0.0000    3.1416    3.1416    3.1416    3.1416    3.1416    3.1416   -0.0000    3.1416   -0.0000    3.1416    3.1416   -0.0000
 %
 %  Columns 18 through 34
 %
 %   -0.0000   -3.1416    3.1416    3.1416    3.1416    3.1416   -3.1416   -0.0000    3.1416   -0.0000   -0.8478   -3.0043   -2.7149   -0.1271   -0.5324   -2.4592   -0.3132
 %
 %  Columns 35 through 51
 %
 %    1.2158    1.7260    2.9075    0.8275    0.0000    3.1416    3.1416    0.0000    0.0000    3.1416   -3.1416   -3.1416    3.1416    3.1416   -0.0000    3.1416   -0.0000
 %
 %  Columns 52 through 64
 %
 %    3.1416   -0.0000   -0.0000   -3.1416   -3.1416   -0.0000    0.0000   -0.0000   -0.0000    0.0000    3.1416    0.0000    3.1416
