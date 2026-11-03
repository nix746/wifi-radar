function gen_fig_4_3_noise_enhancement()
% GEN_FIG_4_3_NOISE_ENHANCEMENT
% Experiment SIM-3 (E3): Modulation order (MCS) limit and ZF noise enhancement.
% Figure 4.3 for Chapter 4 of the thesis:
%   Dual Y-axis comparison of the Zero-Forcing noise enhancement factor
%   zeta_ZF = E[|X|^2]*E[1/|X|^2] [dB] and target detection contrast PNFR [dB]
%   across MCS 0 (BPSK), MCS 3 (16-QAM), MCS 7 (64-QAM), and MCS 11 (1024-QAM)
%   for IEEE 802.11ax (CBW40, TGax Model-C) with dynamic payload scaling
%   maintaining a constant frame duration (~3.87 ms, M = 280 OFDM symbols).
%
% Output file: thesis/img/ch4_sim/rys_4_3_wzmocnienie_szumu_mcs.png

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.3: MCS Noise Enhancement & PNFR (Exp. E3)\n');
fprintf('=================================================================\n');

% 1. Initialize project paths and deterministic seed
[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();
rng(42);

wifi_standard = '802.11ax';
cbw           = 'CBW40';
channel_model = 'Model-C';
snr_dB        = 25.0;

% Moving target scenario in indoor multipath channel (R = 22.5 m, v = +18.0 m/s)
targets = struct('type', 'car', 'range_m', 22.5, 'velocity_mps', 18.0, 'gain', 0.05);

mcs_list   = [0, 3, 7, 11];
mcs_labels = {'MCS 0 (BPSK)', 'MCS 3 (16-QAM)', 'MCS 7 (64-QAM)', 'MCS 11 (1024-QAM)'};

n_mcs      = numel(mcs_list);
zeta_zf_dB = zeros(1, n_mcs);
pnfr_dB    = zeros(1, n_mcs);
n_sym_vec  = zeros(1, n_mcs);
psdu_vec   = zeros(1, n_mcs);

% 2. Execute standard radar pipeline across MCS indices with dynamic payload (DRY)
for i = 1:n_mcs
    mcs = mcs_list(i);

    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, mcs);
    rng(42);
    [rx_signal, fc]             = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);
    radar_data                  = step3_receiver(rx_signal, waveform, fs, fc, params, false);
    [targets_found, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc, wifi_standard, false, 1);

    zeta_zf_dB(i) = radar_data.zeta_zf_dB;
    pnfr_dB(i)    = pnfr.pnfr_dB(1);
    n_sym_vec(i)  = radar_data.n_symbols;
    psdu_vec(i)   = params.psdu_length;

    r_det = radar_data.axis_range(targets_found(1, 1));
    v_det = radar_data.axis_velocity(targets_found(1, 2));

    fprintf('  [%s] PSDU = %6d B (M = %d) | zeta_ZF = %.2f dB | PNFR = %.2f dB | Det: R = %.2f m, v = %+.2f m/s\n', ...
        mcs_labels{i}, psdu_vec(i), n_sym_vec(i), zeta_zf_dB(i), pnfr_dB(i), r_det, v_det);
end

fprintf('  ZF noise enhancement rise (MCS 0 -> MCS 11): %+.2f dB\n', zeta_zf_dB(end) - zeta_zf_dB(1));
fprintf('  Target contrast PNFR drop (MCS 0 -> MCS 11): %+.2f dB\n', pnfr_dB(end) - pnfr_dB(1));

% 3. Plot dual Y-axis chart (yyaxis) with synchronized 1:1 dB grid lines
fig = figure('Name', 'Figure 4.3 - Modulation Order MCS vs ZF Noise Enhancement and PNFR', ...
    'Color', 'white', 'Position', [100, 100, 860, 560], 'Visible', 'off');

color_left  = [0.0000, 0.4470, 0.7410]; % Blue (zeta_ZF)
color_right = [0.8500, 0.3250, 0.0980]; % Orange-Red (PNFR)

% Left Y-axis: ZF Noise Enhancement Factor zeta_ZF [dB] (1 dB per grid line)
yyaxis left;
p1 = plot(mcs_list, zeta_zf_dB, '-o', ...
    'Color', color_left, 'MarkerFaceColor', color_left, ...
    'LineWidth', 2.0, 'MarkerSize', 7.5, ...
    'DisplayName', sprintf('Współczynnik wzmocnienia szumu %c_ZF [dB]', char(950)));
ylabel(sprintf('Współczynnik wzmocnienia szumu %c_ZF [dB]', char(950)), ...
    'FontSize', 11, 'Interpreter', 'none');
ylim([-0.4, 7.4]);
yticks(0:1:7);
ax = gca;
ax.YColor = color_left;

% Right Y-axis: Target Contrast PNFR [dB] (synchronized 1 dB per grid line)
yyaxis right;
p2 = plot(mcs_list, pnfr_dB, '-s', ...
    'Color', color_right, 'MarkerFaceColor', color_right, ...
    'LineWidth', 2.0, 'MarkerSize', 7.5, ...
    'DisplayName', 'Kontrast celu PNFR [dB]');
ylabel('Kontrast celu PNFR [dB]', 'FontSize', 11, 'Interpreter', 'none');
ylim([40.6, 48.4]);
yticks(41:1:48);
ax.YColor = color_right;

% X-axis formatting and title
xlim([-0.8, 11.8]);
xticks(mcs_list);
xticklabels(mcs_labels);
xlabel('Rząd modulacji (indeks MCS)', 'FontSize', 11, 'Interpreter', 'none');
title('Wpływ rzędu modulacji MCS na wzmocnienie szumu i kontrast celu', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');

leg = legend([p1, p2], 'Location', 'southoutside', 'NumColumns', 2, ...
    'FontSize', 10, 'Interpreter', 'none');
leg.Box = 'on';

set(gca, 'FontSize', 10.5, 'LineWidth', 1.0);
grid on;
set(gca, 'GridAlpha', 0.25);

% 4. Export figure in 300 DPI
out_dir = fullfile(project_root, 'thesis', 'img', 'ch4_sim');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
out_file = fullfile(out_dir, 'rys_4_3_wzmocnienie_szumu_mcs.png');

exportgraphics(fig, out_file, 'Resolution', 300);
close(fig);

fprintf('  Figure successfully saved to: %s\n', out_file);
fprintf('=================================================================\n');
end