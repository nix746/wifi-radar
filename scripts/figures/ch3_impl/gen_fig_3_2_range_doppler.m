function fig = gen_fig_3_2_range_doppler(show_figure, save_png)
% GEN_FIG_3_2_RANGE_DOPPLER
% Experiment IMPL-2: Comparison of Raw vs. Processed 2D Range-Doppler
% periodograms for IEEE 802.11ax (CBW80, 80 MHz) in a multipath TGax
% Model-C channel with two moving targets (pedestrian and vehicle).
%
% Layout (2x2):
%   (a) Przed DSP — Wykres 3D (cała mapa jednoznaczna, brak MTI, okno prostokątne)
%   (b) Po DSP    — Wykres 3D (cała mapa jednoznaczna, po MTI, DC i oknie 2D BH)
%   (c) Przed DSP — Zbliżenie 2D na strefę celów (R: 0-85 m, v: +/-25 m/s)
%   (d) Po DSP    — Zbliżenie 2D na strefę celów z detekcją celów
%
% Output file: thesis/img/ch3_impl/rys_3_2_mapa_range_doppler.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

fprintf('=================================================================\n');
fprintf('  Generating Fig. 3.2: Range-Doppler Map Before & After DSP (CBW80)\n');
fprintf('=================================================================\n');

% 1. Initialize project paths
project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
addpath(project_root);
init_paths();

wifi_standard = '802.11ax';
cbw           = 'CBW80';
bw_mhz        = 80;
channel_model = 'Model-C';
snr_dB        = 25; % Realistic Wi-Fi SNR (matching Figs. 3.1 & 3.3, clean STC detection)

% Two moving targets (identical across Chapter 3):
%   Target 1: human (pedestrian) at 22.5 m, -4.0 m/s
%   Target 2: car at 67.5 m, +18.0 m/s
targets = [ ...
    struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
    struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
    ];

% 2. Simulate transmission, multipath channel, receiver DSP, and target interpreter
rng(42);
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, 0);

rng(23); % Deterministic seed where Model-C LOS locks at intrinsic delay (0 m bias)
[rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

radar_data = step3_receiver(rx_signal, waveform, fs, fc, params);
[targets_det, ~, ~, ~, pnfr, diag_info] = step4_interpreter( ...
    radar_data, fs, fc, wifi_standard, 1e-3, 'coherent');

axis_range    = radar_data.axis_range;
axis_velocity = radar_data.axis_velocity;
Nfft          = radar_data.Nfft;
n_symbols     = radar_data.n_symbols;

% 3. Extract Raw 2D periodogram (no MTI, no DC repair, rectangular window)
C_raw     = compute_range_doppler_map(radar_data.H_raw, Nfft, n_symbols, params.active_mask, 4, false);
P_raw_lin = abs(C_raw).^2;
P_raw_dB  = 10 * log10(P_raw_lin / max(P_raw_lin(:)) + 1e-12);

% 4. Extract Processed 2D periodogram (after MTI, DC repair, and 2D Blackman-Harris window)
P_proc_lin = radar_data.Per_F;
P_proc_dB  = 10 * log10(P_proc_lin / max(P_proc_lin(:)) + 1e-12);

% 5. Diagnostic logging
[~, r1_idx] = min(abs(axis_range - targets(1).range_m));
[~, v1_idx] = min(abs(axis_velocity - targets(1).velocity_mps));
[~, r2_idx] = min(abs(axis_range - targets(2).range_m));
[~, v2_idx] = min(abs(axis_velocity - targets(2).velocity_mps));

pnfr_str = 'N/A';
if ~isempty(pnfr.pnfr_dB)
    pnfr_str = sprintf('%.1f dB', pnfr.pnfr_dB(1));
end
fprintf('  [Before DSP] Median = %.2f dB | T1 (human) = %+.2f dB | T2 (car) = %+.2f dB\n', ...
    median(P_raw_dB(:)), P_raw_dB(r1_idx, v1_idx), P_raw_dB(r2_idx, v2_idx));
fprintf('  [After DSP]  Median = %.2f dB | T1 (human) = %+.2f dB | T2 (car) = %+.2f dB | PNFR1 = %s\n', ...
    median(P_proc_dB(:)), P_proc_dB(r1_idx, v1_idx), P_proc_dB(r2_idx, v2_idx), pnfr_str);

% 6. Create 4-panel figure (2x2): Top row 3D, Bottom row 2D Zoom
fig = figure('Name', 'Figure 3.2 - Range-Doppler Map Before and After DSP (CBW80)', ...
    'Color', 'white', 'Position', [60, 60, 1340, 960], 'Visible', 'off');

clim_raw  = [-90, 0];
z_raw     = -90;
clim_proc = [-45, 0];
z_proc    = -45;

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
if ~isempty(targets_det)
    r_neigh = reshape([targets_det.r_idx].' + (-6:6), 1, []);
    v_neigh = reshape([targets_det.d_idx].' + (-3:3), 1, []);
else
    r_neigh = [];
    v_neigh = [];
end
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
set(gca, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
grid on; box on; set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

% --- Panel (d): Po DSP - Zbliżenie 2D na strefę celów z detekcją celów ---
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
if ~isempty(targets_det)
    det_v = [targets_det.v_hat];
    det_r = [targets_det.d_hat];
    plot(det_v, det_r, 'ko', 'MarkerSize', 10, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Wykrycia %s', diag_info.algorithm.name));
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
set(gca, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
grid on; box on; set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

sgtitle(sprintf('Mapa periodogramu Range-Doppler przed i po filtracji DSP (802.11ax, %s, %d MHz)', cbw, bw_mhz), ...
    'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

% 7. Export figure in 300 DPI
save_thesis_figure(fig, 'ch3_impl', 'rys_3_2_mapa_range_doppler.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
