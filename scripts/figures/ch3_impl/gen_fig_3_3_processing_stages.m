function fig = gen_fig_3_3_processing_stages(show_figure, save_png)
% GEN_FIG_3_3_PROCESSING_STAGES
% Experiment IMPL-3: Step-by-step decomposition of the receiver and
% interpreter processing pipeline on the 2D Range-Doppler map for IEEE 802.11ax
% (CBW80, 80 MHz) in a multipath TGax Model-C channel with two moving targets.
%
% Layout (2x2, uniform zoom R in [0, 30] m, v in [-25, +25] m/s, unified Per_F [dB]):
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

targets = [ ...
    struct('range_m', 7.5,  'velocity_mps', -4.0,  'type', 'human'), ...
    struct('range_m', 18.0, 'velocity_mps', +14.0, 'type', 'car') ...
    ];

% 1. Run transmitter, TGax channel, receiver, and Coherent STC interpreter
rng(42);
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, 0);

rng(23); % Deterministic seed for reproducible TGax Model-C channel realization
[rx_signal, fc, intrinsic_delay] = step2_channel(waveform, fs, channel_model, cfg, targets);

radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, [], [], intrinsic_delay);
[targets_det, ~, Per_after, ~, ~, diag_info] = step4_interpreter( ...
    radar_data, fs, fc, 1e-3, 'coherent', [], false);
det_name = diag_info.algorithm.name;

Nfft          = radar_data.Nfft;
n_symbols     = radar_data.n_symbols;
axis_range    = radar_data.axis_range;
axis_velocity = radar_data.axis_velocity;

% 2. Real unnormalized Per_F [dB] for all four stages via lib/compute_range_doppler_map
[~, ~, ~, ~, P_stage0_lin] = compute_range_doppler_map( ...
    radar_data.H_raw, Nfft, n_symbols, params.active_mask, 4, false);
[~, ~, ~, ~, P_stage1_lin] = compute_range_doppler_map( ...
    radar_data.H_no_static, Nfft, n_symbols, params.active_mask, 4, false);

P_stage0_dB = 10 * log10(P_stage0_lin + 1e-12);
P_stage1_dB = 10 * log10(P_stage1_lin + 1e-12);
P_stage2_dB = 10 * log10(radar_data.Per_F + 1e-12);
P_stage3_dB = 10 * log10(Per_after + 1e-12);

fprintf('  Stage 0 (Baseline):             Per_F [median, max] = [%6.1f, %+6.1f] dB\n', median(P_stage0_dB(:)), max(P_stage0_dB(:)));
fprintf('  Stage 1 (Mean subtraction):     Per_F [median, max] = [%6.1f, %+6.1f] dB\n', median(P_stage1_dB(:)), max(P_stage1_dB(:)));
fprintf('  Stage 2 (Mean sub + DC + BH):   Per_F [median, max] = [%6.1f, %+6.1f] dB\n', median(P_stage2_dB(:)), max(P_stage2_dB(:)));
fprintf('  Stage 3 (Post-%s):    Per_F [median, max] = [%6.1f, %+6.1f] dB\n', det_name, median(P_stage3_dB(:)), max(P_stage3_dB(:)));

% 3. 2x2 figure with shared real Per_F [dB] colorbar
fig = figure('Name', 'Figure 3.3 - Receiver and Interpreter Processing Stages (CBW80)', ...
    'Color', 'white', 'Position', [60, 60, 1340, 960], 'Visible', 'off');
tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, 'Etapy przetwarzania sygnału w odbiorniku i interpreterze (802.11ax, CBW80, 80 MHz)', ...
    'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

c_lims = [-45, 55];
zoom_r = [0, 30];
zoom_v = [-25, 25];

stages_dB = {P_stage0_dB, P_stage1_dB, P_stage2_dB, P_stage3_dB};
panel_titles = { ...
    'a) Krok 0: Periodogram bazowy (z echem stałym, okno prostokątne)', ...
    'b) Krok 1: Po odjęciu średniej czasowej (okno prostokątne, luka DC)', ...
    'c) Krok 2: Po interpolacji podnośnych DC i oknie 2D Blackmana-Harrisa', ...
    sprintf('d) Krok 3: Periodogram rezydualny po ekstrakcji (%s)', det_name) ...
    };

for p = 1:4
    ax = nexttile(tl, p);
    imagesc(ax, axis_velocity, axis_range, stages_dB{p});
    axis(ax, 'xy');
    colormap(ax, 'parula');
    clim(ax, c_lims);
    xlim(ax, zoom_v);
    ylim(ax, zoom_r);
    hold(ax, 'on');
    plot(ax, targets(1).velocity_mps, targets(1).range_m, 'r+', 'MarkerSize', 10, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Pieszy (%.1f m, %+.1f m/s)', targets(1).range_m, targets(1).velocity_mps));
    plot(ax, targets(2).velocity_mps, targets(2).range_m, 'mx', 'MarkerSize', 10, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Samochód (%.1f m, %+.1f m/s)', targets(2).range_m, targets(2).velocity_mps));

    if p == 3 && ~isempty(targets_det)
        plot(ax, [targets_det.v_hat], [targets_det.d_hat], 'ko', 'MarkerSize', 10, 'LineWidth', 1.8, ...
            'DisplayName', sprintf('Wykrycia %s', det_name));
    end
    hold(ax, 'off');

    legend(ax, 'Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
    title(ax, panel_titles{p}, 'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel(ax, 'Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
    ylabel(ax, 'Odległość [m]', 'FontSize', 10.5, 'Interpreter', 'none');
    set(ax, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
    grid(ax, 'on');
    set(ax, 'GridColor', [1 1 1], 'GridAlpha', 0.25);
end

cb = colorbar(ax);
cb.Layout.Tile = 'east';
cb.Label.String = 'Moc periodogramu [dB]';
cb.Label.FontSize = 10.5;
cb.Label.Interpreter = 'none';

save_thesis_figure(fig, 'ch3_impl', 'rys_3_3_etapy_przetwarzania.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
