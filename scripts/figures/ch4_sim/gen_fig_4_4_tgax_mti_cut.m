function gen_fig_4_4_tgax_mti_cut()
% GEN_FIG_4_4_TGAX_MTI_CUT
% Eksperyment SIM-4 (E4): Wpływ otoczenia wielodrogowego TGax (Modele A, C, E)
% i tłumienie clutteru stacjonarnego przez filtr MTI w czasie wolnym.
%
% Rysunek 4.4 do Rozdziału 4 pracy dyplomowej:
%   Sześciopanelowe zestawienie dwuwymiarowych map Range–Doppler (siatka 3x2)
%   ze wspólną, bezwzględną skalą mocy w decybelach (0 dB = przesłuch DPI),
%   ukazujące bezpośrednio stopień stłumienia przesłuchu i echa stacjonarnego:
%     Kolumny:
%       - Kolumna 1: Przed MTI (przesłuch DPI i clutter stacjonarny przy 0 dB)
%       - Kolumna 2: Po MTI (spadek mocy składowej stałej o >45-50 dB do poziomu szumu)
%     Wiersze:
%       - Wiersz 1: Model-A (komora bezechowa / brak wielodrogi, tau_rms = 0 ns)
%       - Wiersz 2: Model-C (środowisko biurowe / umiarkowana wielodrożność, tau_rms = 30 ns)
%       - Wiersz 3: Model-E (hala przemysłowa / duża wielodrożność, tau_rms = 100 ns)
%
%   Skala i zakresy:
%     Prędkość radialna: [-20, +20] m/s.
%     Odległość: [0, 25] m.
%     Paleta barwna: klasyczna radarowa 'jet' ze wspólnym zakresem [-90, 0] dB.
%
% Plik wynikowy: thesis/img/ch4_sim/rys_4_4_tlumienie_clutteru_mti.png

fprintf('=================================================================\n');
fprintf('  Generowanie Rys. 4.4: Mapy 2D TGax (wspolna skala wzgledem DPI)\n');
fprintf('=================================================================\n');

% 1. Inicjalizacja ścieżek projektu
[script_path, ~, ~] = fileparts(mfilename('fullpath'));
project_root = fullfile(script_path, '..', '..', '..');
addpath(project_root);
init_paths();

wifi_standard = '802.11ax';
cbw           = 'CBW80';
mcs           = 0;
snr_dB        = 30.0;

% Cel testowy: pojazd / rowerzysta w strefie wielodrogi (R = 10.0 m, v = +8.0 m/s)
r_target_m    = 10.0;
v_target_mps  = 8.0;
target        = struct('type', 'car', 'range_m', r_target_m, ...
    'velocity_mps', v_target_mps, 'gain', 0.025);

% Standaryzowana triada modeli kanału IEEE 802.11ax TGax
models = {'Model-A', 'Model-C', 'Model-E'};
model_labels = { ...
    'Model-A (\tau_{rms} = 0 ns, komora)', ...
    'Model-C (\tau_{rms} = 30 ns, biuro)', ...
    'Model-E (\tau_{rms} = 100 ns, hala)' ...
    };

% 2. Synteza wspólnego pakietu nadawczego IEEE 802.11ax
rng(42);
[waveform, fs, params, cfg] = step1_transmitter(wifi_standard, false, cbw, mcs);

C_pre_all  = cell(1, numel(models));
C_post_all = cell(1, numel(models));
axis_r     = [];
axis_v     = [];

% 3. Symulacja potoku radaru dla każdego modelu TGax (DRY)
for m = 1:numel(models)
    ch_name = models{m};
    rng(23); % Determinizm realizacji kanału
    [rx_signal, fc] = step2_channel(waveform, fs, ch_name, cfg, target, snr_dB);
    radar_data      = step3_receiver(rx_signal, waveform, fs, fc, params, false);

    if isempty(axis_r)
        axis_r = radar_data.axis_range;
        axis_v = radar_data.axis_velocity;
    end

    % Odtworzenie macierzy przed MTI z identyczną naprawą luki DC
    H_pre = radar_data.H_raw;
    dc = params.dc_indices(:).';
    if ~isempty(dc)
        gap_starts = [dc(1), dc(find(diff(dc) > 1) + 1)];
        gap_ends   = [dc(diff(dc) > 1), dc(end)];
        for g = 1:numel(gap_starts)
            idx_gap   = gap_starts(g) : gap_ends(g);
            idx_left  = idx_gap(1) - 1;
            idx_right = idx_gap(end) + 1;
            weights = (1:numel(idx_gap)).' / (numel(idx_gap) + 1);
            H_pre(idx_gap, :) = H_pre(idx_left, :) + ...
                weights .* (H_pre(idx_right, :) - H_pre(idx_left, :));
        end
    end

    % Obliczenie periodogramu przed i po MTI z identycznym oknem 2D Blackmana-Harrisa
    C_pre_all{m}  = compute_range_doppler_map(H_pre, radar_data.Nfft, radar_data.n_symbols, params.active_mask, 4, true);
    C_post_all{m} = radar_data.CPer_base;

    % Metryki kontrolne w punkcie celu i składowej stałej
    [~, r_idx]  = min(abs(axis_r - r_target_m));
    [~, v0_idx] = min(abs(axis_v - 0.0));
    [~, vt_idx] = min(abs(axis_v - v_target_mps));

    P_pre_v0  = abs(C_pre_all{m}(r_idx, v0_idx))^2;
    P_post_v0 = abs(C_post_all{m}(r_idx, v0_idx))^2;
    P_pre_vt  = abs(C_pre_all{m}(r_idx, vt_idx))^2;
    P_post_vt = abs(C_post_all{m}(r_idx, vt_idx))^2;

    notch_dB = 10 * log10(P_pre_v0 / P_post_v0);
    scr_pre  = 10 * log10(P_pre_vt / P_pre_v0);
    scr_post = 10 * log10(P_post_vt / P_post_v0);

    fprintf('  [%s @ R=%.1f m] Tlumienie MTI (v=0): %5.1f dB | SCR: %+5.1f dB -> %+5.1f dB\n', ...
        ch_name, r_target_m, notch_dB, scr_pre, scr_post);
end

% 4. Generacja wielopanelowego wykresu 3x2 w wysokiej rozdzielczości
fig = figure('Name', 'Figure 4.4 - TGax Multipath Clutter & MTI (Exp. E4)', ...
    'Color', 'white', 'Position', [50, 50, 1150, 1150], 'Visible', 'off');

sgtitle('Wpływ wielodrogowości kanału TGax i filtracji MTI na dwuwymiarowe mapy Range–Doppler', ...
    'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

% Zakresy zbliżenia: prędkość [-20, 20] m/s, odległość [0, 25] m
r_mask = axis_r >= 0 & axis_r <= 25;
r_sub  = axis_r(r_mask);
v_lim  = [-20, 20];

% WSPÓLNA NORMALIZACJA DLA WSZYSTKICH 6 PANELI:
% 0 dB = moc przesłuchu bezpośredniego (DPI) przy R = 0 m w Modelu-A
p_ref_global = max(abs(C_pre_all{1}(r_mask, :)).^2, [], 'all');

% Wspólny zakres dynamiki barwnej (clutter przy 0 dB, cel na -25 dB, szum do -90 dB)
c_dyn_range = [-100, 0];

row_letters = {'a', 'c', 'e'; 'b', 'd', 'f'};

% Geometria: dopasowane pozycje z marginesem na sgtitle
w       = 0.380;
h       = 0.235;
x_left  = 0.080;
x_right = 0.495;
y_pos   = [0.650, 0.370, 0.090];

for m = 1:numel(models)
    % --- Kolumna 1: Przed MTI ---
    ax_l = axes('Parent', fig, 'Position', [x_left, y_pos(m), w, h]);
    P_pre_dB = 10 * log10(abs(C_pre_all{m}(r_mask, :)).^2 / p_ref_global + 1e-12);
    imagesc(ax_l, axis_v, r_sub, P_pre_dB);
    axis(ax_l, 'xy');
    colormap(ax_l, 'jet');
    clim(ax_l, c_dyn_range);
    xlim(ax_l, v_lim);
    ylim(ax_l, [0, 25]);
    ylabel(ax_l, 'Odległość [m]', 'FontSize', 10, 'Interpreter', 'none');
    if m == 3
        xlabel(ax_l, 'Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
    end
    title(ax_l, sprintf('%s) %s — Przed MTI', row_letters{1, m}, model_labels{m}), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'tex');
    hold(ax_l, 'on');
    plot(ax_l, v_target_mps, r_target_m, 'wo', 'MarkerSize', 8, 'LineWidth', 1.8);
    text(ax_l, v_target_mps + 0.8, r_target_m, 'Cel', 'Color', 'white', ...
        'FontSize', 8.5, 'FontWeight', 'bold');
    hold(ax_l, 'off');
    set(ax_l, 'FontSize', 9.5, 'LineWidth', 0.9);

    % --- Kolumna 2: Po MTI (TA SAMA WSPÓLNA SKALA CO PRZED MTI!) ---
    ax_r = axes('Parent', fig, 'Position', [x_right, y_pos(m), w, h]);
    P_post_dB = 10 * log10(abs(C_post_all{m}(r_mask, :)).^2 / p_ref_global + 1e-12);
    imagesc(ax_r, axis_v, r_sub, P_post_dB);
    axis(ax_r, 'xy');
    colormap(ax_r, 'jet');
    clim(ax_r, c_dyn_range); % Identyczna skala [-65, 0] dB!
    xlim(ax_r, v_lim);
    ylim(ax_r, [0, 25]);
    if m == 3
        xlabel(ax_r, 'Prędkość radialna [m/s]', 'FontSize', 10, 'Interpreter', 'none');
    end
    title(ax_r, sprintf('%s) %s — Po MTI', row_letters{2, m}, model_labels{m}), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'tex');
    hold(ax_r, 'on');
    plot(ax_r, v_target_mps, r_target_m, 'wo', 'MarkerSize', 8, 'LineWidth', 1.8);
    text(ax_r, v_target_mps + 0.8, r_target_m, 'Cel', 'Color', 'white', ...
        'FontSize', 8.5, 'FontWeight', 'bold');
    hold(ax_r, 'off');
    set(ax_r, 'FontSize', 9.5, 'LineWidth', 0.9);
end

% Jedna wspólna, bezwzględna skala barwna dla wszystkich 6 paneli
cb = colorbar(ax_r, 'Position', [0.905, 0.090, 0.020, 0.795]);
ylabel(cb, 'Moc znormalizowana względem przesłuchu DPI [dB]', 'FontSize', 10, 'Interpreter', 'none');

% 5. Zapis grafiki w wysokiej rozdzielczości (300 DPI)
out_dir = fullfile(project_root, 'thesis', 'img', 'ch4_sim');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end
out_png = fullfile(out_dir, 'rys_4_4_tlumienie_clutteru_mti.png');
exportgraphics(fig, out_png, 'Resolution', 300);
fprintf('  Zapisano Rysunek 4.4 (300 DPI, wspolna skala wzgledem DPI) do:\n    %s\n', out_png);

close(fig);
fprintf('=================================================================\n\n');
end
