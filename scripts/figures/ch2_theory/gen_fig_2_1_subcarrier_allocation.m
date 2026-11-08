function gen_fig_2_1_subcarrier_allocation()
% GEN_FIG_2_1_SUBCARRIER_ALLOCATION
% Figure 2.1 for Chapter 2 of the thesis: subcarrier allocation in the
% data field of IEEE 802.11a (Non-HT) and IEEE 802.11ax (HE-SU, CBW20):
%   (a) 802.11a, 64-point FFT (48 data, 4 pilots, 1 DC null, 6/5 guard)
%   (b) 802.11ax CBW20, 256-point FFT (234 data, 8 pilots, 3 DC nulls, 6/5 guard)
%   (c) 802.11ax CBW20, zoom around the DC nulls
%
% Output file: thesis/img/ch2_theory/rys_2_1_alokacja_podnosnych.png

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 2.1: Subcarrier allocation (802.11a vs 802.11ax)\n');
    fprintf('=================================================================\n');

    init_paths();

    % 1. IEEE 802.11a (Non-HT, 20 MHz): fixed allocation from the standard
    Nfft_a   = 64;
    k_a      = -Nfft_a/2 : Nfft_a/2 - 1;
    pilots_a = [-21, -7, 7, 21];
    active_a = [-26:-1, 1:26];
    [data_a, dc_a, guard_a] = classify(k_a, active_a, pilots_a);

    % 2. IEEE 802.11ax (HE-SU, CBW20): allocation queried from WLAN Toolbox
    cfg = wlanHESUConfig('ChannelBandwidth', 'CBW20');
    ofdminfo = wlanHEOFDMInfo('HE-Data', cfg);
    Nfft_ax   = ofdminfo.FFTLength;
    k_ax      = -Nfft_ax/2 : Nfft_ax/2 - 1;
    active_ax = ofdminfo.ActiveFrequencyIndices(:).';
    pilots_ax = active_ax(ofdminfo.PilotIndices);
    [data_ax, dc_ax, guard_ax] = classify(k_ax, active_ax, pilots_ax);

    fprintf('  802.11a : %d data, %d pilots, %d DC nulls, %d guard\n', ...
        numel(data_a), numel(pilots_a), numel(dc_a), numel(guard_a));
    fprintf('  802.11ax: %d data, %d pilots, %d DC nulls, %d guard\n', ...
        numel(data_ax), numel(pilots_ax), numel(dc_ax), numel(guard_ax));

    % 3. Three-panel plot
    fig = figure('Name', 'Figure 2.1 - Subcarrier allocation', ...
        'Color', 'white', 'Position', [100, 100, 1200, 900], 'Visible', 'off');

    subplot(3, 1, 1);
    plot_allocation(data_a, pilots_a, dc_a, guard_a, [k_a(1) - 1, k_a(end) + 1]);
    title('a) Standard 802.11a (N_FFT = 64)', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    legend({'Podnośne danych', 'Podnośne pilotowe', 'Podnośne zerowe DC', 'Pasma ochronne'}, ...
        'Location', 'eastoutside', 'FontSize', 10);

    subplot(3, 1, 2);
    plot_allocation(data_ax, pilots_ax, dc_ax, guard_ax, [k_ax(1) - 2, k_ax(end) + 2]);
    title('b) Standard 802.11ax, CBW20 (N_FFT = 256)', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    legend({'Podnośne danych', 'Podnośne pilotowe', 'Podnośne zerowe DC', 'Pasma ochronne'}, ...
        'Location', 'eastoutside', 'FontSize', 10);

    subplot(3, 1, 3);
    plot_allocation(data_ax, pilots_ax, dc_ax, guard_ax, [-12, 12]);
    title('c) Standard 802.11ax, CBW20 - otoczenie podnośnej DC', 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    legend({'Podnośne danych', 'Podnośne pilotowe', 'Podnośne zerowe DC', 'Pasma ochronne'}, ...
        'Location', 'eastoutside', 'FontSize', 10);

    sgtitle('Alokacja podnośnych w polu danych ramki Wi-Fi', ...
        'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'none');

    % 4. Export (300 DPI)
    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    out_dir = fullfile(project_root, 'thesis', 'img', 'ch2_theory');
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
    out_file = fullfile(out_dir, 'rys_2_1_alokacja_podnosnych.png');
    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('  Figure saved to: %s\n', out_file);
    close(fig);
    fprintf('=================================================================\n');
end

function [data, dc, guard] = classify(k_all, active, pilots)
% Split subcarrier indices into data, internal (DC) nulls and edge guard bands.
    data     = setdiff(active, pilots);
    inactive = setdiff(k_all, active);
    dc       = inactive(inactive > min(active) & inactive < max(active));
    guard    = setdiff(inactive, dc);
end

function plot_allocation(data, pilots, dc, guard, x_lim)
% Stem plot: active subcarriers at unit modulus, null subcarriers marked at zero.
    hold on;
    stem(data,   ones(size(data)),   'Color', [0.00 0.45 0.74], 'LineWidth', 1.5, 'Marker', 'none');
    stem(pilots, ones(size(pilots)), 'Color', [0.85 0.33 0.10], 'LineWidth', 2.5, 'Marker', 'o', ...
        'MarkerFaceColor', [0.85 0.33 0.10], 'MarkerSize', 5);
    plot(dc,    zeros(size(dc)),    'kx', 'LineWidth', 2.0, 'MarkerSize', 9);
    plot(guard, zeros(size(guard)), 'x', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0, 'MarkerSize', 7);
    hold off;
    xlim(x_lim);
    ylim([-0.2, 1.3]);
    yticks([0, 1]);
    xlabel('Indeks podnośnej k', 'FontSize', 11, 'Interpreter', 'none');
    ylabel('Moduł |X(k)| [-]', 'FontSize', 11, 'Interpreter', 'none');
    set(gca, 'FontSize', 10, 'LineWidth', 1.0);
    grid on;
    set(gca, 'GridAlpha', 0.2);
end

