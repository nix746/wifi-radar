% interpret.m
% Krok 2: Odczyt mapy, algorytm CLEAN i rysowanie wyników

clearvars; close all; clc;

%% 1. Wczytanie wygenerowanej mapy z pamięci
if ~isfile('radar_data.mat')
    error('Brak pliku radar_data.mat. Uruchom najpierw Receiver_Pipeline.m!');
end
load('radar_data.mat');

%% 2. Algorytm CLEAN
CPer_clean = CPer_base;
num_targets = 2; % Szukamy 2 celów
targets_found = [];

for i = 1:num_targets
    % Znajdź szczyt
    [~, idx] = max(abs(CPer_clean(:)));
    [r_idx, d_idx] = ind2sub([N_per, M_per], idx);
    targets_found = [targets_found; r_idx, d_idx];
    
    % Inżynieria odwrotna celu (Idealny model)
    P = zeros(N_per, M_per); P(r_idx, d_idx) = 1;
    H_full = fft(ifft(ifftshift(P, 2), M_per, 2), N_per, 1);
    
    H_crop_win = H_full(1:Nfft, 1:n_symbols) .* W_2D_unshifted;
    
    CPer_target = fftshift(fft(ifft(H_crop_win, N_per, 1), M_per, 2), 2);
    CPer_target_norm = CPer_target / CPer_target(r_idx, d_idx);
    
    % Koherentne odjęcie celu
    CPer_clean = CPer_clean - CPer_clean(r_idx, d_idx) * CPer_target_norm;
    
    fprintf('Znaleziono i usunięto cel nr %d...\n', i);
end

%% 3. Przeliczenie na decybele do rysowania
Per_dB_base = 10*log10( (1/(Nfft*n_symbols)) * abs(CPer_base).^2 + 1e-9);
Per_dB_clean = 10*log10( (1/(Nfft*n_symbols)) * abs(CPer_clean).^2 + 1e-9);

%% 4. Osi i Rysowanie
axis_range = linspace(0, (c / (2 * fs)) * Nfft, N_per);
axis_velocity = linspace(-(c / (2 * fc * ((Nfft + Ncp) / fs)))/2, (c / (2 * fc * ((Nfft + Ncp) / fs)))/2, M_per);

figure('Name', 'Interpretacja Mapy Radarowej', 'Color', 'white', 'Position', [100, 100, 1000, 500]);
c_lims = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];

% Mapa przed CLEAN
subplot(1,2,1);
imagesc(axis_velocity, axis_range, Per_dB_base); axis xy; colormap('jet');
title('Oryginalna Mapa (Przed CLEAN)');
xlabel('Prędkość [m/s]'); ylabel('Odległość [m]');
ylim([0 150]); xlim([-60 60]); clim(c_lims);
hold on; plot(axis_velocity(targets_found(:,2)), axis_range(targets_found(:,1)), 'kx', 'MarkerSize', 12, 'LineWidth', 2);
legend('Zlokalizowane Cele');

% Mapa po CLEAN
subplot(1,2,2);
imagesc(axis_velocity, axis_range, Per_dB_clean); axis xy; colormap('jet');
title('Czyste tło (Po CLEAN)');
xlabel('Prędkość [m/s]'); ylabel('Odległość [m]');
ylim([0 150]); xlim([-60 60]); clim(c_lims);
colorbar;
