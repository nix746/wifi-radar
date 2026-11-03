function gen_fig_3_2_range_doppler()
% GEN_FIG_3_2_RANGE_DOPPLER
% Experiment IMPL-2: 2D Range-Doppler periodogram map P_Per(R, v).
% Figure 3.2 for Chapter 3 of the thesis:
%   2D Range-Doppler periodogram computed with 2D Blackman-Harris windowing
%   (-92 dB sidelobe suppression) for IEEE 802.11ax in a multipath channel
%   with two moving targets (pedestrian and vehicle).
%
% Output file: thesis/img/ch3_impl/rys_3_2_mapa_range_doppler.png

fprintf('=================================================================\n');
fprintf('  Generating Fig. 3.2: 2D Range-Doppler Map (Experiment IMPL-2)\n');
fprintf('=================================================================\n');

% 1. Initialize project paths and random seed
init_paths();
rng(7); % Deterministic seed where Model-C direct path (LOS) locks at tap 0

wifi_standard = '802.11ax';
cbw = 'CBW80';
channel_model = 'Model-C';
snr_dB = 25;

% 2. Generate transmitted baseband waveform (step1_transmitter)
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, 11);

% 3. Simulate multipath TGax channel with two moving targets (step2_channel)
targets = [ ...
    struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
    struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
    ];
[rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

% 4. Run receiver pipeline (step3_receiver) and CLEAN interpreter (step4_interpreter)
radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, false);
[targets_found, ~, ~, pnfr] = step4_interpreter(radar_data, fs, fc, wifi_standard, false, 2);

% 5. Extract periodogram and physical axes from radar_data
CPer_base = radar_data.CPer_base;
axis_range = radar_data.axis_range;
axis_velocity = radar_data.axis_velocity;

% Normalized power periodogram [dB] (0 dB at global maximum)
P_lin = abs(CPer_base).^2;
Per_norm_dB = 10 * log10(P_lin / max(P_lin(:)) + 1e-12);

% Numerical verification of sidelobe/background suppression and target velocities
noise_floor_norm_dB = 10 * log10(median(P_lin(:)) / max(P_lin(:)));
min_sidelobe_dB = prctile(Per_norm_dB(:), 5);
fprintf('  Median background level:   %.1f dB (5th percentile: %.1f dB)\n', ...
    noise_floor_norm_dB, min_sidelobe_dB);
for i = 1:size(targets_found, 1)
    r_det = axis_range(targets_found(i, 1));
    v_det = axis_velocity(targets_found(i, 2));
    fprintf('  Detected Target %d: R = %.2f m, v = %+.2f m/s (|v| <= 27.8 m/s: %d), PNFR = %.1f dB\n', ...
        i, r_det, v_det, abs(v_det) <= 27.78, pnfr.pnfr_dB(i));
end

% 6. Plot 2D Range-Doppler Map
fig = figure('Name', 'Figure 3.2 - 2D Range-Doppler Periodogram', ...
    'Color', 'white', 'Position', [100, 100, 820, 580], 'Visible', 'off');

imagesc(axis_velocity, axis_range, Per_norm_dB);
axis xy;
colormap(gca, 'parula');
clim([-65, 0]);

cbar = colorbar;
cbar.Label.String = 'Moc znormalizowana [dB]';
cbar.Label.FontSize = 11;
cbar.Label.Interpreter = 'none';

% Focus view on physical indoor/urban radar region
xlim([-60, 60]);
ylim([0, 120]);

hold on;
if ~isempty(targets_found)
    det_v = axis_velocity(targets_found(:, 2));
    det_r = axis_range(targets_found(:, 1));
    plot(det_v, det_r, 'ro', 'MarkerSize', 11, 'LineWidth', 2.0, 'DisplayName', 'Wykryte cele');
    legend('Location', 'northeast', 'FontSize', 10.5, 'Interpreter', 'none');
end
hold off;

title('Dwuwymiarowa mapa periodogramu Range-Doppler', ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
xlabel('Prędkość radialna [m/s]', 'FontSize', 11, 'Interpreter', 'none');
ylabel('Odległość bistatyczna [m]', 'FontSize', 11, 'Interpreter', 'none');

set(gca, 'FontSize', 10.5, 'LineWidth', 1.0);
grid on;
set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.3);

% 7. Export figure in 300 DPI
[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
out_dir = fullfile(project_root, 'thesis', 'img', 'ch3_impl');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
out_file = fullfile(out_dir, 'rys_3_2_mapa_range_doppler.png');

exportgraphics(fig, out_file, 'Resolution', 300);
fprintf('  Figure saved to: %s\n', out_file);
close(fig);
fprintf('=================================================================\n');
end

