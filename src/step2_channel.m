function [signal, fc] = step2_channel(waveform, fs, model, cfg, targets, snr_dB, fc_input)
% STEP2_CHANNEL Simulates a multipath radar channel with delay, Doppler shifts, and AWGN noise.
%
% Inputs:
%   waveform - Transmitted baseband waveform
%   fs       - Sampling frequency [Hz]
%   model    - TGax delay profile model:
%                * 'Model-A' (or 'A'): Flat fading (direct path only, no multipath clutter)
%                * 'Model-B' (or 'B'): Indoor residential clutter
%                * 'Model-C' (or 'C'): Small office clutter (tau_rms = 30 ns)
%                * 'Model-E' (or 'E'): Large hall/office clutter (tau_rms = 100 ns)
%   cfg      - WLAN configuration object (from step1_transmitter)
%   targets  - (Optional) Struct or array of structs defining target properties:
%                * type: 'human', 'car', 'pet', or 'custom'
%                * range_m: Target range in meters
%                * velocity_mps / doppler_hz: Motion parameter
%                * rcs: (Optional) RCS in m^2
%                * gain: (Optional) Manual echo amplitude override
%   snr_dB   - (Optional) AWGN SNR in dB referenced to direct path & clutter power (default: 25)
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

    % Normalize model format (support both 'Model-A' and 'A')
    if ischar(model) || isstring(model)
        model = char(model);
        if ~startsWith(upper(model), 'MODEL-')
            model = ['Model-' upper(model)];
        end
    end

    fprintf('>> Running Channel Simulation (Model: %s, fc: %.3f GHz, SNR: %.1f dB)...\n', model, fc / 1e9, snr_dB);

    N = length(waveform);
    t = (0 : N-1).' / fs;
    c = 3e8;

    % 1. Target parameters
    sample_res = c / (2 * fs);

    if nargin < 5 || isempty(targets)
        % Default targets at 5.0 m and 13.5 m for backward compatibility
        target_delays = round([5, 13.5] / sample_res);
        taps     = [0.02, 0.01];
        delays   = target_delays;
        dopplers = [-50, 2];
        target_info = [];
    else
        [delays, dopplers, taps, target_info] = configure_targets(targets, fs, fc);
    end

    fprintf('  Configured %d radar targets:\n', length(taps));
    for k = 1 : length(taps)
        range_m = delays(k) * sample_res;
        vel_ms = (dopplers(k) * c) / (2 * fc);
        if ~isempty(target_info) && isfield(target_info(k), 'type')
            fprintf('    Target %d [%s, RCS=%.2f m^2]: Delay=%.1f spl (%.2f m), Doppler=%+.1f Hz (%+.2f m/s), Gain=%.4f\n', ...
                k, upper(target_info(k).type), target_info(k).rcs, delays(k), range_m, dopplers(k), vel_ms, abs(taps(k)));
        else
            fprintf('    Target %d: Delay=%.1f spl (%.2f m), Doppler=%+.1f Hz (%+.2f m/s), Gain=%.4f\n', ...
                k, delays(k), range_m, dopplers(k), vel_ms, abs(taps(k)));
        end
    end

    % 2. Background clutter & direct path (TGax channel)
    fprintf('  Generating TGax channel propagation (%s, %s)...\n', model, cfg.ChannelBandwidth);
    tgax = wlanTGaxChannel;
    tgax.SampleRate              = fs;
    tgax.ChannelBandwidth        = cfg.ChannelBandwidth;
    tgax.CarrierFrequency        = fc;
    tgax.DelayProfile            = model;
    tgax.LargeScaleFadingEffect  = 'None';
    tgax.NormalizeChannelOutputs = false;

    clutter_signal = tgax(waveform);
    intrinsic_delay = info(tgax).ChannelFilterDelay;

    if length(clutter_signal) > N
        clutter_signal = clutter_signal(1:N);
    elseif length(clutter_signal) < N
        clutter_signal = [clutter_signal; zeros(N - length(clutter_signal), 1)];
    end

    % 3. Moving target reflections (integer + fractional delay via FFT phase ramp)
    target_signal = zeros(N, 1);
    for k = 1 : length(taps)
        delay  = delays(k) + intrinsic_delay;
        d_int  = floor(delay);
        d_frac = delay - d_int;
        if d_int < N
            delayed = [zeros(d_int, 1); waveform(1 : N - d_int)];
            if d_frac > 1e-6
                k_freq = [0 : floor(N/2)-1, -ceil(N/2) : -1].';
                delayed = ifft(fft(delayed) .* exp(-1j * 2 * pi * k_freq * d_frac / N));
            end
            target_signal = target_signal + taps(k) * delayed .* exp(1j * 2 * pi * dopplers(k) * t);
        end
    end

    signal = clutter_signal + target_signal;

    % 4. Anchor AWGN noise power to direct path + clutter so target RCS does not alter noise floor
    ref_power_dBW = 10 * log10(max(mean(abs(clutter_signal).^2), eps));
    signal = awgn(signal, snr_dB, ref_power_dBW);
    fprintf('  Channel simulation complete (SNR = %.1f dB).\n', snr_dB);
end
