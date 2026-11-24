function mc = run_detection_monte_carlo(cfg, cache_file, force_recompute)
% RUN_DETECTION_MONTE_CARLO Multi-target Monte Carlo evaluation of Binary STC and
% Coherent STC: detection probability vs. target range for each target class.
% Metrics follow Braun (2014, Sec. 5.2: p_D, false alarms, RMSE) and
% Wypich & Zielinski (2026, eq. 7: POD within a tolerance gate, PNFR).
%
% Every trial draws a fresh random scene (target counts, ranges, velocities),
% a fresh TGax channel realization and fresh AWGN, then runs the production
% chain step2_channel -> step3_receiver -> step4_interpreter for both detectors
% on the same radar_data.
%
% Inputs:
%   cfg             - Scenario struct:
%                       name, standard, cbw, mcs, channel_model, snr_dB, p_FA,
%                       n_trials, seed, range_lim [m], range_edges [m], gate_v_factor,
%                       classes(k): key, type, rcs [m^2], count_set, vel_abs_lim [m/s]
%   cache_file      - (Optional) .mat path; reused when its stored cfg matches (default: '')
%   force_recompute - (Optional) Ignore cache and rerun the simulation (default: false)
%
% Output:
%   mc              - Struct with cfg, algorithm names, per-bin P_D with 95% Wilson
%                     intervals, summary metrics, raw per-target records and report text

    if nargin < 2, cache_file = ''; end
    if nargin < 3 || isempty(force_recompute), force_recompute = false; end

    if ~isempty(cache_file) && ~force_recompute && isfile(cache_file)
        S = load(cache_file, 'mc');
        if isfield(S, 'mc') && isfield(S.mc, 'cfg') && isequaln(S.mc.cfg, cfg)
            mc = S.mc;
            fprintf('  Loaded cached Monte Carlo results: %s\n', cache_file);
            fprintf('%s', mc.report);
            return;
        end
        fprintf('  Cache %s does not match the scenario config. Recomputing.\n', cache_file);
    end

    alg_ids = {'binary', 'coherent'};
    n_alg   = numel(alg_ids);
    algs    = cell(1, n_alg);
    for a = 1:n_alg
        algs{a} = get_detection_algorithm(alg_ids{a});
    end
    n_cls = numel(cfg.classes);
    c0    = 3e8;

    fprintf('  Monte Carlo [%s]: %s %s MCS %d, %s, SNR = %.1f dB, %d trials\n', ...
        cfg.name, cfg.standard, cfg.cbw, cfg.mcs, cfg.channel_model, cfg.snr_dB, cfg.n_trials);

    rng(cfg.seed, 'twister');
    [waveform, fs, params, cfg_wlan] = run_quiet(@step1_transmitter, 4, cfg.standard, cfg.cbw, cfg.mcs);
    gate_r = c0 / (2 * fs); % One range resolution cell (Rayleigh, c/2B)
    gate_v = [];
    dv_ray = [];
    fc     = [];

    % Raw per-target records
    max_tgt      = cfg.n_trials * sum(arrayfun(@(c) max(c.count_set), cfg.classes));
    rec_trial    = zeros(max_tgt, 1);
    rec_class    = zeros(max_tgt, 1);
    rec_range    = zeros(max_tgt, 1);
    rec_vel      = zeros(max_tgt, 1);
    rec_hit      = false(max_tgt, n_alg);
    rec_hit_comp = false(max_tgt, n_alg);
    rec_err_r    = nan(max_tgt, n_alg);
    rec_err_v    = nan(max_tgt, n_alg);
    rec_pnfr     = nan(max_tgt, n_alg);
    n_rec        = 0;

    % Per-trial records
    trial_sync_err = nan(cfg.n_trials, 1);
    trial_failed   = false(cfg.n_trials, 1);
    trial_n_det    = nan(cfg.n_trials, n_alg);
    trial_n_fa     = nan(cfg.n_trials, n_alg);
    trial_iter     = nan(cfg.n_trials, n_alg);
    trial_resid    = nan(cfg.n_trials, n_alg);

    t_start = tic;
    for tr = 1:cfg.n_trials
        targets = draw_scene(cfg.classes, cfg.range_lim);
        n_t     = numel(targets);
        idx     = n_rec + (1:n_t);
        n_rec   = n_rec + n_t;
        rec_trial(idx) = tr;
        rec_class(idx) = [targets.class_idx];
        rec_range(idx) = [targets.range_m];
        rec_vel(idx)   = [targets.velocity_mps];

        try
            [rx, fc, intrinsic_delay] = run_quiet(@step2_channel, 3, waveform, fs, ...
                cfg.channel_model, cfg_wlan, targets, cfg.snr_dB);
            radar_data = run_quiet(@step3_receiver, 1, rx, waveform, fs, fc, params);
        catch err
            % End-to-end failure (e.g. lost packet sync): all targets count as missed
            trial_failed(tr) = true;
            warning('Trial %d failed in receiver chain: %s', tr, err.message);
            continue;
        end

        sync_err           = radar_data.sync_idx - intrinsic_delay;
        trial_sync_err(tr) = sync_err;

        if isempty(gate_v)
            T_cpi  = radar_data.n_symbols * (radar_data.Nfft + radar_data.Ncp) / fs;
            dv_ray = c0 / (2 * fc * T_cpi); % Doppler (velocity) Rayleigh resolution
            gate_v = cfg.gate_v_factor * dv_ray;
        end

        r_true = [targets.range_m];
        v_true = [targets.velocity_mps];

        for a = 1:n_alg
            [det, ~, ~, ~, pnfr, dg] = run_quiet(@step4_interpreter, 6, radar_data, fs, fc, ...
                cfg.standard, cfg.p_FA, algs{a});
            if isempty(det)
                d_hat = zeros(1, 0);
                v_hat = zeros(1, 0);
            else
                d_hat = [det.d_hat];
                v_hat = [det.v_hat];
            end

            [hit, det_idx] = associate(d_hat, v_hat, r_true, v_true, gate_r, gate_v);
            hit_comp       = associate(d_hat + sync_err * gate_r, v_hat, r_true, v_true, gate_r, gate_v);

            rec_hit(idx, a)      = hit;
            rec_hit_comp(idx, a) = hit_comp;

            m = find(hit);
            if ~isempty(m)
                d_m = d_hat(det_idx(m));
                v_m = v_hat(det_idx(m));
                p_m = pnfr.pnfr_dB(det_idx(m));
                rec_err_r(idx(m), a) = d_m(:) - r_true(m).';
                rec_err_v(idx(m), a) = v_m(:) - v_true(m).';
                rec_pnfr(idx(m), a)  = p_m(:);
            end

            trial_n_det(tr, a) = numel(d_hat);
            trial_n_fa(tr, a)  = numel(d_hat) - nnz(hit);
            trial_iter(tr, a)  = dg.num_iterations;
            trial_resid(tr, a) = dg.num_residuals;
        end

        if mod(tr, 10) == 0 || tr == cfg.n_trials
            fprintf('    trial %3d/%d | elapsed %.1f s\n', tr, cfg.n_trials, toc(t_start));
        end
    end
    elapsed_s = toc(t_start);

    % Trim raw records
    keep         = 1:n_rec;
    rec_trial    = rec_trial(keep);
    rec_class    = rec_class(keep);
    rec_range    = rec_range(keep);
    rec_vel      = rec_vel(keep);
    rec_hit      = rec_hit(keep, :);
    rec_hit_comp = rec_hit_comp(keep, :);
    rec_err_r    = rec_err_r(keep, :);
    rec_err_v    = rec_err_v(keep, :);
    rec_pnfr     = rec_pnfr(keep, :);

    % Per-bin detection probability with 95% Wilson intervals
    edges   = cfg.range_edges(:).';
    n_bin   = numel(edges) - 1;
    centers = (edges(1:end-1) + edges(2:end)) / 2;
    bin_idx = discretize(rec_range, edges);

    bins = struct('edges', edges, 'centers', centers, ...
        'n', zeros(n_alg, n_cls, n_bin), 'k', zeros(n_alg, n_cls, n_bin), ...
        'pd', nan(n_alg, n_cls, n_bin), 'ci_lo', nan(n_alg, n_cls, n_bin), 'ci_hi', nan(n_alg, n_cls, n_bin), ...
        'k_comp', zeros(n_alg, n_cls, n_bin), 'pd_comp', nan(n_alg, n_cls, n_bin));

    for a = 1:n_alg
        for c = 1:n_cls
            for b = 1:n_bin
                sel = (rec_class == c) & (bin_idx == b);
                n   = nnz(sel);
                k   = nnz(rec_hit(sel, a));
                kc  = nnz(rec_hit_comp(sel, a));
                [lo, hi] = wilson_ci(k, n);
                bins.n(a, c, b)      = n;
                bins.k(a, c, b)      = k;
                bins.k_comp(a, c, b) = kc;
                if n > 0
                    bins.pd(a, c, b)      = k / n;
                    bins.pd_comp(a, c, b) = kc / n;
                end
                bins.ci_lo(a, c, b) = lo;
                bins.ci_hi(a, c, b) = hi;
            end
        end
    end

    % Summary metrics per algorithm and class
    summary = struct();
    summary.n_targets = zeros(1, n_cls);
    summary.pd        = nan(n_alg, n_cls);
    summary.pd_lo     = nan(n_alg, n_cls);
    summary.pd_hi     = nan(n_alg, n_cls);
    summary.pd_comp   = nan(n_alg, n_cls);
    summary.rmse_r    = nan(n_alg, n_cls);
    summary.rmse_v    = nan(n_alg, n_cls);
    summary.pnfr_mean = nan(n_alg, n_cls);
    summary.r50       = nan(n_alg, n_cls);
    summary.r80       = nan(n_alg, n_cls);
    for c = 1:n_cls
        sel = rec_class == c;
        summary.n_targets(c) = nnz(sel);
        for a = 1:n_alg
            n = nnz(sel);
            k = nnz(rec_hit(sel, a));
            if n > 0
                summary.pd(a, c)      = k / n;
                summary.pd_comp(a, c) = nnz(rec_hit_comp(sel, a)) / n;
                [summary.pd_lo(a, c), summary.pd_hi(a, c)] = wilson_ci(k, n);
            end
            er = rec_err_r(sel, a);  er = er(~isnan(er));
            ev = rec_err_v(sel, a);  ev = ev(~isnan(ev));
            pn = rec_pnfr(sel, a);   pn = pn(~isnan(pn));
            if ~isempty(er)
                summary.rmse_r(a, c)    = sqrt(mean(er.^2));
                summary.rmse_v(a, c)    = sqrt(mean(ev.^2));
                summary.pnfr_mean(a, c) = mean(pn);
            end
            pd_bins = reshape(bins.pd(a, c, :), 1, []);
            summary.r50(a, c) = range_at_level(centers, pd_bins, 0.5);
            summary.r80(a, c) = range_at_level(centers, pd_bins, 0.8);
        end
    end
    ok = ~trial_failed;
    summary.mean_n_det  = mean(trial_n_det(ok, :), 1);
    summary.mean_n_fa   = mean(trial_n_fa(ok, :), 1);
    summary.mean_iter   = mean(trial_iter(ok, :), 1);
    summary.mean_resid  = mean(trial_resid(ok, :), 1);
    se = trial_sync_err(ok);
    summary.sync_frac0   = mean(se == 0);
    summary.sync_frac_le1 = mean(abs(se) <= 1);
    summary.sync_median  = median(se);
    summary.sync_max     = max(abs(se));
    summary.n_failed     = nnz(trial_failed);

    mc = struct();
    mc.cfg       = cfg;
    mc.alg_ids   = alg_ids;
    mc.alg_names = cellfun(@(s) s.name, algs, 'UniformOutput', false);
    mc.alg_desc  = cellfun(@(s) s.description_pl, algs, 'UniformOutput', false);
    mc.class_keys = {cfg.classes.key};
    mc.bins      = bins;
    mc.summary   = summary;
    mc.meta      = struct('fs', fs, 'fc', fc, 'gate_r', gate_r, 'gate_v', gate_v, ...
        'dv_rayleigh', dv_ray, 'elapsed_s', elapsed_s, 'created', char(datetime('now')));
    mc.raw       = struct('trial', rec_trial, 'class', rec_class, 'range_m', rec_range, ...
        'velocity_mps', rec_vel, 'hit', rec_hit, 'hit_comp', rec_hit_comp, ...
        'err_r', rec_err_r, 'err_v', rec_err_v, 'pnfr_dB', rec_pnfr, ...
        'trial_sync_err', trial_sync_err, 'trial_failed', trial_failed, ...
        'trial_n_det', trial_n_det, 'trial_n_fa', trial_n_fa, ...
        'trial_iter', trial_iter, 'trial_resid', trial_resid);
    mc.report    = build_report(mc);

    fprintf('%s', mc.report);

    if ~isempty(cache_file)
        cache_dir = fileparts(cache_file);
        if ~isempty(cache_dir) && ~isfolder(cache_dir)
            mkdir(cache_dir);
        end
        save(cache_file, 'mc');
        fprintf('  Monte Carlo results cached to: %s\n', cache_file);
    end
end

function targets = draw_scene(classes, range_lim)
% DRAW_SCENE Random scene: per-class target count, uniform range, uniform |v| with random sign.
% No anti-collision constraint: close targets may mask each other, as in reality.
    targets = struct('type', {}, 'rcs', {}, 'range_m', {}, 'velocity_mps', {}, 'class_idx', {});
    for c = 1:numel(classes)
        cls = classes(c);
        n_c = cls.count_set(randi(numel(cls.count_set)));
        for k = 1:n_c
            r_m   = range_lim(1) + diff(range_lim) * rand();
            v_abs = cls.vel_abs_lim(1) + diff(cls.vel_abs_lim) * rand();
            v_ms  = v_abs * (2 * (rand() >= 0.5) - 1);
            targets(end + 1) = struct('type', cls.type, 'rcs', cls.rcs, ...
                'range_m', r_m, 'velocity_mps', v_ms, 'class_idx', c); %#ok<AGROW>
        end
    end
    if isempty(targets)
        error('Scenario drew zero targets; every trial needs at least one target.');
    end
end

function [hit, det_idx] = associate(d_hat, v_hat, r_true, v_true, gate_r, gate_v)
% ASSOCIATE Greedy 1-to-1 nearest-neighbour matching inside a rectangular
% range/velocity tolerance gate (normalized distance, Braun 2014 eq. 5.2 spirit).
    n_t     = numel(r_true);
    n_d     = numel(d_hat);
    hit     = false(n_t, 1);
    det_idx = zeros(n_t, 1);
    if n_t == 0 || n_d == 0
        return;
    end
    dr   = abs(reshape(d_hat, 1, []) - reshape(r_true, [], 1)); % [n_t x n_d]
    dv   = abs(reshape(v_hat, 1, []) - reshape(v_true, [], 1));
    cost = hypot(dr / gate_r, dv / gate_v);
    cost(dr > gate_r | dv > gate_v) = inf;
    while true
        [c_min, lin] = min(cost(:));
        if ~isfinite(c_min)
            break;
        end
        [ti, di] = ind2sub(size(cost), lin);
        hit(ti)     = true;
        det_idx(ti) = di;
        cost(ti, :) = inf;
        cost(:, di) = inf;
    end
end

function [lo, hi] = wilson_ci(k, n)
% WILSON_CI 95% Wilson score interval for a binomial proportion.
    if n == 0
        lo = NaN; hi = NaN;
        return;
    end
    z   = 1.959964;
    p   = k / n;
    den = 1 + z^2 / n;
    ctr = (p + z^2 / (2 * n)) / den;
    hw  = z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / den;
    lo  = max(0, ctr - hw);
    hi  = min(1, ctr + hw);
end

function r = range_at_level(centers, pd, level)
% RANGE_AT_LEVEL Range where P_D first drops below level (linear interpolation).
% Returns Inf if P_D never drops below level, -Inf if already below in the first bin.
    valid = ~isnan(pd);
    x = centers(valid);
    y = pd(valid);
    if isempty(x)
        r = NaN;
        return;
    end
    j = find(y < level, 1, 'first');
    if isempty(j)
        r = Inf;
    elseif j == 1
        r = -Inf;
    else
        r = x(j - 1) + (y(j - 1) - level) * (x(j) - x(j - 1)) / (y(j - 1) - y(j));
    end
end

function s = fmt_range(r, edges)
    if isnan(r)
        s = 'n/a';
    elseif isinf(r) && r > 0
        s = sprintf('> %.0f m', edges(end));
    elseif isinf(r)
        s = sprintf('< %.0f m', edges(1));
    else
        s = sprintf('%.1f m', r);
    end
end

function txt = build_report(mc)
% BUILD_REPORT Console/table summary for Chapter 4.
    cfg = mc.cfg;
    S   = mc.summary;
    B   = mc.bins;
    n_alg = numel(mc.alg_names);
    n_cls = numel(mc.class_keys);

    txt = sprintf('\n  ===== Monte Carlo summary [%s] =====\n', cfg.name);
    txt = [txt, sprintf('  %s %s MCS %d | %s | SNR %.1f dB | p_FA %.0e | %d trials (%d failed) | %.1f s\n', ...
        cfg.standard, cfg.cbw, cfg.mcs, cfg.channel_model, cfg.snr_dB, cfg.p_FA, ...
        cfg.n_trials, S.n_failed, mc.meta.elapsed_s)];
    txt = [txt, sprintf('  Gate: dR = %.3f m, dv = %.2f m/s (%.2f x Rayleigh %.2f m/s)\n', ...
        mc.meta.gate_r, mc.meta.gate_v, cfg.gate_v_factor, mc.meta.dv_rayleigh)];
    txt = [txt, sprintf('  Packet sync error: 0 spl in %.1f%%, |err| <= 1 spl in %.1f%%, median %g spl, max %g spl\n', ...
        100 * S.sync_frac0, 100 * S.sync_frac_le1, S.sync_median, S.sync_max)];

    bin_hdr = strjoin(arrayfun(@(lo, hi) sprintf('%5.0f-%-3.0f', lo, hi), ...
        B.edges(1:end-1), B.edges(2:end), 'UniformOutput', false), ' ');

    for a = 1:n_alg
        txt = [txt, sprintf('\n  --- %s ---\n', mc.alg_names{a})]; %#ok<AGROW>
        txt = [txt, sprintf('  mean detections/frame %.2f | false alarms/frame %.2f | iterations %.1f | residuals %.1f\n', ...
            S.mean_n_det(a), S.mean_n_fa(a), S.mean_iter(a), S.mean_resid(a))]; %#ok<AGROW>
        for c = 1:n_cls
            txt = [txt, sprintf('  %-12s N=%4d | P_D %5.1f%% [%4.1f, %4.1f] | sync-comp %5.1f%% | R50 %s | R80 %s | RMSE_R %.2f m | RMSE_v %.2f m/s | PNFR %.1f dB\n', ...
                mc.class_keys{c}, S.n_targets(c), 100 * S.pd(a, c), 100 * S.pd_lo(a, c), 100 * S.pd_hi(a, c), ...
                100 * S.pd_comp(a, c), fmt_range(S.r50(a, c), B.edges), fmt_range(S.r80(a, c), B.edges), ...
                S.rmse_r(a, c), S.rmse_v(a, c), S.pnfr_mean(a, c))]; %#ok<AGROW>
        end
        txt = [txt, sprintf('  P_D per range bin [m]: %s\n', bin_hdr)]; %#ok<AGROW>
        for c = 1:n_cls
            pd = reshape(B.pd(a, c, :), 1, []);
            n  = reshape(B.n(a, c, :), 1, []);
            cells = arrayfun(@(p, k) sprintf('%3.0f%%(%2d)', 100 * p, k), pd, n, 'UniformOutput', false);
            txt = [txt, sprintf('    %-12s %s\n', mc.class_keys{c}, strjoin(cells, ' '))]; %#ok<AGROW>
        end
    end
    txt = [txt, newline];
end

function varargout = run_quiet(fn, n_out, varargin)
% RUN_QUIET Calls a pipeline function while suppressing its console log.
    varargout = cell(1, n_out);
    evalc('[varargout{1:n_out}] = fn(varargin{:});');
end
