function radar_data = step3_receiver(signal, waveform, fs, fc, WIFI_STANDARD, cbw, k_pri, known_sync_idx)
% STEP3_RECEIVER OFDM demodulation, channel estimation, static echo removal, and 2D Range-Doppler map.
%
% Inputs:
%   signal         - Received baseband time-domain signal
%   waveform       - Reference transmitted time-domain waveform
%   fs             - Sampling frequency [Hz]
%   fc             - Carrier frequency [Hz]
%   WIFI_STANDARD  - Standard name ('802.11a', '802.11ax') or params struct
%   cbw            - (Optional) Channel bandwidth ('CBW20', 'CBW40', 'CBW80', 'CBW160')
%   k_pri          - (Optional) Slow-time PRI subsampling factor in OFDM symbols (default: 1)
%   known_sync_idx - (Optional) Known hardware frame-start sample offset for co-located
%                    Tx-Rx operation (e.g. intrinsic_delay from step2_channel). When omitted
%                    or empty, performs blind WLAN Toolbox preamble synchronization.
%
% Output:
%   radar_data     - Struct containing complex periodogram, axes, and intermediate matrices

if nargin < 7 || isempty(k_pri)
    k_pri = 1;
end
if nargin < 8
    known_sync_idx = [];
end

fprintf('>> Running Receiver Pipeline...\n');

% 1. Resolve Wi-Fi parameters
if isstruct(WIFI_STANDARD) && isfield(WIFI_STANDARD, 'standard')
    params = WIFI_STANDARD;
else
    if nargin < 6 || isempty(cbw)
        cbw = sprintf('CBW%d', round(fs / 1e6));
    end
    params = get_wifi_params(WIFI_STANDARD, [], cbw);
end

cbw  = params.cfg.ChannelBandwidth;
Nfft = params.Nfft;
Ncp  = params.Ncp;

% 2. Packet synchronization: co-located hardware trigger or blind WLAN Toolbox preamble sync
if ~isempty(known_sync_idx)
    sync_idx  = round(double(known_sync_idx));
    sync_mode = 'hardware';
    fprintf('  Using co-located hardware frame-start trigger (sync_idx = %d spl).\n', sync_idx);
else
    pktOffset = wlanPacketDetect(signal, cbw);
    if isempty(pktOffset)
        error('Packet not detected by wlanPacketDetect.');
    end

    % Limit L-LTF correlation to preamble window (L-STF + L-LTF = 16 us, plus 8 us margin)
    preamble_end = min(length(signal), pktOffset + round(24e-6 * fs));
    [fineOffset_peak, M] = wlanSymbolTimingEstimate(signal(pktOffset + 1 : preamble_end), cbw);
    if isempty(fineOffset_peak)
        error('Fine symbol timing estimation failed in wlanSymbolTimingEstimate.');
    end

    % First-arrival-path (leading-edge) refinement on L-LTF metric M:
    % wlanSymbolTimingEstimate's built-in threshold searches forward (CSD), so radar
    % requires a backward search to avoid locking onto delayed multipath clusters (Model-E/F).
    [M_max, n_peak] = max(M);
    search_start    = max(1, n_peak - min(Ncp, round(1.6e-6 * fs)));
    M_bg            = median(M(1 : max(1, search_start - 1)));
    leading_thr     = max(8 * M_bg, 0.08 * M_max);
    n_first         = search_start + find(M(search_start : n_peak) >= leading_thr, 1, 'first') - 1;
    while n_first < n_peak && M(n_first + 1) > M(n_first), n_first = n_first + 1; end
    fineOffset      = fineOffset_peak + (n_first - n_peak);

    sync_idx  = pktOffset + fineOffset;
    sync_mode = 'wlan_preamble';
end
payload_start_rx = sync_idx + params.payload_start;

if payload_start_rx < 1 || payload_start_rx > length(signal)
    error('Synchronized payload start (%d) is outside the signal bounds [1, %d].', ...
        payload_start_rx, length(signal));
end

y_cut = signal(payload_start_rx : end);
x_cut = waveform(params.payload_start : end);

% 3. OFDM demodulation
[F_rx, n_symbols_rx] = demodulate(y_cut, Nfft, Ncp);
[F_tx, n_symbols_tx] = demodulate(x_cut, Nfft, Ncp);

n_symbols = min(n_symbols_rx, n_symbols_tx);
F_rx      = F_rx(:, 1:n_symbols);
F_tx      = F_tx(:, 1:n_symbols);

fprintf('  Demodulated %d OFDM symbols (%d subcarriers each, %s).\n', n_symbols, Nfft, cbw);

% 4. Channel frequency response estimation, static echo removal, and DC null interpolation
[H_shifted, H_raw, zeta_dB, H_no_static] = estimate_channel(F_rx, F_tx, params);

% 5. 2D Blackman-Harris windowing and Range-Doppler periodogram
[CPer_F, W, N_per, M_per, Per_F, N_act] = compute_range_doppler_map( ...
    H_shifted, Nfft, n_symbols, params.active_mask);

% 6. Physical axes and output struct
[axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per, [], k_pri);

radar_data = struct();
radar_data.CPer_F        = CPer_F;
radar_data.Per_F         = Per_F;
radar_data.W             = W;
radar_data.N_act         = N_act;
radar_data.N_per         = N_per;
radar_data.M_per         = M_per;
radar_data.Nfft          = Nfft;
radar_data.n_symbols     = n_symbols;
radar_data.Ncp           = Ncp;
radar_data.fs            = fs;
radar_data.fc            = fc;
radar_data.k_pri         = k_pri;
radar_data.H_raw         = H_raw;
radar_data.H_no_static   = H_no_static;
radar_data.H_shifted     = H_shifted;
radar_data.zeta_dB       = zeta_dB;
radar_data.axis_range    = axis_range;
radar_data.axis_velocity = axis_velocity;
radar_data.params        = params;
radar_data.sync_idx      = sync_idx;
radar_data.sync_mode     = sync_mode;

fprintf('  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n', N_per, M_per);
end
