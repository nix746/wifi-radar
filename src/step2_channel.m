function [signal, fc, c] = step2_channel(waveform, fs, USE_TGAX_CHANNEL, cfg)
% CHANNEL Simulates a multipath radar channel with delay, Doppler shifts, and AWGN noise.
%
% Inputs:
%   waveform         - Transmitted baseband waveform
%   fs               - Sampling frequency
%   USE_TGAX_CHANNEL - boolean to use TGax background clutter
%   cfg              - (Optional) WLAN configuration object (e.g. wlanHESUConfig, wlanNonHTConfig)
% Output:
%   signal - Received baseband signal containing direct path and target reflections
%   fc     - Carrier frequency
%   c      - Speed of light

fprintf(">> Running Channel Simulation...\n");

N = length(waveform);
t = (0 : N-1).' / fs;
c = 3e8;
fc = 5.5e9;

%% 1. Target & Multipath Parameters
sample_res = c / (2 * fs);
target_delays = round([52.5, 105.0] / sample_res); % Targets at 52.5 m and 105 m

if USE_TGAX_CHANNEL
    taps     = [ 0.05, 0.04 ];
    delays   = target_delays;
    dopplers = [ -500, 1200 ];
else
    taps     = [ 1.0,  0.05,    0.04 ];
    delays   = [ 0,    target_delays ];
    dopplers = [ 0,   -500,     1200 ];
end

fprintf("  Configured %d reflection paths:\n", length(taps));
for k = 1 : length(taps)
    range_m = delays(k) * sample_res;
    vel_ms = (dopplers(k) * c) / (2 * fc);
    fprintf("    Path %d: Delay=%d spl (%.2f m), Doppler=%d Hz (%.2f m/s), Gain=%.2f\n", ...
        k, delays(k), range_m, dopplers(k), vel_ms, taps(k));
end

%% 2. Background Clutter (TGax Model-B)
if USE_TGAX_CHANNEL
    % Extract channel bandwidth from configuration or deduce from fs
    if nargin >= 4 && ~isempty(cfg) && isprop(cfg, 'ChannelBandwidth')
        cbw = cfg.ChannelBandwidth;
    else
        cbw = sprintf('CBW%d', round(fs / 1e6));
    end

    fprintf("  Generating realistic TGax background clutter (Model-B, %s)...\n", cbw);
    tgax = wlanTGaxChannel;
    tgax.SampleRate              = fs;
    tgax.ChannelBandwidth        = cbw;
    tgax.CarrierFrequency        = fc;
    tgax.DelayProfile            = 'Model-B';
    tgax.LargeScaleFadingEffect  = 'None';
    tgax.NormalizeChannelOutputs = false;

    clutter_signal = tgax(waveform);
    intrinsic_delay = info(tgax).ChannelFilterDelay;

    % Match lengths to transmitted waveform
    if length(clutter_signal) > N
        clutter_signal = clutter_signal(1:N);
    elseif length(clutter_signal) < N
        clutter_signal = [clutter_signal; zeros(N - length(clutter_signal), 1)];
    end
else
    clutter_signal = zeros(N, 1);
    intrinsic_delay = 0;
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
