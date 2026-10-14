function [signal, fc] = step2_channel(waveform, fs, model, cfg, targets, snr_dB, fc_input)
% STEP2_CHANNEL Simulates a multipath radar channel with delay, Doppler shifts, and AWGN noise.
%
% Inputs:
%   waveform - Transmitted baseband waveform
%   fs       - Sampling frequency [Hz]
%   model    - TGax delay profile model:
%                * 'Model-A' (or 'A'): Flat fading (Direct path only, no multipath clutter)
%                * 'Model-B' (or 'B'): Indoor residential clutter
%                * 'Model-D' (or 'D'): Office environment clutter
%   cfg      - WLAN configuration object (from step1_transmitter)
%   targets  - (Optional) Struct or array of structs defining target properties:
%                * type: 'human', 'car', 'pet', or 'custom'
%                * range_m: Target range in meters
%                * velocity_mps / doppler_hz: Motion parameter
%                * rcs: (Optional) RCS in m^2
%                * gain: (Optional) Manual echo amplitude override
%   snr_dB   - (Optional) Additive White Gaussian Noise SNR in dB (default: 25)
%   fc_input - (Optional) Carrier frequency in Hz or band string ('2.4GHz', '5GHz', '6GHz', default: 5.5e9)
% Output:
%   signal   - Received baseband signal containing direct path, clutter, and target reflections
%   fc       - Carrier frequency [Hz]

    if nargin < 6 || isempty(snr_dB)
        snr_dB = 25;
    end
    if nargin < 7 || isempty(fc_input)
        fc = 5.5e9;
    else
        [fc, ~] = get_carrier_frequency(fc_input);
    end

    % Normalize model format (support direct 'Model-A' / 'Model-B' as well as 'A' / 'B')
    if ischar(model) || isstring(model)
        model = char(model);
        if ~startsWith(upper(model), 'MODEL-')
            model = ['Model-' upper(model)];
        end
    end

    fprintf(">> Running Channel Simulation (Model: %s, fc: %.3f GHz, SNR: %.1f dB)...\n", model, fc / 1e9, snr_dB);

    N = length(waveform);
    t = (0 : N-1).' / fs;
    c = 3e8;

    %% 1. Radar Target Parameters (Moving Objects)
    sample_res = c / (2 * fs);

    if nargin < 5 || isempty(targets)
        % Default targets for backward compatibility
        target_delays = round([5, 13.5] / sample_res); % Targets at 52.5 m and 105 m
        taps     = [ 0.02, 0.01 ];
        delays   = target_delays;
        dopplers = [ -50, 2 ];
        target_info = [];
    else
        [delays, dopplers, taps, target_info] = configure_targets(targets, fs, fc);
    end

    fprintf("  Configured %d radar targets:\n", length(taps));
    for k = 1 : length(taps)
        range_m = delays(k) * sample_res;
        vel_ms = (dopplers(k) * c) / (2 * fc);
        if ~isempty(target_info) && isfield(target_info(k), 'type')
            fprintf("    Target %d [%s, RCS=%.2f m^2]: Delay=%d spl (%.2f m), Doppler=%+.1f Hz (%+.2f m/s), Gain=%.4f\n", ...
                k, upper(target_info(k).type), target_info(k).rcs, delays(k), range_m, dopplers(k), vel_ms, taps(k));
        else
            fprintf("    Target %d: Delay=%d spl (%.2f m), Doppler=%+.1f Hz (%+.2f m/s), Gain=%.4f\n", ...
                k, delays(k), range_m, dopplers(k), vel_ms, taps(k));
        end
    end

    %% 2. Background Clutter & Direct Path (TGax Channel)
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
    signal = awgn(signal, snr_dB, 'measured');
    fprintf("  Channel simulation complete (SNR = %.1f dB).\n", snr_dB);
end
