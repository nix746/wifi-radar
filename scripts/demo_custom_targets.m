% DEMO_CUSTOM_TARGETS
% Demonstrates defining physical targets (human, car, pet) and evaluating
% radar detection under configurable propagation conditions, carrier bands,
% bandwidths (CBW20 - CBW160), and adaptive sensing options.

clc;
clear variables;
close all force;

fprintf("====================================================\n");
fprintf("   Wi-Fi Radar - Custom Physical Targets Demo       \n");
fprintf("====================================================\n\n");

[current_script_dir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(current_script_dir, '..'));
init_paths();

%% 1. Propagation, Band & Standard Configuration
WIFI_STANDARD = '802.11ax';   % '802.11a' or '802.11ax'
CARRIER_BAND  = '5GHz';       % '2.4GHz', '5GHz', '6GHz' or numeric Hz (e.g., 5.5e9)
CHANNEL_MODEL = 'Model-A';    % 'Model-A' (flat/LOS), 'Model-B' (residential), 'Model-D' (office)
SNR_DB        = 25;           % Channel SNR in dB (Gaussian noise level)

% Adaptive Transmission (ISAC) vs Manual Parameters
ENABLE_AUTO_ADAPT = false;    % true = Auto-select CBW & MCS based on channel SNR & band
MANUAL_CBW        = 'CBW20';  % 'CBW20', 'CBW40', 'CBW80', 'CBW160'
MANUAL_MCS        = 0;        % 0 - 11 for 802.11ax, 0 - 7 for 802.11a

ENABLE_VISUALIZATIONS = true;

% Resolve Bandwidth and MCS
[fc_hz, band_str] = get_carrier_frequency(CARRIER_BAND);

if ENABLE_AUTO_ADAPT
    [cbw, mcs, adapt_summary] = adaptive_wifi_params(SNR_DB, WIFI_STANDARD, band_str);
    fprintf("[Auto-Adaptation Engine] %s\n\n", adapt_summary);
else
    cbw = MANUAL_CBW;
    mcs = MANUAL_MCS;
    % Physical restriction: 2.4 GHz Wi-Fi strictly enforces 20 MHz
    if strcmp(band_str, '2.4GHz') && ~strcmp(cbw, 'CBW20')
        warning('2.4 GHz band restricts Wi-Fi to 20 MHz. Enforcing CBW20 (overriding %s).', cbw);
        cbw = 'CBW20';
    end
end

%% 2. Define Physical Scenario Targets
% Properties:
%   - type: 'human' (RCS ~ 1.0 m^2), 'car' (RCS ~ 10.0 m^2), 'pet' (RCS ~ 0.1 m^2)
%   - range_m: Physical distance in meters
%   - velocity_mps: Velocity in m/s (positive = opening, negative = closing)
targets = [
    struct('type', 'human', 'range_m', 22.5, 'velocity_mps',  1.4)
    struct('type', 'car',   'range_m', 45.0, 'velocity_mps', -3.5)
    struct('type', 'pet',   'range_m', 15.0, 'velocity_mps',  0.6)
    ];

fprintf("Scenario Configuration:\n");
fprintf("  Carrier Band:     %s (fc = %.3f GHz)\n", band_str, fc_hz / 1e9);
fprintf("  Propagation:      %s | SNR = %.1f dB\n", CHANNEL_MODEL, SNR_DB);
fprintf("  Waveform Profile: %s | %s | MCS %d\n", WIFI_STANDARD, cbw, mcs);
fprintf("  Targets Defined:\n");
for i = 1 : length(targets)
    fprintf("    Target %d: %s | Range = %.1f m | Velocity = %+.2f m/s\n", ...
        i, upper(targets(i).type), targets(i).range_m, targets(i).velocity_mps);
end
fprintf("\n");

%% 3. Run Pipeline
fprintf("[Step 1/4] Generating Wi-Fi %s Frame (%s, MCS %d)...\n", WIFI_STANDARD, cbw, mcs);
[waveform, fs, params, cfg] = step1_transmitter(WIFI_STANDARD, false, cbw, mcs);
fprintf("\n");

fprintf("[Step 2/4] Simulating Channel (%s, fc = %.3f GHz, SNR = %.1f dB)...\n", CHANNEL_MODEL, fc_hz / 1e9, SNR_DB);
[rx_signal, fc] = step2_channel(waveform, fs, CHANNEL_MODEL, cfg, targets, SNR_DB, fc_hz);
fprintf("\n");

fprintf("[Step 3/4] Processing Range-Doppler Periodogram...\n");
radar_data = step3_receiver(rx_signal, waveform, fs, fc, WIFI_STANDARD, ENABLE_VISUALIZATIONS, cbw);
fprintf("\n");

fprintf("[Step 4/4] Detecting Targets and Running CLEAN Algorithm...\n");
targets_found = step4_interpreter(radar_data, fs, fc, WIFI_STANDARD, ENABLE_VISUALIZATIONS, length(targets));
fprintf("\n");

fprintf("====================================================\n");
fprintf("Demo completed successfully.\n");
fprintf("====================================================\n");
