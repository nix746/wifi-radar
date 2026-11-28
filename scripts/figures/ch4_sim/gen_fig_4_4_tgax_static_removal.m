function fig = gen_fig_4_4_tgax_static_removal(show_figure, save_png)
% GEN_FIG_4_4_TGAX_STATIC_REMOVAL
% Experiment SIM-4 (E4): TGax multipath clutter (Models A, C, E) and slow-time mean subtraction.
% Figure 4.4 for Chapter 4 of the thesis:
%   3x2 grid of 2D Range-Doppler maps on a unified unnormalized Per_F [dB] scale,
%   comparing maps with static echoes (left) and after slow-time mean subtraction (right)
%   over v in [-20, +20] m/s, R in [0, 25] m.
%
% Output file: thesis/img/ch4_sim/rys_4_4_usuwanie_echa_stalego.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.4: TGax 2D Maps (Real Per_F Scale, Exp. E4)\n');
fprintf('=================================================================\n');

[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();

wifi_standard = '802.11ax';
cbw           = 'CBW80';
mcs           = 0;

r_target_m   = 10.0;
v_target_mps = 8.0;
target       = struct('type', 'car', 'range_m', r_target_m, 'velocity_mps', v_target_mps);

models = {'Model-A', 'Model-C', 'Model-E'};
model_labels = { ...
    'Model-A (\tau_{rms} = 0 ns, komora)', ...
    'Model-C (\tau_{rms} = 30 ns, biuro)', ...
    'Model-E (\tau_{rms} = 100 ns, hala)' ...
    };

rng(42);
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, mcs);

P_pre_all  = cell(1, numel(models));
P_post_all = cell(1, numel(models));
axis_r     = [];
axis_v     = [];

for m = 1:numel(models)
    ch_name = models{m};
    rng(23); % Deterministic TGax channel realization
    [rx_signal, fc, intrinsic_delay] = step2_channel(waveform, fs, ch_name, cfg, target);
    radar_data                       = step3_receiver(rx_signal, waveform, fs, fc, params, [], [], intrinsic_delay);

    if isempty(axis_r)
        axis_r = radar_data.axis_range;
        axis_v = radar_data.axis_velocity;
    end

    % Apply identical DC null repair to H_raw so pre/post mean-subtraction maps match in windowing
    H_pre = interpolate_dc_nulls(radar_data.H_raw, params.dc_indices);
    [~, ~, ~, ~, P_pre_all{m}] = compute_range_doppler_map( ...
        H_pre, radar_data.Nfft, radar_data.n_symbols, params.active_mask, 4, true);
    P_post_all{m} = radar_data.Per_F;

    [~, r_idx]  = min(abs(axis_r - r_target_m));
    [~, v0_idx] = min(abs(axis_v - 0.0));
    [~, vt_idx] = min(abs(axis_v - v_target_mps));

    notch_dB = 10 * log10(P_pre_all{m}(r_idx, v0_idx) / max(P_post_all{m}(r_idx, v0_idx), 1e-15));
    scr_pre  = 10 * log10(P_pre_all{m}(r_idx, vt_idx) / max(P_pre_all{m}(r_idx, v0_idx), 1e-15));
    scr_post = 10 * log10(P_post_all{m}(r_idx, vt_idx) / max(P_post_all{m}(r_idx, v0_idx), 1e-15));

    fprintf('  [%s @ R=%.1f m] Static echo suppression (v=0): %5.1f dB | SCR: %+5.1f dB -> %+5.1f dB\n', ...
        ch_name, r_target_m, notch_dB, scr_pre, scr_post);
end

fig = figure('Name', 'Figure 4.4 - TGax Multipath Clutter & Slow-Time Mean Subtraction (Exp. E4)', ...
    'Color', 'white', 'Position', [50, 50, 1150, 1150], 'Visible', 'off');
tl = tiledlayout(fig, 3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, 'Wpływ wielodrogowości kanału TGax i usuwania echa stałego (odjęcie średniej czasowej) na mapy Range–Doppler', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');

r_mask = axis_r >= 0 & axis_r <= 25;
r_sub  = axis_r(r_mask);
v_lim  = [-20, 20];
c_lims = [-45, 55];

row_letters = {'a', 'c', 'e'; 'b', 'd', 'f'};

for m = 1:numel(models)
    % Column 1: With static echoes (real Per_F [dB])
    ax_l = nexttile(tl, 2 * m - 1);
    P_pre_dB = 10 * log10(P_pre_all{m}(r_mask, :) + 1e-12);
    imagesc(ax_l, axis_v, r_sub, P_pre_dB);
    axis(ax_l, 'xy');
    colormap(ax_l, 'parula');
    clim(ax_l, c_lims);
    xlim(ax_l, v_lim);
    ylim(ax_l, [0, 25]);
    ylabel(ax_l, 'Odległość bistatyczna [m]', 'FontSize', 10, 'Interpreter', 'none');
    if m == 3
        xlabel(ax_l, 'Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
    end
    title(ax_l, sprintf('%s) %s — Z echem stałym', row_letters{1, m}, model_labels{m}), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'tex');
    hold(ax_l, 'on');
    plot(ax_l, v_target_mps, r_target_m, 'wo', 'MarkerSize', 8, 'LineWidth', 1.8);
    text(ax_l, v_target_mps + 0.8, r_target_m, 'Cel', 'Color', 'white', ...
        'FontSize', 8.5, 'FontWeight', 'bold');
    hold(ax_l, 'off');
    set(ax_l, 'FontSize', 9.5, 'LineWidth', 0.9, 'Box', 'on');

    % Column 2: After slow-time mean subtraction (identical real Per_F [dB] scale)
    ax_r = nexttile(tl, 2 * m);
    P_post_dB = 10 * log10(P_post_all{m}(r_mask, :) + 1e-12);
    imagesc(ax_r, axis_v, r_sub, P_post_dB);
    axis(ax_r, 'xy');
    colormap(ax_r, 'parula');
    clim(ax_r, c_lims);
    xlim(ax_r, v_lim);
    ylim(ax_r, [0, 25]);
    if m == 3
        xlabel(ax_r, 'Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
    end
    title(ax_r, sprintf('%s) %s — Po odjęciu średniej', row_letters{2, m}, model_labels{m}), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'tex');
    hold(ax_r, 'on');
    plot(ax_r, v_target_mps, r_target_m, 'wo', 'MarkerSize', 8, 'LineWidth', 1.8);
    text(ax_r, v_target_mps + 0.8, r_target_m, 'Cel', 'Color', 'white', ...
        'FontSize', 8.5, 'FontWeight', 'bold');
    hold(ax_r, 'off');
    set(ax_r, 'FontSize', 9.5, 'LineWidth', 0.9, 'Box', 'on');
end

cb = colorbar(ax_r);
cb.Layout.Tile = 'east';
cb.Label.String = 'Moc periodogramu [dB]';
cb.Label.FontSize = 10.5;
cb.Label.Interpreter = 'none';

save_thesis_figure(fig, 'ch4_sim', 'rys_4_4_usuwanie_echa_stalego.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n\n');
end
