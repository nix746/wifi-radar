function radar_data = step3_receiver(signal, waveform, fs, fc, WIFI_STANDARD, ENABLE_VISUALIZATIONS, cbw)
% STEP3_RECEIVER OFDM demodulation, ZF channel estimation, MTI, and 2D Range-Doppler map.
%
% Inputs:
%   signal                - Received baseband time-domain signal
%   waveform              - Reference transmitted time-domain waveform
%   fs                    - Sampling frequency [Hz]
%   fc                    - Carrier frequency [Hz]
%   WIFI_STANDARD         - Standard name ('802.11a', '802.11ax') or params struct
%   ENABLE_VISUALIZATIONS - Logical flag to enable diagnostic plots
%   cbw                   - (Optional) Channel bandwidth ('CBW20', 'CBW40', 'CBW80', 'CBW160')
%
% Output:
%   radar_data            - Struct containing complex periodogram, axes, and intermediate matrices

    if nargin < 6 || isempty(ENABLE_VISUALIZATIONS)
        ENABLE_VISUALIZATIONS = false;
    end

    fprintf('>> Running Receiver Pipeline...\n');

    %% 1. Resolve Wi-Fi Parameters
    if isstruct(WIFI_STANDARD) && isfield(WIFI_STANDARD, 'standard')
        params        = WIFI_STANDARD;
        WIFI_STANDARD = params.standard;
    else
        if nargin < 7 || isempty(cbw)
            cbw = sprintf('CBW%d', round(fs / 1e6));
        end
        params = get_wifi_params(WIFI_STANDARD, [], cbw);
    end

    cbw  = params.cfg.ChannelBandwidth;
    Nfft = params.Nfft;
    Ncp  = params.Ncp;

    %% 2. Packet Synchronization & Payload Extraction
    pktOffset = wlanPacketDetect(signal, cbw);
    if isempty(pktOffset)
        warning('Packet not detected by wlanPacketDetect. Falling back to ideal synchronization.');
        pktOffset  = 0;
        fineOffset = 0;
    else
        fineOffset = wlanSymbolTimingEstimate(signal(pktOffset + 1 : end), cbw);
    end

    sync_idx         = pktOffset + fineOffset;
    payload_start_rx = sync_idx + params.payload_start;

    if payload_start_rx > length(signal)
        error('Synchronized payload start is beyond the end of the signal.');
    end

    y_cut = signal(payload_start_rx : end);
    x_cut = waveform(params.payload_start : end);

    %% 3. Manual OFDM Demodulation
    [F_rx, n_symbols_rx] = demodulate(y_cut, Nfft, Ncp);
    [F_tx, n_symbols_tx] = demodulate(x_cut, Nfft, Ncp);

    n_symbols = min(n_symbols_rx, n_symbols_tx);
    F_rx      = F_rx(:, 1:n_symbols);
    F_tx      = F_tx(:, 1:n_symbols);

    fprintf('  Demodulated %d OFDM symbols (%d subcarriers each, %s).\n', n_symbols, Nfft, cbw);

    %% 4. Channel Estimation, MTI Filtering, and DC Subcarrier Interpolation
    [H_shifted, H_raw, zeta_zf_dB] = estimate_channel_zf(F_rx, F_tx, params);

    %% 5. 2D Blackman-Harris Windowing and Complex Periodogram Generation
    [CPer_base, W_2D, N_per, M_per] = compute_range_doppler_map( ...
        H_shifted, Nfft, n_symbols, params.active_mask);

    %% 6. Physical Axes and Output Packaging
    [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per);

    radar_data = struct();
    radar_data.CPer_base     = CPer_base;
    radar_data.W_2D          = W_2D;
    radar_data.N_per         = N_per;
    radar_data.M_per         = M_per;
    radar_data.Nfft          = Nfft;
    radar_data.n_symbols     = n_symbols;
    radar_data.Ncp           = Ncp;
    radar_data.H_raw         = H_raw;
    radar_data.H_shifted     = H_shifted;
    radar_data.zeta_zf_dB    = zeta_zf_dB;
    radar_data.axis_range    = axis_range;
    radar_data.axis_velocity = axis_velocity;
    radar_data.params        = params;

    fprintf('  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n', N_per, M_per);

    %% 7. Diagnostic Visualization
    if ENABLE_VISUALIZATIONS
        constellation_diagram(F_rx(:), sprintf('Receiver - Demodulated Constellation (RX) (%s, %s)', WIFI_STANDARD, cbw));
        radar_heatmap(fftshift(F_rx, 1), sprintf('Demodulated Symbols (%s, %s)', WIFI_STANDARD, cbw), 'Symbol Index (Time)', 'Subcarrier Index (Frequency)');
        radar_heatmap(H_raw, sprintf('Channel Response (H Matrix) (%s, %s)', WIFI_STANDARD, cbw), 'Symbol Index (Time)', 'Subcarrier Index (Freq)');
        range_doppler_3d(CPer_base, axis_velocity, axis_range, sprintf('Receiver - 3D Range-Doppler Map (%s, %s)', WIFI_STANDARD, cbw));
    end
end
