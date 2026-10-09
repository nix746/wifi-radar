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

% Start index of the packet (0-based offset + fine offset + 1 for 1-based indexing)
% Wait, fineOffset is relative to pktOffset. So total offset is pktOffset + fineOffset.
sync_idx = pktOffset + fineOffset; 

% Extract payload from synchronized signal
payload_start_rx = sync_idx + params.payload_start;

if payload_start_rx > length(signal)
    error('Synchronized payload start is beyond the end of the signal.');
end

y_cut = signal(payload_start_rx : end);
x_cut = waveform(params.payload_start : end);

%% 3. Manual OFDM Demodulation
[F_rx, n_symbols] = demodulate(y_cut, Nfft, Ncp);
[F_tx, ~]         = demodulate(x_cut, Nfft, Ncp);

fprintf("  Demodulated %d OFDM symbols (%d subcarriers each).\n", n_symbols, Nfft);

%% 4. & 5. Channel Estimation, MTI Filtering and DC Subcarrier Interpolation
H_shifted = estimate_channel_zf(F_rx, F_tx, params);

%% 6. & 7. 2D Blackman-Harris Windowing and Complex Periodogram Generation
[CPer_base, W_2D_unshifted, N_per, M_per] = compute_range_doppler_map(H_shifted, Nfft, n_symbols);

%% 8. Save Data for Interpretation
save('radar_data.mat', 'CPer_base', 'W_2D_unshifted', 'N_per', 'M_per', ...
     'Nfft', 'n_symbols', 'fs', 'fc', 'Ncp', 'c');

fprintf("  Pipeline complete. Radar map matrix: %d (Range bins) x %d (Doppler bins).\n", N_per, M_per);
fprintf("  Data saved to 'radar_data.mat'. You can now run clean_interpreter.m.\n");

%% 9. Visualization
if exist('ENABLE_VISUALIZATIONS', 'var') && ENABLE_VISUALIZATIONS
    plot_constellation(F_rx(:), 'Receiver - Demodulated Constellation (RX)');
    
    % 2D Heatmaps (Demodulated Symbols & Channel Response)
    % Center frequencies (DC at index 33) using fftshift for visualization
    plot_heatmap(fftshift(F_rx, 1), 'Demodulated Symbols', 'Symbol Index (Time)', 'Subcarrier Index (Frequency)');
    
    % Reconstruct raw H matrix (before MTI filter) for full channel visualization
    H_raw = F_rx ./ (F_tx + 1e-9);
    plot_heatmap(fftshift(H_raw, 1), 'Channel Response (H Matrix)', 'Symbol Index (Time)', 'Subcarrier Index (Freq)');
    
    % Prepare axes for 3D plot
    delta_r = c / (2 * fs);
    axis_range = linspace(0, delta_r * Nfft, N_per);
    T_sym_total = (Nfft + Ncp) / fs;
    v_unamb = c / (2 * fc * T_sym_total);
    axis_velocity = linspace(-v_unamb/2, v_unamb/2, M_per);
    
    plot_range_doppler_3d(CPer_base, axis_velocity, axis_range, 'Receiver - 3D Range-Doppler Map');
end
