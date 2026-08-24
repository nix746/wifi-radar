% Receiver_Correlation.m
% Odbiornik alternatywny: Cross-Correlation / Matched Filter (W dziedzinie czasu)

clearvars; close all; clc;

%% 1. Konfiguracja
fc = 5.5e9; 
c = 3e8;
fs = wlanSampleRate("CBW20");
Nsym_len = 80; % Rozmiar bloku analizy (64 próbki + 16 CP)

%% 2. Wczytanie danych
load("waveform.mat");
load("signal.mat");

%% 3. Usunięcie preambuły
% Odrzucamy preambułę tak jak w poprzedniej metodzie, 
% aby zachować uczciwe warunki porównania.
preamble_time = 8e-6;
preamble_len = round(preamble_time * fs);

y_cut = signal(preamble_len+1 : end);
x_cut = waveform(preamble_len+1 : end);

%% 4. Formowanie macierzy (Szybki Czas x Wolny Czas)
% Dzielimy sygnał na "bloki" odpowiadające długości symbolu.
% Nie wyrzucamy CP - analizujemy cały przebieg czasowy!
n_blocks = floor(length(y_cut) / Nsym_len);

y_mat = reshape(y_cut(1:n_blocks*Nsym_len), Nsym_len, n_blocks);
x_mat = reshape(x_cut(1:n_blocks*Nsym_len), Nsym_len, n_blocks);

%% 5. Filtr Dopasowany (Korelacja Skrośna w dziedzinie Częstotliwości)
% Używamy FFT do szybkiego obliczenia korelacji czasowej dla każdego bloku.
% Padding (np. do 256) zapobiega zawijaniu się echa (circular convolution).
N_corr = 256; 
Y_f = fft(y_mat, N_corr, 1);
X_f = fft(x_mat, N_corr, 1);

% Wzór na korelację wzajemną: IFFT( Y * sprzężenie(X) )
R_mat = ifft(Y_f .* conj(X_f), N_corr, 1);

% Zachowujemy tylko interesujące nas, krótkie opóźnienia (np. pierwsze 40 próbek = 300 m)
N_range_keep = 40; 
range_profile = R_mat(1:N_range_keep, :);

%% 6. Usunięcie echa stałego (MTI - Moving Target Indicator)
% Odejmujemy średnią z każdego wiersza, co "zabija" statyczny sygnał na dystansie 0m
range_profile_mti = range_profile - mean(range_profile, 2);

%% 7. Przetwarzanie Dopplera (FFT po Wolnym Czasie)
interp_factor = 4;
N_doppler = n_blocks * interp_factor;

% Okno Hamminga, aby zredukować szumy od brzegów sygnału
win = hamming(n_blocks).';
range_profile_win = range_profile_mti .* win;

% FFT wzdłuż 2-go wymiaru (czasu wolnego)
rd_map = fft(range_profile_win, N_doppler, 2);
rd_map_shifted = fftshift(rd_map, 2);

% Zamiana na decybele
power_map = 20*log10(abs(rd_map_shifted) + 1e-9);

%% 8. Obliczenie Osi Wykresu
% Oś Odległości
delta_r = c / (2 * fs);
axis_range = (0:N_range_keep-1) * delta_r;

% Oś Prędkości
T_sym_total = Nsym_len / fs; 
v_max = c / (2 * fc * T_sym_total);
axis_velocity = linspace(-v_max/2, v_max/2, N_doppler);

%% 9. Rysowanie Wyników
figure('Name', 'Cross-Correlation Receiver', 'Color', 'white', 'Position', [100, 100, 800, 600]);
imagesc(axis_velocity, axis_range, power_map);
title('Range-Doppler Map (Cross-Correlation Method)');
xlabel('Velocity [m/s]'); 
ylabel('Range [m]');
colormap(gca, 'jet');
col = colorbar; col.Label.String = 'Power [dB]';
axis xy;

% Ograniczenie widoku do sensownych prędkości i ucięcie poziomu szumów
xlim([-60, 60]);
max_val = max(power_map(:));
clim([max_val - 40, max_val]);
