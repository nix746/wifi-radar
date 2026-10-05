% tests/verify_regression.m
clc; close all;

fprintf('--- Running Regression Test ---\n');

[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_dir, '..');
sim_src_dir = fullfile(sim_project_root, 'src');
sim_tests_dir = fullfile(sim_project_root, 'tests');

% Go to src directory to run the pipeline exactly as users do
cd(sim_src_dir);

rng(42, 'twister');

run('transmitter.m');
run('channel.m');
run('receiver_pipeline.m');
run('clean_interpreter.m');

fprintf('--- Verifying against Golden Master ---\n');
has_error = false;
tol = 1e-12;

% Check waveform
load(fullfile(sim_tests_dir, 'golden_waveform.mat'), 'waveform');
golden_waveform = waveform;
load('waveform.mat', 'waveform');
err_wf = max(abs(waveform(:) - golden_waveform(:)));
fprintf('Waveform max diff: %g\n', err_wf);
if err_wf > tol
    warning('Waveform regression failed!');
    has_error = true;
end

% Check signal
load(fullfile(sim_tests_dir, 'golden_signal.mat'), 'signal');
golden_signal = signal;
load('signal.mat', 'signal');
err_sig = max(abs(signal(:) - golden_signal(:)));
fprintf('Signal max diff: %g\n', err_sig);
if err_sig > tol
    warning('Signal regression failed!');
    has_error = true;
end

% Check radar_data
load(fullfile(sim_tests_dir, 'golden_radar_data.mat'), 'CPer_base', 'W_2D_unshifted');
golden_CPer_base = CPer_base;
golden_W_2D = W_2D_unshifted;
load('radar_data.mat', 'CPer_base', 'W_2D_unshifted');
err_cper = max(abs(CPer_base(:) - golden_CPer_base(:)));
err_w2d = max(abs(W_2D_unshifted(:) - golden_W_2D(:)));
fprintf('CPer_base max diff: %g\n', err_cper);
fprintf('W_2D_unshifted max diff: %g\n', err_w2d);
if err_cper > tol || err_w2d > tol
    warning('Radar data regression failed!');
    has_error = true;
end

% Check clean results (from current workspace)
golden_clean = load(fullfile(sim_tests_dir, 'golden_clean_results.mat'));
err_clean = max(abs(CPer_clean(:) - golden_clean.CPer_clean(:)));
err_targets = max(abs(targets_found(:) - golden_clean.targets_found(:)));
fprintf('CPer_clean max diff: %g\n', err_clean);
fprintf('targets_found max diff: %g\n', err_targets);
if err_clean > tol || err_targets > tol
    warning('CLEAN results regression failed!');
    has_error = true;
end

cd(sim_project_root);
if has_error
    error('REGRESSION TEST FAILED.');
else
    fprintf('REGRESSION TEST PASSED.\n');
end
