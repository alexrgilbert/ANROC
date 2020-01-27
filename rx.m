close all;
clear all;
clc;

Fs = 44100;
nBits = 8;
NumChannels = 1;
filename = 'recording.wav';
record_time = 10;

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





y_bb = zeros(size(y));
for i = 1:length(y)
    y_bb(i) = y(i) * -cos(2*pi*500*i/Fs);
end
figure;
plot(time_axis,y_bb);

ythresh = (abs(y) > .1);
idx = find(ythresh,1)
ytemp = y_bb(idx:end);

y_s = zeros(1,(length(ytemp)/Fs*2));
c = 0;
for i = 1:(Fs/2):(length(ytemp))
   c = c+1;
    acc = 0;
    for j = 0:((Fs/2)-1)
        acc = acc + ytemp(i+j);
    end
    disp(acc);
    y_s(c) = (acc > 0);
end

y_s = y_s(1:12);
% 
% symbol_axis = 0:(1):(((length(y)/Fs))-(1));


figure;
plot(y_s);
