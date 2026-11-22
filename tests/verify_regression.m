% tests/verify_regression.m
clc; close all;

fprintf('--- Running Regression & Braun Binary/Coherent STC Verification ---\n');

[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
sim_project_root = fullfile(current_dir, '..');
sim_tests_dir    = fullfile(sim_project_root, 'tests');

addpath(sim_project_root);
init_paths();

rng(42, 'twister');

% Run pipeline with exact same seed as generate_golden_master
[waveform, fs, params, cfg] = step1_transmitter('802.11ax', false, 'CBW20', 0);
[signal, fc] = step2_channel(waveform, fs, 'Model-A', cfg);
radar_data = step3_receiver(signal, waveform, fs, fc, '802.11ax', false, 'CBW20');
[targets_bin, CPer_F_bin, Per_F_bin, eta_bin, ~, diag_bin] = step4_interpreter( ...
    radar_data, fs, fc, '802.11ax', false);
[targets_coh, CPer_F_coh, Per_F_coh, eta_coh] = step4_interpreter( ...
    radar_data, fs, fc, '802.11ax', false, 1e-3, 'coherent');

fprintf('--- 1. Verifying against Golden Master ---\n');
has_error = false;
tol = 1e-12;

% Check waveform
gw = load(fullfile(sim_tests_dir, 'golden_waveform.mat'), 'waveform');
err_wf = max(abs(waveform(:) - gw.waveform(:)));
fprintf('Waveform max diff: %g\n', err_wf);
if err_wf > tol
    warning('Waveform regression failed!');
    has_error = true;
end

% Check signal
gs = load(fullfile(sim_tests_dir, 'golden_signal.mat'), 'signal');
err_sig = max(abs(signal(:) - gs.signal(:)));
fprintf('Signal max diff: %g\n', err_sig);
if err_sig > tol
    warning('Signal regression failed!');
    has_error = true;
end

% Check radar_data
gr = load(fullfile(sim_tests_dir, 'golden_radar_data.mat'), 'CPer_F', 'Per_F', 'W');
err_cper = max(abs(radar_data.CPer_F(:) - gr.CPer_F(:)));
err_per  = max(abs(radar_data.Per_F(:)  - gr.Per_F(:)));
err_w    = max(abs(radar_data.W(:)      - gr.W(:)));
fprintf('CPer_F max diff: %g | Per_F max diff: %g | W max diff: %g\n', err_cper, err_per, err_w);
if err_cper > tol || err_per > tol || err_w > tol
    warning('Radar data regression failed!');
    has_error = true;
end

% Check Binary (default) & Coherent STC golden results
gstc = load(fullfile(sim_tests_dir, 'golden_stc_results.mat'), ...
    'targets_bin', 'CPer_F_bin', 'Per_F_bin', 'eta_bin', 'B_bin', ...
    'targets_coh', 'CPer_F_coh', 'Per_F_coh', 'eta_coh');

err_bin_cper = max(abs(CPer_F_bin(:) - gstc.CPer_F_bin(:)));
err_bin_per  = max(abs(Per_F_bin(:)  - gstc.Per_F_bin(:)));
err_bin_eta  = abs(eta_bin - gstc.eta_bin);
err_bin_b    = max(abs(double(diag_bin.B(:)) - double(gstc.B_bin(:))));
fprintf('Binary STC (default) CPer_F diff: %g | Per_F diff: %g | B diff: %g | eta diff: %g\n', ...
    err_bin_cper, err_bin_per, err_bin_b, err_bin_eta);
if err_bin_cper > tol || err_bin_per > tol || err_bin_b > tol || err_bin_eta > tol || ...
   ~strcmp(diag_bin.method, 'binary') || numel(targets_bin) ~= numel(gstc.targets_bin)
    warning('Binary STC golden regression failed!');
    has_error = true;
end

err_coh_cper = max(abs(CPer_F_coh(:) - gstc.CPer_F_coh(:)));
err_coh_per  = max(abs(Per_F_coh(:)  - gstc.Per_F_coh(:)));
err_coh_eta  = abs(eta_coh - gstc.eta_coh);
fprintf('Coherent STC CPer_F diff: %g | Per_F diff: %g | eta diff: %g\n', ...
    err_coh_cper, err_coh_per, err_coh_eta);
if err_coh_cper > tol || err_coh_per > tol || err_coh_eta > tol || ...
   numel(targets_coh) ~= numel(gstc.targets_coh)
    warning('Coherent STC golden regression failed!');
    has_error = true;
end

fields_to_check = {'n_hat', 'm_hat', 'r_idx', 'd_idx', 'n_tilde', 'm_tilde', ...
                   'd_hat', 'v_hat', 'Per_peak', 'sigma_RCS_hat', 'iter'};
golden_pairs = {{targets_bin, gstc.targets_bin, 'binary'}, {targets_coh, gstc.targets_coh, 'coherent'}};
for gp = 1 : numel(golden_pairs)
    t_cur = golden_pairs{gp}{1};
    t_ref = golden_pairs{gp}{2};
    lbl   = golden_pairs{gp}{3};
    if numel(t_cur) == numel(t_ref)
        for k = 1 : numel(t_cur)
            for f = 1 : numel(fields_to_check)
                fn = fields_to_check{f};
                if abs(t_cur(k).(fn) - t_ref(k).(fn)) > tol
                    warning('Golden %s target(%d).%s mismatch!', lbl, k, fn);
                    has_error = true;
                end
            end
        end
    end
end

%% --- 2. Unit Tests Directly on Braun Coherent STC (Synthetic Model) ---
fprintf('--- 2. Running Unit Tests on coherent_successive_target_cancellation ---\n');
c0      = 3e8;
Nfft_u  = params.Nfft;
Ncp_u   = params.Ncp;
M_u     = radar_data.n_symbols;
mask_u  = params.active_mask;
delta_f = fs / Nfft_u;
T_O     = (Nfft_u + Ncp_u) / fs;
p_FA_u  = 1e-3;
k_vec   = (0 : Nfft_u - 1).';
l_vec   = (0 : M_u - 1);

% Unit 1: Pure AWGN (No targets)
rng(101, 'twister');
sigma2_noise = 1e-4;
F_noise = sqrt(sigma2_noise / 2) * (randn(Nfft_u, M_u) + 1j * randn(Nfft_u, M_u));
[C_n, W_u, ~, ~, P_n, N_u] = compute_range_doppler_map(F_noise, Nfft_u, M_u, mask_u);
[t_n, ~, P_n_out, eta_n, di_n] = coherent_successive_target_cancellation( ...
    C_n, P_n, W_u, N_u, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);

expected_eta_n = -di_n.sigma2_hat * log(-expm1(log1p(-p_FA_u) / (N_u * M_u)));
err_eta_u1     = abs(eta_n - expected_eta_n);
rel_sig_u1     = abs(di_n.sigma2_hat - sigma2_noise) / sigma2_noise;
fprintf('Unit 1 (Pure AWGN): num_targets=%d | sigma2_rel_err=%.3f | eta_diff=%g\n', ...
    numel(t_n), rel_sig_u1, err_eta_u1);
if ~isempty(t_n) || err_eta_u1 > tol || rel_sig_u1 >= 0.15 || max(P_n_out(:)) >= eta_n
    warning('Unit 1 (Pure AWGN CFAR) failed!');
    has_error = true;
end

% Unit 2: Single Off-Grid Target (d = 23.4 m, v = -11.3 m/s, RCS = 10 m^2)
% SNR_F = 0 dB matches post-FFT SNR_Per ~ +45 dB of Model-A at SNR_comm = 35 dB (b_0 = 0.0173)
rng(102, 'twister');
d_true2 = 23.4; v_true2 = -11.3; rcs_true2 = 10.0; snr_u2 = 0.0;
b_0 = 0.03 * (10.0 / d_true2)^2 * sqrt(rcs_true2);
tau2 = 2 * d_true2 / c0;
fD2  = 2 * v_true2 * fc / c0;
F_sig2 = b_0 * exp(-1j * 2 * pi * k_vec * delta_f * tau2) * ...
               exp( 1j * 2 * pi * l_vec * T_O     * fD2) * exp(1j * 0.7);
sig2_n = (b_0^2) / 10^(snr_u2 / 10);
F_u2   = F_sig2 + sqrt(sig2_n / 2) * (randn(Nfft_u, M_u) + 1j * randn(Nfft_u, M_u));
[C_u2, W_u2, ~, ~, P_u2, N_u2] = compute_range_doppler_map(F_u2, Nfft_u, M_u, mask_u);
[t_u2, ~, P_u2_out, eta_u2, di_u2] = coherent_successive_target_cancellation( ...
    C_u2, P_u2, W_u2, N_u2, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);

fprintf('Unit 2 (Off-Grid): num_targets=%d (res=%d) | d_hat=%.2f m | v_hat=%+.2f m/s | RCS=%.2f m^2\n', ...
    numel(t_u2), di_u2.num_residuals, t_u2(1).d_hat, t_u2(1).v_hat, t_u2(1).sigma_RCS_hat);
if numel(t_u2) ~= 1 || abs(t_u2(1).d_hat - d_true2) >= 0.15 || ...
   abs(t_u2(1).v_hat - v_true2) >= 0.25 || abs(t_u2(1).sigma_RCS_hat - rcs_true2) >= 2.0 || ...
   max(P_u2_out(:)) >= eta_u2
    warning('Unit 2 (Off-grid quadratic interp & Step 4 residual suppression) failed!');
    has_error = true;
end

% Unit 3: Velocity Symmetry (v = -12.0 vs +12.0 m/s, SNR_F = 0 dB -> SNR_Per ~ +45 dB)
d_sym = 23.4; rcs_sym = 10.0; snr_sym = 0.0;
b_sym = 0.03 * (10.0 / d_sym)^2 * sqrt(rcs_sym);
sig2_sym = (b_sym^2) / 10^(snr_sym / 10);
tau_sym  = 2 * d_sym / c0;

rng(103, 'twister');
noise_sym = sqrt(sig2_sym / 2) * (randn(Nfft_u, M_u) + 1j * randn(Nfft_u, M_u));

F_sym_neg = b_sym * exp(-1j * 2 * pi * k_vec * delta_f * tau_sym) * ...
                    exp( 1j * 2 * pi * l_vec * T_O * (2 * (-12.0) * fc / c0)) + noise_sym;
[C_sn, W_sn, ~, ~, P_sn, N_sn] = compute_range_doppler_map(F_sym_neg, Nfft_u, M_u, mask_u);
[t_sn, ~, P_sn_out, eta_sn] = coherent_successive_target_cancellation( ...
    C_sn, P_sn, W_sn, N_sn, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);

F_sym_pos = b_sym * exp(-1j * 2 * pi * k_vec * delta_f * tau_sym) * ...
                    exp( 1j * 2 * pi * l_vec * T_O * (2 * (+12.0) * fc / c0)) + noise_sym;
[C_sp, W_sp, ~, ~, P_sp, N_sp] = compute_range_doppler_map(F_sym_pos, Nfft_u, M_u, mask_u);
[t_sp, ~, P_sp_out, eta_sp] = coherent_successive_target_cancellation( ...
    C_sp, P_sp, W_sp, N_sp, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);

fprintf('Unit 3 (Symmetry): v_neg=%+.3f m/s (n=%d) | v_pos=%+.3f m/s (n=%d) | sum=%+.4f m/s\n', ...
    t_sn(1).v_hat, numel(t_sn), t_sp(1).v_hat, numel(t_sp), t_sn(1).v_hat + t_sp(1).v_hat);
if numel(t_sn) ~= 1 || numel(t_sp) ~= 1 || ...
   abs(t_sn(1).v_hat - (-12.0)) >= 0.25 || abs(t_sp(1).v_hat - 12.0) >= 0.25 || ...
   abs(t_sn(1).v_hat + t_sp(1).v_hat) >= 0.05 || ...
   max(P_sn_out(:)) >= eta_sn || max(P_sp_out(:)) >= eta_sp
    warning('Unit 3 (Velocity symmetry) failed!');
    has_error = true;
end

%% --- 3. End-to-End Pipeline Tests (Coherent STC) ---
fprintf('--- 3. Running End-to-End Pipeline Tests (Coherent STC) ---\n');

% E2E 1: Symmetry in Model-A (R = 23.4 m, v = -12 vs +12 m/s, SNR = 35 dB)
rng(42, 'twister');
[wf_e, fs_e, p_e, cfg_e] = step1_transmitter('802.11ax', false, 'CBW20', 0);

rng(23, 'twister');
[rx_neg, fc_e] = step2_channel(wf_e, fs_e, 'Model-A', cfg_e, ...
    struct('type', 'car', 'range_m', 23.4, 'velocity_mps', -12.0), 35.0);
rd_neg = step3_receiver(rx_neg, wf_e, fs_e, fc_e, p_e, false);
[t_e_neg, ~, P_e_neg, eta_e_neg] = step4_interpreter(rd_neg, fs_e, fc_e, '802.11ax', false, 1e-3, 'coherent');

rng(23, 'twister');
[rx_pos, fc_e] = step2_channel(wf_e, fs_e, 'Model-A', cfg_e, ...
    struct('type', 'car', 'range_m', 23.4, 'velocity_mps', +12.0), 35.0);
rd_pos = step3_receiver(rx_pos, wf_e, fs_e, fc_e, p_e, false);
[t_e_pos, ~, P_e_pos, eta_e_pos] = step4_interpreter(rd_pos, fs_e, fc_e, '802.11ax', false, 1e-3, 'coherent');

fprintf('E2E 1 (Model-A Symmetry): neg=(%.2fm, %+.2fm/s, RCS=%.2f) | pos=(%.2fm, %+.2fm/s, RCS=%.2f)\n', ...
    t_e_neg(1).d_hat, t_e_neg(1).v_hat, t_e_neg(1).sigma_RCS_hat, ...
    t_e_pos(1).d_hat, t_e_pos(1).v_hat, t_e_pos(1).sigma_RCS_hat);
if abs(t_e_neg(1).d_hat - 23.4) >= 0.35 || abs(t_e_pos(1).d_hat - 23.4) >= 0.35 || ...
   abs(t_e_neg(1).v_hat + t_e_pos(1).v_hat) >= 0.15 || ...
   t_e_neg(1).sigma_RCS_hat < 6 || t_e_neg(1).sigma_RCS_hat > 15 || ...
   t_e_pos(1).sigma_RCS_hat < 6 || t_e_pos(1).sigma_RCS_hat > 15 || ...
   max(P_e_neg(:)) >= eta_e_neg || max(P_e_pos(:)) >= eta_e_pos
    warning('E2E 1 (Model-A Symmetry) failed!');
    has_error = true;
end

% E2E 2: 30 dB Dynamic Range (E5 scenario: CBW20, Model-C, SNR = 38 dB)
rng(42, 'twister');
[wf_e5, fs_e5, p_e5, cfg_e5] = step1_transmitter('802.11ax', false, 'CBW20', 0);
tgts_e5 = [ ...
    struct('type', 'car',   'range_m', 15.0, 'velocity_mps', 8.0, 'gain', 0.0500), ...
    struct('type', 'human', 'range_m', 30.0, 'velocity_mps', 8.0, 'gain', 0.0500 * 10^(-30/20)) ...
];
rng(23, 'twister');
[rx_e5, fc_e5] = step2_channel(wf_e5, fs_e5, 'Model-C', cfg_e5, tgts_e5, 38.0);
rd_e5 = step3_receiver(rx_e5, wf_e5, fs_e5, fc_e5, p_e5, false);
[t_e5, ~, P_e5, eta_e5, ~, di_e5] = step4_interpreter(rd_e5, fs_e5, fc_e5, '802.11ax', false, 1e-3, 'coherent');

has_car = any(abs([t_e5.d_hat] - 15.0) < 1.5 & abs([t_e5.v_hat] - 8.0) < 1.5);
has_ped = any(abs([t_e5.d_hat] - 30.0) < 2.0 & abs([t_e5.v_hat] - 8.0) < 1.5);
fprintf('E2E 2 (E5 30 dB Dynamic Range): has_car=%d | has_ped=%d | residuals=%d\n', ...
    has_car, has_ped, di_e5.num_residuals);
if ~has_car || ~has_ped || di_e5.num_residuals < 1 || max(P_e5(:)) >= eta_e5
    warning('E2E 2 (E5 30 dB Dynamic Range) failed!');
    has_error = true;
end

%% --- 4. Binary STC Unit & End-to-End Tests ---
fprintf('--- 4. Running Binary STC Unit & End-to-End Tests ---\n');

% Binary Unit 1: Pure AWGN (No targets)
[tb_n, Bb_n, Pb_n_out, etab_n, dib_n] = binary_successive_target_cancellation( ...
    P_n, W_u, N_u, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);
expected_etab_n = -dib_n.sigma2_hat * log(-expm1(log1p(-p_FA_u) / (N_u * M_u)));
err_etab_u1     = abs(etab_n - expected_etab_n);
rel_sigb_u1     = abs(dib_n.sigma2_hat - sigma2_noise) / sigma2_noise;
fprintf('Binary Unit 1 (Pure AWGN): num_targets=%d | all_B=%d | sigma2_rel_err=%.3f | eta_diff=%g\n', ...
    numel(tb_n), all(Bb_n(:)), rel_sigb_u1, err_etab_u1);
if ~isempty(tb_n) || ~all(Bb_n(:)) || err_etab_u1 > tol || rel_sigb_u1 >= 0.15 || max(Pb_n_out(:)) >= etab_n
    warning('Binary Unit 1 (Pure AWGN CFAR) failed!');
    has_error = true;
end

% Binary Unit 2a & 2b: Off-grid target at SNR_F = 0 dB AND SNR_F = 25 dB
% (Above ~28 dB, corners of the separable 2D Blackman-Harris main lobe at -61.13 dB
% exceed eta just outside Braun's inscribed ellipse — expected geometric property.)
snr_cases_bin = [0.0, 25.0];
for sc = 1 : numel(snr_cases_bin)
    snr_cur  = snr_cases_bin(sc);
    rng(102, 'twister');
    sig2_cur = (b_0^2) / 10^(snr_cur / 10);
    F_cur    = F_sig2 + sqrt(sig2_cur / 2) * (randn(Nfft_u, M_u) + 1j * randn(Nfft_u, M_u));
    [~, W_b2, ~, ~, P_b2, N_b2] = compute_range_doppler_map(F_cur, Nfft_u, M_u, mask_u);
    [t_b2, B_b2, P_b2_out, eta_b2] = binary_successive_target_cancellation( ...
        P_b2, W_b2, N_b2, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);

    fprintf('Binary Unit 2%c (Off-Grid SNR_F=%.0f dB): num_targets=%d | d_hat=%.2f m | v_hat=%+.2f m/s | RCS=%.2f m^2\n', ...
        char('a' + sc - 1), snr_cur, numel(t_b2), t_b2(1).d_hat, t_b2(1).v_hat, t_b2(1).sigma_RCS_hat);
    if numel(t_b2) ~= 1 || abs(t_b2(1).d_hat - d_true2) >= 0.15 || ...
       abs(t_b2(1).v_hat - v_true2) >= 0.25 || abs(t_b2(1).sigma_RCS_hat - rcs_true2) >= 2.0 || ...
       max(P_b2(B_b2)) >= eta_b2 || max(P_b2_out(:)) >= eta_b2
        warning('Binary Unit 2%c (SNR_F=%.0f dB) failed!', char('a' + sc - 1), snr_cur);
        has_error = true;
    end
end

% Binary Unit 3: Velocity Symmetry (v = -12.0 vs +12.0 m/s, SNR_F = 0 dB)
[t_bsn, ~, P_bsn_out, eta_bsn] = binary_successive_target_cancellation( ...
    P_sn, W_sn, N_sn, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);
[t_bsp, ~, P_bsp_out, eta_bsp] = binary_successive_target_cancellation( ...
    P_sp, W_sp, N_sp, M_u, Nfft_u, Ncp_u, fs, fc, p_FA_u);
fprintf('Binary Unit 3 (Symmetry): v_neg=%+.3f m/s (n=%d) | v_pos=%+.3f m/s (n=%d) | sum=%+.4f m/s\n', ...
    t_bsn(1).v_hat, numel(t_bsn), t_bsp(1).v_hat, numel(t_bsp), t_bsn(1).v_hat + t_bsp(1).v_hat);
if numel(t_bsn) ~= 1 || numel(t_bsp) ~= 1 || ...
   abs(t_bsn(1).v_hat - (-12.0)) >= 0.25 || abs(t_bsp(1).v_hat - 12.0) >= 0.25 || ...
   abs(t_bsn(1).v_hat + t_bsp(1).v_hat) >= 0.05 || ...
   max(P_bsn_out(:)) >= eta_bsn || max(P_bsp_out(:)) >= eta_bsp
    warning('Binary Unit 3 (Velocity symmetry) failed!');
    has_error = true;
end

% Binary E2E 1: IMPL23 (CBW80, Model-C, SNR = 45 dB, default 'binary') - no MTI ghosts
rng(42, 'twister');
[wf_i, fs_i, p_i, cfg_i] = step1_transmitter('802.11ax', false, 'CBW80', 0);
tgts_i = [ ...
    struct('range_m', 22.5, 'velocity_mps', -4.0,  'type', 'human'), ...
    struct('range_m', 67.5, 'velocity_mps', +18.0, 'type', 'car') ...
];
rng(23, 'twister');
[rx_i, fc_i] = step2_channel(wf_i, fs_i, 'Model-C', cfg_i, tgts_i, 45.0);
rd_i = step3_receiver(rx_i, wf_i, fs_i, fc_i, p_i, false);
[t_bi, ~, P_bi, eta_bi, ~, di_bi] = step4_interpreter(rd_i, fs_i, fc_i, '802.11ax', false);

has_t1_bi    = any(abs([t_bi.d_hat] - 22.5) < 1.0 & abs([t_bi.v_hat] - (-7.0)) < 2.0);
has_t2_bi    = any(abs([t_bi.d_hat] - 67.5) < 1.0 & abs([t_bi.v_hat] - 18.0) < 2.0);
has_ghost_t1 = any(abs([t_bi.d_hat] - 22.5) < 2.0 & [t_bi.v_hat] > 2.0);
has_ghost_t2 = any(abs([t_bi.d_hat] - 67.5) < 2.0 & [t_bi.v_hat] < 5.0);
fprintf('Binary E2E 1 (IMPL23): num_det=%d | T1=%d T2=%d | ghosts=(%d,%d)\n', ...
    numel(t_bi), has_t1_bi, has_t2_bi, has_ghost_t1, has_ghost_t2);
if ~strcmp(di_bi.method, 'binary') || ~has_t1_bi || ~has_t2_bi || ...
   has_ghost_t1 || has_ghost_t2 || max(P_bi(:)) >= eta_bi
    warning('Binary E2E 1 (IMPL23 MTI ghost suppression) failed!');
    has_error = true;
end

% Binary E2E 2: E5 (30 dB Dynamic Range) - Binary misses pedestrian inside B = 0
[t_be5, ~, P_be5, eta_be5, ~, di_be5] = step4_interpreter( ...
    rd_e5, fs_e5, fc_e5, '802.11ax', false, 1e-3, 'binary');
has_car_bin = any(abs([t_be5.d_hat] - 15.0) < 1.5 & abs([t_be5.v_hat] - 8.0) < 1.5);
has_ped_bin = any(abs([t_be5.d_hat] - 30.0) < 2.5 & abs([t_be5.v_hat] - 8.0) < 2.0);
fprintf('Binary E2E 2 (E5 30 dB): has_car=%d | has_ped=%d (masked inside ~B as expected)\n', ...
    has_car_bin, has_ped_bin);
if ~has_car_bin || has_ped_bin || max(P_be5(:)) >= eta_be5 || all(di_be5.B(:))
    warning('Binary E2E 2 (E5 masking trade-off) failed!');
    has_error = true;
end

%% --- 5. Detection Algorithm Registry Tests ---
fprintf('--- 5. Running Detection Algorithm Registry Tests ---\n');
alg_def1   = get_detection_algorithm();
alg_def2   = get_detection_algorithm([]);
alg_def3   = get_detection_algorithm('');
alg_def4   = get_detection_algorithm("");
alg_def5   = get_detection_algorithm(string(missing));
alg_bin_ref = get_detection_algorithm('binary');
alg_bin_ws = get_detection_algorithm(' BINARY ');
alg_coh_ws = get_detection_algorithm("Coherent");
alg_coh_st = get_detection_algorithm(alg_coh_ws);

defaults_ok = all([alg_def1.is_default, alg_def2.is_default, alg_def3.is_default, alg_def4.is_default, alg_def5.is_default]) && ...
              all(strcmp({alg_def1.id, alg_def2.id, alg_def3.id, alg_def4.id, alg_def5.id}, 'binary')) && ...
              all(strcmp({alg_def1.name, alg_def2.name, alg_def3.name, alg_def4.name, alg_def5.name}, alg_bin_ref.name));
norm_ok     = strcmp(alg_bin_ws.id, 'binary') && strcmp(alg_coh_ws.id, 'coherent') && ...
              strcmp(alg_coh_st.id, 'coherent') && strcmp(alg_coh_st.name, alg_coh_ws.name) && ...
              ~alg_coh_ws.is_default;
diag_ok     = strcmp(diag_bin.algorithm.name, alg_bin_ref.name) && ...
              strcmp(diag_bin.algorithm_name, alg_bin_ref.name);

[~, CPer_F_coh_st, Per_F_coh_st, eta_coh_st, ~, diag_coh_st] = step4_interpreter( ...
    radar_data, fs, fc, '802.11ax', false, 1e-3, alg_coh_st);
struct_dispatch_ok = max(abs(CPer_F_coh_st(:) - CPer_F_coh(:))) <= tol && ...
                     max(abs(Per_F_coh_st(:)  - Per_F_coh(:)))  <= tol && ...
                     abs(eta_coh_st - eta_coh) <= tol && ...
                     strcmp(diag_coh_st.algorithm.name, alg_coh_st.name);

threw_err = false;
try
    get_detection_algorithm('unknown_alg');
catch
    threw_err = true;
end

fprintf('Registry Tests: defaults=%d | norm=%d | diag=%d | struct_dispatch=%d | invalid_err=%d\n', ...
    defaults_ok, norm_ok, diag_ok, struct_dispatch_ok, threw_err);
if ~defaults_ok || ~norm_ok || ~diag_ok || ~struct_dispatch_ok || ~threw_err
    warning('Detection algorithm registry tests failed!');
    has_error = true;
end

if has_error
    error('REGRESSION & BINARY/COHERENT STC TESTS FAILED.');
else
    fprintf('ALL REGRESSION & BRAUN 1:1 BINARY/COHERENT STC TESTS PASSED SUCCESSFULLY.\n');
end
