clear all;
close all;

addpath('../fxns');

p = ofdm_par_fxn();

d.sim = false;

rx_suffix = '_03_11_2020_17_58_34';
tx_suffix = '_03_11_2020_17_58_35_jtof12_q1';
load(strcat('../save/hardware_tests_tx/tx_variables',tx_suffix,'.mat'));
load(strcat('../save/hardware_tests_rx/rx_variables',rx_suffix,'.mat'));

p.thresh_factor = 2.75;%3.5;

% % % TEMPORARY ADDITIONS % % %
% p.fto_range = 7;
% p.align_downconversion = true;
% p.freq_correct = false;
% p.fine_timing_align = true;


p.plot_spectrum = true;
p.plot_separate = true;
p.plot_signal = true;
p.plot_comparison = true;
p.print_detection = true;
p.plot_channel_estimation = true;
p.plot_L = false;
p.plot_pilot_est = false;
p.plot_data = true;

[y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L,H_hat_pilot,syms_eq,bits_est,ints] = ofdm_rx_fxn(y,p,d);

ofdm_proc_fxn(bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, H_hat_pilot,syms_eq,bits_est,ints,...
         r, p, d);
