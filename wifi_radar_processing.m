% wifi_radar_processing.m
% Wi-Fi Passive Radar - Receiver & Processing Stage
% Implements manual OFDM demodulation and 2D Periodogram

% 1. SETUP
% Zakładamy, że w Workspace są zmienne z poprzednich skryptów:
% - rx_dirty (sygnał odebrany z echem)
% - receivedSignal (czysty sygnał nadany - nasza referencja)
% - metadata (parametry próbkowania)

if ~exist('rx_dirty', 'var')
    error('Uruchom najpierw wifi_doppler.m!');
end

fprintf("Processing Radar Data...\n");

% Parametry OFDM dla 802.11a (20 MHz)
N_fft = 64;             % Rozmiar FFT [cite: 448]
N_cp = 16;              % Długość Cyclic Prefix (standard 0.8 us)
N_sym = N_fft + N_cp;   % Całkowita długość symbolu w próbkach [cite: 434]

% 2. MANUALNA DEMODULACJA (Odbiornik)
% Funkcja pomocnicza (zdefiniowana na końcu skryptu) wykonuje:
% Reshape -> Usunięcie CP -> FFT
F_rx_raw = manual_ofdm_demod(rx_dirty, N_fft, N_cp);
F_tx_raw = manual_ofdm_demod(receivedSignal, N_fft, N_cp);

% Sprawdzenie wymiarów (powinny być N_fft x Liczba_Symboli)
[n_carriers, n_symbols] = size(F_rx_raw);
fprintf("Detected OFDM Frame: %d subcarriers x %d symbols\n", n_carriers, n_symbols);

% 3. PRZETWARZANIE RADAROWE (Core Processing)

% A. Dzielenie elementowe (Symbol Division) 
% Usuwamy modulację QAM, zostawiając tylko H (kanał)
% Dodajemy epsilon, aby uniknąć dzielenia przez zero na pustych podnośnych
H_matrix = F_rx_raw ./ (F_tx_raw + 1e-9);

% B. Czyszczenie (Zeroing Guard Bands)
% 802.11a używa tylko 52 podnośnych. Reszta to szum/zera.
% Zerujemy podnośne, gdzie moc sygnału referencyjnego jest znikoma
active_carriers_mask = abs(F_tx_raw(:, 1)) > 0.01; % Prosty próg
H_matrix = H_matrix .* active_carriers_mask;

% 4. OBLICZENIE PERIODOGRAMU 2D (ULEPSZONE)

% Parametry ulepszające wizualizację
interp_factor = 4; % Ile razy zagęścić siatkę (Zero Padding)
N_range_fft = n_carriers * interp_factor; 
N_doppler_fft = n_symbols * interp_factor;

% A. Okienkowanie (Windowing) - usuwa "wielokrotne" piki boczne
% Tworzymy okno 2D (Hamminga), aby wygładzić krawędzie sygnału
% Zgodnie z Tabelą 3.2 pracy Brauna, okno Hamminga tłumi listki boczne o ~42 dB
win_range = hamming(n_carriers);   % Okno w dziedzinie częstotliwości
win_doppler = hamming(n_symbols);  % Okno w dziedzinie czasu
window_2d = win_range * win_doppler.';

H_windowed = H_matrix .* window_2d;

% B. Range Profile (z Zero Padding)
% IFFT z większą liczbą punktów (N_range_fft) automatycznie robi interpolację
range_profile = ifft(H_windowed, N_range_fft, 1); 

% C. Doppler Map (z Zero Padding)
rd_map = fft(range_profile, N_doppler_fft, 2);

% D. Przesunięcie i Skala
rd_map_shifted = fftshift(rd_map, 2);
power_map = 10*log10(abs(rd_map_shifted).^2 + 1e-9);


% 5. WIZUALIZACJA (Skalibrowane osie)

figure('Name', 'Wi-Fi Radar: Windowed & Interpolated', 'Color', 'white');

% Obliczenie osi fizycznych (zgodnie ze wzorami 3.22 i 3.23)
fs = metadata.sampleRate;
c = 3e8;
f_c = 5.5e9; % Częstotliwość nośna 802.11a [cite: 2148]

% Oś Range [metry]
delta_r = c / (2 * fs); % Rozdzielczość podstawowa
max_range = delta_r * n_carriers;
range_axis = linspace(0, max_range, N_range_fft);

% Oś Doppler [m/s]
% Czas trwania jednego symbolu (z CP)
T_sym = (N_fft + N_cp) / fs; 
% Całkowity czas patrzenia (Integration Time)
T_frame = T_sym * n_symbols;
% Max jednoznaczna prędkość
v_unamb = c / (2 * f_c * T_sym); 
doppler_axis = linspace(-v_unamb/2, v_unamb/2, N_doppler_fft);

imagesc(doppler_axis, range_axis, power_map);
colorbar;
title(sprintf('Range-Doppler Map (MCS%d, Packet Len: %.2f ms)', metadata.MCS, T_frame*1000));
xlabel('Velocity [m/s]');
ylabel('Range [m]');
axis xy; 
colormap('jet');

% Ograniczenie widoku do sensownych wartości (żeby nie patrzeć na szum daleko)
ylim([0, 200]); % Pokaż tylko pierwsze 200m
clim([-30, max(power_map(:))]);


% --- FUNKCJE POMOCNICZE ---

function F_matrix = manual_ofdm_demod(time_signal, n_fft, n_cp)
    % Ręczna demodulacja OFDM:
    % 1. Dopasowanie długości wektora do pełnych symboli
    % 2. Reshape do macierzy [Długość_symbolu x Liczba_symboli]
    % 3. Usunięcie CP [cite: 544]
    % 4. FFT [cite: 545]
    
    sym_len = n_fft + n_cp;
    n_syms = floor(length(time_signal) / sym_len);
    
    % Przycinamy sygnał do pełnej liczby symboli
    truncated_sig = time_signal(1 : n_syms * sym_len);
    
    % Reshape: każda kolumna to jeden symbol w czasie (z CP)
    matrix_time_with_cp = reshape(truncated_sig, sym_len, n_syms);
    
    % Usunięcie CP: bierzemy próbki od (N_cp+1) do końca w każdej kolumnie
    matrix_time_no_cp = matrix_time_with_cp(n_cp+1 : end, :);
    
    % FFT wzdłuż kolumn (wymiar czasu szybkiego -> częstotliwość)
    F_matrix = fft(matrix_time_no_cp, n_fft, 1);
end
