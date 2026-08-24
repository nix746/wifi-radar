% Transmitter.m
% Outputs a file with a frame ready to transmit

clc
clearvars
close all
fprintf(">> Transmitter\n")


%% Config of a non High Throughput Frame
psdu_length = 4095;

cfgNonHT = wlanNonHTConfig;
cfgNonHT.PSDULength = psdu_length;
t = transmitTime(cfgNonHT);

%% Frame creation
payload = randi([0 1], psdu_length* 8, 1);   
waveform = wlanWaveformGenerator(payload, cfgNonHT); 

save("waveform.mat", "waveform")

%% Plot
fs = wlanSampleRate(cfgNonHT);
[pxx, f] = pwelch(waveform, [], [], [], fs, 'centered');

plot(f/1e6, 10*log10(pxx))
title('Power Spectral Density Estimate')
xlabel('Frequency [MHz]')
ylabel('Power [dB/Hz]')
grid on
