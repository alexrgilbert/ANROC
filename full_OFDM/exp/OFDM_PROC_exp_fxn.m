clear all;
close all;

addpath('../fxns');

p = ofdm_par_fxn();

d.sim = false;

rx_suffix = '_09_03_2020_11_17_55';
tx_suffix = '_09_03_2020_11_17_57';
load(strcat('../save/hardware_tests_tx/tx_variables',tx_suffix,'.mat'));
load(strcat('../save/hardware_tests_rx/rx_variables',rx_suffix,'.mat'));

p.thresh_factor = 2.6;

p.plot_spectrum = true;
p.plot_separate = false;
p.plot_signal = true;
p.plot_comparison = true;
p.print_detection = true;
p.plot_channel_estimation = true;
p.plot_L = false;

[y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L]= ofdm_rx_fxn(y,p,d);

ofdm_proc_fxn(bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, r, p, d);
