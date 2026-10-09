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

[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(current_dir, '..', 'lib'));

%% 1. Load Transmitted Waveform and Received Signal
if ~isfile("waveform.mat") || ~isfile("signal.mat")
    error("waveform.mat or signal.mat not found. Please run transmitter.m and channel.m first!");
end
load("waveform.mat", "waveform", "fs", "WIFI_STANDARD");
load("signal.mat", "signal", "fc", "c");

if ~exist('WIFI_STANDARD', 'var')
    WIFI_STANDARD = '802.11a'; % Fallback
end

params = get_wifi_params(WIFI_STANDARD);
cbw = params.cfg.ChannelBandwidth;
Nfft = params.Nfft;
Ncp = params.Ncp;
Nsym_len = Nfft + Ncp;

%% 2. Synchronization & Payload Extraction
% Detect packet start
pktOffset = wlanPacketDetect(signal, cbw);
if isempty(pktOffset)
    warning('Packet not detected by wlanPacketDetect. Falling back to ideal synchronization.');
    pktOffset = 0;
    fineOffset = 0;
else
    % Estimate fine symbol timing
    fineOffset = wlanSymbolTimingEstimate(signal(pktOffset+1:end), cbw);
end

% Total synchronization offset
sync_idx = pktOffset + fineOffset; 

% Extract payload from synchronized signal
payload_start_rx = sync_idx + params.payload_start;

if payload_start_rx > length(signal)
    error('Synchronized payload start is beyond the end of the signal.');
end

y_cut = signal(payload_start_rx : end);
x_cut = waveform(params.payload_start : end);

%% 3. Manual OFDM Demodulation
[F_rx, n_symbols_rx] = demodulate(y_cut, Nfft, Ncp);
[F_tx, n_symbols_tx] = demodulate(x_cut, Nfft, Ncp);

% Match sizes (in case channel delay caused y_cut to have fewer complete symbols)
n_symbols = min(n_symbols_rx, n_symbols_tx);
F_rx = F_rx(:, 1:n_symbols);
F_tx = F_tx(:, 1:n_symbols);

fprintf("  Demodulated %d OFDM symbols (%d subcarriers each).\n", n_symbols, Nfft);

%% 4. & 5. Channel Estimation, MTI Filtering and DC Subcarrier Interpolation
H_shifted = estimate_channel_zf(F_rx, F_tx, params);

%% 6. & 7. 2D Blackman-Harris Windowing and Complex Periodogram Generation
[CPer_base, W_2D_unshifted, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols);

%% 8. Save Data for Interpretation
save('radar_data.mat', 'CPer_base', 'W_2D_unshifted', 'N_per', 'M_per', ...
     'Nfft', 'n_symbols', 'fs', 'fc', 'Ncp', 'c', 'WIFI_STANDARD');

fprintf("  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n", N_per, M_per);
fprintf("  Data saved to 'radar_data.mat'. You can now run clean_interpreter.m.\n");

%% 9. Visualization
if exist('ENABLE_VISUALIZATIONS', 'var') && ENABLE_VISUALIZATIONS
    plot_constellation(F_rx(:), sprintf('Receiver - Demodulated Constellation (RX) (%s)', WIFI_STANDARD));
    
    % 2D Heatmaps (Demodulated Symbols & Channel Response)
    % Center frequencies (DC at index 33) using fftshift for visualization
    plot_heatmap(fftshift(F_rx, 1), sprintf('Demodulated Symbols (%s)', WIFI_STANDARD), 'Symbol Index (Time)', 'Subcarrier Index (Frequency)');
    
    % Reconstruct raw H matrix (before MTI filter) for full channel visualization
    H_raw = F_rx ./ (F_tx + 1e-9);
    plot_heatmap(fftshift(H_raw, 1), sprintf('Channel Response (H Matrix) (%s)', WIFI_STANDARD), 'Symbol Index (Time)', 'Subcarrier Index (Freq)');
    
    % Prepare axes for 3D plot
    [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per, c);
    
    plot_range_doppler_3d(CPer_base, axis_velocity, axis_range, sprintf('Receiver - 3D Range-Doppler Map (%s)', WIFI_STANDARD));
end
