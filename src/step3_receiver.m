function radar_data = step3_receiver(signal, waveform, fs, fc, c, WIFI_STANDARD, ENABLE_VISUALIZATIONS)
% RECEIVER_PIPELINE
% Stage 1: OFDM Demodulation, Zero-Forcing Channel Estimation, MTI, DC Repair, 
% 2D Blackman-Harris Windowing, and Complex Range-Doppler Periodogram Generation.
%
% Inputs:
%   signal       - Received signal
%   waveform     - Transmitted waveform
%   fs           - Sampling frequency
%   fc           - Carrier frequency
%   c            - Speed of light
%   WIFI_STANDARD - Standard string
%   ENABLE_VISUALIZATIONS - boolean
% Output:
%   radar_data   - Struct containing periodogram and parameters

    fprintf(">> Running Receiver Pipeline...\n");

    params = get_wifi_params(WIFI_STANDARD);
    cbw = params.cfg.ChannelBandwidth;
    Nfft = params.Nfft;
    Ncp = params.Ncp;

    %% 1. Synchronization & Payload Extraction
    pktOffset = wlanPacketDetect(signal, cbw);
    if isempty(pktOffset)
        warning('Packet not detected by wlanPacketDetect. Falling back to ideal synchronization.');
        pktOffset = 0;
        fineOffset = 0;
    else
        fineOffset = wlanSymbolTimingEstimate(signal(pktOffset+1:end), cbw);
    end

    sync_idx = pktOffset + fineOffset; 
    payload_start_rx = sync_idx + params.payload_start;

    if payload_start_rx > length(signal)
        error('Synchronized payload start is beyond the end of the signal.');
    end

    y_cut = signal(payload_start_rx : end);
    x_cut = waveform(params.payload_start : end);

    %% 2. Manual OFDM Demodulation
    [F_rx, n_symbols_rx] = demodulate(y_cut, Nfft, Ncp);
    [F_tx, n_symbols_tx] = demodulate(x_cut, Nfft, Ncp);

    n_symbols = min(n_symbols_rx, n_symbols_tx);
    F_rx = F_rx(:, 1:n_symbols);
    F_tx = F_tx(:, 1:n_symbols);

    fprintf("  Demodulated %d OFDM symbols (%d subcarriers each).\n", n_symbols, Nfft);

    %% 3. Channel Estimation, MTI Filtering and DC Subcarrier Interpolation
    H_shifted = estimate_channel_zf(F_rx, F_tx, params);

    %% 4. 2D Blackman-Harris Windowing and Complex Periodogram Generation
    [CPer_base, W_2D_unshifted, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols);

    %% 5. Pack Data for Interpretation
    radar_data = struct();
    radar_data.CPer_base = CPer_base;
    radar_data.W_2D_unshifted = W_2D_unshifted;
    radar_data.N_per = N_per;
    radar_data.M_per = M_per;
    radar_data.Nfft = Nfft;
    radar_data.n_symbols = n_symbols;
    radar_data.Ncp = Ncp;

    fprintf("  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n", N_per, M_per);

    %% 6. Visualization
    if ENABLE_VISUALIZATIONS
        constellation_diagram(F_rx(:), sprintf('Receiver - Demodulated Constellation (RX) (%%s)', WIFI_STANDARD));
        
        radar_heatmap(fftshift(F_rx, 1), sprintf('Demodulated Symbols (%%s)', WIFI_STANDARD), 'Symbol Index (Time)', 'Subcarrier Index (Frequency)');
        
        H_raw = F_rx ./ (F_tx + 1e-9);
        radar_heatmap(fftshift(H_raw, 1), sprintf('Channel Response (H Matrix) (%%s)', WIFI_STANDARD), 'Symbol Index (Time)', 'Subcarrier Index (Freq)');
        
        [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per, c);
        
        range_doppler_3d(CPer_base, axis_velocity, axis_range, sprintf('Receiver - 3D Range-Doppler Map (%%s)', WIFI_STANDARD));
    end
end
