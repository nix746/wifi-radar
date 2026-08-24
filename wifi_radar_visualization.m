% wifi_radar_visualization.m
% Advanced Visualization for Wi-Fi Passive Radar
% Uruchom TO po wifi_radar_processing.m

if ~exist('H_matrix', 'var')
    error('Uruchom najpierw wifi_radar_processing.m!');
end

figure('Name', 'Wi-Fi Radar: Detailed Analysis', 'Color', 'white', 'Position', [50, 50, 1200, 800]);
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- WYKRES 1: Sygnał w Czasie (Fragment) ---
nexttile;
t_axis_us = (0:length(rx_dirty)-1) / fs * 1e6;
hold on;
plot(t_axis_us, real(rx_dirty), 'Color', [0.7 0.7 0.7]); % Szary: Odbiornik
plot(t_axis_us, real(receivedSignal), 'b', 'LineWidth', 1.2); % Niebieski: Nadajnik
hold off;
xlim([0, 10]); % Pokaż tylko pierwsze 10 mikrosekund
title('1. Time Domain (Zoom)');
xlabel('Time [\mus]'); ylabel('Amplitude');
legend('Rx (Dirty)', 'Tx (Clean)');
grid on;

% --- WYKRES 2: Macierz Kanału H (Przed FFT) ---
nexttile;
% To jest wizualizacja tego, co Braun nazywa "Channel Estimation"
imagesc(abs(H_matrix));
title('2. Channel Matrix H (Magnitude)');
xlabel('Symbol Index (Time)'); ylabel('Subcarrier Index (Freq)');
colormap(gca, 'parula');
colorbar;

% --- WYKRES 3: Profil Odległości (Range Profile - 1D) ---
nexttile;
% Uśredniamy wszystkie symbole, żeby zobaczyć średni profil echa
range_avg = mean(abs(range_profile), 2);
range_axis_m = (0:N_range_fft-1) * (c / (2*fs)); % Oś w metrach

plot(range_axis_m, 20*log10(range_avg + 1e-9), 'LineWidth', 2, 'Color', 'r');
xlim([0, 200]); % Pokaż tylko bliski zasięg
title('3. Range Profile (Averaged)');
xlabel('Distance [m]'); ylabel('Magnitude [dB]');
grid on;

% --- PRZYGOTOWANIE DO WYKRESÓW RD (Usuwanie Sygnału Bezpośredniego) ---
% Wykonujemy proste filtrowanie: odejmujemy średnią wartość w dziedzinie czasu
% To usuwa obiekty statyczne (prędkość 0), czyli głównie sygnał bezpośredni.
rd_map_clean = rd_map_shifted;
center_index = ceil(N_doppler_fft/2) + 1;
% Zerujemy dokładnie środek (DC component) w dziedzinie Dopplera
rd_map_clean(:, center_index-1:center_index+1) = 1e-9; 

power_map_clean = 10*log10(abs(rd_map_clean).^2 + 1e-9);

% --- WYKRES 4: Mapa Range-Doppler (2D Widok z Góry) ---
nexttile([1, 1]); % Zajmij 1 kafelek
imagesc(doppler_axis, range_axis, power_map_clean);
title('4. Range-Doppler Map (Filtered)');
xlabel('Velocity [m/s]'); ylabel('Range [m]');
axis xy;
ylim([0, 200]); % Zoom na zasięg
caxis([-20, max(power_map_clean(:))]); % Obcięcie szumu tła
colormap(gca, 'jet');
colorbar;

% --- WYKRES 5: Mapa Range-Doppler (3D Surface) ---
nexttile([1, 2]); % Zajmij 2 kafelki szerokości
% Tworzymy siatkę do wykresu 3D
[D_grid, R_grid] = meshgrid(doppler_axis, range_axis);

% Wycinamy fragment danych do wyświetlenia (żeby nie rysować tysięcy punktów szumu)
range_limit_idx = find(range_axis > 200, 1); 
surf(D_grid(1:range_limit_idx, :), ...
     R_grid(1:range_limit_idx, :), ...
     power_map_clean(1:range_limit_idx, :), 'EdgeColor', 'none');

title('5. 3D Landscape of Targets');
xlabel('Velocity [m/s]'); ylabel('Range [m]'); zlabel('Power [dB]');
view(-30, 45); % Ustawienie kamery
colormap(gca, 'jet');
shading interp; % Wygładzanie
grid on;

fprintf("Wizualizacja wygenerowana. Sprawdź Wykres 4 i 5, czy cele są widoczne.\n");
