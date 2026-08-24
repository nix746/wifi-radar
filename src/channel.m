% CHANNEL
% Simulates a multipath radar channel with delay, Doppler shifts, and AWGN noise.
%
% Input:
%   waveform.mat - Transmitted baseband waveform
% Output:
%   signal.mat   - Received baseband signal containing direct path and target reflections

fprintf(">> Running Channel Simulation...\n");

%% 1. Load Transmitted Waveform
if ~isfile("waveform.mat")
    error("waveform.mat not found. Please run transmitter.m first!");
end
load("waveform.mat", "waveform", "fs");

N = length(waveform);
t = (0 : N-1).' / fs;

%% 2. Target & Multipath Parameters
% Target definitions: [Direct path (0m, 0 Hz), Target 1, Target 2]
taps     = [ 1.0,   0.05,   0.04   ]; % Relative complex amplitudes
delays   = [ 0,     7,      14     ]; % Delays in samples
dopplers = [ 0,    -500,    1200   ]; % Doppler frequency shifts [Hz]

c = 3e8;
fc = 5.5e9;
sample_range_res = c / (2 * fs); % ~7.5 m per sample

fprintf("  Configured %d reflection paths:\n", length(taps));
for k = 1 : length(taps)
    range_m = delays(k) * sample_range_res;
    vel_ms = (dopplers(k) * c) / (2 * fc);
    fprintf("    Path %d: Delay=%d spl (%.2f m), Doppler=%d Hz (%.2f m/s), Gain=%.2f\n", ...
        k, delays(k), range_m, dopplers(k), vel_ms, taps(k));
end

%% 3. Channel Application (Linear Delay & Doppler Modulation)
signal = zeros(size(waveform));

for k = 1 : length(taps)
    delay = delays(k);
    gain = taps(k);
    fd = dopplers(k);
    
    delayed_signal = zeros(N, 1);
    if delay < N 
        delayed_signal(delay + 1 : end) = waveform(1 : end - delay);
    end

    doppler_factor = exp(1j * 2 * pi * fd * t);
    signal = signal + (gain * delayed_signal .* doppler_factor);
end

%% 4. Additive White Gaussian Noise (AWGN)
SNR_dB = 25;
signal = awgn(signal, SNR_dB, 'measured');

%% 5. Save Output
save("signal.mat", "signal", "taps", "delays", "dopplers", "SNR_dB", "fc", "c");
fprintf("  Received signal saved to 'signal.mat' (SNR = %d dB).\n", SNR_dB);
