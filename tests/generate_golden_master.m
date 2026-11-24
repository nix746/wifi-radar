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
[waveform, fs, params, cfg] = step1_transmitter('802.11ax', 'CBW20', 0);
save(fullfile(sim_tests_dir, 'golden_waveform.mat'), 'waveform', 'fs');

fprintf('Running step2_channel...\n');
[signal, fc] = step2_channel(waveform, fs, 'Model-A', cfg);
save(fullfile(sim_tests_dir, 'golden_signal.mat'), 'signal', 'fc');

fprintf('Running step3_receiver...\n');
radar_data = step3_receiver(signal, waveform, fs, fc, '802.11ax', 'CBW20');
CPer_F = radar_data.CPer_F;
Per_F  = radar_data.Per_F;
W      = radar_data.W;
save(fullfile(sim_tests_dir, 'golden_radar_data.mat'), 'radar_data', 'CPer_F', 'Per_F', 'W');

alg_bin = get_detection_algorithm('binary');
alg_coh = get_detection_algorithm('coherent');
fprintf('Running step4_interpreter (Braun 1:1 %s & %s)...\n', alg_bin.name, alg_coh.name);
[targets_bin, CPer_F_bin, Per_F_bin, eta_bin, ~, diag_bin] = step4_interpreter( ...
    radar_data, fs, fc, '802.11ax', 1e-3, alg_bin);
[targets_coh, CPer_F_coh, Per_F_coh, eta_coh] = step4_interpreter( ...
    radar_data, fs, fc, '802.11ax', 1e-3, alg_coh);
B_bin = diag_bin.B;
save(fullfile(sim_tests_dir, 'golden_stc_results.mat'), ...
    'targets_bin', 'CPer_F_bin', 'Per_F_bin', 'eta_bin', 'B_bin', ...
    'targets_coh', 'CPer_F_coh', 'Per_F_coh', 'eta_coh');

fprintf('Golden master generated in tests/ directory.\n');
