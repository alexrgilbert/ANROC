clear all;
close all;

p = ofdm_par_fxn();

[bits, syms, syms_int, signal_bb, signal_bb_ds, signal, detected_syms_gt,...
 detected_syms_gt_ds] = ofdm_tx_fxn(p);

 sound(signal, p.TX_Fs);

 save(strcat('tx_variables',p.save_suffix,'.mat'), 'bits', 'syms', 'syms_int', 'signal_bb', 'signal_bb_ds', 'signal', 'detected_syms_gt',...
  'detected_syms_gt_ds');
