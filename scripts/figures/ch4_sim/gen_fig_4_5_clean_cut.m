function gen_fig_4_5_clean_cut()
% GEN_FIG_4_5_CLEAN_CUT
% Eksperyment SIM-5 (E5): Granica dynamiki mocy — porównanie algorytmów
% Binary STC (maskowanie binarne) oraz Coherent STC (odejmowanie koherentne)
% według M. Brauna (2014) z progiem CFAR eta.
%
% Rysunek 4.5 do Rozdziału 4 pracy dyplomowej:
%   Dwupanelowe zestawienie przekrojów odległościowych 1D (Range cut) mapy Range–Doppler
%   w kolumnie prędkości Dopplera celu głównego w kanale TGax Model-C (CBW20, 20 MHz)
%   dla asymetrii mocy 30 dB:
%     - Cel 1 (silny, 0 dB): pojazd na odległości R_1 = 15.0 m (v = 8.0 m/s),
%     - Cel 2 (słaby, -30 dB): pieszy na odległości R_2 = 30.0 m (v = 8.0 m/s),
%       leżący wewnątrz szerokiego listka głównego Blackmana–Harrisa celu 1.
%
%   Panele:
%     a) Binary STC (maskowanie binarne): wycięta elipsa B = 0 wokół pojazdu pochłania
%        pieszego, uniemożliwiając jego detekcję.
%     b) Coherent STC (odejmowanie koherentne): odjęcie repliki pojazdu odsłania ostry
%        pik pieszego powyżej progu CFAR eta i pozwala wykryć oba cele.
%
% Plik wynikowy: thesis/img/ch4_sim/rys_4_5_clean_prog_adaptacyjny.png

% 1. Inicjalizacja ścieżek projektu i definicji algorytmów
[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();

alg_bin = get_detection_algorithm('binary');
alg_coh = get_detection_algorithm('coherent');

fprintf('=================================================================\n');
fprintf('  Generowanie Rys. 4.5: %s vs %s (CBW20, Exp. E5)\n', alg_bin.name, alg_coh.name);
fprintf('=================================================================\n');

wifi_standard = '802.11ax';
cbw           = 'CBW20';
mcs           = 0;
channel_model = 'Model-C';
snr_dB        = 38.0;

% Konfiguracja celów: asymetria mocy 30 dB (stosunek amplitud 10^(30/20) ~ 31.62)
r1_m = 15.0;  v1_ms = 8.0;  gain1 = 0.0500;             % Pojazd (0 dB ref)
r2_m = 30.0;  v2_ms = 8.0;  gain2 = gain1 * 10^(-30/20); % Pieszy (-30 dB)

targets = [ ...
    struct('type', 'car',   'range_m', r1_m, 'velocity_mps', v1_ms, 'gain', gain1), ...
    struct('type', 'human', 'range_m', r2_m, 'velocity_mps', v2_ms, 'gain', gain2) ...
    ];

% 2. Wykonanie potoku nadawczo-odbiorczego (DRY)
rng(42);
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, mcs);

rng(23); % Stałe ziarno wielodrogi TGax
[rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

radar_data = step3_receiver(rx_signal, waveform, fs, fc, params);

% 3. Uruchomienie obu metod Brauna na tej samej mapie
p_FA = 1e-3;
[targets_bin, ~, Per_after_bin, eta_bin, ~, diag_bin] = step4_interpreter( ...
    radar_data, fs, fc, wifi_standard, p_FA, alg_bin);
[targets_coh, ~, Per_after_coh, eta_coh, ~, diag_coh] = step4_interpreter( ...
    radar_data, fs, fc, wifi_standard, p_FA, alg_coh);

ped_bin = any(abs([targets_bin.d_hat] - r2_m) < 2.5 & abs([targets_bin.v_hat] - v2_ms) < 2.0);
ped_coh = any(abs([targets_coh.d_hat] - r2_m) < 2.5 & abs([targets_coh.v_hat] - v2_ms) < 2.0);
fprintf('  [Porównanie E5] %s: %d wykryć (pieszy wykryty = %d)\n', alg_bin.name, numel(targets_bin), ped_bin);
fprintf('  [Porównanie E5] %s: %d wykryć, %d odrzucone rezydua (pieszy wykryty = %d)\n', ...
    alg_coh.name, numel(targets_coh), diag_coh.num_residuals, ped_coh);

% 4. Ekstrakcja przekrojów 1D w kolumnie Dopplera celu głównego
dop_col = targets_coh(1).d_idx;
r_axis  = radar_data.axis_range;

cand_idx = find([targets_coh.d_hat] > 22.0);
if isempty(cand_idx)
    error('Nie wykryto pieszego w strefie R > 22 m w trybie %s dla E5.', alg_coh.name);
end
[~, best_rel] = min(hypot([targets_coh(cand_idx).d_hat] - r2_m, [targets_coh(cand_idx).v_hat] - v2_ms));
idx_ped = cand_idx(best_rel);
k_ped   = targets_coh(idx_ped).iter;

cut_raw = radar_data.Per_F(:, dop_col);
max_pwr = max(cut_raw); % Globalna normalizacja do piku celu silnego (0 dB)

cut_raw_dB      = 10 * log10(cut_raw / max_pwr + 1e-12);
cut_after_bin   = 10 * log10(Per_after_bin(:, dop_col) / max_pwr + 1e-12);
cut_after_t1_dB = 10 * log10(diag_coh.Per_history{k_ped + 1}(:, dop_col) / max_pwr + 1e-12);
cut_final_coh   = 10 * log10(Per_after_coh(:, dop_col) / max_pwr + 1e-12);
eta_bin_dB      = 10 * log10(eta_bin / max_pwr + 1e-12);
eta_coh_dB      = 10 * log10(eta_coh / max_pwr + 1e-12);

fprintf('  Próg CFAR (eta): %s = %.2f dB | %s = %.2f dB\n', alg_bin.name, eta_bin_dB, alg_coh.name, eta_coh_dB);

% 5. Dwupanelowa wizualizacja porównawcza
fig = figure('Color', 'w', 'Position', [80, 100, 1280, 500], 'Visible', 'off');
sgtitle(sprintf('Porównanie algorytmów %s i %s (Braun) w scenariuszu dynamiki 30 dB', alg_bin.name, alg_coh.name), ...
    'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

y_lims = [-60, 5];
x_lims = [0, 55];

% --- Panel (a) ---
subplot(1, 2, 1);
hold on;

% Cieniowane przedziały zamaskowane przez mapę binarną (B = 0)
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
    'DisplayName', 'Sygnał surowy');
plot(r_axis, cut_after_bin, 'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Po %s (Per_F · B)', alg_bin.name));
xline(r2_m, ':k', 'LineWidth', 1.4, 'DisplayName', 'Pozycja pieszego (30,0 m)');
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

% --- Panel (b) ---
subplot(1, 2, 2);
hold on;
plot(r_axis, cut_raw_dB, 'Color', [0.0, 0.45, 0.74], 'LineStyle', '-', 'LineWidth', 2.0, ...
    'DisplayName', 'Sygnał surowy');
plot(r_axis, cut_after_t1_dB, 'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.8, ...
    'DisplayName', 'Po usunięciu celu 1 (pojazd)');
plot(r_axis, cut_final_coh, 'Color', [0.47, 0.67, 0.19], 'LineStyle', ':', 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Stan końcowy (po %s)', alg_coh.name));
xline(r2_m, ':k', 'LineWidth', 1.4, 'DisplayName', 'Pozycja pieszego (30,0 m)');
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

% 6. Zapis grafiki w wysokiej rozdzielczości (300 DPI)
out_dir = fullfile(project_root, 'thesis', 'img', 'ch4_sim');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
out_file = fullfile(out_dir, 'rys_4_5_clean_prog_adaptacyjny.png');
exportgraphics(fig, out_file, 'Resolution', 300);
close(fig);

fprintf('  Grafika wyeksportowana pomyślnie do:\n  %s\n', out_file);
fprintf('=================================================================\n');
end
