function fig = gen_fig_4_7_stat_environment(show_figure, save_png, force_recompute)
% GEN_FIG_4_7_STAT_ENVIRONMENT
% Experiment SIM-7 (Monte Carlo, Realistic WLAN Environment - Model-C):
% detection probability vs. range for Binary STC and Coherent STC in a random
% suburban/residential property scenario with randomized channel bandwidth
% (CBW20/40/80/160) and modulation order (MCS 0..8) in every trial, followed by
% a console correlation and stratified factor breakdown.
%
% Output file: thesis/img/ch4_sim/rys_4_7_statystyka_otoczenie_wlan.png
% Cache file:  results/exp7_mc_environment.mat

    if nargin < 1 || isempty(show_figure),     show_figure     = true;  end
    if nargin < 2 || isempty(save_png),        save_png        = true;  end
    if nargin < 3 || isempty(force_recompute), force_recompute = false; end

    project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    addpath(project_root);
    project_root = init_paths();

    fprintf('=================================================================\n');
    fprintf('  Generating Fig. 4.7: Environment Monte Carlo P_D(R) (Exp. SIM-7)\n');
    fprintf('=================================================================\n');

    cfg = struct( ...
        'name',          'Environment_ModelC', ...
        'standard',      '802.11ax', ...
        'cbw',           {{'CBW20', 'CBW40', 'CBW80', 'CBW160'}}, ...
        'mcs',           0:8, ...
        'channel_model', 'Model-C', ...
        'p_rx_dBm',      -50.0, ...
        'p_FA',          1e-3, ...
        'n_trials',      120, ...
        'seed',          2027, ...
        'range_lim',     [1, 29], ...
        'range_edges',   1:4:29, ...
        'gate_v_factor', 1.0);

    cfg.classes = [ ...
        struct('key', 'car',        'type', 'car',   'rcs', 10.0, 'count_set', [0, 1, 2], 'range_lim', [5, 29], 'vel_abs_lim', [4.0, 15.0]), ...
        struct('key', 'cyclist',    'type', 'human', 'rcs', 1.0,  'count_set', [0, 1, 2], 'range_lim', [5, 21], 'vel_abs_lim', [4.0, 8.0]), ...
        struct('key', 'pedestrian', 'type', 'human', 'rcs', 1.0,  'count_set', [1, 2],    'range_lim', [1, 17], 'vel_abs_lim', [0.8, 2.2]), ...
        struct('key', 'animal',     'type', 'pet',   'rcs', 0.1,  'count_set', [0, 1, 2], 'range_lim', [1, 13], 'vel_abs_lim', [1.0, 6.0]) ...
        ];

    cache_file = fullfile(project_root, 'results', 'exp7_mc_environment.mat');
    mc = run_detection_monte_carlo(cfg, cache_file, force_recompute);

    print_correlation_analysis(mc);

    sig = char(963); sq = char(178);
    styles = [ ...
        struct('label', sprintf('Samochód (%s = 10 m%s)', sig, sq),   'color', [0.49, 0.18, 0.56], 'marker', 'd'), ...
        struct('label', sprintf('Rowerzysta (%s = 1 m%s)', sig, sq),  'color', [0.47, 0.67, 0.19], 'marker', '^'), ...
        struct('label', sprintf('Pieszy (%s = 1 m%s)', sig, sq),      'color', [0.00, 0.45, 0.74], 'marker', 'o'), ...
        struct('label', sprintf('Zwierzę (%s = 0,1 m%s)', sig, sq),   'color', [0.85, 0.33, 0.10], 'marker', 's') ...
        ];

    tgax_p = get_tgax_propagation_params(cfg.channel_model);
    fig = plot_detection_vs_range(mc, styles, ...
        'Skuteczność detekcji w otoczeniu WLAN – TGax Model-C (losowe CBW 20–160 MHz, MCS 0–8)', ...
        tgax_p.d_bp);

    save_thesis_figure(fig, 'ch4_sim', 'rys_4_7_statystyka_otoczenie_wlan.png', show_figure, save_png);
    if ~show_figure
        fig = [];
    end
    fprintf('=================================================================\n');
end

function print_correlation_analysis(mc)
% PRINT_CORRELATION_ANALYSIS Prints Pearson/Spearman correlations and stratified
% P_D tables across range, velocity, RCS, CBW, MCS, and synchronization error.
    R = mc.raw;

    factors = { ...
        'R [m]',            R.range_m(:); ...
        '|v| [m/s]',        abs(R.velocity_mps(:)); ...
        'log10(RCS)',       log10(max(R.rcs(:), 1e-6)); ...
        'CBW [MHz]',        R.cbw_mhz(:); ...
        'MCS',              R.mcs(:); ...
        '|sync_err| [spl]', abs(R.sync_err(:)); ...
        '|sync_err| [m]',   abs(R.sync_err_m(:)) ...
        };
    n_fac = size(factors, 1);

    hit_bin      = double(R.hit(:, 1));
    hit_coh      = double(R.hit(:, 2));
    hit_bin_comp = double(R.hit_comp(:, 1));
    hit_coh_comp = double(R.hit_comp(:, 2));

    fprintf('\n  ===== Correlation & Factor Impact Analysis [%s] =====\n', mc.cfg.name);
    fprintf('  Point-biserial Pearson r and Spearman rho vs. target detection (N = %d targets):\n', numel(hit_bin));
    fprintf('  %-18s | %15s | %15s | %15s | %15s\n', ...
        'Factor', 'Binary STC (E2E)', 'Coherent (E2E)', 'Binary (sync-cmp)', 'Coherent (sync-cmp)');
    fprintf('  %-18s | %7s %7s | %7s %7s | %7s %7s | %7s %7s\n', ...
        '', 'r', 'rho', 'r', 'rho', 'r', 'rho', 'r', 'rho');
    fprintf('  %s\n', repmat('-', 1, 90));

    r_abs_coh = zeros(n_fac, 1);
    r_coh_vec = zeros(n_fac, 1);
    rho_coh_vec = zeros(n_fac, 1);
    for f = 1:n_fac
        x = factors{f, 2};
        [rb,  pb]  = safe_corr(x, hit_bin);
        [rc,  pc]  = safe_corr(x, hit_coh);
        [rbc, pbc] = safe_corr(x, hit_bin_comp);
        [rcc, pcc] = safe_corr(x, hit_coh_comp);
        r_abs_coh(f)   = abs(rc);
        r_coh_vec(f)   = rc;
        rho_coh_vec(f) = pc;
        fprintf('  %-18s | %+7.3f %+7.3f | %+7.3f %+7.3f | %+7.3f %+7.3f | %+7.3f %+7.3f\n', ...
            factors{f, 1}, rb, pb, rc, pc, rbc, pbc, rcc, pcc);
    end

    [~, order] = sort(r_abs_coh, 'descend');
    fprintf('\n  Factor ranking by |r| for Coherent STC (end-to-end):\n');
    for k = 1:n_fac
        idx = order(k);
        fprintf('    %d. %-18s r = %+6.3f  (rho = %+6.3f)\n', ...
            k, factors{idx, 1}, r_coh_vec(idx), rho_coh_vec(idx));
    end

    % Full Pearson correlation matrix across factors + detections
    labels_mat = [factors(:, 1); {'hit_bin'; 'hit_coh'}];
    X_mat = zeros(numel(hit_bin), n_fac + 2);
    for f = 1:n_fac
        X_mat(:, f) = factors{f, 2};
    end
    X_mat(:, n_fac + 1) = hit_bin;
    X_mat(:, n_fac + 2) = hit_coh;
    valid_rows = all(~isnan(X_mat), 2);
    C_mat = corrcoef(X_mat(valid_rows, :));
    short_lbl = {'R', '|v|', 'lgRCS', 'CBW', 'MCS', '|se_s|', '|se_m|', 'DetBin', 'DetCoh'};

    fprintf('\n  Full Pearson correlation matrix (valid N = %d):\n', nnz(valid_rows));
    fprintf('  %-8s', '');
    for j = 1:numel(short_lbl)
        fprintf(' %7s', short_lbl{j});
    end
    fprintf('\n');
    for i = 1:numel(labels_mat)
        fprintf('  %-8s', short_lbl{i});
        for j = 1:numel(labels_mat)
            fprintf(' %+7.3f', C_mat(i, j));
        end
        fprintf('\n');
    end

    % Stratified P_D by CBW (plus trial-level sync & FA stats)
    fprintf('\n  --- Stratified P_D by Channel Bandwidth (CBW) ---\n');
    cbw_vals = unique(R.cbw_mhz(~isnan(R.cbw_mhz))).';
    for b = cbw_vals
        st  = R.cbw_mhz == b;
        str = R.trial_cbw_mhz == b & ~R.trial_failed;
        se_tr = R.trial_sync_err(str);
        sem_tr = R.trial_sync_err_m(str);
        fprintf('  CBW%-3d (%2d trials, N=%3d tgt) | Bin %5.1f%% (cmp %5.1f%%) | Coh %5.1f%% (cmp %5.1f%%) | sync=0 %5.1f%% | mean|se| %.2f m | FA/fr B=%.2f C=%.2f\n', ...
            b, nnz(str), nnz(st), ...
            100 * mean(R.hit(st, 1)), 100 * mean(R.hit_comp(st, 1)), ...
            100 * mean(R.hit(st, 2)), 100 * mean(R.hit_comp(st, 2)), ...
            100 * mean(se_tr == 0), mean(abs(sem_tr)), ...
            mean(R.trial_n_fa(str, 1)), mean(R.trial_n_fa(str, 2)));
    end

    % Stratified P_D by MCS (individual + constellation groups)
    fprintf('\n  --- Stratified P_D by MCS ---\n');
    mcs_vals = unique(R.mcs(~isnan(R.mcs))).';
    for m = mcs_vals
        st = R.mcs == m;
        fprintf('  MCS %2d (N=%3d) | Bin %5.1f%% (cmp %5.1f%%) | Coh %5.1f%% (cmp %5.1f%%)\n', ...
            m, nnz(st), ...
            100 * mean(R.hit(st, 1)), 100 * mean(R.hit_comp(st, 1)), ...
            100 * mean(R.hit(st, 2)), 100 * mean(R.hit_comp(st, 2)));
    end
    const_groups = { ...
        'BPSK (MCS 0)',      0; ...
        'QPSK (MCS 1-2)',    [1, 2]; ...
        '16-QAM (MCS 3-4)',  [3, 4]; ...
        '64-QAM (MCS 5-7)',  [5, 6, 7]; ...
        '256-QAM (MCS 8)',   8 ...
        };
    fprintf('  By modulation order:\n');
    for g = 1:size(const_groups, 1)
        st = ismember(R.mcs, const_groups{g, 2});
        if any(st)
            fprintf('    %-18s (N=%3d) | Bin %5.1f%% (cmp %5.1f%%) | Coh %5.1f%% (cmp %5.1f%%)\n', ...
                const_groups{g, 1}, nnz(st), ...
                100 * mean(R.hit(st, 1)), 100 * mean(R.hit_comp(st, 1)), ...
                100 * mean(R.hit(st, 2)), 100 * mean(R.hit_comp(st, 2)));
        end
    end

    % Stratified P_D by packet sync error
    fprintf('\n  --- Stratified P_D by |sync_err| [samples] ---\n');
    se_masks = { ...
        '|sync_err| == 0', abs(R.sync_err) == 0; ...
        '|sync_err| == 1', abs(R.sync_err) == 1; ...
        '|sync_err| >= 2', abs(R.sync_err) >= 2 ...
        };
    for s = 1:size(se_masks, 1)
        st = se_masks{s, 2};
        if any(st)
            fprintf('  %-18s (N=%3d) | Bin %5.1f%% (cmp %5.1f%%) | Coh %5.1f%% (cmp %5.1f%%)\n', ...
                se_masks{s, 1}, nnz(st), ...
                100 * mean(R.hit(st, 1)), 100 * mean(R.hit_comp(st, 1)), ...
                100 * mean(R.hit(st, 2)), 100 * mean(R.hit_comp(st, 2)));
        end
    end

    % Stratified P_D by Range zones (LoS vs NLOS)
    fprintf('\n  --- Stratified P_D by Range Zones [m] ---\n');
    r_zones = { ...
        '1 -  5 m (LoS)',  R.range_m >= 1  & R.range_m < 5; ...
        '5 - 13 m (NLOS)', R.range_m >= 5  & R.range_m < 13; ...
        '13 - 21 m (NLOS)',R.range_m >= 13 & R.range_m < 21; ...
        '21 - 29 m (NLOS)',R.range_m >= 21 & R.range_m <= 29 ...
        };
    for z = 1:size(r_zones, 1)
        st = r_zones{z, 2};
        if any(st)
            fprintf('  %-18s (N=%3d) | Bin %5.1f%% (cmp %5.1f%%) | Coh %5.1f%% (cmp %5.1f%%)\n', ...
                r_zones{z, 1}, nnz(st), ...
                100 * mean(R.hit(st, 1)), 100 * mean(R.hit_comp(st, 1)), ...
                100 * mean(R.hit(st, 2)), 100 * mean(R.hit_comp(st, 2)));
        end
    end

    % Stratified P_D by |v| zones (MTI notch vs clear Doppler)
    fprintf('\n  --- Stratified P_D by Radial Speed |v| [m/s] ---\n');
    v_abs = abs(R.velocity_mps);
    v_zones = { ...
        '|v| < 1.5 m/s (MTI)', v_abs < 1.5; ...
        '1.5 <= |v| < 3.0',    v_abs >= 1.5 & v_abs < 3.0; ...
        '3.0 <= |v| < 8.0',    v_abs >= 3.0 & v_abs < 8.0; ...
        '|v| >= 8.0 m/s',      v_abs >= 8.0 ...
        };
    for z = 1:size(v_zones, 1)
        st = v_zones{z, 2};
        if any(st)
            fprintf('  %-18s (N=%3d) | Bin %5.1f%% (cmp %5.1f%%) | Coh %5.1f%% (cmp %5.1f%%)\n', ...
                v_zones{z, 1}, nnz(st), ...
                100 * mean(R.hit(st, 1)), 100 * mean(R.hit_comp(st, 1)), ...
                100 * mean(R.hit(st, 2)), 100 * mean(R.hit_comp(st, 2)));
        end
    end
    fprintf('\n');
end

function [r_pearson, rho_spearman] = safe_corr(x, y)
    valid = ~isnan(x) & ~isnan(y);
    xv = x(valid);
    yv = y(valid);
    if numel(xv) < 3 || std(xv) == 0 || std(yv) == 0
        r_pearson    = NaN;
        rho_spearman = NaN;
        return;
    end
    C = corrcoef(xv, yv);
    r_pearson = C(1, 2);
    rx = rank_avg(xv);
    ry = rank_avg(yv);
    Cs = corrcoef(rx, ry);
    rho_spearman = Cs(1, 2);
end

function r = rank_avg(x)
% RANK_AVG Average-tie rank vector using base MATLAB only (no Statistics Toolbox).
    n = numel(x);
    [xs, ord] = sort(x(:));
    r_sorted = zeros(n, 1);
    i = 1;
    while i <= n
        j = i;
        while j < n && xs(j + 1) == xs(i)
            j = j + 1;
        end
        r_sorted(i:j) = 0.5 * (i + j);
        i = j + 1;
    end
    r = zeros(n, 1);
    r(ord) = r_sorted;
end
