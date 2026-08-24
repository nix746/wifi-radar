% Receiver.m

clearvars
close all

%% Constants
fc = 5.5e9; 
c = 3e8;
fs = wlanSampleRate("CBW20");

Nfft = 64;                 % FFT size
Ncp = Nfft/4;              % Cyclic Prefix length
Nsym_len = Nfft + Ncp;     % Total symbol length

%% Load data
load("waveform.mat")
load("signal.mat")

N = length(signal);
t = (0:N-1)/fs * 1e6;

% Time domain plot
figure
sgtitle('Recieved and Transmitted signal (Time domain)')
subplot(2,1, 1)
plot(t, abs(signal)); hold on
plot(t, abs(waveform)); hold off
title('before preamble removal')
xlabel('Time [\mus]'); ylabel('Amplitude')
legend('Transmitted', 'Recieved')
xlim([0, 20]); grid on

%% Cut prambule
preamble_time = 8e-6;
preamble_len = round(preamble_time * fs);

signal = signal(preamble_len+1 : end);
waveform = waveform(preamble_len+1 : end);

N = length(signal);
t = (0:N-1)/fs * 1e6;

% Time domain plot
subplot(2,1, 2)
plot(t, abs(signal)); hold on
plot(t, abs(waveform)); hold off
title('after preable removal')
xlabel('Time [\mus]'); ylabel('Amplitude')
xlim([0, 12]); grid on


%% OFDM Demodulation
[F_rx, n_symbols] = demodulate(signal, Nfft, Ncp);
[F_tx, ~]         = demodulate(waveform, Nfft, Ncp);

figure
F_plot = fftshift(F_rx, 1);
imagesc(20*log10(abs(F_plot) + 1e-9));
colorbar;
colormap('parula');
title(sprintf('Demodulated Symbols'));
xlabel('Symbol Index (Time)');
ylabel('Subcarrier Index (Frequency)');
axis xy;

%% Channel estimation
epsilon = 1e-9;
H = F_rx ./ (F_tx + epsilon);

% Guard Band Removal
active_mask = abs(F_tx(:, 1)) > 0.02;
H = H .* active_mask;

% Visualisation
H_plot = fftshift(H, 1);
H_dB = 20*log10(abs(H_plot) + epsilon);

figure
imagesc(1:n_symbols, 1:Nfft, H_dB);
title('Channel Response (H Matrix)');
xlabel('Symbol Index (Time)'); ylabel('Subcarrier Index (Freq)');
colormap(gca, 'jet'); 
colorbar;
axis xy;
med_val = median(H_dB(:));
clim([med_val - 20, med_val + 20]);

%% FFT
interpolation_factor = 4;
N_range_fft = Nfft * interpolation_factor;
N_doppler_fft = n_symbols * interpolation_factor;

range_profile = ifft(H, N_range_fft, 1); 
rd_map = fft(range_profile, N_doppler_fft, 2);

%% Shift and Magnitude
rd_map_shifted = fftshift(rd_map, 2);
power_map = 20*log10(abs(rd_map_shifted) + epsilon); % [dB]
 
% Range Axis
delta_r = c / (2 * fs);
max_range = delta_r * Nfft;
axis_range = linspace(0, max_range, N_range_fft);

% Doppler Axis
T_sym_total = Nsym_len / fs; 
v = c / (2 * fc * T_sym_total);
axis_velocity = linspace(-v/2, v/2, N_doppler_fft);

range_profile_db = 20*log10(abs(range_profile) + epsilon);

%% Visualise results
figure('Name', 'Range Profile', 'Color', 'white');
imagesc(1:n_symbols, axis_range, range_profile_db);
title('Range Profile Map (Range vs Time)');
xlabel('Symbol Index (Slow Time)'); 
ylabel('Range [m]');
colormap(gca, 'jet'); 
c = colorbar; c.Label.String = 'Power [dB]';
axis xy;

ylim([0, 200]); 
max_rp = max(range_profile_db(:));
clim([max_rp - 50, max_rp]);

figure
imagesc(axis_velocity, axis_range, power_map);
title('Range-Doppler Map');
xlabel('Velocity [m/s]'); ylabel('Range [m]');
colormap(gca, 'jet');
col = colorbar; col.Label.String = 'Power [dB]';
axis xy;

max_val = max(power_map(:));
clim([max_val - 35, max_val]);
