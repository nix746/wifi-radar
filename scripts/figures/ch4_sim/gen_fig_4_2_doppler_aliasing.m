function fig = gen_fig_4_2_doppler_aliasing(show_figure, save_png)
% GEN_FIG_4_2_DOPPLER_ALIASING
% Experiment SIM-2 (E2): Unambiguous velocity limit comparison (802.11a vs 802.11ax).
% Figure 4.2 for Chapter 4 of the thesis:
%   1D Doppler velocity profile cut on a single plot for a fast moving vehicle target
%   (v = +20.0 m/s = 72 km/h, R = 12.0 m) in a flat-fading channel (Model-A),
%   comparing IEEE 802.11a (T_sym = 4.0 us, v_unamb = +/-56.8 m/s) against
%   IEEE 802.11ax (T_sym = 13.6 us, v_unamb = +/-16.7 m/s) across each standard's
%   actual unambiguous Doppler interval. Shows Doppler aliasing in 802.11ax folding
%   the echo to v_alias = -13.4 m/s while 802.11a resolves the true velocity (+20.0 m/s).
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

cbw           = 'CBW20';
mcs           = 0;
channel_model = 'Model-A';

% Physical carrier frequency and slow-time CPI subsampling factor k_pri (T_PRI = k_pri * T_sym)
fc_base = 5.5e9;
k_pri   = 60;

r_true_m  = 12.0;
v_true_ms = 20.0;
targets   = struct('type', 'car', 'range_m', r_true_m, 'velocity_mps', v_true_ms);

standards = {'802.11a', '802.11ax'};
cuts_dB   = cell(1, 2);
axes_v    = cell(1, 2);
v_unamb   = zeros(1, 2);
v_det     = zeros(1, 2);
r_det     = zeros(1, 2);

for i = 1:numel(standards)
    std_name = standards{i};
    rng(42);
    [waveform, fs, params, cfg]      = step1_transmitter(std_name, cbw, mcs);
    [rx_signal, fc, intrinsic_delay] = step2_channel(waveform, fs, channel_model, cfg, targets, [], fc_base, [], k_pri);
    radar_data                       = step3_receiver(rx_signal, waveform, fs, fc, params, [], k_pri, intrinsic_delay);
    targets_det                      = step4_interpreter(radar_data, fs, fc, [], [], [], false);

    r_idx   = targets_det(1).r_idx;
    v_idx   = targets_det(1).d_idx;
    P_slice = radar_data.Per_F(r_idx, :);

    cuts_dB{i} = 10 * log10(P_slice + 1e-12);
    axes_v{i}  = radar_data.axis_velocity;
    v_unamb(i) = abs(axes_v{i}(1));
    v_det(i)   = axes_v{i}(v_idx);
    r_det(i)   = radar_data.axis_range(r_idx);

    fprintf('  [%s] T_sym = %.1f us (k_PRI=%d) | v_unamb = +/-%.2f m/s | Detected: R = %.2f m, v = %+.2f m/s | Peak = %+.1f dB\n', ...
        std_name, (params.Nfft + params.Ncp) / fs * 1e6, k_pri, v_unamb(i), ...
        r_det(i), v_det(i), max(cuts_dB{i}));
end

v_alias_th = v_true_ms - 2 * v_unamb(2);
fprintf('  Theoretical aliased velocity in 802.11ax: %.2f - 2 * %.2f = %.2f m/s (measured: %.2f m/s)\n', ...
    v_true_ms, v_unamb(2), v_alias_th, v_det(2));

v_lim_a = v_unamb(1);

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

h_true = xline(v_true_ms, ':', 'Color', color_true, 'LineWidth', 1.6, ...
    'DisplayName', sprintf('Prędkość rzeczywista celu (+%s m/s)', strrep(sprintf('%.1f', v_true_ms), '.', ',')));

p_a = plot(axes_v{1}, cuts_dB{1}, '-', 'Color', color_a, 'LineWidth', 1.4, ...
    'DisplayName', 'IEEE 802.11a (T_sym = 4,0 µs)');
p_ax = plot(axes_v{2}, cuts_dB{2}, '-', 'Color', color_ax, 'LineWidth', 1.4, ...
    'DisplayName', 'IEEE 802.11ax (T_sym = 13,6 µs)');
hold off;

xlim([-v_lim_a, v_lim_a]);
ylim([-62, 26]);

v_lim_str = strrep(sprintf('%.1f', v_lim_a), '.', ',');
title(sprintf('Profile Dopplera w przedziale jednoznaczności IEEE 802.11a (±%s m/s)', v_lim_str), ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Prędkość radialna [m/s]', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Moc profilu Dopplera [dB]', 'FontSize', 11, 'Interpreter', 'none');

leg = legend([p_a, p_ax, h_true, h_bound], ...
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