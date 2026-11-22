function [targets, CPer_F, Per_F, eta, diag_info] = coherent_successive_target_cancellation( ...
    CPer_F, Per_F, W, N, M, Nfft, Ncp, fs, fc, p_FA)
% COHERENT_SUCCESSIVE_TARGET_CANCELLATION
% Canonical 1:1 implementation of M. Braun's Coherent Successive Target Cancellation
% (Braun 2014, "OFDM Radar Algorithms in Mobile Communication Networks", Sec. 3.3.5-3.3.7,
% eqs. 3.30-3.34, 3.84-3.86, 3.90-3.102).
%
% Inputs:
%   CPer_F - Complex 2D Range-Doppler periodogram [N_Per x M_Per]
%   Per_F  - Real-valued power periodogram (1/(N*M))*|CPer_F|^2 [N_Per x M_Per]
%   W      - 2D window matrix [Nfft x M] applied to generate CPer_F
%   N      - Number of active subcarriers (N_act)
%   M      - Number of OFDM symbols in frame
%   Nfft   - Baseband FFT length
%   Ncp    - Cyclic prefix length [samples]
%   fs     - Sampling frequency [Hz]
%   fc     - Carrier frequency [Hz]
%   p_FA   - (Optional) Target per-frame CFAR false-alarm probability (default: 1e-3)
%
% Outputs:
%   targets   - Struct array of detected targets (n_hat, m_hat, r_idx, d_idx,
%               n_tilde, m_tilde, d_hat, v_hat, Per_peak, sigma_RCS_hat, iter)
%   CPer_F    - Residual complex periodogram after cancellation
%   Per_F     - Residual real-valued periodogram after cancellation
%   eta       - CFAR detection threshold (linear power, eq. 3.95)
%   diag_info - (Optional) Diagnostic struct for plotting/inspection

    if nargin < 10 || isempty(p_FA)
        p_FA = 1e-3;
    end
    if isempty(Per_F)
        Per_F = (1 / (N * M)) * abs(CPer_F).^2;
    end

    c0      = 3e8;
    delta_f = fs / Nfft;
    T_O     = (Nfft + Ncp) / fs;
    [N_Per, M_Per] = size(Per_F);

    % RCS calibration constant c_norm (eq. 3.34) matched to configure_targets.m
    % (d_ref = 10 m, sigma_ref = 1 m^2, b_ref = 0.03) and coherent window gain
    P_Tx      = 0.1; % 100 mW (20 dBm EIRP)
    G         = 1.0;
    G_win     = (sum(W(:))^2) / ((N * M)^2);
    d_ref     = 10.0;
    sigma_ref = 1.0;
    b_ref     = 0.03;
    c_norm    = (P_Tx * G * c0^2) / ((4 * pi)^3 * fc^2) * ...
                (sigma_ref / (b_ref^2 * d_ref^4 * G_win));

    % Effective -3 dB main-lobe width of window W for residual check (Step 4)
    w_r   = sum(W, 2);
    w_d   = sum(W, 1).';
    N_win = 2 * compute_mainlobe_3dB_width(w_r, N_Per);
    M_win = 2 * compute_mainlobe_3dB_width(w_d, M_Per);

    % Noise power ML estimate beyond N_max (eq. 3.98), guarded from R=0 wraparound
    N_max      = ceil((Ncp / Nfft) * N_Per);
    n_guard    = ceil(2 * N_win);
    row_start  = min(N_Per - 1, N_max + n_guard + 1);
    row_end    = max(row_start, N_Per - n_guard);
    sigma2_hat = mean(Per_F(row_start : row_end, :), 'all');

    % CFAR threshold (eq. 3.95) with numerically stable log-evaluation
    p_FA_bin = -expm1(log1p(-p_FA) / (N * M));
    eta      = -sigma2_hat * log(p_FA_bin);

    k_vec = (0 : Nfft - 1).';
    l_vec = (0 : M - 1);

    targets = struct( ...
        'n_hat', {}, 'm_hat', {}, 'r_idx', {}, 'd_idx', {}, ...
        'n_tilde', {}, 'm_tilde', {}, 'd_hat', {}, 'v_hat', {}, ...
        'Per_peak', {}, 'sigma_RCS_hat', {}, 'iter', {});

    record_history = (nargout >= 5);
    if record_history
        Per_history      = {Per_F};
        iter_is_residual = false(0, 1);
    end

    % Step 1: Initialize iteration counter i = 0
    i        = 0;
    max_iter = 200; % Safety bound against high-target-count residual instability (Sec. 5.2.2)

    while i < max_iter
        % Step 2: Find the largest peak in Per_F
        [peak_val, lin_idx] = max(Per_F(:));
        [rn, dm] = ind2sub([N_Per, M_Per], lin_idx);
        n_hat = rn - 1;
        m_hat = dm - (M_Per / 2 + 1);

        % Step 3: Stop searching if peak falls below CFAR threshold eta
        if peak_val < eta
            break;
        end

        % Step 4: Check whether the peak is a residual inside a prior target's main lobe
        is_residual = false;
        for t_idx = 1 : numel(targets)
            dn = abs(n_hat - targets(t_idx).n_hat);
            dn = min(dn, N_Per - dn);
            dm_dist = abs(m_hat - targets(t_idx).m_hat);
            dm_dist = min(dm_dist, M_Per - dm_dist);
            if (dn / (N_win / 2))^2 + (dm_dist / (M_win / 2))^2 <= 1
                is_residual = true;
                break;
            end
        end

        % Step 5: Quadratic interpolation (eqs. 3.84-3.86) and physical estimation (eqs. 3.32, 3.34)
        if ~is_residual
            rn_m = mod(rn - 2, N_Per) + 1;
            rn_p = mod(rn,     N_Per) + 1;
            dm_m = mod(dm - 2, M_Per) + 1;
            dm_p = mod(dm,     M_Per) + 1;

            p_c  = Per_F(rn, dm);
            p_rm = Per_F(rn_m, dm);
            p_rp = Per_F(rn_p, dm);
            p_dm = Per_F(rn, dm_m);
            p_dp = Per_F(rn, dm_p);

            denom_n = 2 * (p_rm + p_rp - 2 * p_c);
            if denom_n < -eps
                delta_n = max(-0.5, min(0.5, (p_rm - p_rp) / denom_n));
            else
                delta_n = 0;
            end

            denom_m = 2 * (p_dm + p_dp - 2 * p_c);
            if denom_m < -eps
                delta_m = max(-0.5, min(0.5, (p_dm - p_dp) / denom_m));
            else
                delta_m = 0;
            end

            n_tilde = max(0, n_hat + delta_n);
            m_tilde = m_hat + delta_m;

            Per_interp = p_c - 0.25 * ((p_rm - p_rp) * delta_n + (p_dm - p_dp) * delta_m);
            Per_interp = max(Per_interp, p_c);

            d_hat         = (n_tilde * c0) / (2 * delta_f * N_Per);
            v_hat         = (m_tilde * c0) / (2 * fc * T_O * M_Per);
            sigma_RCS_hat = c_norm * (Per_interp / (P_Tx * N * M)) * ...
                            (((4 * pi)^3 * fc^2 * max(d_hat, 1.0)^4) / (G * c0^2));

            targets(end + 1) = struct( ...
                'n_hat', n_hat, ...
                'm_hat', m_hat, ...
                'r_idx', rn, ...
                'd_idx', dm, ...
                'n_tilde', n_tilde, ...
                'm_tilde', m_tilde, ...
                'd_hat', d_hat, ...
                'v_hat', v_hat, ...
                'Per_peak', Per_interp, ...
                'sigma_RCS_hat', sigma_RCS_hat, ...
                'iter', i);
        end

        % Step 6: Single-target radar processing matrix and complex periodogram (eqs. 3.99-3.100)
        F_target         = exp(-1j * 2 * pi * k_vec * n_hat / N_Per) * exp(1j * 2 * pi * l_vec * m_hat / M_Per);
        CPer_target      = fftshift(N_Per * ifft(fft(F_target .* W, M_Per, 2), N_Per, 1), 2);
        CPer_target_norm = CPer_target / CPer_target(rn, dm);

        % Step 7: Coherent subtraction from complex periodogram (eq. 3.101)
        CPer_F = CPer_F - CPer_F(rn, dm) * CPer_target_norm;

        % Step 8: Update real-valued periodogram (eq. 3.102)
        Per_F = (1 / (N * M)) * abs(CPer_F).^2;

        if record_history
            Per_history{end + 1}         = Per_F;
            iter_is_residual(end + 1, 1) = is_residual;
        end

        % Step 9-10: Increment iteration counter and continue at Step 2
        i = i + 1;
    end

    if nargout >= 5
        diag_info = struct( ...
            'Per_history', {Per_history}, ...
            'iter_is_residual', iter_is_residual, ...
            'num_iterations', i, ...
            'num_residuals', sum(iter_is_residual), ...
            'sigma2_hat', sigma2_hat, ...
            'N_max', N_max, ...
            'N_win', N_win, ...
            'M_win', M_win, ...
            'p_FA', p_FA);
    end
end

function bw_3dB = compute_mainlobe_3dB_width(w, L_fft)
% COMPUTE_MAINLOBE_3DB_WIDTH Full -3 dB main-lobe width in zero-padded FFT bins.
    P_w = abs(fft(w, L_fft)).^2;
    if P_w(1) <= 0
        bw_3dB = 1.0;
        return;
    end
    P_w     = P_w / P_w(1);
    k_cross = find(P_w(1 : floor(L_fft / 2)) < 0.5, 1, 'first');
    if isempty(k_cross) || k_cross <= 1
        bw_3dB = 1.0;
    else
        p_hi   = P_w(k_cross - 1);
        p_lo   = P_w(k_cross);
        hw     = (k_cross - 2) + (p_hi - 0.5) / max(p_hi - p_lo, eps);
        bw_3dB = 2 * hw;
    end
end
