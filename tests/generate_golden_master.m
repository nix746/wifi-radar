% tests/generate_golden_master.m
clc; close all;

[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_dir, '..');
sim_tests_dir = fullfile(sim_project_root, 'tests');

addpath(sim_project_root);
init_paths();

% 1. Set seed for reproducibility
rng(42, 'twister');

% 2. Run simulation steps using current pipeline functions
fprintf('Running step1_transmitter...\n');
[waveform, fs, params, cfg] = step1_transmitter('802.11ax', false, 'CBW20', 0);
save(fullfile(sim_tests_dir, 'golden_waveform.mat'), 'waveform', 'fs');

fprintf('Running step2_channel...\n');
[signal, fc] = step2_channel(waveform, fs, 'Model-A', cfg);
save(fullfile(sim_tests_dir, 'golden_signal.mat'), 'signal', 'fc');

fprintf('Running step3_receiver...\n');
radar_data = step3_receiver(signal, waveform, fs, fc, '802.11ax', false, 'CBW20');
CPer_base = radar_data.CPer_base;
W_2D = radar_data.W_2D;
save(fullfile(sim_tests_dir, 'golden_radar_data.mat'), 'radar_data', 'CPer_base', 'W_2D');

fprintf('Running step4_interpreter (legacy mode, num_targets=2)...\n');
[targets_found, CPer_clean, threshold] = step4_interpreter(radar_data, fs, fc, '802.11ax', false, 2);
save(fullfile(sim_tests_dir, 'golden_clean_results.mat'), 'CPer_clean', 'targets_found', 'threshold');

fprintf('Golden master generated in tests/ directory.\n');
