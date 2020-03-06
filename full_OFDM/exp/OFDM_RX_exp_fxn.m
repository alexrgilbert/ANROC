
addpath('../fxns');

p = ofdm_par_fxn();

filename = 'recording.wav';
rx_record_time = 1;
rx_nBits = 16;
rx_NumChannels = 1;

recObj =  audiorecorder(p.RX_Fs, rx_nBits, rx_NumChannels);

disp('Start Recording.')
recordblocking(recObj, rx_record_time);
disp('End of Recording.');

y = getaudiodata(recObj);
audiowrite(filename,y,p.RX_Fs);

disp('Start of Playback.');
sound(y,p.RX_Fs);
disp('End of Playback.');

y = y';
save(strcat('../save/rx_variables',p.save_suffix,'.mat'),'y');
