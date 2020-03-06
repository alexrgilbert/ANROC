clear all;
close all;

addpath('../fxns');
addpath('../helpers');

p = ofdm_par_fxn();

[x_stf,x_ltf] = gt_training_fields(p.x_stf_len,p.x_ltf_len,p.delta_fs,p.symbol_time);

save('../save/training_fields.mat','x_stf','x_ltf');
