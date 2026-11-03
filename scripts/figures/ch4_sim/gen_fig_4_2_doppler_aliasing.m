function gen_fig_4_2_doppler_aliasing()
% GEN_FIG_4_2_DOPPLER_ALIASING
% Experiment SIM-2 (E2): Unambiguous velocity limit comparison (802.11a vs 802.11ax).
% Figure 4.2 for Chapter 4 of the thesis:
%   1D Doppler velocity profile cuts for a fast moving vehicle target
%   (v = +20.0 m/s = 72 km/h, R = 30.0 m) in a flat-fading channel (Model-A),
%   comparing IEEE 802.11a (T_sym = 4.0 us, v_unamb = +/-56.8 m/s) against
%   IEEE 802.11ax (T_sym = 13.6 us, v_unamb = +/-16.7 m/s), where spectrum
%   wrapping (Doppler aliasing) folds the echo to v_alias = -13.4 m/s.
%
% Output file: thesis/img/ch4_sim/rys_4_2_aliasing_dopplera.png

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.2: Doppler Velocity Aliasing (Exp. E2)\n');
fprintf('=================================================================\n');

% 1. Initialize project paths and deterministic seed
[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();
rng(42);

cbw           = 'CBW20';
mcs           = 0;
channel_model = 'Model-A';
snr_dB        = 40.0;

% Physical carrier frequency and effective CPI slow-time sampling factor
fc_base = 5.5e9;
k_pri   = 60;
fc_eff  = k_pri * fc_base;

% Target scenario: fast vehicle moving at v = +20.0 m/s (72 km/h) at R = 30.0 m
r_true_m  = 30.0;
v_true_ms = 20.0;
targets   = struct('type', 'car', 'range_m', r_true_m, ...
    'velocity_mps', k_pri * v_true_ms, 'gain', 0.12);

standards = {'802.11a', '802.11ax'};
cuts_dB   = cell(1, 2);
axes_v    = cell(1, 2);
v_unamb   = zeros(1, 2);
v_det     = zeros(1, 2);
r_det     = zeros(1, 2);
pnfr_dB   = zeros(1, 2);
nf_cut_dB = zeros(1, 2);

% 2. Execute standard radar pipeline for 802.11a and 802.11ax (DRY)
for i = 1:numel(standards)
    std_name = standards{i};
    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(std_name, false, cbw, mcs);
    [rx_signal, ~]              = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB, fc_base);
    radar_data                  = step3_receiver(rx_signal, waveform, fs, fc_eff, params, false);
    [targets_found, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc_eff, std_name, false, 1);

    % Extract 1D Doppler velocity profile at the detected target range bin
    r_idx   = targets_found(1, 1);
    v_idx   = targets_found(1, 2);
    P_slice = abs(radar_data.CPer_base(r_idx, :)).^2;
    max_val = max(P_slice);

    cuts_dB{i}   = 10 * log10(P_slice / max_val + 1e-12);
    axes_v{i}    = radar_data.axis_velocity;
    v_unamb(i)   = abs(axes_v{i}(end));
    v_det(i)     = axes_v{i}(v_idx);
    r_det(i)     = radar_data.axis_range(r_idx);
    pnfr_dB(i)   = pnfr.pnfr_dB(1);
    nf_cut_dB(i) = 10 * log10(median(P_slice) / max_val);

    fprintf('  [%s] T_sym = %.1f us | v_unamb = +/-%.2f m/s | Detected: R = %.2f m, v = %+.2f m/s | NF_cut = %.1f dB, PNFR = %.1f dB\n', ...
        std_name, (params.Nfft + params.Ncp) / fs * 1e6, v_unamb(i), ...
        r_det(i), v_det(i), nf_cut_dB(i), pnfr_dB(i));
end

v_alias_th = v_true_ms - 2 * v_unamb(2);
fprintf('  Theoretical aliased velocity in 802.11ax: %.2f - 2 * %.2f = %.2f m/s (measured: %.2f m/s)\n', ...
    v_true_ms, v_unamb(2), v_alias_th, v_det(2));

% 3. Plot 1D Doppler cuts comparison (two side-by-side panels)
fig = figure('Name', 'Figure 4.2 - Doppler Velocity Aliasing (802.11a vs 802.11ax)', ...
    'Color', 'white', 'Position', [100, 100, 1200, 580], 'Visible', 'off');

sgtitle('Porównanie jednoznaczności prędkości: IEEE 802.11a vs 802.11ax', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

color_a     = [0.0000, 0.4470, 0.7410]; % Blue
color_ax    = [0.8500, 0.3250, 0.0980]; % Orange-Red
color_true  = [0.1330, 0.5450, 0.1330]; % Forest Green
color_bound = [0.2500, 0.2500, 0.2500]; % Dark Gray

% --- Panel (a): IEEE 802.11a ---
subplot(1, 2, 1);
hold on;
% Shade ambiguous region outside [-v_unamb, +v_unamb]
patch([-65, -v_unamb(1), -v_unamb(1), -65], [-60, -60, 5, 5], [0.92, 0.92, 0.92], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7, 'DisplayName', 'Obszar niejednoznaczności');
patch([v_unamb(1), 65, 65, v_unamb(1)], [-60, -60, 5, 5], [0.92, 0.92, 0.92], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7, 'HandleVisibility', 'off');

plot(axes_v{1}, cuts_dB{1}, '-', 'Color', color_a, 'LineWidth', 1.9, ...
    'DisplayName', 'Profil Dopplera 802.11a');
xline(-v_unamb(1), '--', 'Color', color_bound, 'LineWidth', 1.4, ...
    'DisplayName', 'Granica ±v_unamb (±56,8 m/s)');
xline(+v_unamb(1), '--', 'Color', color_bound, 'LineWidth', 1.4, ...
    'HandleVisibility', 'off');
xline(v_true_ms, ':', 'Color', color_true, 'LineWidth', 1.8, ...
    'DisplayName', 'Prędkość rzeczywista (+20,0 m/s)');
plot(v_det(1), 0, 'o', 'Color', color_a, 'MarkerFaceColor', color_a, ...
    'MarkerSize', 7, 'DisplayName', sprintf('Wykryty pik (+%s m/s)', strrep(sprintf('%.1f', v_det(1)), '.', ',')));
hold off;

xlim([-65, 65]);
ylim([-55, 4]);
title('a) IEEE 802.11a (T_sym = 4,0 µs)', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Prędkość radialna [m/s]', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'Interpreter', 'none');
leg1 = legend('Location', 'southoutside', 'NumColumns', 2, 'FontSize', 9.0, 'Interpreter', 'none');
leg1.Box = 'on';
set(gca, 'FontSize', 10.5, 'LineWidth', 1.0, 'Layer', 'top');
grid on;
set(gca, 'GridAlpha', 0.25);

% --- Panel (b): IEEE 802.11ax ---
subplot(1, 2, 2);
hold on;
% Shade ambiguous region outside [-v_unamb, +v_unamb]
patch([-65, -v_unamb(2), -v_unamb(2), -65], [-60, -60, 5, 5], [0.92, 0.92, 0.92], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7, 'DisplayName', 'Obszar niejednoznaczności');
patch([v_unamb(2), 65, 65, v_unamb(2)], [-60, -60, 5, 5], [0.92, 0.92, 0.92], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.7, 'HandleVisibility', 'off');

plot(axes_v{2}, cuts_dB{2}, '-', 'Color', color_ax, 'LineWidth', 1.9, ...
    'DisplayName', 'Profil Dopplera 802.11ax');
xline(-v_unamb(2), '--', 'Color', color_bound, 'LineWidth', 1.4, ...
    'DisplayName', 'Granica ±v_unamb (±16,7 m/s)');
xline(+v_unamb(2), '--', 'Color', color_bound, 'LineWidth', 1.4, ...
    'HandleVisibility', 'off');
xline(v_true_ms, ':', 'Color', color_true, 'LineWidth', 1.8, ...
    'DisplayName', 'Prędkość rzeczywista (+20,0 m/s)');
plot(v_det(2), 0, 'o', 'Color', color_ax, 'MarkerFaceColor', color_ax, ...
    'MarkerSize', 7, 'DisplayName', sprintf('Pik po aliasingu (%s m/s)', strrep(sprintf('%.1f', v_det(2)), '.', ',')));
hold off;

xlim([-65, 65]);
ylim([-55, 4]);
title('b) IEEE 802.11ax (T_sym = 13,6 µs)', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Prędkość radialna [m/s]', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'Interpreter', 'none');
leg2 = legend('Location', 'southoutside', 'NumColumns', 2, 'FontSize', 9.0, 'Interpreter', 'none');
leg2.Box = 'on';
set(gca, 'FontSize', 10.5, 'LineWidth', 1.0, 'Layer', 'top');
grid on;
set(gca, 'GridAlpha', 0.25);

% 4. Export figure in 300 DPI
[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
out_dir = fullfile(project_root, 'thesis', 'img', 'ch4_sim');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
out_file = fullfile(out_dir, 'rys_4_2_aliasing_dopplera.png');

exportgraphics(fig, out_file, 'Resolution', 300);
close(fig);

fprintf('  Figure successfully saved to: %s\n', out_file);
end