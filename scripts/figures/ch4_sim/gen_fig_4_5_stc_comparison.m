function fig = gen_fig_4_5_stc_comparison(show_figure, save_png)
% GEN_FIG_4_5_STC_COMPARISON
% Experiment SIM-5 (E5): Dynamic range limit - Binary STC vs Coherent STC (Braun 2014).
% Figure 4.5 for Chapter 4 of the thesis:
%   1D range cuts at the main target Doppler column in TGax Model-A (CBW40, 40 MHz)
%   for a ~30 dB power asymmetry (pedestrian at 3.5 m, car at 15.0 m inside BH main lobe).
%
% Output file: thesis/img/ch4_sim/rys_4_5_porownanie_stc.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();

alg_bin = get_detection_algorithm('binary');
alg_coh = get_detection_algorithm('coherent');

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.5: %s vs %s (CBW20, Exp. E5)\n', alg_bin.name, alg_coh.name);
fprintf('=================================================================\n');

wifi_standard = '802.11ax';
cbw           = 'CBW40';
mcs           = 0;
channel_model = 'Model-A';


% Natural ~14.0 dB dynamic range from dual-slope radar equation (pedestrian at 10.0 m, car at 22.0 m)
r1_m = 10.0;  v1_ms = 8.0;
r2_m = 22.0;  v2_ms = 8.0;

targets = [ ...
    struct('type', 'human', 'range_m', r1_m, 'velocity_mps', v1_ms), ...
    struct('type', 'car',   'range_m', r2_m, 'velocity_mps', v2_ms) ...
    ];

rng(42);
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, mcs);

rng(23); % Deterministic TGax channel realization
[rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets);

radar_data = step3_receiver(rx_signal, waveform, fs, fc, params);

p_FA = 1e-3;
[targets_bin, ~, Per_after_bin, eta_bin, ~, diag_bin] = step4_interpreter( ...
    radar_data, fs, fc, wifi_standard, p_FA, alg_bin);
[targets_coh, ~, Per_after_coh, eta_coh, ~, diag_coh] = step4_interpreter( ...
    radar_data, fs, fc, wifi_standard, p_FA, alg_coh);

car_bin = any(abs([targets_bin.d_hat] - r2_m) < 2.5 & abs([targets_bin.v_hat] - v2_ms) < 2.0);
car_coh = any(abs([targets_coh.d_hat] - r2_m) < 2.5 & abs([targets_coh.v_hat] - v2_ms) < 2.0);
fprintf('  [E5 Comparison] %s: %d detections (car detected = %d)\n', alg_bin.name, numel(targets_bin), car_bin);
fprintf('  [E5 Comparison] %s: %d detections, %d residuals rejected (car detected = %d)\n', ...
    alg_coh.name, numel(targets_coh), diag_coh.num_residuals, car_coh);

% Extract 1D range cuts at the main target Doppler column
dop_col = targets_coh(1).d_idx;
r_axis  = radar_data.axis_range;

cand_idx = find([targets_coh.d_hat] > 14.0 & [targets_coh.d_hat] < 35.0);
if isempty(cand_idx)
    error('Car target in R in (14, 35) m zone was not detected by %s in E5.', alg_coh.name);
end
[~, best_rel] = min(hypot([targets_coh(cand_idx).d_hat] - r2_m, [targets_coh(cand_idx).v_hat] - v2_ms));
idx_car = cand_idx(best_rel);
k_car   = targets_coh(idx_car).iter;

cut_raw = radar_data.Per_F(:, dop_col);
max_pwr = max(cut_raw); % Normalize relative to strong target peak (0 dB)

cut_raw_dB      = 10 * log10(cut_raw / max_pwr + 1e-12);
cut_after_bin   = 10 * log10(Per_after_bin(:, dop_col) / max_pwr + 1e-12);
cut_after_t1_dB = 10 * log10(diag_coh.Per_history{k_car + 1}(:, dop_col) / max_pwr + 1e-12);
cut_final_coh   = 10 * log10(Per_after_coh(:, dop_col) / max_pwr + 1e-12);
eta_bin_dB      = 10 * log10(eta_bin / max_pwr + 1e-12);
eta_coh_dB      = 10 * log10(eta_coh / max_pwr + 1e-12);

fprintf('  CFAR threshold eta: %s = %.2f dB | %s = %.2f dB\n', alg_bin.name, eta_bin_dB, alg_coh.name, eta_coh_dB);

fig = figure('Name', 'Figure 4.5 - Binary STC vs Coherent STC (30 dB Dynamic Range)', ...
    'Color', 'w', 'Position', [80, 100, 1280, 500], 'Visible', 'off');
sgtitle(sprintf('Porównanie algorytmów %s i %s (Braun) w scenariuszu dynamiki 30 dB', alg_bin.name, alg_coh.name), ...
    'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

y_lims = [-60, 5];
x_lims = [0, 35];

% Panel (a): Binary STC
subplot(1, 2, 1);
hold on;

% Shade contiguous range intervals masked by B = 0
mask_zero = (~diag_bin.B(:, dop_col)) & (r_axis(:) <= x_lims(2));
idx_m = find(mask_zero);
if ~isempty(idx_m)
    breaks = find(diff(idx_m) > 1);
    blk_s  = [idx_m(1); idx_m(breaks + 1)];
    blk_e  = [idx_m(breaks); idx_m(end)];
    for b = 1:numel(blk_s)
        r_lo = r_axis(blk_s(b));
        r_hi = r_axis(blk_e(b));
        if b == 1
            patch([r_lo, r_hi, r_hi, r_lo], [y_lims(1), y_lims(1), y_lims(2), y_lims(2)], ...
                [0.85, 0.85, 0.85], 'FaceAlpha', 0.45, 'EdgeColor', 'none', ...
                'DisplayName', 'Obszar zamaskowany (B = 0)');
        else
            patch([r_lo, r_hi, r_hi, r_lo], [y_lims(1), y_lims(1), y_lims(2), y_lims(2)], ...
                [0.85, 0.85, 0.85], 'FaceAlpha', 0.45, 'EdgeColor', 'none', ...
                'HandleVisibility', 'off');
        end
    end
end

plot(r_axis, cut_raw_dB, 'Color', [0.0, 0.45, 0.74], 'LineStyle', '-', 'LineWidth', 2.0, ...
    'DisplayName', 'Periodogram przed detekcją');
plot(r_axis, cut_after_bin, 'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Po %s (Per_F · B)', alg_bin.name));
xline(r2_m, ':k', 'LineWidth', 1.4, 'DisplayName', 'Pozycja samochodu (22,0 m)');
yline(eta_bin_dB, '-.', 'Color', [0.2, 0.2, 0.2], 'LineWidth', 1.6, ...
    'DisplayName', sprintf('Próg CFAR %c', char(951)));
hold off;

xlim(x_lims);
ylim(y_lims);
title(sprintf('a) %s (%s)', alg_bin.name, alg_bin.description_pl), 'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Odległość bistatyczna [m]', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
set(gca, 'GridAlpha', 0.25, 'MinorGridAlpha', 0.15, 'Layer', 'top');
box on;
set(gca, 'Box', 'on', 'LineWidth', 1.1);
legend('Location', 'southoutside', 'Orientation', 'horizontal', ...
    'FontSize', 9.5, 'NumColumns', 2, 'Interpreter', 'none');

% Panel (b): Coherent STC
subplot(1, 2, 2);
hold on;
plot(r_axis, cut_raw_dB, 'Color', [0.0, 0.45, 0.74], 'LineStyle', '-', 'LineWidth', 2.0, ...
    'DisplayName', 'Periodogram przed detekcją');
plot(r_axis, cut_after_t1_dB, 'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.8, ...
    'DisplayName', 'Po usunięciu celu 1 (pieszy)');
plot(r_axis, cut_final_coh, 'Color', [0.47, 0.67, 0.19], 'LineStyle', ':', 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Stan końcowy (po %s)', alg_coh.name));
xline(r2_m, ':k', 'LineWidth', 1.4, 'DisplayName', 'Pozycja samochodu (22,0 m)');
yline(eta_coh_dB, '-.', 'Color', [0.2, 0.2, 0.2], 'LineWidth', 1.6, ...
    'DisplayName', sprintf('Próg CFAR %c', char(951)));
hold off;

xlim(x_lims);
ylim(y_lims);
title(sprintf('b) %s (%s)', alg_coh.name, alg_coh.description_pl), 'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Odległość bistatyczna [m]', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
set(gca, 'GridAlpha', 0.25, 'MinorGridAlpha', 0.15, 'Layer', 'top');
box on;
set(gca, 'Box', 'on', 'LineWidth', 1.1);
legend('Location', 'southoutside', 'Orientation', 'horizontal', ...
    'FontSize', 9.5, 'NumColumns', 2, 'Interpreter', 'none');

save_thesis_figure(fig, 'ch4_sim', 'rys_4_5_porownanie_stc.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
