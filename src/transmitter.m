% TRANSMITTER
% Generates IEEE 802.11a/g compliant Non-HT OFDM baseband waveform.
%
% Output:
%   waveform.mat - Contains complex baseband time-domain waveform and metadata.

fprintf(">> Running Transmitter...\n");

WIFI_STANDARD = '802.11ax'; % Switch between '802.11a' and '802.11ax'

% Add lib directory to path
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(current_dir, '..', 'lib'));

%% 1. Wi-Fi Frame Configuration
psdu_length = 4095; % Payload length in bytes
params = get_wifi_params(WIFI_STANDARD, psdu_length);
cfg = params.cfg;
fs = params.fs;

tx_time = transmitTime(cfg);

fprintf('  Standard:         %s\n', params.standard);
fprintf('  Sampling Rate:    %.2f MHz\n', fs/1e6);
fprintf('  Packet Duration:  %.2f us\n', tx_time * 1e6);
fprintf('  Modulation:       MCS %d\n', cfg.MCS);
fprintf('  Payload Size:     %d bytes\n', psdu_length);

%% 2. Waveform Generation
payload_bits = randi([0 1], psdu_length * 8, 1);
waveform = wlanWaveformGenerator(payload_bits, cfg);

%% 3. Save Output
save("waveform.mat", "waveform", "cfg", "fs", "WIFI_STANDARD", "params");
fprintf("  Waveform saved to 'waveform.mat' (%d samples).\n", length(waveform));

%% 4. Visualization
if exist('ENABLE_VISUALIZATIONS', 'var') && ENABLE_VISUALIZATIONS
    plot_signal_time_domain(waveform, fs, 'Transmitter - Time Domain (I & Q)');
    plot_power_spectral_density(waveform, fs, sprintf('Transmitter - Power Spectral Density (%s)', WIFI_STANDARD));
end
