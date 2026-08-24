% wifi_doppler.m
% Wi-Fi Radar Channel Simulator

clearvars; close all;

% 1. SIGNAL READ

load("WiFi_MCS0_BW20.mat"); 

tx_clean = receivedSignal;
fs = metadata.sampleRate;
N = length(tx_clean); 

% 2. CHANNEL PARAMS

% Taps, Delays, Dopplers
taps     = [ 1.0,   0.5,    0.4    ]; 
delays   = [ 0,     7,      14     ]; 
Dopplers = [ 0,     -500,   1200   ];

SNR_dB = 25; % Noise

% 3. CHANNEL

y_channel = zeros(size(tx_clean));
time_vec = (0 : length(tx_clean)-1).' / fs;

for k = 1 : length(taps)
    % Delay
    %sig_delayed = circshift(tx_clean, delays(k));
    %if delays(k) > 0
    %    sig_delayed(1:delays(k)) = 0;
    %end
    
    d = delays(k);
    
    % --- POPRAWKA: Przesunięcie Liniowe (Linear Shift) ---
    % Zamiast circshift, tworzymy wektor zer o długości opóźnienia,
    % doklejamy go na początek, a następnie przycinamy koniec, 
    % aby długość wektora się zgadzała.
    
    if d > 0
        % 1. Stwórz ciszę (zera) na początku
        padding = zeros(d, 1);
        
        % 2. Przesuń sygnał (doklej zera na start)
        shifted_signal = [padding; tx_clean];
        
        % 3. Przytnij ogon, aby pasował do okna odbiorczego
        sig_delayed = shifted_signal(1:N);
    else
        % Brak opóźnienia
        sig_delayed = tx_clean;
    end
    % Doppler
    doppler_factor = exp(1j * 2 * pi * Dopplers(k) * time_vec);
    
    % Sum
    y_channel = y_channel + (taps(k) * sig_delayed .* doppler_factor);
end

% Noise
rng('default');
rx_dirty = awgn(y_channel, SNR_dB, 'measured');

% 4. PLOTING
