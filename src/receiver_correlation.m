% RECEIVER_CORRELATION
% Alternative Baseline: Time-Domain Matched Filter / Cross-Correlation Receiver.
%
% Input:
%   waveform.mat, signal.mat

fprintf(">> Running Cross-Correlation / Matched Filter Receiver...\n");

%% 1. Parameters & Data Loading
if ~isfile("waveform.mat") || ~isfile("signal.mat")
    error("waveform.mat or signal.mat not found. Please run transmitter.m and channel.m first!");
end
load("waveform.mat", "waveform", "fs");
load("signal.mat", "signal", "fc", "c");

Nsym_len = 80; % Symbol length (64 subcarriers + 16 CP)

%% 2. Preamble Removal
preamble_time = 20e-6;
preamble_len = round(preamble_time * fs);

y_cut = signal(preamble_len + 1 : end);
x_cut = waveform(preamble_len + 1 : end);

%% 3. Block Reshaping (Fast-Time x Slow-Time)
n_blocks = floor(length(y_cut) / Nsym_len);
y_mat = reshape(y_cut(1 : n_blocks * Nsym_len), Nsym_len, n_blocks);
x_mat = reshape(x_cut(1 : n_blocks * Nsym_len), Nsym_len, n_blocks);

%% 4. Fast Cross-Correlation via Frequency Domain
N_corr = 256;
Y_f = fft(y_mat, N_corr, 1);
X_f = fft(x_mat, N_corr, 1);

% Cross-correlation: IFFT( Y .* conj(X) )
R_mat = ifft(Y_f .* conj(X_f), N_corr, 1);

% Retain fast-time range window
N_range_keep = 40;
range_profile = R_mat(1 : N_range_keep, :);

%% 5. MTI Filtering (Moving Target Indicator)
range_profile_mti = range_profile - mean(range_profile, 2);

%% 6. Doppler Processing (Slow-Time FFT with Hamming Window)
interp_factor = 4;
N_doppler = n_blocks * interp_factor;

win = hamming(n_blocks).';
range_profile_win = range_profile_mti .* win;

rd_map = fft(range_profile_win, N_doppler, 2);
rd_map_shifted = fftshift(rd_map, 2);
power_map = 20*log10(abs(rd_map_shifted) + 1e-9);

%% 7. Calibrated Physical Axes
delta_r = c / (2 * fs);
axis_range = (0 : N_range_keep - 1) * delta_r;

T_sym_total = Nsym_len / fs;
v_max = c / (2 * fc * T_sym_total);
axis_velocity = linspace(-v_max/2, v_max/2, N_doppler);

%% 8. Visualization
figure('Name', 'Cross-Correlation Receiver', 'Color', 'white', 'Position', [100, 100, 800, 550]);
imagesc(axis_velocity, axis_range, power_map);
title('Range-Doppler Map (Cross-Correlation / Matched Filter Method)');
xlabel('Velocity [m/s]'); ylabel('Range [m]');
colormap(gca, 'jet');
cbar = colorbar; cbar.Label.String = 'Power [dB]';
axis xy;
xlim([-60, 60]);
max_val = max(power_map(:));
clim([max_val - 40, max_val]);
grid on;
