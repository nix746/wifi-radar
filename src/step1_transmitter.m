function [waveform, fs, params, cfg] = step1_transmitter(WIFI_STANDARD, ENABLE_VISUALIZATIONS, cbw, mcs)
% TRANSMITTER Generates IEEE 802.11a/g/ax compliant OFDM baseband waveform.
%
% Inputs:
%   WIFI_STANDARD         - '802.11a', '802.11ax', etc.
%   ENABLE_VISUALIZATIONS - boolean to enable plots
%   cbw                   - (Optional) Channel bandwidth ('CBW20', 'CBW40', 'CBW80', 'CBW160')
%   mcs                   - (Optional) Modulation and coding scheme index (0-11)
% Output:
%   waveform - Complex baseband time-domain waveform
%   fs       - Sampling frequency
%   params   - Struct with Wi-Fi parameters
%   cfg      - WLAN configuration object

    if nargin < 3 || isempty(cbw)
        cbw = 'CBW20';
    end
    if nargin < 4 || isempty(mcs)
        mcs = 0;
    end

    fprintf(">> Running Transmitter...\n");

    %% 1. Wi-Fi Frame Configuration
    psdu_length = 4095; % Payload length in bytes
    params = get_wifi_params(WIFI_STANDARD, psdu_length, cbw, mcs);
    cfg = params.cfg;
    fs = params.fs;

    tx_time = transmitTime(cfg);

    fprintf('  Standard:         %s\n', params.standard);
    fprintf('  Bandwidth:        %s\n', cfg.ChannelBandwidth);
    fprintf('  Sampling Rate:    %.2f MHz\n', fs/1e6);
    fprintf('  Packet Duration:  %.2f us\n', tx_time * 1e6);
    fprintf('  Modulation:       MCS %d\n', cfg.MCS);
    fprintf('  Payload Size:     %d bytes\n', psdu_length);

    %% 2. Waveform Generation
    payload_bits = randi([0 1], psdu_length * 8, 1);
    waveform = wlanWaveformGenerator(payload_bits, cfg);

    fprintf("  Waveform generated (%d samples).\n", length(waveform));

    %% 3. Visualization
    if ENABLE_VISUALIZATIONS
        power_spectral_density(waveform, fs, sprintf('Transmitter - Power Spectral Density (%s)', WIFI_STANDARD));
    end
end
