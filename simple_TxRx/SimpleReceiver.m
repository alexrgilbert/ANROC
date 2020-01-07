close all;
clear all;
clc;

Fs = 8192;
nBits = 8;
NumChannels = 1;
filename = 'recording.wav';
record_time = 5;

recObj =  audiorecorder(Fs, nBits, NumChannels);

disp('Start Recording.')
recordblocking(recObj, record_time);
disp('End of Recording.');

y = getaudiodata(recObj);
audiowrite(filename,y,Fs);


disp('Start of Playback.');
sound(y,Fs);
disp('End of Playback.');

% time_axis = 0:(1/Fs):(((length(y)/Fs))-(1/Fs));
% 
% figure;
% plot(time_axis,y);
% 
% y_bb = zeros(size(y));
% for i = 1:length(y)
%     y_bb(i) = y(i) * cos(2*pi*500*i);
% end

% y_s = zeros(1,(length(y)/Fs));
% for i = 1:Fs:(length(y)/Fs)
%     
%     for j = 1:Fs
%         
%     end
% end

% figure;
% plot(time_axis,y_bb);