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

%% 4. & 5. Channel Estimation, MTI Filtering and DC Subcarrier Interpolation
H_shifted = estimate_channel_zf(F_rx, F_tx, Nfft);

%% 6. & 7. 2D Blackman-Harris Windowing and Complex Periodogram Generation
[CPer_base, W_2D_unshifted, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols);

%% 8. Save Data for Interpretation
save('radar_data.mat', 'CPer_base', 'W_2D_unshifted', 'N_per', 'M_per', ...
     'Nfft', 'n_symbols', 'fs', 'fc', 'Ncp', 'c');

fprintf("  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n", N_per, M_per);
fprintf("  Data saved to 'radar_data.mat'. You can now run clean_interpreter.m.\n");
