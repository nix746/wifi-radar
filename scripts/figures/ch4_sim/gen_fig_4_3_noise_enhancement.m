function fig = gen_fig_4_3_noise_enhancement(show_figure, save_png)
% GEN_FIG_4_3_NOISE_ENHANCEMENT
% Experiment SIM-3 (E3): Modulation order (MCS) limit and subcarrier-division noise enhancement.
% Figure 4.3 for Chapter 4 of the thesis:
%   Dual Y-axis comparison of the subcarrier-division noise enhancement factor
%   zeta = E[|X|^2]*E[1/|X|^2] [dB] and target detection contrast PNFR [dB]
%   across all available MCS 0-11 (BPSK to 1024-QAM) for IEEE 802.11ax
%   (CBW40, TGax Model-C) with dynamic payload scaling maintaining a constant
%   frame duration (~3.87 ms, M = 280 OFDM symbols).
%
% Output file: thesis/img/ch4_sim/rys_4_3_wzmocnienie_szumu_mcs.png

    if nargin < 1 || isempty(show_figure), show_figure = true; end
    if nargin < 2 || isempty(save_png),    save_png    = true; end

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 4.3: MCS Noise Enhancement & PNFR (Exp. E3)\n');
    fprintf('=================================================================\n');

    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    addpath(project_root);
    init_paths();
    rng(42);

    wifi_standard = '802.11ax';
    cbw           = 'CBW40';
    channel_model = 'Model-C';
    snr_dB        = 25.0;

    targets = struct('type', 'car', 'range_m', 22.5, 'velocity_mps', 18.0);

    mcs_list  = 0:11;
    n_mcs     = numel(mcs_list);
    zeta_dB   = zeros(1, n_mcs);
    pnfr_dB   = zeros(1, n_mcs);
    n_sym_vec = zeros(1, n_mcs);
    psdu_vec  = zeros(1, n_mcs);

    for i = 1:n_mcs
        mcs = mcs_list(i);

        rng(42);
        [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, mcs);
        rng(42);
        [rx_signal, fc]             = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);
        radar_data                  = step3_receiver(rx_signal, waveform, fs, fc, params);
        [targets_det, ~, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc, wifi_standard);

        zeta_dB(i)   = radar_data.zeta_dB;
        pnfr_dB(i)   = pnfr.pnfr_dB(1);
        n_sym_vec(i) = radar_data.n_symbols;
        psdu_vec(i)  = params.psdu_length;

        r_det = targets_det(1).d_hat;
        v_det = targets_det(1).v_hat;

        fprintf('  [MCS %2d] PSDU = %6d B (M = %d) | zeta = %.2f dB | PNFR = %.2f dB | Det: R = %.2f m, v = %+.2f m/s\n', ...
            mcs, psdu_vec(i), n_sym_vec(i), zeta_dB(i), pnfr_dB(i), r_det, v_det);
    end

    fprintf('  Subcarrier-division noise enhancement rise (MCS 0 -> MCS 11): %+.2f dB\n', zeta_dB(end) - zeta_dB(1));
    fprintf('  Target contrast PNFR drop (MCS 0 -> MCS 11): %+.2f dB\n', pnfr_dB(end) - pnfr_dB(1));

    % Dual Y-axis chart with synchronized 1:1 dB grid lines
    fig = figure('Name', 'Figure 4.3 - Modulation Order MCS vs Noise Enhancement and PNFR', ...
        'Color', 'white', 'Position', [100, 100, 860, 560], 'Visible', 'off');

    color_left  = [0.0000, 0.4470, 0.7410];
    color_right = [0.8500, 0.3250, 0.0980];

    yyaxis left;
    p1 = plot(mcs_list, zeta_dB, '-o', ...
        'Color', color_left, 'MarkerFaceColor', color_left, ...
        'LineWidth', 2.0, 'MarkerSize', 7.5, ...
        'DisplayName', sprintf('Współczynnik wzmocnienia szumu %c [dB]', char(950)));
    ylabel(sprintf('Współczynnik wzmocnienia szumu %c [dB]', char(950)), ...
        'FontSize', 11, 'Interpreter', 'none');
    ylim([-0.4, 7.4]);
    yticks(0:1:7);
    ax = gca;
    ax.YColor = color_left;

    yyaxis right;
    p2 = plot(mcs_list, pnfr_dB, '-s', ...
        'Color', color_right, 'MarkerFaceColor', color_right, ...
        'LineWidth', 2.0, 'MarkerSize', 7.5, ...
        'DisplayName', 'Kontrast celu PNFR [dB]');
    ylabel('Kontrast celu PNFR [dB]', 'FontSize', 11, 'Interpreter', 'none');
    y_top = ceil(max(pnfr_dB));
    ylim([y_top - 7.4, y_top + 0.4]);
    yticks((y_top - 7):1:y_top);
    ax.YColor = color_right;

    xlim([-0.6, 11.6]);
    xticks(mcs_list);
    xticklabels(string(mcs_list));
    xtickangle(0);
    xlabel('Indeks schematu modulacji i kodowania (MCS)', 'FontSize', 11, 'Interpreter', 'none');
    title('Wpływ indeksu MCS na wzmocnienie szumu przy dzieleniu podnośnych i kontrast PNFR', ...
        'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');

    leg = legend([p1, p2], 'Location', 'southoutside', 'NumColumns', 2, ...
        'FontSize', 10, 'Interpreter', 'none');
    leg.Box = 'on';

    set(gca, 'FontSize', 10.5, 'LineWidth', 1.0, 'Box', 'on');
    grid on; box on;
    set(gca, 'GridAlpha', 0.25);

    save_thesis_figure(fig, 'ch4_sim', 'rys_4_3_wzmocnienie_szumu_mcs.png', show_figure, save_png);
    if ~show_figure
        fig = [];
    end
    fprintf('=================================================================\n');
end