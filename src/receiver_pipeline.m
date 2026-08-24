% RECEIVER_PIPELINE
% Stage 1: OFDM Demodulation, Zero-Forcing Channel Estimation, MTI, DC Repair, 
% 2D Blackman-Harris Windowing, and Complex Range-Doppler Periodogram Generation.
%
% Reference:
%   Martin Braun, "OFDM Radar Algorithms in Mobile Communication Networks", KIT, 2014.
%
% Inputs:
%   waveform.mat, signal.mat
% Output:
%   radar_data.mat - Prepared complex periodogram and parameters for target detection

fprintf(">> Running Receiver Pipeline...\n");

% Ensure lib directory is on MATLAB search path
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(current_dir, '..', 'lib'));

%% 1. Load Transmitted Waveform and Received Signal
if ~isfile("waveform.mat") || ~isfile("signal.mat")
    error("waveform.mat or signal.mat not found. Please run transmitter.m and channel.m first!");
end
load("waveform.mat", "waveform", "fs");
load("signal.mat", "signal", "fc", "c");

Nfft = 64;             % 802.11a FFT subcarriers
Ncp = 16;              % Cyclic prefix length (0.8 us)
Nsym_len = Nfft + Ncp; % Total OFDM symbol length (80 samples = 4 us)

%% 2. Preamble Removal (20 us = 400 samples for IEEE 802.11a L-STF, L-LTF, SIGNAL)
preamble_time = 20e-6;
preamble_len = round(preamble_time * fs);

y_cut = signal(preamble_len + 1 : end);
x_cut = waveform(preamble_len + 1 : end);

%% 3. Manual OFDM Demodulation
[F_rx, n_symbols] = demodulate(y_cut, Nfft, Ncp);
[F_tx, ~]         = demodulate(x_cut, Nfft, Ncp);

fprintf("  Demodulated %d OFDM symbols (%d subcarriers each).\n", n_symbols, Nfft);

%% 4. Channel Estimation (Zero-Forcing / Element-wise Division)
epsilon = 1e-9;
H = F_rx ./ (F_tx + epsilon);

% Active subcarrier mask for IEEE 802.11a (52 data/pilot subcarriers, excluding guard bands)
mask_shifted = zeros(Nfft, 1);
mask_shifted(7:32)  = 1; % Lower subcarriers [-26 to -1]
mask_shifted(34:59) = 1; % Upper subcarriers [1 to 26]
H = H .* ifftshift(mask_shifted);

%% 5. MTI Filtering and DC Subcarrier Interpolation
% MTI Filter: eliminate static reflection at direct path (0 m, 0 Hz)
H_shifted = fftshift(H, 1);
H_shifted = H_shifted - mean(H_shifted, 2);

% DC carrier repair: interpolate DC gap at carrier index 33 to prevent spectral leakage
H_shifted(33, :) = (H_shifted(32, :) + H_shifted(34, :)) / 2;

%% 6. 2D Blackman-Harris Windowing (92 dB Sidelobe Suppression)
L_win = 53; % Span of active carriers including DC
n_idx = (0 : L_win - 1)';
a0 = 0.35875; a1 = 0.48829; a2 = 0.14128; a3 = 0.01168;

bh_window = a0 - a1*cos(2*pi*n_idx/(L_win-1)) + a2*cos(4*pi*n_idx/(L_win-1)) - a3*cos(6*pi*n_idx/(L_win-1));

win_f_shifted = zeros(Nfft, 1);
win_f_shifted(7:59) = bh_window;

win_t = a0 - a1*cos(2*pi*(0:n_symbols-1)/(n_symbols-1)) + ...
             a2*cos(4*pi*(0:n_symbols-1)/(n_symbols-1)) - ...
             a3*cos(6*pi*(0:n_symbols-1)/(n_symbols-1));

W_2D_shifted = win_f_shifted .* win_t;
W_2D_unshifted = ifftshift(W_2D_shifted, 1); % Preserved for CLEAN point spread function reconstruction

H_ready = ifftshift(H_shifted .* W_2D_shifted, 1);

%% 7. Complex Periodogram Generation (Range-Doppler Processing)
N_per = 256;                  % Range FFT size (Zero padding)
M_per = 2^nextpow2(n_symbols); % Doppler FFT size (Optimal power of 2)

CPer_base = fftshift(fft(ifft(H_ready, N_per, 1), M_per, 2), 2);

%% 8. Save Data for Interpretation
save('radar_data.mat', 'CPer_base', 'W_2D_unshifted', 'N_per', 'M_per', ...
     'Nfft', 'n_symbols', 'fs', 'fc', 'Ncp', 'c');

fprintf("  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n", N_per, M_per);
fprintf("  Data saved to 'radar_data.mat'. You can now run clean_interpreter.m.\n");
