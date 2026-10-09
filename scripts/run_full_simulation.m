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

% Enable visualizations for a single simulation run
ENABLE_VISUALIZATIONS = true;
USE_TGAX_CHANNEL = true;

% Set up paths
[current_script_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_script_dir, '..');
sim_src_dir = fullfile(sim_project_root, 'src');
sim_lib_dir = fullfile(sim_project_root, 'lib');

addpath(sim_src_dir);
addpath(sim_lib_dir);

sim_orig_dir = pwd;
cd(sim_src_dir);

standards_to_test = {'802.11a', '802.11ax'};

try
    for i = 1:length(standards_to_test)
        WIFI_STANDARD = standards_to_test{i};
        fprintf('\n=======================================================\n');
        fprintf('=== RUNNING SIMULATION FOR STANDARD: %s ===\n', WIFI_STANDARD);
        fprintf('=======================================================\n\n');

        % Step 1: Transmitter
        fprintf("[Step 1/4] Generating Wi-Fi %s Frame...\n", WIFI_STANDARD);
        run(fullfile(sim_src_dir, 'transmitter.m'));
        fprintf("\n");

        % Step 2: Channel
        fprintf("[Step 2/4] Simulating Multipath Channel with Doppler...\n");
        run(fullfile(sim_src_dir, 'channel.m'));
        fprintf("\n");

        % Step 3: Receiver Pipeline
        fprintf("[Step 3/4] Processing Range-Doppler Periodogram...\n");
        run(fullfile(sim_src_dir, 'receiver_pipeline.m'));
        fprintf("\n");

        % Step 4: Target Detection & CLEAN
        fprintf("[Step 4/4] Detecting Targets and Running CLEAN Algorithm...\n");
        run(fullfile(sim_src_dir, 'clean_interpreter.m'));
        fprintf("\n");

        if i < length(standards_to_test)
            fprintf('Simulation for %s complete.\n', WIFI_STANDARD);
            fprintf('Check the generated figures. Press any key in the Command Window to run the next standard...\n');
            pause;
        end
    end
catch ME
    cd(sim_orig_dir);
    rethrow(ME);
end

% Return to project root
cd(sim_project_root);
fprintf("====================================================\n");
fprintf("All simulations completed successfully.\n");
fprintf("====================================================\n");
