% RUN_FULL_SIMULATION
% Master execution script that runs the full end-to-end Wi-Fi Radar simulation:
%   1. Signal Generation (Transmitter)
%   2. Multipath & Doppler Channel Simulation (Channel)
%   3. Range-Doppler Processing (Receiver Pipeline)
%   4. Target Detection & Cancellation (CLEAN Interpreter)

clc;
clear variables;
close all force;

fprintf("====================================================\n");
fprintf("       Wi-Fi Passive Radar Full Simulation          \n");
fprintf("====================================================\n\n");

ENABLE_VISUALIZATIONS = true;

[current_script_dir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(current_script_dir, '..'));
init_paths();

% Initialize unique timestamped directory for this run
timestamp_str = char(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
run_root_dir = fullfile(current_script_dir, '..', 'results', 'figures', sprintf('run_%s', timestamp_str));
if ~exist(run_root_dir, 'dir')
    mkdir(run_root_dir);
end
fprintf("Figure output directory for this run:\n  %s\n\n", run_root_dir);

standards_to_test = {'802.11a', '802.11ax'};

% Channel models to test (TGax delay profiles by letter or 'None'):
%   'A' - Flat fading (Single tap / Direct path only, no multipath clutter)
%   'B' - Indoor residential (RMS delay spread 15 ns, 9 taps)
% Note: You can easily add 'C', 'D' (Office), 'E', 'F'
channel_models_to_test = {'A', 'B'};

for ch_idx = 1:length(channel_models_to_test)
    CHANNEL_MODEL = channel_models_to_test{ch_idx};

    for std_idx = 1:length(standards_to_test)
        WIFI_STANDARD = standards_to_test{std_idx};

        % Set dedicated figures subfolder for this standard and channel model
        ch_tag  = lower(sprintf('model_%s', regexprep(CHANNEL_MODEL, '[^a-zA-Z0-9]', '_')));
        std_tag = lower(regexprep(WIFI_STANDARD, '[^a-zA-Z0-9]', '_'));
        config_subfolder = sprintf('%s_%s', ch_tag, std_tag);
        config_fig_dir = fullfile(run_root_dir, config_subfolder);
        if ~exist(config_fig_dir, 'dir')
            mkdir(config_fig_dir);
        end
        setappdata(0, 'wifi_radar_figures_dir', config_fig_dir);

        fprintf('\n=======================================================\n');
        fprintf('=== STANDARD: %s | CHANNEL: %s ===\n', WIFI_STANDARD, CHANNEL_MODEL);
        fprintf('=======================================================\n\n');

        fprintf("[Step 1/4] Generating Wi-Fi %s Frame...\n", WIFI_STANDARD);
        [waveform, fs, params, cfg] = step1_transmitter(WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        fprintf("[Step 2/4] Simulating Channel (%s) with Targets...\n", CHANNEL_MODEL);
        [rx_signal, fc] = step2_channel(waveform, fs, CHANNEL_MODEL, cfg);
        fprintf("\n");

        fprintf("[Step 3/4] Processing Range-Doppler Periodogram...\n");
        radar_data = step3_receiver(rx_signal, waveform, fs, fc, WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        fprintf("[Step 4/4] Detecting Targets and Running CLEAN Algorithm...\n");
        targets_found = step4_interpreter(radar_data, fs, fc, WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        drawnow;
        fprintf("Finished configuration %s (%s). Figures saved to:\n  %s\n\n", ...
            WIFI_STANDARD, CHANNEL_MODEL, config_fig_dir);

        is_last_run = (ch_idx == length(channel_models_to_test)) && (std_idx == length(standards_to_test));
        if ~is_last_run
            % Automatically close figure windows to prevent window clutter
            close all force;
        end
    end
end

fprintf("====================================================\n");
fprintf("All simulations completed successfully.\n");
fprintf("All figures saved in:\n  %s\n", run_root_dir);
fprintf("====================================================\n");

