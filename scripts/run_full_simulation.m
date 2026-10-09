% RUN_FULL_SIMULATION
% Master execution script that runs the full end-to-end Wi-Fi Radar simulation:
%   1. Signal Generation (Transmitter)
%   2. Multipath & Doppler Channel Simulation (Channel)
%   3. Range-Doppler Processing (Receiver Pipeline)
%   4. Target Detection & Cancellation (CLEAN Interpreter)

clc;
close all;

fprintf("====================================================\n");
fprintf("       Wi-Fi Passive Radar Full Simulation          \n");
fprintf("====================================================\n\n");

ENABLE_VISUALIZATIONS = true;

[current_script_dir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(current_script_dir, '..'));
init_paths();

standards_to_test = {'802.11a', '802.11ax'};
environments_to_test = [false, true];

for env_idx = 1:length(environments_to_test)
    USE_TGAX_CHANNEL = environments_to_test(env_idx);
    env_name = {'Ideal Channel', 'TGax Multipath'};
    
    for std_idx = 1:length(standards_to_test)
        WIFI_STANDARD = standards_to_test{std_idx};
        
        fprintf('\n=======================================================\n');
        fprintf('=== STANDARD: %s | ENVIRONMENT: %s ===\n', WIFI_STANDARD, env_name{env_idx});
        fprintf('=======================================================\n\n');

        fprintf("[Step 1/4] Generating Wi-Fi %s Frame...\n", WIFI_STANDARD);
        [waveform, fs, params, cfg] = transmitter(WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        fprintf("[Step 2/4] Simulating Multipath Channel with Doppler...\n");
        [rx_signal, fc, c] = channel(waveform, fs, USE_TGAX_CHANNEL);
        fprintf("\n");

        fprintf("[Step 3/4] Processing Range-Doppler Periodogram...\n");
        radar_data = receiver_pipeline(rx_signal, waveform, fs, fc, c, WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        fprintf("[Step 4/4] Detecting Targets and Running CLEAN Algorithm...\n");
        targets_found = clean_interpreter(radar_data, fs, fc, c, WIFI_STANDARD, ENABLE_VISUALIZATIONS);
        fprintf("\n");

        is_last_run = (env_idx == length(environments_to_test)) && (std_idx == length(standards_to_test));
        if ~is_last_run
            fprintf('Simulation complete. Press any key to run the next configuration...\n');
            pause;
        end
    end
end

fprintf("====================================================\n");
fprintf("All simulations completed successfully.\n");
fprintf("====================================================\n");
