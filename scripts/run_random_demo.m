function results = run_random_demo(num_targets, seed, show_figures)
% RUN_RANDOM_DEMO Interactive showcase generating random moving targets and comparing
% Binary STC and Coherent STC detection on the 2D Range-Doppler periodogram.
%
% Usage:
%   run_random_demo()            % 3 random targets, fresh random seed, display plots
%   run_random_demo(4)           % 4 random targets
%   run_random_demo(3, 42)       % Reproducible run with seed 42
%   run_random_demo(3, 42, true) % Control figure window display explicitly
%
% Inputs:
%   num_targets  - (Optional) Number of random targets in 1..6 (default: 3)
%   seed         - (Optional) RNG seed; [] shuffles for a fresh scenario (default: [])
%   show_figures - (Optional) Display Binary STC & Coherent STC windows (default: true)
%
% Output:
%   results      - Struct with seed, ground truth targets, detections, thresholds, PNFR, and figures

if nargin < 1 || isempty(num_targets)
    num_targets = 3;
end
if nargin < 2
    seed = [];
end
if nargin < 3 || isempty(show_figures)
    show_figures = true;
end

if ~isnumeric(num_targets) || ~isscalar(num_targets) || num_targets < 1 || num_targets > 6 || mod(num_targets, 1) ~= 0
    error('num_targets must be an integer between 1 and 6.');
end

project_root = fullfile(fileparts(mfilename('fullpath')), '..');
addpath(project_root);
init_paths();

if isempty(seed)
    rng('shuffle');
    sc = rng;
    used_seed = sc.Seed;
else
    rng(seed, 'twister');
    used_seed = seed;
end

wifi_standard = '802.11ax';
cbw           = 'CBW40';
mcs           = 5;
channel_model = 'Model-C';
p_FA          = 1e-3;

targets_true = generate_random_targets(num_targets);

fprintf('=================================================================\n');
fprintf('  Wi-Fi Passive Radar - Random Targets Detection Demo\n');
fprintf('  Standard: %s | %s | %s | Seed = %u\n', ...
    wifi_standard, cbw, channel_model, used_seed);
fprintf('=================================================================\n\n');

[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, mcs);
[rx_signal, fc, intrinsic_delay] = step2_channel(waveform, fs, channel_model, cfg, targets_true);
radar_data                       = step3_receiver(rx_signal, waveform, fs, fc, params, [], [], intrinsic_delay);

alg_bin = get_detection_algorithm('binary');
alg_coh = get_detection_algorithm('coherent');

[targets_bin, ~, Per_after_bin, eta_bin, pnfr_bin, diag_bin] = step4_interpreter( ...
    radar_data, fs, fc, p_FA, alg_bin);
[targets_coh, ~, Per_after_coh, eta_coh, pnfr_coh, diag_coh] = step4_interpreter( ...
    radar_data, fs, fc, p_FA, alg_coh);

print_demo_summary(used_seed, targets_true, targets_bin, pnfr_bin, eta_bin, diag_bin, ...
    targets_coh, pnfr_coh, eta_coh, diag_coh);

figs = gobjects(0);
if show_figures
    close all force;
end

meta = struct('standard', wifi_standard, 'cbw', cbw, 'channel', channel_model);
fig_bin = plot_binary_stc_demo(radar_data.Per_F, diag_bin.B, ...
    radar_data.axis_velocity, radar_data.axis_range, targets_true, targets_bin, alg_bin, meta, show_figures);
fig_coh = plot_coherent_stc_demo(radar_data.Per_F, Per_after_coh, ...
    radar_data.axis_velocity, radar_data.axis_range, targets_true, targets_coh, alg_coh, meta, show_figures);

if show_figures
    figs = [fig_bin, fig_coh];
end

results = struct( ...
    'seed',         used_seed, ...
    'targets_true', targets_true, ...
    'targets_bin',  targets_bin, ...
    'targets_coh',  targets_coh, ...
    'Per_after_bin', Per_after_bin, ...
    'Per_after_coh', Per_after_coh, ...
    'eta_bin',      eta_bin, ...
    'eta_coh',      eta_coh, ...
    'pnfr_bin',     pnfr_bin, ...
    'pnfr_coh',     pnfr_coh, ...
    'figs',         figs);
end

function targets = generate_random_targets(num_targets)
% GENERATE_RANDOM_TARGETS Draws physically valid moving targets well separated
% from the R = 0 clutter ridge, v = 0 MTI notch, and within the ~30 m detection range.
targets = repmat(struct('type', '', 'range_m', 0, 'velocity_mps', 0), num_targets, 1);

for k = 1:num_targets
    placed = false;
    for attempt = 1:200
        if rand() < 0.5
            t_type = 'car';
            r_m    = 6.0 + 22.0 * rand();  % [6, 28] m
            v_mag  = 6.0 + 12.0 * rand();  % [6, 18] m/s
        else
            t_type = 'human';
            r_m    = 3.0 + 15.0 * rand();  % [3, 18] m
            v_mag  = 1.8 + 3.2 * rand();   % [1.8, 5.0] m/s (brisk walk / jog)
        end

        v_sign = 2 * (rand() >= 0.5) - 1;
        r_m    = round(r_m, 1);
        v_ms   = round(v_sign * v_mag, 1);

        if k == 1
            separated = true;
        else
            prev_r    = [targets(1:k-1).range_m];
            prev_v    = [targets(1:k-1).velocity_mps];
            separated = all(abs(r_m - prev_r) >= 4.0 | abs(v_ms - prev_v) >= 6.0);
        end

        if separated
            targets(k) = struct('type', t_type, 'range_m', r_m, 'velocity_mps', v_ms);
            placed = true;
            break;
        end
    end

    if ~placed
        error('Could not place %d separated targets after 200 attempts.', num_targets);
    end
end
end

function print_demo_summary(used_seed, targets_true, targets_bin, pnfr_bin, eta_bin, diag_bin, ...
    targets_coh, pnfr_coh, eta_coh, diag_coh)

fprintf('\n=================================================================\n');
fprintf('  SUMMARY: Ground Truth vs. Detections (Seed: %u)\n', used_seed);
fprintf('  Replay: run_random_demo(%d, %u)\n', numel(targets_true), used_seed);
fprintf('=================================================================\n');

fprintf('\nGround Truth Targets (%d):\n', numel(targets_true));
fprintf('  ID | Type  | Range [m] | Velocity [m/s]\n');
fprintf('  ---+-------+-----------+---------------\n');
for k = 1:numel(targets_true)
    fprintf('  T%d | %-5s | %9.1f | %+14.1f\n', ...
        k, upper(targets_true(k).type), targets_true(k).range_m, targets_true(k).velocity_mps);
end

print_algorithm_table('Binary STC', targets_bin, pnfr_bin, eta_bin, diag_bin, targets_true);
print_algorithm_table('Coherent STC', targets_coh, pnfr_coh, eta_coh, diag_coh, targets_true);
fprintf('=================================================================\n\n');
end

function print_algorithm_table(alg_label, targets_det, pnfr, eta, diag_info, targets_true)
fprintf('\n%s (eta = %.3e | iterations = %d | residuals rejected = %d):\n', ...
    alg_label, eta, diag_info.num_iterations, diag_info.num_residuals);
if isempty(targets_det)
    fprintf('  No targets detected above CFAR threshold.\n');
    return;
end

fprintf('  #  | Range [m] | Vel [m/s] | RCS [m^2] | PNFR [dB] | Match\n');
fprintf('  ---+-----------+-----------+-----------+-----------+-------------------------\n');
true_r = [targets_true.range_m];
true_v = [targets_true.velocity_mps];

for k = 1:numel(targets_det)
    dr_vec = targets_det(k).d_hat - true_r;
    dv_vec = targets_det(k).v_hat - true_v;
    [min_dist, best_idx] = min(hypot(dr_vec, dv_vec));

    if abs(dr_vec(best_idx)) <= 3.0 && abs(dv_vec(best_idx)) <= 3.5 && min_dist < 5.0
        match_str = sprintf('T%d (dR=%+.2fm, dv=%+.2fm/s)', best_idx, dr_vec(best_idx), dv_vec(best_idx));
    else
        match_str = 'Unmatched / clutter';
    end

    fprintf('  %2d | %9.2f | %+9.2f | %9.2f | %9.1f | %s\n', ...
        k, targets_det(k).d_hat, targets_det(k).v_hat, targets_det(k).sigma_RCS_hat, ...
        pnfr.pnfr_dB(k), match_str);
end
end

function fig = plot_binary_stc_demo(Per_F_base, B, axis_velocity, axis_range, ...
    targets_true, targets_det, alg, meta, show_figures)
% PLOT_BINARY_STC_DEMO Range-Doppler map and binary cancellation mask B after Binary STC.

Per_dB_base = 10 * log10(Per_F_base + 1e-12);
c_lims      = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];
v_lims      = [max(-25, axis_velocity(1)), min(25, axis_velocity(end))];
r_lims      = [0, min(30, axis_range(end))];

fig_title = sprintf('Demo losowych celów - %s (%s, %s, %s)', ...
    alg.name, meta.standard, meta.cbw, meta.channel);
fig = figure('Name', fig_title, 'Color', 'white', ...
    'Position', [80, 140, 1220, 520], 'WindowStyle', 'normal', 'Visible', 'off');

% Panel 1: Range-Doppler periodogram with ground truth and detections
ax1 = subplot(1, 2, 1);
imagesc(ax1, axis_velocity, axis_range, Per_dB_base);
axis(ax1, 'xy');
colormap(ax1, 'jet');
clim(ax1, c_lims);
xlim(ax1, v_lims);
ylim(ax1, r_lims);
hold(ax1, 'on');
plot(ax1, [targets_true.velocity_mps], [targets_true.range_m], ...
    'wo', 'MarkerSize', 10, 'LineWidth', 1.8, 'DisplayName', 'Cele rzeczywiste');
if ~isempty(targets_det)
    plot(ax1, [targets_det.v_hat], [targets_det.d_hat], ...
        'kx', 'MarkerSize', 11, 'LineWidth', 2.0, 'DisplayName', ['Wykrycia ' alg.name]);
end
hold(ax1, 'off');
legend(ax1, 'Location', 'northeast', 'FontSize', 9, 'Interpreter', 'none');
cbar = colorbar(ax1);
cbar.Label.String = 'Moc [dB]';
cbar.Label.Interpreter = 'none';
title(ax1, sprintf('1. Periodogram Range-Doppler (przed %s)', alg.name), ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax1, 'Prędkość radialna [m/s]', 'Interpreter', 'none');
ylabel(ax1, 'Odległość bistatyczna [m]', 'Interpreter', 'none');
grid(ax1, 'on');
box(ax1, 'on');

% Panel 2: Binary cancellation mask B (1 = unmasked, 0 = cancelled main lobe)
ax2 = subplot(1, 2, 2);
imagesc(ax2, axis_velocity, axis_range, double(B));
axis(ax2, 'xy');
colormap(ax2, gray(2));
clim(ax2, [0, 1]);
xlim(ax2, v_lims);
ylim(ax2, r_lims);
hold(ax2, 'on');
plot(ax2, [targets_true.velocity_mps], [targets_true.range_m], ...
    'ro', 'MarkerSize', 10, 'LineWidth', 1.8, 'DisplayName', 'Cele rzeczywiste');
hold(ax2, 'off');
legend(ax2, 'Location', 'northeast', 'FontSize', 9, 'Interpreter', 'none');
title(ax2, sprintf('2. Maska binarna B (po %s)', alg.name), ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax2, 'Prędkość radialna [m/s]', 'Interpreter', 'none');
ylabel(ax2, 'Odległość bistatyczna [m]', 'Interpreter', 'none');
grid(ax2, 'on');
box(ax2, 'on');

sgtitle(fig_title, 'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'none');

if show_figures
    set(fig, 'Visible', 'on');
    drawnow;
else
    close(fig);
    fig = [];
end
end

function fig = plot_coherent_stc_demo(Per_F_base, Per_F_after, axis_velocity, axis_range, ...
    targets_true, targets_det, alg, meta, show_figures)
% PLOT_COHERENT_STC_DEMO Range-Doppler periodograms before and after Coherent STC.

Per_dB_base  = 10 * log10(Per_F_base + 1e-12);
Per_dB_after = 10 * log10(Per_F_after + 1e-12);
c_lims       = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];
v_lims       = [max(-25, axis_velocity(1)), min(25, axis_velocity(end))];
r_lims       = [0, min(30, axis_range(end))];

fig_title = sprintf('Demo losowych celów - %s (%s, %s, %s)', ...
    alg.name, meta.standard, meta.cbw, meta.channel);
fig = figure('Name', fig_title, 'Color', 'white', ...
    'Position', [130, 90, 1220, 520], 'WindowStyle', 'normal', 'Visible', 'off');

% Panel 1: Original Range-Doppler periodogram with ground truth and detections
ax1 = subplot(1, 2, 1);
imagesc(ax1, axis_velocity, axis_range, Per_dB_base);
axis(ax1, 'xy');
colormap(ax1, 'jet');
clim(ax1, c_lims);
xlim(ax1, v_lims);
ylim(ax1, r_lims);
hold(ax1, 'on');
plot(ax1, [targets_true.velocity_mps], [targets_true.range_m], ...
    'wo', 'MarkerSize', 10, 'LineWidth', 1.8, 'DisplayName', 'Cele rzeczywiste');
if ~isempty(targets_det)
    plot(ax1, [targets_det.v_hat], [targets_det.d_hat], ...
        'kx', 'MarkerSize', 11, 'LineWidth', 2.0, 'DisplayName', ['Wykrycia ' alg.name]);
end
hold(ax1, 'off');
legend(ax1, 'Location', 'northeast', 'FontSize', 9, 'Interpreter', 'none');
title(ax1, sprintf('1. Periodogram Range-Doppler (przed %s)', alg.name), ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax1, 'Prędkość radialna [m/s]', 'Interpreter', 'none');
ylabel(ax1, 'Odległość bistatyczna [m]', 'Interpreter', 'none');
grid(ax1, 'on');
box(ax1, 'on');

% Panel 2: Residual periodogram after coherent target subtraction
ax2 = subplot(1, 2, 2);
imagesc(ax2, axis_velocity, axis_range, Per_dB_after);
axis(ax2, 'xy');
colormap(ax2, 'jet');
clim(ax2, c_lims);
xlim(ax2, v_lims);
ylim(ax2, r_lims);
hold(ax2, 'on');
plot(ax2, [targets_true.velocity_mps], [targets_true.range_m], ...
    'wo', 'MarkerSize', 10, 'LineWidth', 1.8, 'DisplayName', 'Cele rzeczywiste');
hold(ax2, 'off');
legend(ax2, 'Location', 'northeast', 'FontSize', 9, 'Interpreter', 'none');
cbar = colorbar(ax2);
cbar.Label.String = 'Moc [dB]';
cbar.Label.Interpreter = 'none';
title(ax2, sprintf('2. Periodogram rezydualny (po %s)', alg.name), ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel(ax2, 'Prędkość radialna [m/s]', 'Interpreter', 'none');
ylabel(ax2, 'Odległość bistatyczna [m]', 'Interpreter', 'none');
grid(ax2, 'on');
box(ax2, 'on');

sgtitle(fig_title, 'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'none');

if show_figures
    set(fig, 'Visible', 'on');
    drawnow;
else
    close(fig);
    fig = [];
end
end
