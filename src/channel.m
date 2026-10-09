% CHANNEL
% Simulates a multipath radar channel with delay, Doppler shifts, and AWGN noise.
%
% Input:
%   waveform.mat - Transmitted baseband waveform
% Output:
%   signal.mat   - Received baseband signal containing direct path and target reflections

fprintf(">> Running Channel Simulation...\n");

if ~exist('USE_TGAX_CHANNEL', 'var')
    USE_TGAX_CHANNEL = true; % Default if not run from run_all.m
end

%% 1. Load Transmitted Waveform
if ~isfile("waveform.mat")
    error("waveform.mat not found. Please run transmitter.m first!");
end
load("waveform.mat", "waveform", "fs");

N = length(waveform);
t = (0 : N-1).' / fs;

%% 2. Target & Multipath Parameters
if USE_TGAX_CHANNEL
    % When using TGax, it provides the direct path leakage and static background clutter.
    % We only define the moving radar targets here: [Target 1, Target 2]
    taps     = [ 0.05,   0.04   ]; % Relative complex amplitudes
    delays   = [ 7,      14     ]; % Delays in samples
    dopplers = [ -500,    1200   ]; % Doppler frequency shifts [Hz]
else
    % Ideal channel: [Direct path (0m, 0 Hz), Target 1, Target 2]
    taps     = [ 1.0,   0.05,   0.04   ]; % Relative complex amplitudes
    delays   = [ 0,     7,      14     ]; % Delays in samples
    dopplers = [ 0,    -500,    1200   ]; % Doppler frequency shifts [Hz]
end

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

%% 3. Channel Application (Background Clutter + Targets)
if USE_TGAX_CHANNEL
    fprintf("  Generating realistic TGax background clutter (Model-B)...\n");
    tgax = wlanTGaxChannel;
    tgax.SampleRate = fs;
    tgax.DelayProfile = 'Model-B'; % Typical indoor office environment
    tgax.LargeScaleFadingEffect = 'None';
    tgax.NormalizeChannelOutputs = false; % Keep realistic power levels
    
    clutter_signal = tgax(waveform);
    
    % Get intrinsic delay of the TGax channel filter to align targets
    chInfo = info(tgax);
    intrinsic_delay = chInfo.ChannelFilterDelay;
    
    % Match lengths
    if length(clutter_signal) > N
        clutter_signal = clutter_signal(1:N);
    elseif length(clutter_signal) < N
        clutter_signal = [clutter_signal; zeros(N - length(clutter_signal), 1)];
    end
else
    clutter_signal = zeros(N, 1);
    intrinsic_delay = 0;
end

target_signal = zeros(size(waveform));

for k = 1 : length(taps)
    % Align target delays with the intrinsic delay of the direct path
    delay = delays(k) + intrinsic_delay;
    gain = taps(k);
    fd = dopplers(k);
    
    delayed_signal = zeros(N, 1);
    if delay < N 
        delayed_signal(delay + 1 : end) = waveform(1 : end - delay);
    end

    doppler_factor = exp(1j * 2 * pi * fd * t);
    target_signal = target_signal + (gain * delayed_signal .* doppler_factor);
end

signal = clutter_signal + target_signal;

%% 4. Additive White Gaussian Noise (AWGN)
SNR_dB = 25;
signal = awgn(signal, SNR_dB, 'measured');

%% 5. Save Output
save("signal.mat", "signal", "taps", "delays", "dopplers", "SNR_dB", "fc", "c");
fprintf("  Received signal saved to 'signal.mat' (SNR = %d dB).\n", SNR_dB);
