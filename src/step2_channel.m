function [signal, fc, intrinsic_delay] = step2_channel(waveform, fs, model, cfg, targets, p_rx_dBm, fc_input, nf_dB, k_pri)
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
%   p_rx_dBm - (Optional) Received residual direct-path + clutter power [dBm] (default: -50.0 dBm,
%              corresponding to 70 dB passive Tx-Rx isolation + analog SIC at 20 dBm AP EIRP)
%   fc_input - (Optional) Carrier frequency in Hz or band string ('2.4GHz', '5GHz', '6GHz', default: 5.5e9)
%   nf_dB    - (Optional) Receiver noise figure [dB] (default: 7.0 dB)
%   k_pri    - (Optional) Slow-time PRI subsampling factor in OFDM symbols (default: 1)
% Output:
%   signal   - Received baseband signal containing direct path, clutter, and target reflections
%   fc       - Carrier frequency [Hz]
%   intrinsic_delay - TGax channel filter delay [samples] (ideal packet sync index)

if nargin < 6 || isempty(p_rx_dBm)
    p_rx_dBm = -50.0;
end
if nargin < 7 || isempty(fc_input)
    fc = 5.5e9;
else
    [fc, ~] = get_carrier_frequency(fc_input);
end
if nargin < 8 || isempty(nf_dB)
    nf_dB = 7.0;
end
if nargin < 9 || isempty(k_pri)
    k_pri = 1;
end

% Normalize model format (support both 'Model-A' and 'A')
if ischar(model) || isstring(model)
    model = char(model);
    if ~startsWith(upper(model), 'MODEL-')
        model = ['Model-' upper(model)];
    end
end

% Thermal noise power P_N = k_B * T_0 * B * F (T_0 = 290 K)
k_B              = 1.380649e-23; % Boltzmann constant [J/K]
T_0              = 290.0;        % Reference noise temperature [K]
bw_hz            = str2double(regexprep(cfg.ChannelBandwidth, '\D', '')) * 1e6;
p_n_dBm          = 10 * log10(k_B * T_0 * bw_hz * 1e3) + nf_dB;
effective_snr_dB = p_rx_dBm - p_n_dBm;

fprintf('>> Running Channel Simulation (Model: %s, fc: %.3f GHz, P_rx: %.1f dBm, P_N(%s): %.1f dBm, SNR: %.2f dB)...\n', ...
    model, fc / 1e9, p_rx_dBm, cfg.ChannelBandwidth, p_n_dBm, effective_snr_dB);

N = length(waveform);
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
    [delays, dopplers, taps, target_info] = configure_targets(targets, fs, fc, model, p_rx_dBm);
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
if k_pri == 1
    t_eff = (0 : N-1).' / fs;
else
    ind = wlanFieldIndices(cfg);
    if isa(cfg, 'wlanNonHTConfig')
        payload_start_1 = double(ind.NonHTData(1));
        sym_len = 80;
    else
        payload_start_1 = double(ind.HEData(1));
        ofdminfo = wlanHEOFDMInfo('HE-Data', cfg);
        sym_len  = double(ofdminfo.FFTLength) + round(cfg.GuardInterval * 1e-6 * fs);
    end
    idx_0     = (0 : N-1).';
    t_eff     = idx_0 / fs;
    rel_start = payload_start_1 + intrinsic_delay - 1;
    mask_data = idx_0 >= rel_start;
    rel       = idx_0(mask_data) - rel_start;
    sym_idx   = floor(rel / sym_len);
    in_sym    = mod(rel, sym_len);
    t_eff(mask_data) = (rel_start + sym_idx * k_pri * sym_len + in_sym) / fs;
end

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
        target_signal = target_signal + taps(k) * delayed .* exp(1j * 2 * pi * dopplers(k) * t_eff);
    end
end

signal = clutter_signal + target_signal;

% 4. Anchor AWGN noise power to nominal transmitted waveform power (decoupled from TGax fading)
ref_power_dBW = 10 * log10(max(mean(abs(waveform).^2), eps));
signal        = awgn(signal, effective_snr_dB, ref_power_dBW);
fprintf('  Channel simulation complete (P_rx = %.1f dBm, P_N(%s, NF=%.1f dB) = %.2f dBm, SNR_eff = %.2f dB).\n', ...
    p_rx_dBm, cfg.ChannelBandwidth, nf_dB, p_n_dBm, effective_snr_dB);
end
