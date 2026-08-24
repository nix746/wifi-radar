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

% Set up paths
[current_script_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_script_dir, '..');
sim_src_dir = fullfile(sim_project_root, 'src');
sim_lib_dir = fullfile(sim_project_root, 'lib');

addpath(sim_src_dir);
addpath(sim_lib_dir);

sim_orig_dir = pwd;
cd(sim_src_dir);

try
    % Step 1: Transmitter
    fprintf("[Step 1/4] Generating Wi-Fi 802.11a Frame...\n");
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

catch ME
    cd(sim_orig_dir);
    rethrow(ME);
end

% Return to project root
cd(sim_project_root);
fprintf("====================================================\n");
fprintf("Simulation completed successfully.\n");
fprintf("Figures and results have been generated in results/figures/\n");
fprintf("====================================================\n");
