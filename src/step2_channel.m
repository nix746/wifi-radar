function [signal, fc] = step2_channel(waveform, fs, model, cfg)
% STEP2_CHANNEL Simulates a multipath radar channel with delay, Doppler shifts, and AWGN noise.
%
% Inputs:
%   waveform - Transmitted baseband waveform
%   fs       - Sampling frequency [Hz]
%   model    - TGax delay profile model ('A', 'B', 'C', 'D', 'E', 'F' or 'Model-A'...'Model-F')
%                * 'A' (Model-A): Flat fading (Direct path only, no multipath clutter)
%                * 'B' (Model-B): Indoor residential clutter
%                * 'D' (Model-D): Office environment clutter
%   cfg      - WLAN configuration object (from step1_transmitter)
% Output:
%   signal   - Received baseband signal containing direct path, clutter, and target reflections
%   fc       - Carrier frequency [Hz]

fprintf(">> Running Channel Simulation...\n");

N = length(waveform);
t = (0 : N-1).' / fs;
c = 3e8;
fc = 5.5e9;

%% 1. Radar Target Parameters (Moving Objects)
sample_res = c / (2 * fs);
target_delays = round([52.5, 105.0] / sample_res); % Targets at 52.5 m and 105 m

taps     = [ 0.05, 0.04 ];
delays   = target_delays;
dopplers = [ -500, 1200 ];

fprintf("  Configured %d radar targets:\n", length(taps));
for k = 1 : length(taps)
    range_m = delays(k) * sample_res;
    vel_ms = (dopplers(k) * c) / (2 * fc);
    fprintf("    Target %d: Delay=%d spl (%.2f m), Doppler=%d Hz (%.2f m/s), Gain=%.2f\n", ...
        k, delays(k), range_m, dopplers(k), vel_ms, taps(k));
end

%% 2. Background Clutter & Direct Path (TGax Channel)
if length(model) == 1
    model = ['Model-' upper(model)];
end

fprintf("  Generating TGax channel propagation (%s, %s)...\n", model, cfg.ChannelBandwidth);
tgax = wlanTGaxChannel;
tgax.SampleRate              = fs;
tgax.ChannelBandwidth        = cfg.ChannelBandwidth;
tgax.CarrierFrequency        = fc;
tgax.DelayProfile            = model;
tgax.LargeScaleFadingEffect  = 'None';
tgax.NormalizeChannelOutputs = false;

clutter_signal = tgax(waveform);
intrinsic_delay = info(tgax).ChannelFilterDelay;

% Match length to transmitted waveform
if length(clutter_signal) > N
    clutter_signal = clutter_signal(1:N);
elseif length(clutter_signal) < N
    clutter_signal = [clutter_signal; zeros(N - length(clutter_signal), 1)];
end

%% 3. Target Reflections
target_signal = zeros(N, 1);
for k = 1 : length(taps)
    delay = delays(k) + intrinsic_delay;
    if delay < N
        delayed = [zeros(delay, 1); waveform(1 : N - delay)];
        target_signal = target_signal + taps(k) * delayed .* exp(1j * 2 * pi * dopplers(k) * t);
    end
end

signal = clutter_signal + target_signal;

%% 4. Additive White Gaussian Noise (AWGN)
SNR_dB = 25;
signal = awgn(signal, SNR_dB, 'measured');
fprintf("  Channel simulation complete (SNR = %d dB).\n", SNR_dB);
end
