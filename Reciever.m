% Receiver_Pipeline.m
% Krok 1: Demodulacja i wygenerowanie zespolonej mapy Range-Doppler

clearvars; close all; clc;

%% 1. Parametry i Wczytanie Danych
fc = 5.5e9; 
c = 3e8;
fs = wlanSampleRate("CBW20");
Nfft = 64;
Ncp = Nfft/4;

load("waveform.mat");
load("signal.mat");

preamble_len = round(20e-6 * fs);
y_cut = signal(preamble_len+1 : end);
x_cut = waveform(preamble_len+1 : end);

%% 2. Demodulacja i Zero-Forcing
[F_rx, n_symbols] = demodulate(y_cut, Nfft, Ncp);
[F_tx, ~]         = demodulate(x_cut, Nfft, Ncp);

H = F_rx ./ (F_tx + 1e-9);

% Maska 802.11a
mask_shifted = zeros(Nfft, 1);
mask_shifted(7:32) = 1; mask_shifted(34:59) = 1;
H = H .* ifftshift(mask_shifted);

%% 3. MTI i Łatanie DC
H_shifted = fftshift(H, 1);
H_shifted = H_shifted - mean(H_shifted, 2);
H_shifted(33, :) = (H_shifted(32, :) + H_shifted(34, :)) / 2;

%% 4. Okienkowanie
L_win = 53; n_idx = (0 : L_win-1)';
a0=0.35875; a1=0.48829; a2=0.14128; a3=0.01168;
bh_window = a0 - a1*cos(2*pi*n_idx/(L_win-1)) + a2*cos(4*pi*n_idx/(L_win-1)) - a3*cos(6*pi*n_idx/(L_win-1));

win_f_shifted = zeros(Nfft, 1); win_f_shifted(7:59) = bh_window; 
win_t = a0 - a1*cos(2*pi*(0:n_symbols-1)/(n_symbols-1)) + a2*cos(4*pi*(0:n_symbols-1)/(n_symbols-1)) - a3*cos(6*pi*(0:n_symbols-1)/(n_symbols-1));

W_2D_shifted = win_f_shifted .* win_t;
W_2D_unshifted = ifftshift(W_2D_shifted, 1); % Do zapisu dla algorytmu CLEAN!

H_ready = ifftshift(H_shifted .* W_2D_shifted, 1);

%% 5. Zespolony Periodogram
N_per = 256; 

% Dynamiczny dobór M_per: zawsze kolejna potęga dwójki większa niż n_symbols
% Dzięki temu zachowujemy 100% danych i zyskujemy gęstą, piękną oś prędkości
M_per = 2^nextpow2(n_symbols); 
% (Opcjonalnie możesz dodać * 2 na końcu, np. M_per = 2^nextpow2(n_symbols) * 2, jeśli chcesz wyższej rozdzielczości wykresu)

CPer_base = fftshift(fft(ifft(H_ready, N_per, 1), M_per, 2), 2);      

% Zapisujemy wszystko do pliku
fprintf('Zapisuję dane do interpretacji...\n');
save('radar_data.mat', 'CPer_base', 'W_2D_unshifted', 'N_per', 'M_per', 'Nfft', 'n_symbols', 'fs', 'fc', 'Ncp', 'c');
fprintf('Gotowe. Macierz ma rozmiar %dx%d. Możesz uruchomić interpret.m\n', N_per, M_per);
