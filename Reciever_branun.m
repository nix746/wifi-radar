% Receiver_Advanced.m
% Porównanie algorytmów detekcji: CFAR, Binary Cancellation, Coherent CLEAN

clearvars; close all; clc;

%% 1. Parametry i Wczytanie Danych
fc = 5.5e9; 
c = 3e8;
fs = wlanSampleRate("CBW20");
Nfft = 64;
Ncp = Nfft/4;

load("waveform.mat");
load("signal.mat");

% Wycięcie preambuły (L-STF i L-LTF generujące duchy)
preamble_time = 8e-6;
preamble_len = round(preamble_time * fs);
y_cut = signal(preamble_len+1 : end);
x_cut = waveform(preamble_len+1 : end);

%% 2. Demodulacja i Estymacja Kanału (Zero-Forcing)
[F_rx, n_symbols] = demodulate(y_cut, Nfft, Ncp);
[F_tx, ~]         = demodulate(x_cut, Nfft, Ncp);

epsilon = 1e-9;
H = F_rx ./ (F_tx + epsilon);

% Maska dla podnośnych aktywnych (usunięcie pasm ochronnych)
active_mask = abs(F_tx(:, 1)) > 0.02;
H = H .* active_mask;

% Usuwamy statyczne echo od nadajnika (0m) - MTI Filter
H = H - mean(H, 2);

%% 3. Tworzenie Okna Blackman-Harris 2D
% Praca doktorska zaleca to okno dla metody binarnej ze względu na tłumienie 92dB[cite: 523].
a0=0.35875; a1=0.48829; a2=0.14128; a3=0.01168;
n_idx_f = (0:Nfft-1)';
n_idx_t = (0:n_symbols-1);
win_f = a0 - a1*cos(2*pi*n_idx_f/(Nfft-1)) + a2*cos(4*pi*n_idx_f/(Nfft-1)) - a3*cos(6*pi*n_idx_f/(Nfft-1));
win_t = a0 - a1*cos(2*pi*n_idx_t/(n_symbols-1)) + a2*cos(4*pi*n_idx_t/(n_symbols-1)) - a3*cos(6*pi*n_idx_t/(n_symbols-1));
W_2D = win_f .* win_t;

H_win = H .* W_2D;

%% 4. Obliczenie Bazowego Zespolonego Periodogramu (CPer)
% Zgodnie ze wzorem 3.30 z pracy: IFFT po częstotliwości (odległość), FFT po czasie (Doppler) [cite: 30, 40]
N_per = 256; % Zero-padding dla lepszej interpolacji
M_per = 512;

CPer_base = ifft(H_win, N_per, 1);       % Range profile
CPer_base = fft(CPer_base, M_per, 2);    % Doppler profile
CPer_base = fftshift(CPer_base, 2);      % Centrowanie Dopplera

% Surowy Periodogram Mocy (wzor 3.31) [cite: 41]
Per_base = (1/(Nfft*n_symbols)) * abs(CPer_base).^2;
Per_dB_base = 10*log10(Per_base + epsilon);

%% 5. Algorytm 1: Binarne Anulowanie Celów (Binary Cancellation)
% Krok po kroku wg sekcji 3.3.7 "Binary Successive Target Cancellation" [cite: 800, 807]
Per_binary = Per_base;
binary_map = ones(N_per, M_per); % (B)_{k,l} = 1 [cite: 808]
targets_binary = [];
num_targets_to_find = 3; % Szukamy 3 najsilniejszych celów

% Promień "wycinania" (dostosowany do szerokości listka głównego okna B-H)
R_range = 4;  
R_dopp = 8;   

for i = 1:num_targets_to_find
    % Szukamy maksimum tylko tam, gdzie maska B == 1 [cite: 810]
    masked_per = Per_binary .* binary_map;
    [val, idx] = max(masked_per(:));
    [r_idx, d_idx] = ind2sub([N_per, M_per], idx);
    
    targets_binary = [targets_binary; r_idx, d_idx];
    
    % Wyzerowanie obszaru wokół znalezionego celu [cite: 815]
    for r = -R_range : R_range
        for d = -R_dopp : R_dopp
            rr = max(1, min(N_per, r_idx + r));
            dd = max(1, min(M_per, d_idx + d));
            % W pracy jest to elipsa, my upraszczamy do prostokąta dla czytelności
            binary_map(rr, dd) = 0; 
        end
    end
end
Per_dB_binary = 10*log10((Per_base .* binary_map) + epsilon);

%% 6. Algorytm 2: Koherentne Anulowanie Celów (Coherent CLEAN)
% Krok po kroku wg sekcji 3.3.7 "Coherent Successive Target Cancellation" [cite: 869, 876]
CPer_clean = CPer_base;
targets_coherent = [];

% Siatki do generowania idealnego sygnału celu
[L_mat, K_mat] = meshgrid(0:n_symbols-1, 0:Nfft-1);

for i = 1:num_targets_to_find
    % 2. Znajdź szczyt w aktualnym periodogramie [cite: 879]
    Per_current = abs(CPer_clean).^2;
    [val, idx] = max(Per_current(:));
    [r_idx, d_idx] = ind2sub([N_per, M_per], idx);
    
    targets_coherent = [targets_coherent; r_idx, d_idx];
    
    % Zespolona amplituda w tym punkcie 
    complex_amp = CPer_clean(r_idx, d_idx);
    
    % 6. Generowanie idealnego modelu echa dla tego pojedynczego celu (Wzór 3.99 uproszczony) [cite: 886]
    n_math = r_idx - 1; 
    m_math = d_idx - 1 - M_per/2; % Przesunięcie wynikające z fftshift
    
    F_target = exp(1j * 2 * pi * L_mat .* (m_math / M_per)) .* exp(1j * 2 * pi * K_mat .* (n_math / N_per));
    F_target_win = F_target .* W_2D;
    
    % Obliczenie CPer dla idealnego celu [cite: 888]
    CPer_target = ifft(F_target_win, N_per, 1);
    CPer_target = fft(CPer_target, M_per, 2);
    CPer_target = fftshift(CPer_target, 2);
    
    % Normalizacja modelu
    model_peak = CPer_target(r_idx, d_idx);
    CPer_target_normalized = CPer_target / model_peak;
    
    % 7. Koherentne odjęcie celu (razem z jego listkami bocznymi!) 
    CPer_clean = CPer_clean - complex_amp * CPer_target_normalized;
end
Per_dB_clean = 10*log10(abs(CPer_clean).^2 + epsilon);


%% 7. Generowanie osi i Rysowanie Wyników
delta_r = c / (2 * fs);
axis_range = linspace(0, delta_r * Nfft, N_per);

T_sym_total = (Nfft + Ncp) / fs; 
v_max = c / (2 * fc * T_sym_total);
axis_velocity = linspace(-v_max/2, v_max/2, M_per);

% Wykresy
figure('Name', 'Porównanie Algorytmów', 'Color', 'white', 'Position', [100, 100, 1400, 500]);

% Wspólny zakres kolorów dla sprawiedliwego porównania
c_lims = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];

% 1. CFAR Bazowy
subplot(1,3,1);
imagesc(axis_velocity, axis_range, Per_dB_base); axis xy; colormap('jet');
title('1. Bazowy Periodogram (CFAR)');
xlabel('Prędkość [m/s]'); ylabel('Odległość [m]');
ylim([0 150]); xlim([-60 60]); clim(c_lims);
hold on;
% Zaznaczamy cele wybrane przez algorytm binarny (dla podglądu)
plot(axis_velocity(targets_binary(:,2)), axis_range(targets_binary(:,1)), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
legend('Wykryte Cele (Maksima)');

% 2. Binarne Anulowanie (Maska)
subplot(1,3,2);
imagesc(axis_velocity, axis_range, Per_dB_binary); axis xy; colormap('jet');
title('2. Po Anulowaniu Binarnym');
xlabel('Prędkość [m/s]'); ylabel('Odległość [m]');
ylim([0 150]); xlim([-60 60]); clim(c_lims);

% 3. Koherentne Anulowanie (CLEAN)
subplot(1,3,3);
imagesc(axis_velocity, axis_range, Per_dB_clean); axis xy; colormap('jet');
title('3. Po Anulowaniu Koherentnym (CLEAN)');
xlabel('Prędkość [m/s]'); ylabel('Odległość [m]');
ylim([0 150]); xlim([-60 60]); clim(c_lims);
cbar = colorbar; cbar.Label.String = 'Moc [dB]';
