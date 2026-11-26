function fig = gen_fig_4_1_bandwidth_cut(show_figure, save_png)
% GEN_FIG_4_1_BANDWIDTH_CUT
% Experiment SIM-1 (E1): Range resolution limit vs. channel bandwidth.
% Figure 4.1 for Chapter 4 of the thesis:
%   1D range periodogram cuts for bandwidths B = 20, 40, 80, 160 MHz
%   (IEEE 802.11ax, MCS 0, TGax Model-C) for two close targets separated
%   by Delta_R = 3.75 m (R_1 = 15.0 m, R_2 = 18.75 m) under constant AP
%   transmit power (P_tx = 100 mW EIRP, P_N = k_B * T * B * F).
%
% Output file: thesis/img/ch4_sim/rys_4_1_przekroj_odleglosci_pasma.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.1: Bandwidth vs Range Resolution (Exp. E1)\n');
fprintf('=================================================================\n');

project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
addpath(project_root);
init_paths();

wifi_standard = '802.11ax';
channel_model = 'Model-A';
mcs           = 0;

cbw_list   = {'CBW20', 'CBW40', 'CBW80', 'CBW160'};
bw_mhz     = [20, 40, 80, 160];
delta_r_th = 3e8 ./ (2 * bw_mhz * 1e6);

% Constant AP EIRP (100 mW): default P_rx in step2_channel, receiver thermal noise P_N = k_B*T_0*B*F (NF = 7 dB)
% rises by +3.01 dB per bandwidth doubling (+9.03 dB at 160 MHz vs 20 MHz)
nf_dB     = 7.0;

r1_m = 7.50;
r2_m = 11.25;
v_ms = 6.0;

% Human (7.5 m, RCS=1 m^2) + Car (11.25 m, RCS=10 m^2): natural ~2.3 dB balance under dual-slope
targets = [ ...
    struct('range_m', r1_m, 'velocity_mps', v_ms, 'type', 'human'), ...
    struct('range_m', r2_m, 'velocity_mps', v_ms, 'type', 'car') ...
    ];

cuts_dB   = cell(1, 4);
axes_r    = cell(1, 4);
nf_2d_dB  = zeros(1, 4);
nf_cut_dB = zeros(1, 4);

for i = 1:numel(cbw_list)
    cbw = cbw_list{i};

    rng(42);
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, mcs);

    rng(23);
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, [], [], nf_dB);

    radar_data = step3_receiver(rx_signal, waveform, fs, fc, params);
    [~, ~, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc, wifi_standard);

    P_map = radar_data.Per_F;
    [~, max_idx] = max(P_map(:));
    [~, dop_col] = ind2sub(size(P_map), max_idx);

    cut_lin    = P_map(:, dop_col);
    max_val    = max(cut_lin);
    cuts_dB{i} = 10 * log10(cut_lin / max_val + 1e-12);
    axes_r{i}  = radar_data.axis_range;

    nf_cut_dB(i) = 10 * log10(median(cut_lin(axes_r{i} >= 25 & axes_r{i} <= 45)) / max_val);
    nf_2d_dB(i)  = 10 * log10(median(P_map(:)) / max_val);

    mask_roi = axes_r{i} <= 20;
    [pks, locs] = findpeaks(cuts_dB{i}(mask_roi), axes_r{i}(mask_roi), ...
        'MinPeakProminence', 0.05, 'MinPeakHeight', -15);
    dip_val = 0;
    if numel(locs) >= 2
        idx1 = find(axes_r{i} >= locs(1), 1);
        idx2 = find(axes_r{i} >= locs(2), 1);
        dip_val = min(cuts_dB{i}(idx1:idx2)) - min(pks(1:2));
    end
        fprintf('  [%s] Delta_R_th = %.2f m | Peaks in ROI: %d at %s m (dip = %.2f dB) | NF_2D = %.1f dB, NF_cut = %.1f dB (PNFR1 = %.1f dB)\n', ...
        cbw, delta_r_th(i), numel(pks), mat2str(round(locs, 2)), ...
        dip_val, nf_2d_dB(i), nf_cut_dB(i), pnfr.pnfr_dB(1));
end

fprintf('  Noise floor rise (160 MHz vs 20 MHz): %+.2f dB (2D map), %+.2f dB (1D cut)\n', ...
    nf_2d_dB(4) - nf_2d_dB(1), nf_cut_dB(4) - nf_cut_dB(1));

fig = figure('Name', 'Figure 4.1 - Range Resolution vs Bandwidth', ...
    'Color', 'white', 'Position', [100, 100, 860, 540], 'Visible', 'off');

colors = [ ...
    0.0000, 0.4470, 0.7410; ...
    0.8500, 0.3250, 0.0980; ...
    0.4660, 0.6740, 0.1880; ...
    0.6350, 0.0780, 0.1840  ...
    ];
line_styles = {'-', '-', '-', '-'};
line_widths = [1.8, 1.8, 1.8, 2.1];

hold on;
for i = 1:4
    leg_str = sprintf('%d MHz', bw_mhz(i));
    plot(axes_r{i}, cuts_dB{i}, ...
        'Color', colors(i, :), ...
        'LineStyle', line_styles{i}, ...
        'LineWidth', line_widths(i), ...
        'DisplayName', leg_str);
end

xline(r1_m, ':k', 'LineWidth', 1.4, 'DisplayName', 'Cel 1 (7,5 m)');
xline(r2_m, '--k', 'LineWidth', 1.2, 'DisplayName', 'Cel 2 (11,25 m)');
hold off;

xlim([0, 45]);
ylim([-55, 3]);

title('Wpływ szerokości pasma na rozdzielczość odległościową', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Odległość bistatyczna [m]', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'Interpreter', 'none');

leg = legend('Location', 'northeast', 'FontSize', 10, 'Interpreter', 'none');
leg.Box = 'on';

set(gca, 'FontSize', 10.5, 'LineWidth', 1.0, 'Box', 'on');
grid on; box on;
set(gca, 'GridAlpha', 0.25);

save_thesis_figure(fig, 'ch4_sim', 'rys_4_1_przekroj_odleglosci_pasma.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
