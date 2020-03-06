clear all;
close all;

addpath('../fxns');

p = ofdm_par_fxn();

d.sim = false;

load(strcat('../save/tx_variables',p.save_suffix,'.mat'));
load(strcat('../save/rx_variables',p.save_suffix,'.mat'));

[y_bb_us,y_bb_hp,y_bb,detected_syms,r, H_hat_avg, L_hat_avg, L]= ofdm_rx_fxn(y,p,d);

ofdm_proc_fxn(bits, syms, syms_int, signal_bb, signal_bb_ds, signal,...
        detected_syms_gt, detected_syms_gt_ds, y, y_bb_us, y_bb_hp, y_bb,...
         detected_syms, H_hat_avg, L_hat_avg, L, r, p, d);
