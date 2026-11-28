function fig = gen_fig_3_1_channel_matrix_h(show_figure, save_png)
% GEN_FIG_3_1_CHANNEL_MATRIX_H
% Experiment IMPL-1: Channel transfer matrix H(k,l) in the time-frequency domain.
% Figure 3.1 for Chapter 3 of the thesis (IEEE 802.11ax, CBW80, TGax Model-C):
%   (a) Direct channel estimate before static echo removal (showing DPI crosstalk and multipath fading)
%   (b) Transfer matrix after static echo removal (slow-time mean subtraction)
%
% Output file: thesis/img/ch3_impl/rys_3_1_macierz_transmitancji_h.png

if nargin < 1 || isempty(show_figure), show_figure = true; end
if nargin < 2 || isempty(save_png),    save_png    = true; end

fprintf('=================================================================\n');
fprintf('  Generating Fig. 3.1: Channel matrix H (802.11ax, CBW80)\n');
fprintf('=================================================================\n');

% 1. Initialize paths and deterministic seed
project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
addpath(project_root);
init_paths();
rng(42);

wifi_standard = '802.11ax';
cbw           = 'CBW80';
channel_model = 'Model-C';

% 2. Run transmitter, TGax channel, and receiver pipeline
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, 0);

rng(23); % Deterministic seed where Model-C LOS locks at intrinsic delay (0 m bias)
targets = [ ...
    struct('range_m', 7.5,  'velocity_mps', -4.0,  'type', 'human'), ...
    struct('range_m', 18.0, 'velocity_mps', +14.0, 'type', 'car') ...
    ];
[rx_signal, fc, intrinsic_delay] = step2_channel(waveform, fs, channel_model, cfg, targets);

radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, [], [], intrinsic_delay);
H_raw     = radar_data.H_raw;
H_proc    = radar_data.H_no_static;
n_symbols = radar_data.n_symbols;
Nfft      = radar_data.Nfft;

% 3. Validate DPI and static clutter suppression at v = 0 m/s on the Range-Doppler map
C_raw_rdm  = compute_range_doppler_map(H_raw, Nfft, n_symbols, params.active_mask, 4, true);
C_proc_rdm = compute_range_doppler_map(H_proc, Nfft, n_symbols, params.active_mask, 4, true);
[~, v0_idx] = min(abs(radar_data.axis_velocity));
p_v0_raw  = mean(abs(C_raw_rdm(:, v0_idx)).^2);
p_v0_proc = mean(abs(C_proc_rdm(:, v0_idx)).^2);

suppression_dpi_dB  = 10 * log10(p_v0_raw / max(p_v0_proc, 1e-15));
total_power_raw_dB  = 10 * log10(mean(abs(H_raw(:)).^2));
total_power_proc_dB = 10 * log10(mean(abs(H_proc(:)).^2));
total_drop_dB       = total_power_raw_dB - total_power_proc_dB;

fprintf('  Total power before static removal: %+.2f dB\n', total_power_raw_dB);
fprintf('  Total power after static removal:  %+.2f dB (drop of %.2f dB)\n', total_power_proc_dB, total_drop_dB);
fprintf('  Static clutter suppress (v = 0):   %.1f dB on Range-Doppler map\n', suppression_dpi_dB);

% 4. Centered subcarrier axis and magnitude in dB
k_range   = (-Nfft/2) : (Nfft/2 - 1);
H_raw_dB  = 20 * log10(abs(H_raw) + 1e-9);
H_proc_dB = 20 * log10(abs(H_proc) + 1e-9);

fprintf('  H_raw_dB [median, max]:  [%.1f, %.1f] dB\n', median(H_raw_dB(:)), max(H_raw_dB(:)));
fprintf('  H_proc_dB [median, max]: [%.1f, %.1f] dB\n', median(H_proc_dB(:)), max(H_proc_dB(:)));

% 5. Two-panel plot
fig = figure('Name', 'Figure 3.1 - Channel Transfer Matrix H(k,l) (CBW80)', ...
    'Color', 'white', 'Position', [100, 100, 1260, 560], 'Visible', 'off');

sym_axis = 1:n_symbols;

% Panel (a): Direct channel estimate before static echo removal
subplot(1, 2, 1);
imagesc(sym_axis, k_range, H_raw_dB);
axis xy;
colormap(gca, 'parula');
clim([-30, 8]); % Color limits highlighting multipath fading dips and DC notch
c1 = colorbar;
c1.Label.String = 'Moduł transmitancji |H(k,l)| [dB]';
c1.Label.FontSize = 10.5;
c1.Label.Interpreter = 'none';

title('a) Bezpośrednia estymata transmitancji (z echem stałym)', 'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Numer symbolu OFDM (czas wolny)', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Indeks podnośnej k (częstotliwość)', 'FontSize', 11, 'Interpreter', 'none');
set(gca, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
grid on; box on;
set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

% Panel (b): Transfer matrix after slow-time mean subtraction
subplot(1, 2, 2);
imagesc(sym_axis, k_range, H_proc_dB);
axis xy;
colormap(gca, 'parula');
clim([-40, -16]); % Color limits matched to post-removal amplitude distribution at 25 dB SNR
c2 = colorbar;
c2.Label.String = 'Moduł transmitancji |H(k,l)| [dB]';
c2.Label.FontSize = 10.5;
c2.Label.Interpreter = 'none';

title('b) Po odjęciu średniej czasowej', 'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Numer symbolu OFDM (czas wolny)', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Indeks podnośnej k (częstotliwość)', 'FontSize', 11, 'Interpreter', 'none');
set(gca, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
grid on; box on;
set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

% Overall figure title
sgtitle('Macierz transmitancji H(k,l) w dziedzinie czas-częstotliwość (802.11ax, CBW80)', ...
    'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

% 8. Export figure in high resolution (300 DPI) to thesis directory
save_thesis_figure(fig, 'ch3_impl', 'rys_3_1_macierz_transmitancji_h.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
