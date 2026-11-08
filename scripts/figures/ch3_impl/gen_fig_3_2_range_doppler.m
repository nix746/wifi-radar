function gen_fig_3_2_range_doppler()
% GEN_FIG_3_2_RANGE_DOPPLER
% Experiment IMPL-2: Comparison of Raw vs. Processed 2D Range-Doppler
% periodograms for IEEE 802.11ax (CBW80, 80 MHz) in a multipath TGax
% Model-C channel with two moving targets (pedestrian and vehicle).
%
% Layout (2x2):
%   (a) Przed DSP — Wykres 3D (cała mapa jednoznaczna, brak MTI, okno prostokątne)
%   (b) Po DSP    — Wykres 3D (cała mapa jednoznaczna, po MTI, DC i oknie 2D BH)
%   (c) Przed DSP — Zbliżenie 2D na strefę celów (R: 0-85 m, v: +/-25 m/s)
%   (d) Po DSP    — Zbliżenie 2D na strefę celów z detekcją Coherent CLEAN
%
% Output file: thesis/img/ch3_impl/rys_3_2_mapa_range_doppler.png

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 3.2: Range-Doppler Map Before & After DSP (CBW80)\n');
    fprintf('=================================================================\n');

    % 1. Initialize project paths
    init_paths();

    wifi_standard = '802.11ax';
    cbw           = 'CBW80';
    bw_mhz        = 80;
    channel_model = 'Model-C';
    snr_dB        = 45; % High SNR regime (matching Figs. 3.1 & 3.3)

    % Two moving targets (identical across Chapter 3):
    %   Target 1: human (pedestrian) at 22.5 m, -4.0 m/s
    %   Target 2: car at 67.5 m, +18.0 m/s
    targets = [ ...
        struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
        struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
    ];

    % 2. Simulate transmission, multipath channel, receiver DSP, and CLEAN interpreter
    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, 0);

    rng(23); % Deterministic seed where Model-C LOS locks at intrinsic delay (0 m bias)
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

    radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, false);
    [targets_found, ~, ~, pnfr] = step4_interpreter( ...
        radar_data, fs, fc, wifi_standard, false, 2);

    axis_range    = radar_data.axis_range;
    axis_velocity = radar_data.axis_velocity;
    Nfft          = radar_data.Nfft;
    n_symbols     = radar_data.n_symbols;

    % 3. Extract Raw 2D periodogram (no MTI, no DC repair, rectangular window)
    C_raw     = compute_range_doppler_map(radar_data.H_raw, Nfft, n_symbols, params.active_mask, 4, false);
    P_raw_lin = abs(C_raw).^2;
    P_raw_dB  = 10 * log10(P_raw_lin / max(P_raw_lin(:)) + 1e-12);

    % 4. Extract Processed 2D periodogram (after MTI, DC repair, and 2D Blackman-Harris window)
    C_proc     = radar_data.CPer_base;
    P_proc_lin = abs(C_proc).^2;
    P_proc_dB  = 10 * log10(P_proc_lin / max(P_proc_lin(:)) + 1e-12);

    % 5. Diagnostic logging
    [~, r1_idx] = min(abs(axis_range - targets(1).range_m));
    [~, v1_idx] = min(abs(axis_velocity - targets(1).velocity_mps));
    [~, r2_idx] = min(abs(axis_range - targets(2).range_m));
    [~, v2_idx] = min(abs(axis_velocity - targets(2).velocity_mps));

    fprintf('  [Before DSP] Median = %.2f dB | T1 (human) = %+.2f dB | T2 (car) = %+.2f dB\n', ...
        median(P_raw_dB(:)), P_raw_dB(r1_idx, v1_idx), P_raw_dB(r2_idx, v2_idx));
    fprintf('  [After DSP]  Median = %.2f dB | T1 (human) = %+.2f dB | T2 (car) = %+.2f dB | PNFR1 = %.1f dB\n', ...
        median(P_proc_dB(:)), P_proc_dB(r1_idx, v1_idx), P_proc_dB(r2_idx, v2_idx), pnfr.pnfr_dB(1));

    % 6. Create 4-panel figure (2x2): Top row 3D, Bottom row 2D Zoom
    fig = figure('Name', 'Figure 3.2 - Range-Doppler Map Before and After DSP (CBW80)', ...
        'Color', 'white', 'Position', [60, 60, 1340, 960], 'Visible', 'off');

    clim_raw  = [-105, 0];
    z_raw     = -105;
    clim_proc = [-65, 0];
    z_proc    = -65;

    step_r = 16;
    step_v = 8;

    % --- Panel (a): Przed DSP - Wykres 3D (cała mapa jednoznaczna) ---
    subplot(2, 2, 1);
    idx_r1  = 1:step_r:length(axis_range);
    idx_v1  = 1:step_v:length(axis_velocity);
    P_mesh1 = max(P_raw_dB(idx_r1, idx_v1), z_raw);
    mesh(axis_velocity(idx_v1), axis_range(idx_r1), P_mesh1);
    colormap(gca, 'parula');
    clim(clim_raw);
    view(-35, 42);
    xlim([axis_velocity(1), axis_velocity(end)]);
    ylim([0, axis_range(end)]);
    zlim([z_raw, 5]);
    title('a) Przed DSP — Wykres 3D (cała mapa)', ...
        'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
    ylabel('Odległość bistatyczna [m]', 'FontSize', 10, 'Interpreter', 'none');
    zlabel('Moc [dB]', 'FontSize', 10, 'Interpreter', 'none');
    set(gca, 'FontSize', 9.5, 'LineWidth', 0.9);
    grid on;

    % --- Panel (b): Po DSP - Wykres 3D (cała mapa jednoznaczna) ---
    subplot(2, 2, 2);
    r_neigh = reshape(targets_found(:, 1) + (-6:6), 1, []);
    v_neigh = reshape(targets_found(:, 2) + (-3:3), 1, []);
    idx_r2  = unique([1:step_r:length(axis_range), r_neigh]);
    idx_v2  = unique([1:step_v:length(axis_velocity), v_neigh]);
    idx_r2  = idx_r2(idx_r2 >= 1 & idx_r2 <= length(axis_range));
    idx_v2  = idx_v2(idx_v2 >= 1 & idx_v2 <= length(axis_velocity));
    P_mesh2 = max(P_proc_dB(idx_r2, idx_v2), z_proc);
    mesh(axis_velocity(idx_v2), axis_range(idx_r2), P_mesh2);
    colormap(gca, 'parula');
    clim(clim_proc);
    view(-35, 42);
    xlim([axis_velocity(1), axis_velocity(end)]);
    ylim([0, axis_range(end)]);
    zlim([z_proc, 5]);
    title('b) Po DSP — Wykres 3D (cała mapa)', ...
        'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
    ylabel('Odległość bistatyczna [m]', 'FontSize', 10, 'Interpreter', 'none');
    zlabel('Moc [dB]', 'FontSize', 10, 'Interpreter', 'none');
    set(gca, 'FontSize', 9.5, 'LineWidth', 0.9);
    grid on;

    % Zoom coordinates enclosing both objects and direct path:
    zoom_r = [0, 85];
    zoom_v = [-25, 25];

    % --- Panel (c): Przed DSP - Zbliżenie 2D na strefę celów ---
    subplot(2, 2, 3);
    imagesc(axis_velocity, axis_range, P_raw_dB);
    axis xy;
    colormap(gca, 'parula');
    clim(clim_raw);
    xlim(zoom_v);
    ylim(zoom_r);
    hold on;
    plot(targets(1).velocity_mps, targets(1).range_m, 'r+', 'MarkerSize', 11, 'LineWidth', 2.0, ...
        'DisplayName', sprintf('Pieszy (%.1f m, %+.1f m/s)', targets(1).range_m, targets(1).velocity_mps));
    plot(targets(2).velocity_mps, targets(2).range_m, 'mx', 'MarkerSize', 11, 'LineWidth', 2.0, ...
        'DisplayName', sprintf('Samochód (%.1f m, %+.1f m/s)', targets(2).range_m, targets(2).velocity_mps));
    hold off;
    legend('Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
    c3 = colorbar;
    c3.Label.String = 'Moc znormalizowana [dB]';
    c3.Label.FontSize = 10;
    c3.Label.Interpreter = 'none';
    title('c) Przed DSP — Zbliżenie na strefę celów (2D)', ...
        'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
    ylabel('Odległość bistatyczna [m]', 'FontSize', 10.5, 'Interpreter', 'none');
    set(gca, 'FontSize', 10, 'LineWidth', 1.0);
    grid on; set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

    % --- Panel (d): Po DSP - Zbliżenie 2D na strefę celów z detekcją CLEAN ---
    subplot(2, 2, 4);
    imagesc(axis_velocity, axis_range, P_proc_dB);
    axis xy;
    colormap(gca, 'parula');
    clim(clim_proc);
    xlim(zoom_v);
    ylim(zoom_r);
    hold on;
    plot(targets(1).velocity_mps, targets(1).range_m, 'r+', 'MarkerSize', 10, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Pieszy (%.1f m, %+.1f m/s)', targets(1).range_m, targets(1).velocity_mps));
    plot(targets(2).velocity_mps, targets(2).range_m, 'mx', 'MarkerSize', 10, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Samochód (%.1f m, %+.1f m/s)', targets(2).range_m, targets(2).velocity_mps));
    if ~isempty(targets_found)
        det_v = axis_velocity(targets_found(:, 2));
        det_r = axis_range(targets_found(:, 1));
        plot(det_v, det_r, 'ko', 'MarkerSize', 12, 'LineWidth', 2.0, ...
            'DisplayName', 'Wykrycia CLEAN');
    end
    hold off;
    legend('Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
    c4 = colorbar;
    c4.Label.String = 'Moc znormalizowana [dB]';
    c4.Label.FontSize = 10;
    c4.Label.Interpreter = 'none';
    title('d) Po DSP — Zbliżenie na strefę celów (2D)', ...
        'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
    ylabel('Odległość bistatyczna [m]', 'FontSize', 10.5, 'Interpreter', 'none');
    set(gca, 'FontSize', 10, 'LineWidth', 1.0);
    grid on; set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

    sgtitle(sprintf('Mapa periodogramu Range-Doppler przed i po filtracji DSP (802.11ax, %s, %d MHz)', cbw, bw_mhz), ...
        'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

    % 7. Export figure in 300 DPI
    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    out_dir = fullfile(project_root, 'thesis', 'img', 'ch3_impl');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
    out_file = fullfile(out_dir, 'rys_3_2_mapa_range_doppler.png');

    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('\n  Figure saved successfully to: %s\n', out_file);
    close(fig);
    fprintf('=================================================================\n');
end
