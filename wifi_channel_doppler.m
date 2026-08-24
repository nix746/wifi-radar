% wifi_channel_doppler.m
% Wi-Fi Radar Channel Simulator

clear all; close all; clc;

% 1. SIGNAL READ

load("WiFi_MCS0_BW20.mat"); 

tx_clean = receivedSignal;
fs = metadata.sampleRate;

% 2. CHANNEL PARAMS

% Taps, Delays, Dopplers
taps     = [ 1.0,  0.01,   0.01   ]; 
delays   = [ 0,    7,     14    ];  
Dopplers = [ 0,    15000,   -7500  ]; 

SNR_dB = 30; % Noise

% 3. CHANNEL

y_channel = zeros(size(tx_clean));
time_vec = (0 : length(tx_clean)-1).' / fs;

for k = 1 : length(taps)
    % Delay
    sig_delayed = circshift(tx_clean, delays(k));
    % if delays(k) > 0
    %     sig_delayed(1:delays(k)) = 0;
    % end
    
    % Doppler
    doppler_factor = exp(1j * 2 * pi * Dopplers(k) * time_vec);
    
    % Sum
    y_channel = y_channel + (taps(k) * sig_delayed .* doppler_factor);
end

% Noise
rng('default');
rx_dirty = awgn(y_channel, SNR_dB, 'measured');

% 4. SAVING TO FILE 
receivedSignal = rx_dirty; 

metadata.sampleRate = fs;
metadata.centerFreq = 0;        
metadata.duration = length(rx_dirty)/fs; 
metadata.timestamp = datetime('now');
metadata.isSimulation = true;

filename = sprintf('WiFi_Doppler.mat');

% Zapis
save(filename, 'receivedSignal', 'metadata');
disp(['Plik zapisano jako: ' filename]);
