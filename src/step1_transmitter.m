function [waveform, fs, params, cfg] = step1_transmitter(WIFI_STANDARD, ENABLE_VISUALIZATIONS, cbw, mcs, psdu_length)
% STEP1_TRANSMITTER Generates IEEE 802.11a/ax compliant OFDM baseband waveform.
%
% Inputs:
%   WIFI_STANDARD         - '802.11a' or '802.11ax'
%   ENABLE_VISUALIZATIONS - Logical flag to enable diagnostic plots
%   cbw                   - (Optional) Channel bandwidth ('CBW20', 'CBW40', 'CBW80', 'CBW160')
%   mcs                   - (Optional) Modulation and coding scheme index (0-11)
%   psdu_length           - (Optional) Payload length in bytes (default: auto-scaled for constant frame duration)
%
% Outputs:
%   waveform              - Complex baseband time-domain waveform
%   fs                    - Sampling frequency [Hz]
%   params                - Struct with Wi-Fi and OFDM parameters
%   cfg                   - WLAN Toolbox configuration object

    if nargin < 2 || isempty(ENABLE_VISUALIZATIONS)
        ENABLE_VISUALIZATIONS = false;
    end
    if nargin < 3 || isempty(cbw)
        cbw = 'CBW20';
    end
    if nargin < 4 || isempty(mcs)
        mcs = 0;
    end
    if nargin < 5
        psdu_length = [];
    end

    fprintf('>> Running Transmitter...\n');

    %% 1. Wi-Fi Frame Configuration
    params      = get_wifi_params(WIFI_STANDARD, psdu_length, cbw, mcs);
    psdu_length = params.psdu_length;
    cfg         = params.cfg;
    fs          = params.fs;
    tx_time     = transmitTime(cfg);

    fprintf('  Standard:         %s\n', params.standard);
    fprintf('  Bandwidth:        %s\n', cfg.ChannelBandwidth);
    fprintf('  Sampling Rate:    %.2f MHz\n', fs / 1e6);
    fprintf('  Packet Duration:  %.2f us\n', tx_time * 1e6);
    fprintf('  Modulation:       MCS %d\n', cfg.MCS);
    fprintf('  Payload Size:     %d bytes\n', psdu_length);

    %% 2. Baseband Waveform Synthesis
    payload_bits = randi([0, 1], psdu_length * 8, 1);
    waveform     = wlanWaveformGenerator(payload_bits, cfg);

    fprintf('  Waveform generated (%d samples).\n', length(waveform));

    %% 3. Diagnostic Visualization
    if ENABLE_VISUALIZATIONS
        power_spectral_density(waveform, fs, sprintf('Transmitter - Power Spectral Density (%s)', WIFI_STANDARD));
    end
end
