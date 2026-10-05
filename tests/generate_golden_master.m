% tests/generate_golden_master.m
clc; close all;

[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_dir, '..');
sim_src_dir = fullfile(sim_project_root, 'src');
sim_tests_dir = fullfile(sim_project_root, 'tests');

cd(sim_src_dir);

% 1. Set seed for reproducibility
rng(42, 'twister');

% 2. Run simulation steps
fprintf('Running transmitter...\n');
run('transmitter.m');
copyfile('waveform.mat', fullfile(sim_tests_dir, 'golden_waveform.mat'));

fprintf('Running channel...\n');
run('channel.m');
copyfile('signal.mat', fullfile(sim_tests_dir, 'golden_signal.mat'));

fprintf('Running receiver_pipeline...\n');
run('receiver_pipeline.m');
copyfile('radar_data.mat', fullfile(sim_tests_dir, 'golden_radar_data.mat'));

fprintf('Running clean_interpreter...\n');
run('clean_interpreter.m');
save(fullfile(sim_tests_dir, 'golden_clean_results.mat'), 'CPer_clean', 'targets_found', 'Per_dB_clean', 'Per_dB_base');

fprintf('Golden master generated in tests/ directory.\n');
