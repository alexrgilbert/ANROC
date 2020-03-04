

filename = 'recording.wav';
rx_record_time = 1;
rx_nBits = 16;
rx_NumChannels = 1;
RX_Fs = 48000;

recObj =  audiorecorder(RX_Fs, rx_nBits, rx_NumChannels);

disp('Start Recording.')
recordblocking(recObj, rx_record_time);
disp('End of Recording.');

y = getaudiodata(recObj);
audiowrite(filename,y,RX_Fs);

disp('Start of Playback.');
sound(y,RX_Fs);
disp('End of Playback.');

save 'rx_variables.mat' y
