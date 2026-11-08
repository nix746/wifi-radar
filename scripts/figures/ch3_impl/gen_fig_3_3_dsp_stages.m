function gen_fig_3_3_dsp_stages()
% GEN_FIG_3_3_DSP_STAGES
% Experiment IMPL-3: Step-by-step decomposition of the receiver and
% interpreter DSP pipeline on the 2D Range-Doppler map for IEEE 802.11ax
% (CBW80, 80 MHz) in a multipath TGax Model-C channel with two moving targets.
%
% Layout (2x2, uniform zoom R in [0, 85] m, v in [-25, +25] m/s):
%   (a) Krok 0: Surowy periodogram (brak MTI, okno prostokątne)
%   (b) Krok 1: Po filtracji MTI (okno prostokątne, brak łaty DC)
%   (c) Krok 2: Po interpolacji DC i oknie 2D Blackmana-Harrisa
%   (d) Krok 3: Po ekstrakcji celów algorytmem Coherent CLEAN
%
% Output file: thesis/img/ch3_impl/rys_3_3_etapy_przetwarzania_dsp.png

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 3.3: DSP Pipeline Stages Decomposition (CBW80)\n');
    fprintf('=================================================================\n');

    % 1. Initialize project paths
    init_paths();

    wifi_standard = '802.11ax';
    cbw           = 'CBW80';
    channel_model = 'Model-C';
    snr_dB        = 45; % High SNR regime (matching Figs. 3.1 & 3.2)

    % Two moving targets (identical to Figs. 3.1 and 3.2):
    %   Target 1: human (pedestrian) at 22.5 m, -4.0 m/s
    %   Target 2: car at 67.5 m, +18.0 m/s
    targets = [ ...
        struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
        struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
    ];

    % 2. Run transmitter, multipath channel, receiver, and CLEAN interpreter
    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, 0);

    rng(23); % Deterministic seed where Model-C LOS locks at intrinsic delay (0 m bias)
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

    radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, false);
    [targets_found, CPer_clean, ~, ~] = step4_interpreter( ...
        radar_data, fs, fc, wifi_standard, false, 2);

    Nfft          = radar_data.Nfft;
    n_symbols     = radar_data.n_symbols;
    axis_range    = radar_data.axis_range;
    axis_velocity = radar_data.axis_velocity;

    % 3. Extract intermediate periodograms using lib/compute_range_doppler_map (DRY)
    % Stage 0: Raw (no MTI, no DC interpolation, rectangular window)
    C_stage0 = compute_range_doppler_map(radar_data.H_raw, Nfft, n_symbols, params.active_mask, 4, false);
    P_stage0_lin = abs(C_stage0).^2;
    P_stage0_dB  = 10 * log10(P_stage0_lin / max(P_stage0_lin(:)) + 1e-12);

    % Stage 1: After slow-time MTI only (rectangular window, before DC repair)
    C_stage1 = compute_range_doppler_map(radar_data.H_mti, Nfft, n_symbols, params.active_mask, 4, false);
    P_stage1_lin = abs(C_stage1).^2;
    P_stage1_dB  = 10 * log10(P_stage1_lin / max(P_stage1_lin(:)) + 1e-12);

    % Stage 2: Full receiver DSP (MTI + DC linear interpolation + 2D Blackman-Harris window)
    C_stage2 = radar_data.CPer_base;
    P_stage2_lin = abs(C_stage2).^2;
    P_stage2_max = max(P_stage2_lin(:));
    P_stage2_dB  = 10 * log10(P_stage2_lin / P_stage2_max + 1e-12);

    % Stage 3: After Coherent CLEAN target extraction (normalized to Stage 2 peak)
    P_stage3_lin = abs(CPer_clean).^2;
    P_stage3_dB  = 10 * log10(P_stage3_lin / P_stage2_max + 1e-12);

    % 4. Diagnostic logging of stage-by-stage improvement
    [~, r1_idx] = min(abs(axis_range - targets(1).range_m));
    [~, v1_idx] = min(abs(axis_velocity - targets(1).velocity_mps));
    [~, r2_idx] = min(abs(axis_range - targets(2).range_m));
    [~, v2_idx] = min(abs(axis_velocity - targets(2).velocity_mps));

    fprintf('\n  --- Stage-by-Stage Target Contrast & Background Summary ---\n');
    fprintf('  Stage 0 (Raw):            Median = %6.2f dB | T1 (human) = %+6.2f dB | T2 (car) = %+6.2f dB\n', ...
        median(P_stage0_dB(:)), P_stage0_dB(r1_idx, v1_idx), P_stage0_dB(r2_idx, v2_idx));
    fprintf('  Stage 1 (MTI only):       Median = %6.2f dB | T1 (human) = %+6.2f dB | T2 (car) = %+6.2f dB\n', ...
        median(P_stage1_dB(:)), P_stage1_dB(r1_idx, v1_idx), P_stage1_dB(r2_idx, v2_idx));
    fprintf('  Stage 2 (MTI + DC + BH):  Median = %6.2f dB | T1 (human) = %+6.2f dB | T2 (car) = %+6.2f dB\n', ...
        median(P_stage2_dB(:)), P_stage2_dB(r1_idx, v1_idx), P_stage2_dB(r2_idx, v2_idx));
    fprintf('  Stage 3 (Post-CLEAN):     Median = %6.2f dB | Max residual = %+6.2f dB (rel. to Stage 2 peak)\n', ...
        median(P_stage3_dB(:)), max(P_stage3_dB(:)));

    % 5. Create 4-panel figure (2x2)
    fig = figure('Name', 'Figure 3.3 - DSP Pipeline Stages Decomposition (CBW80)', ...
        'Color', 'white', 'Position', [60, 60, 1340, 960], 'Visible', 'off');

    clim_list = {[-80, 0], [-55, 0], [-55, 0], [-55, 0]};
    zoom_r  = [0, 85];
    zoom_v  = [-25, 25];

    stages_dB = {P_stage0_dB, P_stage1_dB, P_stage2_dB, P_stage3_dB};
    panel_titles = { ...
        'a) Krok 0: Surowy periodogram (brak MTI, okno prostokątne)', ...
        'b) Krok 1: Po filtracji MTI (okno prostokątne, brak łaty DC)', ...
        'c) Krok 2: Po interpolacji DC i oknie 2D Blackmana-Harrisa', ...
        'd) Krok 3: Po ekstrakcji celów algorytmem Coherent CLEAN' ...
    };

    for p = 1:4
        subplot(2, 2, p);
        imagesc(axis_velocity, axis_range, stages_dB{p});
        axis xy;
        colormap(gca, 'parula');
        clim(clim_list{p});
        xlim(zoom_v);
        ylim(zoom_r);
        hold on;
        plot(targets(1).velocity_mps, targets(1).range_m, 'r+', 'MarkerSize', 10, 'LineWidth', 1.8, ...
            'DisplayName', sprintf('Pieszy (%.1f m, %+.1f m/s)', targets(1).range_m, targets(1).velocity_mps));
        plot(targets(2).velocity_mps, targets(2).range_m, 'mx', 'MarkerSize', 10, 'LineWidth', 1.8, ...
            'DisplayName', sprintf('Samochód (%.1f m, %+.1f m/s)', targets(2).range_m, targets(2).velocity_mps));

        if p >= 3 && ~isempty(targets_found)
            det_v = axis_velocity(targets_found(:, 2));
            det_r = axis_range(targets_found(:, 1));
            plot(det_v, det_r, 'ko', 'MarkerSize', 12, 'LineWidth', 2.0, ...
                'DisplayName', 'Wykrycia CLEAN');
        end
        hold off;

        legend('Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
        cb = colorbar;
        cb.Label.String = 'Moc znormalizowana [dB]';
        cb.Label.FontSize = 10;
        cb.Label.Interpreter = 'none';

        title(panel_titles{p}, 'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel('Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
        ylabel('Odległość bistatyczna [m]', 'FontSize', 10.5, 'Interpreter', 'none');
        set(gca, 'FontSize', 10, 'LineWidth', 1.0);
        grid on;
        set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);
    end

    sgtitle('Dekompozycja etapów przetwarzania DSP w odbiorniku i interpreterze (802.11ax, CBW80, 80 MHz)', ...
        'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

    % 6. Export figure in 300 DPI
    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    out_dir = fullfile(project_root, 'thesis', 'img', 'ch3_impl');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
    out_file = fullfile(out_dir, 'rys_3_3_etapy_przetwarzania_dsp.png');

    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('\n  Figure saved successfully to: %s\n', out_file);
    close(fig);
    fprintf('=================================================================\n');
end
