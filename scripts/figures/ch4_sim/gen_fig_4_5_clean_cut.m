function gen_fig_4_5_clean_cut()
% GEN_FIG_4_5_CLEAN_CUT
% Eksperyment SIM-5 (E5): Granica dynamiki mocy i dekonwolucja Coherent CLEAN
% z adaptacyjnym progiem tła szumowego MAD.
%
% Rysunek 4.5 do Rozdziału 4 pracy dyplomowej:
%   Przekrój odległościowy 1D (Range cut) periodogramu Range–Doppler
%   w kolumnie prędkości Dopplera badanych celów w realistycznym kanale
%   wielodrogowym TGax Model-C dla asymetrii mocy 30 dB w pasmie CBW20 (20 MHz):
%     - Cel 1 (silny, 0 dB): pojazd na odległości R_1 = 15.0 m (v = 8.0 m/s),
%     - Cel 2 (słaby, -30 dB): pieszy na odległości R_2 = 30.0 m (v = 8.0 m/s),
%       zamaskowany całkowicie pod szerokim zboczem odpowiedzi impulsowej (PSF) pojazdu.
%
%   Przebiegi na wykresie:
%     1. Sygnał surowy (przed CLEAN) - dominacja pojazdu, pieszy niewidoczny (-11.7 dB vs -31.0 dB),
%     2. Po iteracji 1 - pik pojazdu i zbocza odjęte, odsłonięty ostry pik pieszego (spadek o 19 dB),
%     3. Po iteracji 2 - usunięty również pieszy, pozostaje płaskie tło szumowe,
%     4. Pozioma linia przerywana adaptacyjnego progu MAD (T_stop).
%
% Plik wynikowy: thesis/img/ch4_sim/rys_4_5_clean_prog_adaptacyjny.png

    fprintf('=================================================================\n');
    fprintf('  Generowanie Rys. 4.5: Coherent CLEAN i próg MAD (CBW20, Exp. E5)\n');
    fprintf('=================================================================\n');

    % 1. Inicjalizacja ścieżek projektu
    [script_path, ~, ~] = fileparts(mfilename('fullpath'));
    project_root = fullfile(script_path, '..', '..', '..');
    addpath(project_root);
    init_paths();

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
    [waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, mcs);

    rng(23); % Stałe ziarno wielodrogi TGax
    [rx_signal, fc] = step2_channel(waveform, fs, channel_model, cfg, targets, snr_dB);

    radar_data = step3_receiver(rx_signal, waveform, fs, fc, params, false);

    % 3. Dekonwolucja Coherent CLEAN z adaptacyjnym progiem MAD
    % W pasmie CBW20 margines 18 dB ustala próg na poziomie -32.4 dB, idealnie rozdzielając
    % odsłonięty pik pieszego (-31.0 dB) od tła szumowo-resztkowego.
    margin_dB   = 18.0;
    max_targets = 5;
    apply_mti   = true;
    [CPer_clean, targets_found, threshold, CPer_history] = run_coherent_clean( ...
        radar_data.CPer_base, radar_data.W_2D, radar_data.N_per, radar_data.M_per, ...
        radar_data.Nfft, radar_data.n_symbols, max_targets, margin_dB, apply_mti);

    n_det = size(targets_found, 1);
    fprintf('  Liczba wykrytych celów przez adaptacyjny CLEAN: %d\n', n_det);
    for k = 1:n_det
        r_det = radar_data.axis_range(targets_found(k, 1));
        v_det = radar_data.axis_velocity(targets_found(k, 2));
        fprintf('    Cel %d: Odległość = %.2f m, Prędkość = %+.2f m/s\n', k, r_det, v_det);
    end

    % 4. Ekstrakcja przekrojów 1D w kolumnie Dopplera wykrytych obiektów
    dop_col = targets_found(1, 2);
    r_axis  = radar_data.axis_range;

    cut_raw   = abs(CPer_history{1}(:, dop_col)).^2;
    max_pwr   = max(cut_raw); % Globalna normalizacja do piku celu silnego (0 dB)

    cut_raw_dB   = 10 * log10(cut_raw / max_pwr + 1e-12);
    cut_iter1_dB = 10 * log10(abs(CPer_history{2}(:, dop_col)).^2 / max_pwr + 1e-12);
    cut_iter2_dB = 10 * log10(abs(CPer_history{3}(:, dop_col)).^2 / max_pwr + 1e-12);
    thresh_dB    = 10 * log10((threshold^2) / max_pwr + 1e-12);

    % Weryfikacja numeryczna poziomów pików
    [pk_raw, loc_raw]     = max(cut_raw_dB(r_axis <= 20));
    [pk_iter1, loc_iter1] = max(cut_iter1_dB(r_axis >= 24 & r_axis <= 36));
    r_pk_iter1            = r_axis(find(r_axis >= 24, 1) + loc_iter1 - 1);
    noise_floor_res       = median(cut_iter2_dB(r_axis >= 10 & r_axis <= 40));

    fprintf('  Pik celu 1 (pojazd): %.2f dB przy R = %.2f m\n', pk_raw, r_axis(loc_raw));
    fprintf('  Pik celu 2 (pieszy po iter 1): %.2f dB przy R = %.2f m\n', pk_iter1, r_pk_iter1);
    fprintf('  Próg adaptacyjny MAD (T_stop): %.2f dB\n', thresh_dB);
    fprintf('  Mediana szumu resztkowego po iter 2: %.2f dB\n', noise_floor_res);

    % 5. Wizualizacja przekroju 1D ze zróżnicowanymi stylami linii dla czytelności
    fig = figure('Color', 'w', 'Position', [100, 100, 850, 480], 'Visible', 'off');

    plot(r_axis, cut_raw_dB, 'Color', [0.0, 0.45, 0.74], 'LineStyle', '-', 'LineWidth', 2.0, ...
        'DisplayName', 'Sygnał surowy');
    hold on;
    plot(r_axis, cut_iter1_dB, 'Color', [0.85, 0.33, 0.10], 'LineStyle', '--', 'LineWidth', 1.8, ...
        'DisplayName', 'Po iteracji 1');
    plot(r_axis, cut_iter2_dB, 'Color', [0.47, 0.67, 0.19], 'LineStyle', ':', 'LineWidth', 1.8, ...
        'DisplayName', 'Po iteracji 2');

    yline(thresh_dB, '-.', 'Color', [0.2, 0.2, 0.2], 'LineWidth', 1.6, ...
        'DisplayName', 'Próg adaptacyjny MAD');

    hold off;

    % Ograniczenie kadru do strefy celów
    xlim([0, 45]);
    ylim([-55, 5]);

    title('Jednowymiarowy przekrój odległościowy mapy Range–Doppler – proces dekonwolucji Coherent CLEAN', ...
        'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel('Odległość bistatyczna [m]', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Moc znormalizowana [dB]', 'FontSize', 11, 'FontWeight', 'bold');

    grid on;
    set(gca, 'GridAlpha', 0.25, 'MinorGridAlpha', 0.15);
    box on;
    set(gca, 'Box', 'on', 'LineWidth', 1.1);

    legend('Location', 'southoutside', 'Orientation', 'horizontal', ...
        'FontSize', 10, 'NumColumns', 2);

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
