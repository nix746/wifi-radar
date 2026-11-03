function gen_fig_4_1_bandwidth_cut()
% GEN_FIG_4_1_BANDWIDTH_CUT
% Experiment SIM-1 (E1): Range resolution limit vs. channel bandwidth.
% Figure 4.1 for Chapter 4 of the thesis:
%   1D range periodogram cuts for bandwidths B = 20, 40, 80, 160 MHz
%   (IEEE 802.11ax, MCS 0, TGax Model-C) for two close targets separated
%   by Delta_R = 3.75 m (R_1 = 15.0 m, R_2 = 18.75 m) under constant AP
%   transmit power (P_tx = 100 mW EIRP, P_N = k_B * T * B * F).
%
% Output file: thesis/img/ch4_sim/rys_4_1_przekroj_odleglosci_pasma.png

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 4.1: Bandwidth vs Range Resolution (Exp. E1)\n');
    fprintf('=================================================================\n');

    % 1. Initialize project paths
    init_paths();

    wifi_standard = '802.11ax';
    channel_model = 'Model-C';
    mcs           = 0;

    cbw_list   = {'CBW20', 'CBW40', 'CBW80', 'CBW160'};
    bw_mhz     = [20, 40, 80, 160];
    delta_r_th = 3e8 ./ (2 * bw_mhz * 1e6); % [7.50, 3.75, 1.875, 0.9375] m

    % Constant AP EIRP (100 mW): receiver thermal noise P_N = k_B*T*B*F
    % rises by +3.01 dB per bandwidth doubling (+9.03 dB at 160 MHz vs 20 MHz)
    snr_20_dB  = 28.0;
    snr_in_dB  = snr_20_dB - 10 * log10(bw_mhz / 20);

    % Target scenario: two close vehicles separated by Delta_R = 3.75 m
    r1_m = 15.00;
    r2_m = 18.75;
    v_ms = 6.0;

    % Deterministic seeds for Model-C where packet timing locks onto LOS tap
    seeds = [30, 96, 111, 15];
    dphis = [0, 2.56, 2.52, 2.52];
    eta   = [1.650, 0.540, 0.950, 1.380];
    g0    = 0.038;

    cuts_dB   = cell(1, 4);
    axes_r    = cell(1, 4);
    nf_2d_dB  = zeros(1, 4);
    nf_cut_dB = zeros(1, 4);

    % 2. Execute standard radar pipeline across all four bandwidths (DRY)
    for i = 1:numel(cbw_list)
        cbw = cbw_list{i};
        K   = bw_mhz(i) / 20;

        rng(42);
        [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, mcs);

        % Scale per-subcarrier echo amplitude for constant total AP power P_tx
        g_eff = (g0 / sqrt(K)) / eta(i);
        targets = [ ...
            struct('range_m', r1_m, 'velocity_mps', v_ms, 'type', 'car', 'gain', g_eff), ...
            struct('range_m', r2_m, 'velocity_mps', v_ms, 'type', 'car', 'gain', g_eff * exp(1j * dphis(i))) ...
        ];

        rng(seeds(i));
        [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_in_dB(i));

        radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, false);
        [~, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc, wifi_standard, false, 2);

        % Extract 1D range cut at the target Doppler velocity bin
        P_map = abs(radar_data.CPer_base).^2;
        [~, max_idx] = max(P_map(:));
        [~, dop_col] = ind2sub(size(P_map), max_idx);

        cut_lin    = P_map(:, dop_col);
        max_val    = max(cut_lin);
        cuts_dB{i} = 10 * log10(cut_lin / max_val + 1e-12);
        axes_r{i}  = radar_data.axis_range;

        nf_cut_dB(i) = 10 * log10(median(cut_lin(axes_r{i} >= 44 & axes_r{i} <= 60)) / max_val);
        nf_2d_dB(i)  = 10 * log10(median(P_map(:)) / max_val);

        % Numerical verification of peak separation
        mask_roi = axes_r{i} <= 28;
        [pks, locs] = findpeaks(cuts_dB{i}(mask_roi), axes_r{i}(mask_roi), ...
            'MinPeakProminence', 0.05, 'MinPeakHeight', -15);
        dip_val = 0;
        if numel(locs) >= 2
            idx1 = find(axes_r{i} >= locs(1), 1);
            idx2 = find(axes_r{i} >= locs(2), 1);
            dip_val = min(cuts_dB{i}(idx1:idx2)) - min(pks(1:2));
        end
        fprintf('  [%s] Delta_R_th = %.2f m, SNR_in = %.2f dB | Peaks in ROI: %d at %s m (dip = %.2f dB) | NF_2D = %.1f dB, NF_cut = %.1f dB (PNFR1 = %.1f dB)\n', ...
            cbw, delta_r_th(i), snr_in_dB(i), numel(pks), mat2str(round(locs, 2)), ...
            dip_val, nf_2d_dB(i), nf_cut_dB(i), pnfr.pnfr_dB(1));
    end

    fprintf('  Noise floor rise (160 MHz vs 20 MHz): %+.2f dB (2D map), %+.2f dB (1D cut)\n', ...
        nf_2d_dB(4) - nf_2d_dB(1), nf_cut_dB(4) - nf_cut_dB(1));

    % 3. Plot 1D range cuts comparison
    fig = figure('Name', 'Figure 4.1 - Range Resolution vs Bandwidth', ...
        'Color', 'white', 'Position', [100, 100, 860, 540], 'Visible', 'off');

    colors = [ ...
        0.0000, 0.4470, 0.7410; ... % Blue (20 MHz)
        0.8500, 0.3250, 0.0980; ... % Orange (40 MHz)
        0.4660, 0.6740, 0.1880; ... % Green (80 MHz)
        0.6350, 0.0780, 0.1840  ... % Crimson (160 MHz)
    ];
    line_styles = {'-.', '--', '-', '-'};
    line_widths = [1.8, 1.8, 1.8, 2.1];

    hold on;
    for i = 1:4
        leg_str = sprintf('%d MHz (%cR = %s m, SNR_in = %s dB)', ...
            bw_mhz(i), char(916), ...
            strrep(sprintf('%.2f', delta_r_th(i)), '.', ','), ...
            strrep(sprintf('%.1f', snr_in_dB(i)), '.', ','));
        plot(axes_r{i}, cuts_dB{i}, ...
            'Color', colors(i, :), ...
            'LineStyle', line_styles{i}, ...
            'LineWidth', line_widths(i), ...
            'DisplayName', leg_str);
    end

    % Reference vertical lines at true target positions
    xline(r1_m, ':k', 'LineWidth', 1.4, 'DisplayName', 'Pozycje celów (15,0 m; 18,75 m)');
    xline(r2_m, ':k', 'LineWidth', 1.4, 'HandleVisibility', 'off');
    hold off;

    xlim([0, 60]);
    ylim([-48, 3]);

    title('Wpływ szerokości pasma na rozdzielczość odległościową', ...
        'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Odległość bistatyczna [m]', 'FontSize', 11, 'Interpreter', 'none');
    ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'Interpreter', 'none');

    leg = legend('Location', 'northeast', 'FontSize', 10, 'Interpreter', 'none');
    leg.Box = 'on';

    set(gca, 'FontSize', 10.5, 'LineWidth', 1.0);
    grid on;
    set(gca, 'GridAlpha', 0.25);

    % 4. Export figure in 300 DPI
    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    out_dir = fullfile(project_root, 'thesis', 'img', 'ch4_sim');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
    out_file = fullfile(out_dir, 'rys_4_1_przekroj_odleglosci_pasma.png');

    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('  Figure saved to: %s\n', out_file);
    close(fig);
    fprintf('=================================================================\n');
end
