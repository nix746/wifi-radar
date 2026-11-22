function [targets, B, Per_F_masked, eta, diag_info] = binary_successive_target_cancellation( ...
    Per_F, W, N, M, Nfft, Ncp, fs, fc, p_FA)
% BINARY_SUCCESSIVE_TARGET_CANCELLATION
% Canonical 1:1 implementation of M. Braun's Binary Successive Target Cancellation
% (Braun 2014, "OFDM Radar Algorithms in Mobile Communication Networks", Sec. 3.3.7,
% pp. 56-58, Fig. 3.13, eqs. 3.32, 3.34, 3.84-3.86, 3.95, 3.98).
%
% Inputs:
%   Per_F  - Real-valued power periodogram (1/(N*M))*|CPer_F|^2 [N_Per x M_Per]
%   W      - 2D window matrix [Nfft x M] applied to generate Per_F
%   N      - Number of active subcarriers (N_act)
%   M      - Number of OFDM symbols in frame
%   Nfft   - Baseband FFT length
%   Ncp    - Cyclic prefix length [samples]
%   fs     - Sampling frequency [Hz]
%   fc     - Carrier frequency [Hz]
%   p_FA   - (Optional) Target per-frame CFAR false-alarm probability (default: 1e-3)
%
% Outputs:
%   targets      - Struct array of detected targets (n_hat, m_hat, r_idx, d_idx,
%                  n_tilde, m_tilde, d_hat, v_hat, Per_peak, sigma_RCS_hat, iter)
%   B            - Final binary map {0, 1} of unmasked periodogram bins [N_Per x M_Per]
%   Per_F_masked - Periodogram masked by B (Per_F .* B)
%   eta          - CFAR detection threshold (linear power, eq. 3.95)
%   diag_info    - (Optional) Diagnostic struct for plotting/inspection

    if nargin < 9 || isempty(p_FA)
        p_FA = 1e-3;
    end

    c0      = 3e8;
    delta_f = fs / Nfft;
    T_O     = (Nfft + Ncp) / fs;
    [N_Per, M_Per] = size(Per_F);

    % RCS calibration constant c_norm (eq. 3.34) matched to configure_targets.m
    P_Tx      = 0.1; % 100 mW (20 dBm EIRP)
    G         = 1.0;
    G_win     = (sum(W(:))^2) / ((N * M)^2);
    d_ref     = 10.0;
    sigma_ref = 1.0;
    b_ref     = 0.03;
    c_norm    = (P_Tx * G * c0^2) / ((4 * pi)^3 * fc^2) * ...
                (sigma_ref / (b_ref^2 * d_ref^4 * G_win));

    % Full null-to-null main-lobe width of window W (Braun Sec. 3.3.7 & Table 3.2)
    w_r   = sum(W, 2);
    w_d   = sum(W, 1).';
    N_win = compute_mainlobe_null_width(w_r, N_Per);
    M_win = compute_mainlobe_null_width(w_d, M_Per);

    % Noise power ML estimate beyond N_max (eq. 3.98), guarded from R=0 wraparound
    N_max      = ceil((Ncp / Nfft) * N_Per);
    n_guard    = ceil(N_win);
    row_start  = min(N_Per - 1, N_max + n_guard + 1);
    row_end    = max(row_start, N_Per - n_guard);
    sigma2_hat = mean(Per_F(row_start : row_end, :), 'all');

    % CFAR threshold (eq. 3.95) with numerically stable log-evaluation
    p_FA_bin = -expm1(log1p(-p_FA) / (N * M));
    eta      = -sigma2_hat * log(p_FA_bin);

    n_grid = (0 : N_Per - 1).';
    m_grid = floor(-M_Per / 2) : (ceil(M_Per / 2) - 1);

    targets = struct( ...
        'n_hat', {}, 'm_hat', {}, 'r_idx', {}, 'd_idx', {}, ...
        'n_tilde', {}, 'm_tilde', {}, 'd_hat', {}, 'v_hat', {}, ...
        'Per_peak', {}, 'sigma_RCS_hat', {}, 'iter', {});

    % Step 1: Initialize all elements of binary map B to 1 (true) and i = 0
    B        = true(N_Per, M_Per);
    i        = 0;
    max_iter = 200;

    record_history = (nargout >= 5);
    if record_history
        B_history = {B};
    end

    while i < max_iter
        % Step 2: Find the largest peak subject to B(n, m) == 1
        Per_search     = Per_F;
        Per_search(~B) = -inf;
        [peak_val, lin_idx] = max(Per_search(:));
        [rn, dm] = ind2sub([N_Per, M_Per], lin_idx);
        n_hat = rn - 1;
        m_hat = m_grid(dm);

        % Step 3: If Per_F(n_hat, m_hat) < eta, stop searching
        if peak_val < eta
            break;
        end

        % Step 4: Quadratic interpolation on Per_F (eqs. 3.84-3.86) and physical estimation
        [n_tilde, m_tilde, Per_interp] = quadratic_peak_interp(Per_F, rn, dm, n_hat, m_hat, N_Per, M_Per);

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

        % Step 5: Zero out main-lobe ellipse in binary map B (periodic wrap on FFT axes)
        dn = abs(n_grid - n_hat);
        dn = min(dn, N_Per - dn);
        dm_dist = abs(m_grid - m_hat);
        dm_dist = min(dm_dist, M_Per - dm_dist);
        in_ellipse = (dn / (N_win / 2)).^2 + (dm_dist / (M_win / 2)).^2 <= 1;
        B(in_ellipse) = false;

        if record_history
            B_history{end + 1} = B;
        end

        % Step 6-7: Increment i and continue at Step 2
        i = i + 1;
    end

    Per_F_masked = Per_F .* B;

    if record_history
        diag_info = struct( ...
            'B', B, ...
            'B_history', {B_history}, ...
            'num_iterations', i, ...
            'num_residuals', 0, ...
            'sigma2_hat', sigma2_hat, ...
            'N_max', N_max, ...
            'N_win', N_win, ...
            'M_win', M_win, ...
            'p_FA', p_FA);
    end
end

function full_width = compute_mainlobe_null_width(w, L_fft)
% COMPUTE_MAINLOBE_NULL_WIDTH Full null-to-null main-lobe width in zero-padded FFT bins.
    P_w      = abs(fft(w, L_fft)).^2;
    half_len = floor(L_fft / 2);
    k_null   = find(diff(P_w(1 : half_len)) > 0, 1, 'first');
    if isempty(k_null) || k_null <= 1
        half_width = max(1, round(L_fft / max(1, nnz(w > 0))));
    else
        half_width = k_null - 1;
    end
    full_width = 2 * half_width;
end

function [n_tilde, m_tilde, Per_interp] = quadratic_peak_interp(Per_F, rn, dm, n_hat, m_hat, N_Per, M_Per)
% QUADRATIC_PEAK_INTERP 2D parabolic peak interpolation (Braun 2014, eqs. 3.84-3.86).
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

    n_tilde    = max(0, n_hat + delta_n);
    m_tilde    = m_hat + delta_m;
    Per_interp = max(p_c - 0.25 * ((p_rm - p_rp) * delta_n + (p_dm - p_dp) * delta_m), p_c);
end
