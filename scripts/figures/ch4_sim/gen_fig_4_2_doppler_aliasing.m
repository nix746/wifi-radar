function fig = gen_fig_4_2_doppler_aliasing(show_figure, save_png)
% GEN_FIG_4_2_DOPPLER_ALIASING
% Experiment SIM-2 (E2): Unambiguous velocity limit comparison (802.11a vs 802.11ax).
% Figure 4.2 for Chapter 4 of the thesis:
%   Integrated 1D Doppler velocity profile cut on a single plot for a fast moving vehicle target
%   (v = +20.0 m/s = 72 km/h, R = 30.0 m) in a flat-fading channel (Model-A),
%   comparing IEEE 802.11a (T_sym = 4.0 us, v_unamb = +/-56.8 m/s) against
%   IEEE 802.11ax (T_sym = 13.6 us, v_unamb = +/-16.7 m/s) across the 802.11a
%   unambiguous Doppler window (+/-56.8 m/s). Shows Doppler aliasing in 802.11ax
%   folding the echo to v_alias = -13.4 m/s in its fundamental interval, while
%   both standards exhibit a peak at the true velocity (+20.0 m/s).
%
% Output file: thesis/img/ch4_sim/rys_4_2_aliasing_dopplera.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.2: Doppler Velocity Aliasing (Exp. E2)\n');
fprintf('=================================================================\n');

[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();
rng(42);

cbw           = 'CBW20';
mcs           = 0;
channel_model = 'Model-A';

% Physical carrier frequency and effective slow-time CPI subsampling factor k_pri
fc_base = 5.5e9;
k_pri   = 60;
fc_eff  = k_pri * fc_base;

r_true_m  = 12.0;
v_true_ms = 20.0;
targets   = struct('type', 'car', 'range_m', r_true_m, ...
    'velocity_mps', k_pri * v_true_ms);

standards = {'802.11a', '802.11ax'};
cuts_dB   = cell(1, 2);
axes_v    = cell(1, 2);
v_unamb   = zeros(1, 2);
v_det     = zeros(1, 2);
r_det     = zeros(1, 2);
pnfr_dB   = zeros(1, 2);
nf_cut_dB = zeros(1, 2);

for i = 1:numel(standards)
    std_name = standards{i};
    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(std_name, cbw, mcs);
    [rx_signal, ~]              = step2_channel(waveform, fs, channel_model, cfg, targets, [], fc_base);
    radar_data                  = step3_receiver(rx_signal, waveform, fs, fc_eff, params);
    [targets_det, ~, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc_eff, std_name);

    r_idx   = targets_det(1).r_idx;
    v_idx   = targets_det(1).d_idx;
    P_slice = radar_data.Per_F(r_idx, :);

    cuts_dB{i}   = 10 * log10(P_slice + 1e-12);
    axes_v{i}    = radar_data.axis_velocity;
    v_unamb(i)   = abs(axes_v{i}(1));
    v_det(i)     = axes_v{i}(v_idx);
    r_det(i)     = radar_data.axis_range(r_idx);
    pnfr_dB(i)   = pnfr.pnfr_dB(1);
    nf_cut_dB(i) = 10 * log10(median(P_slice) + 1e-12);

    fprintf('  [%s] T_sym = %.1f us | v_unamb = +/-%.2f m/s | Detected: R = %.2f m, v = %+.2f m/s | NF_cut = %.1f dB, PNFR = %.1f dB\n', ...
        std_name, (params.Nfft + params.Ncp) / fs * 1e6, v_unamb(i), ...
        r_det(i), v_det(i), nf_cut_dB(i), pnfr_dB(i));
end

v_alias_th = v_true_ms - 2 * v_unamb(2);
fprintf('  Theoretical aliased velocity in 802.11ax: %.2f - 2 * %.2f = %.2f m/s (measured: %.2f m/s)\n', ...
    v_true_ms, v_unamb(2), v_alias_th, v_det(2));

% Periodic extension of 802.11ax across 802.11a unambiguous window [-v_lim_a, +v_lim_a]
v_lim_a     = v_unamb(1);
T_v2        = 2 * v_unamb(2);
k_rep       = (-2:2).';
v_ax_full   = reshape((axes_v{2} + k_rep * T_v2).', 1, []);
cut_ax_full = repmat(cuts_dB{2}, 1, numel(k_rep));

[v_ax_sorted, sort_idx] = sort(v_ax_full);
cut_ax_sorted = cut_ax_full(sort_idx);
mask_ax       = (v_ax_sorted >= -v_lim_a) & (v_ax_sorted <= v_lim_a);
v_ax_plot     = v_ax_sorted(mask_ax);
cut_ax_plot   = cut_ax_sorted(mask_ax);

fig = figure('Name', 'Figure 4.2 - Doppler Velocity Aliasing (802.11a vs 802.11ax)', ...
    'Color', 'white', 'Position', [100, 100, 920, 500], 'Visible', 'off');
hold on;

color_a     = [0.0000, 0.4470, 0.7410];
color_ax    = [0.8500, 0.3250, 0.0980];
color_true  = [0.1330, 0.5450, 0.1330];
color_bound = [0.4500, 0.4500, 0.4500];

xline(-v_unamb(2), '-.', 'Color', color_bound, 'LineWidth', 1.2, 'HandleVisibility', 'off');
h_bound = xline(+v_unamb(2), '-.', 'Color', color_bound, 'LineWidth', 1.2, ...
    'DisplayName', sprintf('Granice jednoznaczności 802.11ax (±%s m/s)', strrep(sprintf('%.1f', v_unamb(2)), '.', ',')));

h_true = xline(v_true_ms, ':', 'Color', color_true, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('Prędkość rzeczywista celu (+%s m/s)', strrep(sprintf('%.1f', v_true_ms), '.', ',')));

p_a = plot(axes_v{1}, cuts_dB{1}, '-', 'Color', color_a, 'LineWidth', 1.3, ...
    'DisplayName', 'IEEE 802.11a (T_sym = 4,0 µs)');
p_ax = plot(v_ax_plot, cut_ax_plot, '-', 'Color', color_ax, 'LineWidth', 1.3, ...
    'DisplayName', 'IEEE 802.11ax (T_sym = 13,6 µs)');
hold off;

xlim([-v_lim_a, v_lim_a]);
ylim([-62, 26]);

v_lim_str = strrep(sprintf('%.1f', v_lim_a), '.', ',');
title(sprintf('Profile Dopplera w przedziale jednoznaczności IEEE 802.11a (±%s m/s)', v_lim_str), ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Prędkość radialna [m/s]', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Moc profilu Dopplera [dB]', 'FontSize', 11, 'Interpreter', 'none');

leg = legend([p_ax, p_a, h_true, h_bound], ...
    {'IEEE 802.11ax (T_sym = 13,6 µs)', ...
    'IEEE 802.11a (T_sym = 4,0 µs)', ...
    sprintf('Prędkość rzeczywista celu (+%s m/s)', strrep(sprintf('%.1f', v_true_ms), '.', ',')), ...
    sprintf('Granice jednoznaczności 802.11ax (±%s m/s)', strrep(sprintf('%.1f', v_unamb(2)), '.', ','))}, ...
    'Location', 'southoutside', 'NumColumns', 2, 'FontSize', 9.5, 'Interpreter', 'none');
leg.Box = 'on';

set(gca, 'FontSize', 10.5, 'LineWidth', 1.0, 'Box', 'on');
grid on; box on;
set(gca, 'GridAlpha', 0.25);

save_thesis_figure(fig, 'ch4_sim', 'rys_4_2_aliasing_dopplera.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end