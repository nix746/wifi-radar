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
environments_to_test = [false, true];

for env_idx = 1:length(environments_to_test)
    USE_TGAX_CHANNEL = environments_to_test(env_idx);
    env_name = {'Ideal Channel', 'TGax Multipath'};
    
    for std_idx = 1:length(standards_to_test)
        WIFI_STANDARD = standards_to_test{std_idx};
        
        % Set dedicated figures subfolder for this standard and channel configuration
        if USE_TGAX_CHANNEL
            env_tag = 'tgax';
        else
            env_tag = 'ideal';
        end
        std_tag = lower(regexprep(WIFI_STANDARD, '[^a-zA-Z0-9]', '_'));
        config_subfolder = sprintf('%s_%s', env_tag, std_tag);
        config_fig_dir = fullfile(run_root_dir, config_subfolder);
        if ~exist(config_fig_dir, 'dir')
            mkdir(config_fig_dir);
        end
        setappdata(0, 'wifi_radar_figures_dir', config_fig_dir);
        
        fprintf('\n=======================================================\n');
        fprintf('=== STANDARD: %s | ENVIRONMENT: %s ===\n', WIFI_STANDARD, env_name{env_idx});
        fprintf('=======================================================\n\n');

        fprintf("[Step 1/4] Generating Wi-Fi %s Frame...\n", WIFI_STANDARD);
        [waveform, fs, params, cfg] = step1_transmitter(WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        fprintf("[Step 2/4] Simulating Multipath Channel with Doppler...\n");
        [rx_signal, fc, c] = step2_channel(waveform, fs, USE_TGAX_CHANNEL);
        fprintf("\n");

        fprintf("[Step 3/4] Processing Range-Doppler Periodogram...\n");
        radar_data = step3_receiver(rx_signal, waveform, fs, fc, c, WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        fprintf("[Step 4/4] Detecting Targets and Running CLEAN Algorithm...\n");
        targets_found = step4_interpreter(radar_data, fs, fc, c, WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        drawnow;
        fprintf("Finished configuration %s (%s). Figures saved to:\n  %s\n\n", ...
            WIFI_STANDARD, env_name{env_idx}, config_fig_dir);

        is_last_run = (env_idx == length(environments_to_test)) && (std_idx == length(standards_to_test));
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

