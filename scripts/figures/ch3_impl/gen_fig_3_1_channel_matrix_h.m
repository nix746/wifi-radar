function gen_fig_3_1_channel_matrix_h()
% GEN_FIG_3_1_CHANNEL_MATRIX_H
% Experiment IMPL-1: Channel transfer matrix H(k,l) in the time-frequency domain.
% Figure 3.1 for Chapter 3 of the thesis:
%   (a) Raw transfer matrix before MTI (showing DPI crosstalk and DC gap)
%   (b) Transfer matrix after slow-time MTI filtering and linear DC interpolation
%
% Output file: thesis/img/ch3_impl/rys_3_1_macierz_transmitancji_h.png

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 3.1: Channel matrix H (Experiment IMPL-1)\n');
    fprintf('=================================================================\n');

    % 1. Initialize project paths and random number generator seed
    init_paths();
    rng(42); % Ensure repeatability of noise and random payload data
    
    wifi_standard = '802.11ax';
    cbw = 'CBW20';
    channel_model = 'Model-C';
    
    % High SNR regime (45 dB) to clearly expose the physical wave structure
    % and target phase modulation fringes before 2D integration
    snr_dB = 45; 
    
    % 2. Generate transmitted baseband waveform (IEEE 802.11ax HE-SU)
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, 0);
    
    % 3. Simulate multipath TGax channel with moving targets
    % Physical scenario:
    %   - Target 1: Vehicle (R = 15.0 m, v = +8.0 m/s, RCS = 15.0 m^2)
    %   - Target 2: Pedestrian (R = 8.0 m, v = +2.0 m/s, RCS = 2.0 m^2)
    targets = [ ...
        struct('range_m', 15.0, 'velocity_mps', 8.0, 'type', 'car', 'rcs', 15.0), ...
        struct('range_m', 8.0,  'velocity_mps', 2.0, 'type', 'human', 'rcs', 2.0) ...
    ];
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

    % 4. Packet synchronization and OFDM demodulation
    pktOffset = wlanPacketDetect(rx_signal, cbw);
    if isempty(pktOffset)
        pktOffset = 0;
        fineOffset = 0;
    else
        fineOffset = wlanSymbolTimingEstimate(rx_signal(pktOffset+1:end), cbw);
    end
    sync_idx = pktOffset + fineOffset;
    payload_start_rx = sync_idx + params.payload_start;
    
    y_cut = rx_signal(payload_start_rx : end);
    x_cut = waveform(params.payload_start : end);
    
    Nfft = params.Nfft;
    Ncp = params.Ncp;
    [F_rx, n_rx] = demodulate(y_cut, Nfft, Ncp);
    [F_tx, n_tx] = demodulate(x_cut, Nfft, Ncp);
    n_symbols = min(n_rx, n_tx);
    F_rx = F_rx(:, 1:n_symbols);
    F_tx = F_tx(:, 1:n_symbols);
    
    % 5. Zero-Forcing channel estimation before and after MTI filtering
    epsilon = 1e-9;
    H_zf = (F_rx ./ (F_tx + epsilon)) .* ifftshift(params.active_mask);
    H_raw = fftshift(H_zf, 1);
    
    % Slow-time MTI filtering and linear DC subcarrier interpolation
    H_proc = estimate_channel_zf(F_rx, F_tx, params);

    % 6. Numerical validation of direct path (DPI) suppression
    static_component_raw = mean(H_raw, 2);
    static_component_proc = mean(H_proc, 2);
    p_static_raw = mean(abs(static_component_raw(params.active_mask > 0)).^2);
    p_static_proc = mean(abs(static_component_proc(params.active_mask > 0)).^2);
    
    suppression_dpi_dB = 10 * log10(p_static_raw / max(p_static_proc, 1e-15));
    total_power_raw_dB = 10 * log10(mean(abs(H_raw(:)).^2));
    total_power_proc_dB = 10 * log10(mean(abs(H_proc(:)).^2));
    total_drop_dB = total_power_raw_dB - total_power_proc_dB;
    
    fprintf('  Total power before MTI:    %+.2f dB\n', total_power_raw_dB);
    fprintf('  Total power after MTI:     %+.2f dB (drop of %.2f dB)\n', total_power_proc_dB, total_drop_dB);
    fprintf('  Static component suppress: > %.1f dB (MTI eliminates DPI)\n', min(suppression_dpi_dB, 120));
    
    % 7. Two-panel plot for the thesis
    fig = figure('Name', 'Figure 3.1 - Channel Transfer Matrix H(k,l)', ...
        'Color', 'white', 'Position', [100, 100, 1260, 560], 'Visible', 'off');

    % Active subcarrier range (for 802.11ax CBW20: indices -122 to +122)
    ofdminfo = wlanHEOFDMInfo('HE-Data', cfg);
    act_idx = ofdminfo.ActiveFrequencyIndices;
    k_range = min(act_idx) : max(act_idx);         % -122 .. +122
    k_indices_in_matrix = (1 + Nfft/2) + k_range; % 1-based matrix row indices
    
    H_raw_sub = H_raw(k_indices_in_matrix, :);
    H_proc_sub = H_proc(k_indices_in_matrix, :);
    
    % Convert magnitude to decibel scale [dB]
    H_raw_dB = 20 * log10(abs(H_raw_sub) + 1e-9);
    H_proc_dB = 20 * log10(abs(H_proc_sub) + 1e-9);
    
    sym_axis = 1:n_symbols;
    
    % Panel (a): Raw transfer matrix before MTI filtering
    subplot(1, 2, 1);
    imagesc(sym_axis, k_range, H_raw_dB);
    axis xy;
    colormap(gca, 'parula');
    clim([-35, 5]); % Color limits highlighting multipath fading dips and DC notch
    c1 = colorbar;
    c1.Label.String = 'Moc transmitancji [dB]';
    c1.Label.FontSize = 10.5;
    c1.Label.Interpreter = 'none';
    
    title('a) Przed MTI', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Numer symbolu OFDM (czas wolny)', 'FontSize', 11, 'Interpreter', 'none');
    ylabel('Indeks podnośnej k (częstotliwość)', 'FontSize', 11, 'Interpreter', 'none');
    set(gca, 'FontSize', 10, 'LineWidth', 1.0);
    grid on;
    set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

    % Panel (b): Transfer matrix after MTI filtering and DC interpolation
    subplot(1, 2, 2);
    imagesc(sym_axis, k_range, H_proc_dB);
    axis xy;
    colormap(gca, 'parula');
    clim([-45, -15]); % Color limits exposing target interference wave fringes
    c2 = colorbar;
    c2.Label.String = 'Moc transmitancji [dB]';
    c2.Label.FontSize = 10.5;
    c2.Label.Interpreter = 'none';
    
    title('b) Po MTI', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Numer symbolu OFDM (czas wolny)', 'FontSize', 11, 'Interpreter', 'none');
    ylabel('Indeks podnośnej k (częstotliwość)', 'FontSize', 11, 'Interpreter', 'none');
    set(gca, 'FontSize', 10, 'LineWidth', 1.0);
    grid on;
    set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

    % Overall figure title
    sgtitle('Macierz transmitancji H(k,l)', 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

    % 8. Export figure in high resolution (300 DPI) to thesis directory
    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    out_dir = fullfile(project_root, 'thesis', 'img', 'ch3_impl');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
    out_file = fullfile(out_dir, 'rys_3_1_macierz_transmitancji_h.png');
    
    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('  Figure saved to: %s\n', out_file);
    close(fig);
    fprintf('=================================================================\n');
end
