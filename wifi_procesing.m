% wifi_procesing.mat
% WiFi Doppler Map processing

clear all; close all; clc;

% --- 1. ŁADOWANIE DANYCH ---
try
    load("WiFi_MCS0_BW20.mat"); 
    tx_signal = receivedSignal;
    
    load('WiFi_Doppler.mat');
    rx_signal = receivedSignal;
catch
    error('Brak plików .mat! Upewnij się, że WiFi_MCS0_BW20.mat i WiFi_Doppler.mat są dostępne.');
end

fs = 20e6;              % Częstotliwość próbkowania 20 MHz
plcp_overhead = 400;    % (16us Preamble + 4us Header) * 20MHz = 400 próbek

% --- 2. DETEKCJA PAKIETÓW ---
fprintf('Detekcja pakietu TX...\n');
tx_packet_start = find_packet_start(tx_signal);

fprintf('Detekcja pakietu RX...\n');
rx_packet_start = find_packet_start(rx_signal);

if isempty(tx_packet_start) || isempty(rx_packet_start)
    error('Nie udało się wykryć początku pakietu w jednym z sygnałów.');
end

fprintf('  TX Start Index: %d\n', tx_packet_start);
fprintf('  RX Start Index: %d\n', rx_packet_start);

% --- 3. PRZYGOTOWANIE I SYNCHRONIZACJA DANYCH ---
cp = 16;
nfft = 64;
symbol_len = cp + nfft; % 80 próbek

% Obliczamy punkty startowe danych (pomijamy preambułę i nagłówek)
idx_tx_data_start = tx_packet_start + plcp_overhead;
idx_rx_data_start = rx_packet_start + plcp_overhead;

% Sprawdzamy ile próbek jest dostępnych do końca każdego z nagrań
len_tx_avail = length(tx_signal) - idx_tx_data_start + 1;
len_rx_avail = length(rx_signal) - idx_rx_data_start + 1;

% Wybieramy krótszą długość (limituje nas ten sygnał, który kończy się pierwszy)
len_common = min(len_tx_avail, len_rx_avail);

% Obliczamy liczbę PEŁNYCH symboli, które się zmieszczą
num_symbols = floor(len_common / symbol_len);

fprintf('  Liczba przetwarzanych symboli: %d\n', num_symbols);

% Wycinamy dokładnie taką samą liczbę próbek z obu sygnałów
tx_data = tx_signal(idx_tx_data_start : idx_tx_data_start + num_symbols*symbol_len - 1);
rx_data = rx_signal(idx_rx_data_start : idx_rx_data_start + num_symbols*symbol_len - 1);

% --- 4. PRZETWARZANIE OFDM ---

% Reshape do macierzy [80 x Liczba_Symboli]
txx = reshape(tx_data, symbol_len, num_symbols);
rxx = reshape(rx_data, symbol_len, num_symbols);

% Usunięcie prefiksu cyklicznego (CP)
% Usuwamy pierwsze 16 wierszy, zostaje 64
txx = txx(cp+1:end, :);
rxx = rxx(cp+1:end, :);

% FFT (Przejście na dziedzinę częstotliwości)
TXX = fft(txx); % Widmo nadajnika (znane/wzorcowe)
RXX = fft(rxx); % Widmo odbiornika (z odbiciami)

% --- 5. ESTYMACJA KANAŁU ---
denominator = TXX;
bad_idx = abs(denominator) < 1e-6; 
denominator(bad_idx) = 1; 
H_est = RXX ./ denominator;
H_est(bad_idx) = 0;
H_est(isnan(H_est)) = 0;

% --- 6. RANGE-DOPPLER MAP ---
Range_Map = ifft(H_est, [], 1); 
RD_Map = fft(Range_Map, [], 2);
RD_Map = fftshift(RD_Map, 2);

% --- 7. WIZUALIZACJA (POPRAWIONA) ---
figure('Color', 'w');

% 1. Obliczamy dB bezpiecznie
% Dodajemy 'eps' (najmniejsza liczba > 0), żeby log10(0) nie dał -Inf
RD_Map_dB = 20*log10(abs(RD_Map) + eps);

% 2. Znajdujemy maksimum globalne (szukamy w całej macierzy)
max_val = max(RD_Map_dB(:));

% 3. Zabezpieczenie na wypadek, gdyby jednak wyszło NaN lub Inf (np. pusty sygnał)
if isinf(max_val) || isnan(max_val)
    max_val = 0; 
    warning('Sygnał jest pusty lub zerowy - ustawiam sztuczną skalę.');
end

% 4. Wyświetlanie (ucinamy połowę zakresu Range - aliasing)
half_range = floor(nfft/2); 
mesh(RD_Map_dB(1:half_range, :));

title('WiFi Passive Radar: Range-Doppler Map');
xlabel('Doppler (Speed)');
ylabel('Range (Distance bins)');
colormap('jet');
colorbar;
axis xy; % Zero na dole osi Y
