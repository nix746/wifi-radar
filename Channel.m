% Channel.m
% Simulates channel conditions with reflections

clearvars
close all

%% Define Reflections
taps     = [ 1.0,   0.05,   0.04   ]; 
delays   = [ 0,     7,      14     ]; 
dopplers = [ 0,    -500,    1200   ];

%% Constants
fc = 5.5e9; 
c = 3e8;
fs = wlanSampleRate("CBW20");

load("waveform.mat")
N = length(waveform);
t = (0 : N-1).' / fs;


%% Doppler shift
signal = zeros(size(waveform));
for k = 1 : length(taps)
    delay = delays(k);
    gain = taps(k);
    fd = dopplers(k);
    
    delayed_signal = zeros(N, 1);
    if delay < N 
        delayed_signal(delay+1:end) = waveform(1:end-delay);
    end

    doppler_factor = exp(1j * 2 * pi * fd * t);
    signal = signal + (gain * delayed_signal .* doppler_factor);
end

%% Noise
SNR = 25;                                       %[dB]
signal = awgn(signal, SNR, 'measured');

save("signal.mat", "signal")
