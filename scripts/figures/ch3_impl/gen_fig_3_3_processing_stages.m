function fig = gen_fig_3_3_processing_stages(show_figure, save_png)
% GEN_FIG_3_3_PROCESSING_STAGES
% Experiment IMPL-3: Step-by-step decomposition of the receiver and
% interpreter processing pipeline on the 2D Range-Doppler map for IEEE 802.11ax
% (CBW80, 80 MHz) in a multipath TGax Model-C channel with two moving targets.
%
% Layout (2x2, uniform zoom R in [0, 85] m, v in [-25, +25] m/s):
%   (a) Stage 0: Baseline periodogram (with static echoes, rectangular window)
%   (b) Stage 1: After slow-time mean subtraction (rectangular window, DC gap)
%   (c) Stage 2: After DC interpolation and 2D Blackman-Harris windowing (with detections)
%   (d) Stage 3: Residual periodogram after Coherent STC target extraction
%
% Output file: thesis/img/ch3_impl/rys_3_3_etapy_przetwarzania.png

    if nargin < 1 || isempty(show_figure), show_figure = true; end
    if nargin < 2 || isempty(save_png),    save_png    = true; end

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 3.3: Receiver & Interpreter Stages (CBW80)\n');
    fprintf('=================================================================\n');

    project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    addpath(project_root);
    init_paths();

    wifi_standard = '802.11ax';
    cbw           = 'CBW80';
    channel_model = 'Model-C';
    snr_dB        = 25;

    targets = [ ...
        struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
        struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
        ];

    % 1. Run transmitter, TGax channel, receiver, and Coherent STC interpreter
    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, 0);

    rng(23); % Deterministic seed where Model-C LOS locks at intrinsic delay (0 m bias)
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

    radar_data = step3_receiver(rx_signal, waveform, fs, fc, params);
    [targets_det, ~, Per_after, ~, ~, diag_info] = step4_interpreter( ...
        radar_data, fs, fc, wifi_standard, 1e-3, 'coherent');
    det_name = diag_info.algorithm.name;

    Nfft          = radar_data.Nfft;
    n_symbols     = radar_data.n_symbols;
    axis_range    = radar_data.axis_range;
    axis_velocity = radar_data.axis_velocity;

    % 2. Compute intermediate periodograms via lib/compute_range_doppler_map
    C_stage0 = compute_range_doppler_map(radar_data.H_raw, Nfft, n_symbols, params.active_mask, 4, false);
    P_stage0_lin = abs(C_stage0).^2;
    P_stage0_dB  = 10 * log10(P_stage0_lin / max(P_stage0_lin(:)) + 1e-12);

    C_stage1 = compute_range_doppler_map(radar_data.H_no_static, Nfft, n_symbols, params.active_mask, 4, false);
    P_stage1_lin = abs(C_stage1).^2;
    P_stage1_dB  = 10 * log10(P_stage1_lin / max(P_stage1_lin(:)) + 1e-12);

    P_stage2_lin = radar_data.Per_F;
    P_stage2_max = max(P_stage2_lin(:));
    P_stage2_dB  = 10 * log10(P_stage2_lin / P_stage2_max + 1e-12);

    P_stage3_lin = Per_after;
    P_stage3_dB  = 10 * log10(P_stage3_lin / P_stage2_max + 1e-12);

    % 3. Diagnostic summary
    [~, r1_idx] = min(abs(axis_range - targets(1).range_m));
    [~, v1_idx] = min(abs(axis_velocity - targets(1).velocity_mps));
    [~, r2_idx] = min(abs(axis_range - targets(2).range_m));
    [~, v2_idx] = min(abs(axis_velocity - targets(2).velocity_mps));

    fprintf('\n  --- Stage-by-Stage Target Contrast & Background Summary ---\n');
    fprintf('  Stage 0 (Baseline):             Median = %6.2f dB | T1 (human) = %+6.2f dB | T2 (car) = %+6.2f dB\n', ...
        median(P_stage0_dB(:)), P_stage0_dB(r1_idx, v1_idx), P_stage0_dB(r2_idx, v2_idx));
    fprintf('  Stage 1 (Mean subtraction):     Median = %6.2f dB | T1 (human) = %+6.2f dB | T2 (car) = %+6.2f dB\n', ...
        median(P_stage1_dB(:)), P_stage1_dB(r1_idx, v1_idx), P_stage1_dB(r2_idx, v2_idx));
    fprintf('  Stage 2 (Mean sub + DC + BH):   Median = %6.2f dB | T1 (human) = %+6.2f dB | T2 (car) = %+6.2f dB\n', ...
        median(P_stage2_dB(:)), P_stage2_dB(r1_idx, v1_idx), P_stage2_dB(r2_idx, v2_idx));
    fprintf('  Stage 3 (Post-%s):    Median = %6.2f dB | Max residual = %+6.2f dB (rel. to Stage 2 peak)\n', ...
        det_name, median(P_stage3_dB(:)), max(P_stage3_dB(:)));

    % 4. 2x2 figure
    fig = figure('Name', 'Figure 3.3 - Receiver and Interpreter Processing Stages (CBW80)', ...
        'Color', 'white', 'Position', [60, 60, 1340, 960], 'Visible', 'off');

    clim_list = {[-80, 0], [-45, 0], [-45, 0], [-45, 0]};
    zoom_r  = [0, 85];
    zoom_v  = [-25, 25];

    stages_dB = {P_stage0_dB, P_stage1_dB, P_stage2_dB, P_stage3_dB};
    panel_titles = { ...
        'a) Krok 0: Periodogram bazowy (z echem stałym, okno prostokątne)', ...
        'b) Krok 1: Po odjęciu średniej czasowej (okno prostokątne, luka DC)', ...
        'c) Krok 2: Po interpolacji podnośnych DC i oknie 2D Blackmana-Harrisa', ...
        sprintf('d) Krok 3: Periodogram rezydualny po ekstrakcji (%s)', det_name) ...
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

        if p == 3 && ~isempty(targets_det)
            det_v = [targets_det.v_hat];
            det_r = [targets_det.d_hat];
            plot(det_v, det_r, 'ko', 'MarkerSize', 10, 'LineWidth', 1.8, ...
                'DisplayName', sprintf('Wykrycia %s', det_name));
        end
        hold off;

        legend('Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
        cb = colorbar;
        cb.Label.String = 'Moc znormalizowana [dB]';
        cb.Label.FontSize = 10;
        cb.Label.Interpreter = 'none';

        title(panel_titles{p}, 'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel('Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
        ylabel('Odległość bistatyczna [m]', 'FontSize', 10.5, 'Interpreter', 'none');
        set(gca, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
        grid on; box on;
        set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);
    end

    sgtitle('Etapy przetwarzania sygnału w odbiorniku i interpreterze (802.11ax, CBW80, 80 MHz)', ...
        'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

    save_thesis_figure(fig, 'ch3_impl', 'rys_3_3_etapy_przetwarzania.png', show_figure, save_png);
    if ~show_figure
        fig = [];
    end
    fprintf('=================================================================\n');
end
