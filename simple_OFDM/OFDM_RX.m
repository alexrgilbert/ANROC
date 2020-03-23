
close all;
clear all;
clc;
Fc = 500;
Fs = 44100;
us_rate = 2.25;
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
    % In Phase
    y_bb_i(i) = y(i) * sqrt(2)*cos(2*pi*FC*i/Fs);
    c(i) = sqrt(2)*cos(2*pi*FC*i/Fs);
    % Quadrature
    y_bb_q(i) = y(i) * -1 * sqrt(2) * sin(2*pi*FC*i/Fs);
    s(i) = -sqrt(2)*sin(2*pi*FC*i/Fs);
end

y_bb = complex(y_bb_i,y_bb_q);

    us_len = us_rate*length(x);
    x_upsampled = complex(zeros(1,us_len),...
                        zeros(1,us_len));
ds_len = length(y_bb) / us_rate;
y_bb_downsampled = complex(zeros(1,ds_len),...
                    zeros(1,ds_len));

for i = 1:(ds_len)
    upsampled_idcs = (ceil((i-1)*2.25)+1):1:()(ceil((i)*2.25)+1)-1)
    % % % TODO:  BETTER TO JUST CHOOSE ONE OR TAKE AVERAGE?
    y_bb_downsampled(1,i) = (y_bb(1,upsampled_idcs(1)));
    % y_bb_downsampled(1,i) = mean(y_bb(1,upsampled_idcs));
end



figure;
plot(time_axis,y_bb_downsampled);
