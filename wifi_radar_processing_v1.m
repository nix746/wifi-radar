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

% 4. OBLICZENIE PERIODOGRAMU 2D (Range-Doppler Map) [cite: 666]

% Krok 1: Range (Odległość) -> IFFT po kolumnach (częstotliwość)
% Zgodnie ze wzorem 3.22, opóźnienie jest powiązane z częstotliwością wierszy F
range_profile = ifft(H_matrix, [], 1); 

% Krok 2: Doppler (Prędkość) -> FFT po wierszach (czas)
% Zgodnie ze wzorem 3.23, Doppler jest powiązany z częstotliwością kolumn F
rd_map = fft(range_profile, [], 2);

% Przesunięcie FFT, aby zero było na środku (dla wizualizacji Dopplera)
rd_map_shifted = fftshift(rd_map, 2);

% Moc w skali logarytmicznej
power_map = 10*log10(abs(rd_map_shifted).^2 + 1e-9);

% 5. WIZUALIZACJA

figure('Name', 'Wi-Fi Passive Radar Result', 'Color', 'white');

% Osie (uproszczone - indeksy)
doppler_axis = linspace(-n_symbols/2, n_symbols/2, n_symbols);
range_axis = 0:n_carriers-1;

imagesc(doppler_axis, range_axis, power_map);
colorbar;
title('Range-Doppler Map (Periodogram)');
xlabel('Doppler Index (Velocity)');
ylabel('Range Index (Delay samples)');
axis xy; % Klasyczny widok radarowy (0 na dole)
colormap('jet');
clim([-40, max(power_map(:))]); % Skalowanie kolorów do dynamiki sygnału

fprintf("Processing Complete.\n");


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
