    close all;
clear all;
clc;
Fc = 500;
Fs = 44100;
nBits = 64;
NumChannels = 1;
filename = 'recording.wav';
record_time = 8;

recObj =  audiorecorder(Fs, nBits, NumChannels);

disp('Start Recording.')
recordblocking(recObj, record_time);
disp('End of Recording.');

y = getaudiodata(recObj);
audiowrite(filename,y,Fs);


disp('Start of Playback.');
sound(y,Fs);
disp('End of Playback.');

time_axis = 0:(1/Fs):(((length(y)/Fs))-(1/Fs));

figure;
plot(time_axis,y);

y_bb_i = zeros(size(y));
y_bb_q = zeros(size(y));
c = zeros(size(y));
s = zeros(size(y));
for i = 1:length(y)
    y_bb_i(i) = y(i) * sqrt(2)*cos(2*pi*FC*i/Fs);
    c(i) = sqrt(2)*cos(2*pi*FC*i/Fs);
end
for i = 1:length(y)
    y_bb_q(i) = y(i) * -1 * sqrt(2) * sin(2*pi*FC*i/Fs);
    s(i) = -sqrt(2)*(2*pi*FC*i/Fs);
end

y_bb = complex(y_bb_i,y_bb_q);

y_s = zeros(1,(length(y)/Fs));
for i = 1:Fs:(length(y)/Fs)
    
    for j = 1:Fs
        
    end
end

figure;
plot(time_axis,y_bb);