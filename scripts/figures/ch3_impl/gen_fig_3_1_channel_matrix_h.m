function fig = gen_fig_3_1_channel_matrix_h(show_figure, save_png)
% GEN_FIG_3_1_CHANNEL_MATRIX_H
% Experiment IMPL-1: Channel transfer matrix H(k,l) in the time-frequency domain.
% Figure 3.1 for Chapter 3 of the thesis (IEEE 802.11ax, CBW80, TGax Model-C):
%   (a) Raw transfer matrix before MTI (showing DPI crosstalk, multipath fading, and DC gap)
%   (b) Transfer matrix after slow-time MTI filtering and linear DC interpolation
%
% Output file: thesis/img/ch3_impl/rys_3_1_macierz_transmitancji_h.png

    if nargin < 1 || isempty(show_figure), show_figure = true; end
    if nargin < 2 || isempty(save_png),    save_png    = true; end

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 3.1: Channel matrix H (802.11ax, CBW80)\n');
    fprintf('=================================================================\n');

    % 1. Initialize project paths and random number generator seed
    project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    addpath(project_root);
    init_paths();
    rng(42); % Ensure repeatability of noise and random payload data

    wifi_standard = '802.11ax';
    cbw           = 'CBW80';
    channel_model = 'Model-C';

    % Realistic Wi-Fi SNR (25 dB, matching Figs. 3.2 & 3.3)
    snr_dB = 25;

    % 2. Generate transmitted baseband waveform (IEEE 802.11ax HE-SU, CBW80)
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, cbw, 0);

    % 3. Simulate multipath TGax channel with two moving targets (matching Figs. 3.2 & 3.3)
    rng(23); % Deterministic seed where Model-C LOS locks at intrinsic delay (0 m bias)
    targets = [ ...
        struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
        struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
    ];
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

    % 4. Run receiver pipeline (step3_receiver) directly
    radar_data = step3_receiver(rx_signal, waveform, fs, fc, params);
    H_raw     = radar_data.H_raw;
    H_proc    = radar_data.H_shifted;
    n_symbols = radar_data.n_symbols;
    Nfft      = radar_data.Nfft;

    % 5. Numerical validation of direct path (DPI) suppression
    static_component_raw  = mean(H_raw, 2);
    static_component_proc = mean(H_proc, 2);
    p_static_raw  = mean(abs(static_component_raw(params.active_mask > 0)).^2);
    p_static_proc = mean(abs(static_component_proc(params.active_mask > 0)).^2);

    suppression_dpi_dB  = 10 * log10(p_static_raw / max(p_static_proc, 1e-15));
    total_power_raw_dB  = 10 * log10(mean(abs(H_raw(:)).^2));
    total_power_proc_dB = 10 * log10(mean(abs(H_proc(:)).^2));
    total_drop_dB       = total_power_raw_dB - total_power_proc_dB;

    fprintf('  Total power before MTI:    %+.2f dB\n', total_power_raw_dB);
    fprintf('  Total power after MTI:     %+.2f dB (drop of %.2f dB)\n', total_power_proc_dB, total_drop_dB);
    fprintf('  Static component suppress: > %.1f dB (MTI eliminates DPI)\n', min(suppression_dpi_dB, 120));

    % 6. Full centered subcarrier range (including guard bands and DC nulls: -Nfft/2 .. +Nfft/2-1)
    k_range = (-Nfft/2) : (Nfft/2 - 1);

    % Convert magnitude to decibel scale [dB]
    H_raw_dB  = 20 * log10(abs(H_raw) + 1e-9);
    H_proc_dB = 20 * log10(abs(H_proc) + 1e-9);

    fprintf('  H_raw_dB percentiles [1, 5, 50, 95, 99, max]:  [%.1f, %.1f, %.1f, %.1f, %.1f, %.1f] dB\n', ...
        prctile(H_raw_dB(:), 1), prctile(H_raw_dB(:), 5), median(H_raw_dB(:)), ...
        prctile(H_raw_dB(:), 95), prctile(H_raw_dB(:), 99), max(H_raw_dB(:)));
    fprintf('  H_proc_dB percentiles [1, 5, 50, 95, 99, max]: [%.1f, %.1f, %.1f, %.1f, %.1f, %.1f] dB\n', ...
        prctile(H_proc_dB(:), 1), prctile(H_proc_dB(:), 5), median(H_proc_dB(:)), ...
        prctile(H_proc_dB(:), 95), prctile(H_proc_dB(:), 99), max(H_proc_dB(:)));

    % 7. Two-panel plot for the thesis
    fig = figure('Name', 'Figure 3.1 - Channel Transfer Matrix H(k,l) (CBW80)', ...
        'Color', 'white', 'Position', [100, 100, 1260, 560], 'Visible', 'off');

    sym_axis = 1:n_symbols;

    % Panel (a): Raw transfer matrix before MTI filtering
    subplot(1, 2, 1);
    imagesc(sym_axis, k_range, H_raw_dB);
    axis xy;
    colormap(gca, 'parula');
    clim([-30, 8]); % Color limits highlighting multipath fading dips and DC notch
    c1 = colorbar;
    c1.Label.String = 'Moc transmitancji [dB]';
    c1.Label.FontSize = 10.5;
    c1.Label.Interpreter = 'none';

    title('a) Przed MTI', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Numer symbolu OFDM (czas wolny)', 'FontSize', 11, 'Interpreter', 'none');
    ylabel('Indeks podnośnej k (częstotliwość)', 'FontSize', 11, 'Interpreter', 'none');
    set(gca, 'FontSize', 10, 'LineWidth', 1.0, 'Box', 'on');
    grid on; box on;
    set(gca, 'GridColor', [1 1 1], 'GridAlpha', 0.25);

    % Panel (b): Transfer matrix after MTI filtering and DC interpolation
    subplot(1, 2, 2);
    imagesc(sym_axis, k_range, H_proc_dB);
    axis xy;
    colormap(gca, 'parula');
    clim([-40, -16]); % Color limits matched to post-MTI amplitude distribution at 25 dB SNR
    c2 = colorbar;
    c2.Label.String = 'Moc transmitancji [dB]';
    c2.Label.FontSize = 10.5;
    c2.Label.Interpreter = 'none';

    title('b) Po MTI i interpolacji DC', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
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
