% tests/verify_regression.m
clc; close all;

fprintf('--- Running Regression Test ---\n');

[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_dir, '..');
sim_tests_dir = fullfile(sim_project_root, 'tests');

addpath(sim_project_root);
init_paths();

rng(42, 'twister');

% Run pipeline with exact same seed
[waveform, fs, params, cfg] = step1_transmitter('802.11ax', false, 'CBW20', 0);
[signal, fc] = step2_channel(waveform, fs, 'Model-A', cfg);
radar_data = step3_receiver(signal, waveform, fs, fc, '802.11ax', false, 'CBW20');
[targets_found, CPer_clean, threshold] = step4_interpreter(radar_data, fs, fc, '802.11ax', false, 2);

fprintf('--- Verifying against Golden Master ---\n');
has_error = false;
tol = 1e-12;

% Check waveform
load(fullfile(sim_tests_dir, 'golden_waveform.mat'), 'waveform');
golden_waveform = waveform;
err_wf = max(abs(waveform(:) - golden_waveform(:)));
fprintf('Waveform max diff: %g\n', err_wf);
if err_wf > tol
    warning('Waveform regression failed!');
    has_error = true;
end

% Check signal
load(fullfile(sim_tests_dir, 'golden_signal.mat'), 'signal');
golden_signal = signal;
err_sig = max(abs(signal(:) - golden_signal(:)));
fprintf('Signal max diff: %g\n', err_sig);
if err_sig > tol
    warning('Signal regression failed!');
    has_error = true;
end

% Check radar_data
load(fullfile(sim_tests_dir, 'golden_radar_data.mat'), 'CPer_base', 'W_2D');
golden_CPer_base = CPer_base;
golden_W_2D = W_2D;
err_cper = max(abs(radar_data.CPer_base(:) - golden_CPer_base(:)));
err_w2d = max(abs(radar_data.W_2D(:) - golden_W_2D(:)));
fprintf('CPer_base max diff: %g\n', err_cper);
fprintf('W_2D max diff: %g\n', err_w2d);
if err_cper > tol || err_w2d > tol
    warning('Radar data regression failed!');
    has_error = true;
end

% Check clean results
golden_clean = load(fullfile(sim_tests_dir, 'golden_clean_results.mat'));
err_clean = max(abs(CPer_clean(:) - golden_clean.CPer_clean(:)));
err_targets = max(abs(targets_found(:) - golden_clean.targets_found(:)));
fprintf('CPer_clean max diff: %g\n', err_clean);
fprintf('targets_found max diff: %g\n', err_targets);
if err_clean > tol || err_targets > tol
    warning('CLEAN results regression failed!');
    has_error = true;
end

% --- Verify Adaptive Threshold functionality ---
fprintf('--- Verifying Adaptive Threshold Functionality ---\n');
% 1. Legacy call: threshold must be 0
if threshold ~= 0
    warning('Legacy call threshold must be 0!');
    has_error = true;
end

% 2. Adaptive call with margin_dB
margin_dB = 15;
[targets_adapt, CPer_adapt, th_adapt] = step4_interpreter(radar_data, fs, fc, '802.11ax', false, 5, margin_dB);
expected_th = (median(abs(radar_data.CPer_base(:))) / 0.6745) * 10^(margin_dB / 20);
err_th = abs(th_adapt - expected_th);
fprintf('Adaptive threshold diff: %g (expected: %g, got: %g)\n', err_th, expected_th, th_adapt);
if err_th > tol
    warning('Adaptive threshold calculation mismatch!');
    has_error = true;
end

% Residual peak must be strictly below threshold after stopping or maximum targets reached
max_res = max(abs(CPer_adapt(:)));
fprintf('Residual peak: %g, Threshold: %g\n', max_res, th_adapt);
if size(targets_adapt, 1) < 5 && max_res >= th_adapt
    warning('CLEAN stopped early but residual peak exceeds threshold!');
    has_error = true;
end

if has_error
    error('REGRESSION TEST FAILED.');
else
    fprintf('ALL REGRESSION & ADAPTIVE CLEAN TESTS PASSED SUCCESSFULLY.\n');
end
