function fig = gen_fig_3_2_range_doppler(show_figure, save_png)
% GEN_FIG_3_2_RANGE_DOPPLER
% Experiment IMPL-2: Comparison of Baseline vs. Conditioned 2D Range-Doppler
% periodograms for IEEE 802.11ax (CBW80, 80 MHz) in a multipath TGax
% Model-C channel with two moving targets (pedestrian and vehicle).
%
% Layout (2x2, unified unnormalized Per_F [dB] scale):
%   (a) Baseline - 3D mesh (full unambiguous map, no static echo removal, rectangular window)
%   (b) Conditioned - 3D mesh (slow-time mean subtraction + DC interpolation + 2D Blackman-Harris)
%   (c) Baseline - 2D zoom on target zone (R: 0-30 m, v: +/-25 m/s)
%   (d) Conditioned - 2D zoom on target zone with Coherent STC detections
%
% Output file: thesis/img/ch3_impl/rys_3_2_mapa_range_doppler.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

fprintf('=================================================================\n');
fprintf('  Generating Fig. 3.2: Range-Doppler Map (Baseline vs Conditioned, CBW80)\n');
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
[targets_det, ~, ~, ~, ~, diag_info] = step4_interpreter( ...
    radar_data, fs, fc, 1e-3, 'coherent', [], false);

axis_range    = radar_data.axis_range;
axis_velocity = radar_data.axis_velocity;
Nfft          = radar_data.Nfft;
n_symbols     = radar_data.n_symbols;

% 2. Real unnormalized Per_F [dB]: baseline (rect, with DPI) vs conditioned (MTI + DC + 2D BH)
[~, ~, ~, ~, P_raw_lin] = compute_range_doppler_map( ...
    radar_data.H_raw, Nfft, n_symbols, params.active_mask, 4, false);
P_raw_dB  = 10 * log10(P_raw_lin + 1e-12);
P_proc_dB = 10 * log10(radar_data.Per_F + 1e-12);

fprintf('  [Baseline]    Per_F [median, max] = [%.1f, %+.1f] dB\n', median(P_raw_dB(:)), max(P_raw_dB(:)));
fprintf('  [Conditioned] Per_F [median, max] = [%.1f, %+.1f] dB\n', median(P_proc_dB(:)), max(P_proc_dB(:)));

% 3. 2x2 figure with unified real Per_F [dB] scale across all panels
fig = figure('Name', 'Figure 3.2 - Range-Doppler Map: Baseline vs Conditioned (CBW80)', ...
    'Color', 'white', 'Position', [60, 60, 1340, 960], 'Visible', 'off');
tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, sprintf('Periodogram Range-Doppler: bazowy oraz po usunięciu echa stałego, interpolacji DC i oknowaniu (802.11ax, %s)', cbw), ...
    'FontSize', 12.5, 'FontWeight', 'bold', 'Interpreter', 'none');

c_lims = [-45, 55];
z_lims = [-45, 55];

step_r = 8;
step_v = 4;
idx_r  = 1:step_r:length(axis_range);
idx_v  = 1:step_v:length(axis_velocity);

% Panel (a): Before DSP - 3D mesh
ax1 = nexttile(tl, 1);
mesh(ax1, axis_velocity(idx_v), axis_range(idx_r), max(P_raw_dB(idx_r, idx_v), z_lims(1)));
colormap(ax1, 'parula');
clim(ax1, c_lims);
view(ax1, -35, 42);
xlim(ax1, [axis_velocity(1), axis_velocity(end)]);
ylim(ax1, [0, axis_range(end)]);
zlim(ax1, z_lims);
title(ax1, 'a) Periodogram bazowy — widok 3D (cała mapa)', ...
    'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax1, 'Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
ylabel(ax1, 'Odległość [m]', 'FontSize', 10, 'Interpreter', 'none');
zlabel(ax1, 'Moc periodogramu [dB]', 'FontSize', 10, 'Interpreter', 'none');
set(ax1, 'FontSize', 9.5, 'LineWidth', 0.9);
grid(ax1, 'on');

% Panel (b): After DSP - 3D mesh (identical uniform grid and real Z scale)
ax2 = nexttile(tl, 2);
mesh(ax2, axis_velocity(idx_v), axis_range(idx_r), max(P_proc_dB(idx_r, idx_v), z_lims(1)));
colormap(ax2, 'parula');
clim(ax2, c_lims);
view(ax2, -35, 42);
xlim(ax2, [axis_velocity(1), axis_velocity(end)]);
ylim(ax2, [0, axis_range(end)]);
zlim(ax2, z_lims);
title(ax2, 'b) Po usunięciu echa stałego, interpolacji DC i oknie 2D — 3D', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax2, 'Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
ylabel(ax2, 'Odległość [m]', 'FontSize', 10, 'Interpreter', 'none');
zlabel(ax2, 'Moc periodogramu [dB]', 'FontSize', 10, 'Interpreter', 'none');
set(ax2, 'FontSize', 9.5, 'LineWidth', 0.9);
grid(ax2, 'on');

zoom_r = [0, 30];
zoom_v = [-25, 25];

% Panel (c): Before DSP - 2D zoom
ax3 = nexttile(tl, 3);
imagesc(ax3, axis_velocity, axis_range, P_raw_dB);
axis(ax3, 'xy');
colormap(ax3, 'parula');
clim(ax3, c_lims);
xlim(ax3, zoom_v);
ylim(ax3, zoom_r);
hold(ax3, 'on');
plot(ax3, targets(1).velocity_mps, targets(1).range_m, 'r+', 'MarkerSize', 11, 'LineWidth', 2.0, ...
    'DisplayName', sprintf('Pieszy (%.1f m, %+.1f m/s)', targets(1).range_m, targets(1).velocity_mps));
plot(ax3, targets(2).velocity_mps, targets(2).range_m, 'mx', 'MarkerSize', 11, 'LineWidth', 2.0, ...
    'DisplayName', sprintf('Samochód (%.1f m, %+.1f m/s)', targets(2).range_m, targets(2).velocity_mps));
hold(ax3, 'off');
legend(ax3, 'Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
title(ax3, 'c) Periodogram bazowy — zbliżenie na strefę celów (2D)', ...
    'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax3, 'Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
ylabel(ax3, 'Odległość [m]', 'FontSize', 10.5, 'Interpreter', 'none');
set(ax3, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
grid(ax3, 'on');
set(ax3, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

% Panel (d): After DSP - 2D zoom with target detections
ax4 = nexttile(tl, 4);
imagesc(ax4, axis_velocity, axis_range, P_proc_dB);
axis(ax4, 'xy');
colormap(ax4, 'parula');
clim(ax4, c_lims);
xlim(ax4, zoom_v);
ylim(ax4, zoom_r);
hold(ax4, 'on');
plot(ax4, targets(1).velocity_mps, targets(1).range_m, 'r+', 'MarkerSize', 10, 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Pieszy (%.1f m, %+.1f m/s)', targets(1).range_m, targets(1).velocity_mps));
plot(ax4, targets(2).velocity_mps, targets(2).range_m, 'mx', 'MarkerSize', 10, 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Samochód (%.1f m, %+.1f m/s)', targets(2).range_m, targets(2).velocity_mps));
if ~isempty(targets_det)
    plot(ax4, [targets_det.v_hat], [targets_det.d_hat], 'ko', 'MarkerSize', 10, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Wykrycia %s', diag_info.algorithm.name));
end
hold(ax4, 'off');
legend(ax4, 'Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none');
title(ax4, 'd) Po usunięciu echa stałego, interpolacji DC i oknie 2D — 2D', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax4, 'Prędkość radialna [m/s]', 'FontSize', 10.5, 'Interpreter', 'none');
ylabel(ax4, 'Odległość [m]', 'FontSize', 10.5, 'Interpreter', 'none');
set(ax4, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
grid(ax4, 'on');
set(ax4, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

cb = colorbar(ax4);
cb.Layout.Tile = 'east';
cb.Label.String = 'Moc periodogramu [dB]';
cb.Label.FontSize = 10.5;
cb.Label.Interpreter = 'none';

save_thesis_figure(fig, 'ch3_impl', 'rys_3_2_mapa_range_doppler.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
