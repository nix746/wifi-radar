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
%                       name, standard, cbw (char or cellstr pool), mcs (scalar or vector pool),
%                       channel_model, p_rx_dBm (optional), p_FA, n_trials, seed,
%                       range_lim [m] (optional default if class lacks range_lim),
%                       range_edges [m], gate_v_factor, gate_r_factor (optional, default 1.0),
%                       classes(k): key, type, rcs [m^2], count_set, vel_abs_lim [m/s],
%                                   range_lim [m] (optional per-class override)
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
    if isfield(S, 'mc') && isfield(S.mc, 'cfg') && isequaln(S.mc.cfg, cfg) ...
            && isfield(S.mc, 'summary') && ~isfield(S.mc.summary, 'pd_comp')
        mc = S.mc;
        fprintf('  Loaded cached Monte Carlo results: %s\n', cache_file);
        fprintf('%s', mc.report);
        return;
    end
    fprintf('  Cache %s does not match the current schema/config. Recomputing.\n', cache_file);
end

alg_ids = {'binary', 'coherent'};
n_alg   = numel(alg_ids);
algs    = cell(1, n_alg);
for a = 1:n_alg
    algs{a} = get_detection_algorithm(alg_ids{a});
end
n_cls = numel(cfg.classes);
c0    = 3e8;

[cbw_pool, mcs_pool] = normalize_tx_pools(cfg.cbw, cfg.mcs);

if isfield(cfg, 'range_lim') && ~isempty(cfg.range_lim)
    default_range_lim = cfg.range_lim;
else
    default_range_lim = [cfg.range_edges(1), cfg.range_edges(end)];
end

if isfield(cfg, 'gate_r_factor') && ~isempty(cfg.gate_r_factor)
    gate_r_factor = cfg.gate_r_factor;
else
    gate_r_factor = 1.0;
end

if isfield(cfg, 'p_rx_dBm') && ~isempty(cfg.p_rx_dBm)
    p_rx_arg = cfg.p_rx_dBm;
    p_rx_str = sprintf('P_rx = %.1f dBm', p_rx_arg);
else
    p_rx_arg = [];
    p_rx_str = 'P_rx = default';
end

fprintf('  Monte Carlo [%s]: %s %s %s, %s, %s, %d trials\n', ...
    cfg.name, cfg.standard, format_cbw_pool(cbw_pool), format_mcs_pool(mcs_pool), ...
    cfg.channel_model, p_rx_str, cfg.n_trials);

rng(cfg.seed, 'twister');
tx_cache = cell(numel(cbw_pool), numel(mcs_pool));
if numel(cbw_pool) == 1 && numel(mcs_pool) == 1
    [wf0, fs0, prm0, cfg0] = run_quiet(@step1_transmitter, 4, cfg.standard, cbw_pool{1}, mcs_pool(1));
    tx_cache{1, 1} = make_tx_entry(wf0, fs0, prm0, cfg0, cbw_pool{1});
end
fc = [];

% Raw per-target records
max_tgt     = cfg.n_trials * sum(arrayfun(@(c) max(c.count_set), cfg.classes));
rec_trial   = zeros(max_tgt, 1);
rec_class   = zeros(max_tgt, 1);
rec_rcs     = zeros(max_tgt, 1);
rec_range   = zeros(max_tgt, 1);
rec_vel     = zeros(max_tgt, 1);
rec_cbw_mhz = zeros(max_tgt, 1);
rec_mcs     = zeros(max_tgt, 1);
rec_hit     = false(max_tgt, n_alg);
rec_err_r   = nan(max_tgt, n_alg);
rec_err_v   = nan(max_tgt, n_alg);
rec_pnfr    = nan(max_tgt, n_alg);
n_rec       = 0;

% Per-trial records
trial_cbw_mhz = nan(cfg.n_trials, 1);
trial_mcs     = nan(cfg.n_trials, 1);
trial_fs      = nan(cfg.n_trials, 1);
trial_gate_r  = nan(cfg.n_trials, 1);
trial_gate_v  = nan(cfg.n_trials, 1);
trial_dv_ray  = nan(cfg.n_trials, 1);
trial_failed  = false(cfg.n_trials, 1);
trial_n_det   = nan(cfg.n_trials, n_alg);
trial_n_fa    = nan(cfg.n_trials, n_alg);
trial_iter    = nan(cfg.n_trials, n_alg);
trial_resid   = nan(cfg.n_trials, n_alg);

t_start = tic;
for tr = 1:cfg.n_trials
    if numel(cbw_pool) > 1
        icbw = randi(numel(cbw_pool));
    else
        icbw = 1;
    end
    if numel(mcs_pool) > 1
        imcs = randi(numel(mcs_pool));
    else
        imcs = 1;
    end
    if isempty(tx_cache{icbw, imcs})
        [wf_t, fs_t, prm_t, cfg_t] = run_quiet(@step1_transmitter, 4, cfg.standard, cbw_pool{icbw}, mcs_pool(imcs));
        tx_cache{icbw, imcs} = make_tx_entry(wf_t, fs_t, prm_t, cfg_t, cbw_pool{icbw});
    end
    tx       = tx_cache{icbw, imcs};
    waveform = tx.waveform;
    fs       = tx.fs;
    params   = tx.params;
    cfg_wlan = tx.cfg_wlan;
    cbw_mhz  = tx.cbw_mhz;
    mcs_val  = mcs_pool(imcs);

    dr_ray_tr  = c0 / (2 * fs); % One range resolution cell (Rayleigh, c/2B)
    gate_r_tr  = gate_r_factor * dr_ray_tr;

    trial_cbw_mhz(tr) = cbw_mhz;
    trial_mcs(tr)     = mcs_val;
    trial_fs(tr)      = fs;
    trial_gate_r(tr)  = gate_r_tr;

    targets = draw_scene(cfg.classes, default_range_lim);
    n_t     = numel(targets);
    idx     = n_rec + (1:n_t);
    n_rec   = n_rec + n_t;
    rec_trial(idx)   = tr;
    rec_class(idx)   = [targets.class_idx];
    rec_rcs(idx)     = [targets.rcs];
    rec_range(idx)   = [targets.range_m];
    rec_vel(idx)     = [targets.velocity_mps];
    rec_cbw_mhz(idx) = cbw_mhz;
    rec_mcs(idx)     = mcs_val;

    try
        [rx, fc, intrinsic_delay] = run_quiet(@step2_channel, 3, waveform, fs, ...
            cfg.channel_model, cfg_wlan, targets, p_rx_arg);
        radar_data = run_quiet(@step3_receiver, 1, rx, waveform, fs, fc, params, [], [], intrinsic_delay);
    catch err
        trial_failed(tr) = true;
        warning('Trial %d failed in receiver chain: %s', tr, err.message);
        continue;
    end

    T_cpi_tr  = radar_data.n_symbols * (radar_data.Nfft + radar_data.Ncp) / fs;
    dv_ray_tr = c0 / (2 * fc * T_cpi_tr); % Doppler (velocity) Rayleigh resolution
    gate_v_tr = cfg.gate_v_factor * dv_ray_tr;
    trial_dv_ray(tr) = dv_ray_tr;
    trial_gate_v(tr) = gate_v_tr;

    r_true = [targets.range_m];
    v_true = [targets.velocity_mps];

    for a = 1:n_alg
        [det, ~, ~, ~, pnfr, dg] = run_quiet(@step4_interpreter, 6, radar_data, fs, fc, ...
            cfg.p_FA, algs{a}, p_rx_arg, false);
        if isempty(det)
            d_hat = zeros(1, 0);
            v_hat = zeros(1, 0);
        else
            d_hat = [det.d_hat];
            v_hat = [det.v_hat];
        end

        [hit, det_idx] = associate(d_hat, v_hat, r_true, v_true, gate_r_tr, gate_v_tr);
        rec_hit(idx, a) = hit;

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
keep        = 1:n_rec;
rec_trial   = rec_trial(keep);
rec_class   = rec_class(keep);
rec_rcs     = rec_rcs(keep);
rec_range   = rec_range(keep);
rec_vel     = rec_vel(keep);
rec_cbw_mhz = rec_cbw_mhz(keep);
rec_mcs     = rec_mcs(keep);
rec_hit     = rec_hit(keep, :);
rec_err_r   = rec_err_r(keep, :);
rec_err_v   = rec_err_v(keep, :);
rec_pnfr    = rec_pnfr(keep, :);

% Per-bin detection probability with 95% Wilson intervals
edges   = cfg.range_edges(:).';
n_bin   = numel(edges) - 1;
centers = (edges(1:end-1) + edges(2:end)) / 2;
bin_idx = discretize(rec_range, edges);

bins = struct('edges', edges, 'centers', centers, ...
    'n', zeros(n_alg, n_cls, n_bin), 'k', zeros(n_alg, n_cls, n_bin), ...
    'pd', nan(n_alg, n_cls, n_bin), 'ci_lo', nan(n_alg, n_cls, n_bin), 'ci_hi', nan(n_alg, n_cls, n_bin));

for a = 1:n_alg
    for c = 1:n_cls
        for b = 1:n_bin
            sel = (rec_class == c) & (bin_idx == b);
            n   = nnz(sel);
            k   = nnz(rec_hit(sel, a));
            [lo, hi] = wilson_ci(k, n);
            bins.n(a, c, b) = n;
            bins.k(a, c, b) = k;
            if n > 0
                bins.pd(a, c, b) = k / n;
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
            summary.pd(a, c) = k / n;
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
summary.mean_n_det = mean(trial_n_det(ok, :), 1);
summary.mean_n_fa  = mean(trial_n_fa(ok, :), 1);
summary.mean_iter  = mean(trial_iter(ok, :), 1);
summary.mean_resid = mean(trial_resid(ok, :), 1);

% Empty-scene (K = 0) empirical false-alarm verification
n_empty        = 10;
empty_fa_count = zeros(n_empty, n_alg);
t_empty        = struct('type', 'human', 'range_m', 10.0, 'velocity_mps', 10.0, 'rcs', 0.0);
for et = 1:n_empty
    icbw_e = mod(et - 1, numel(cbw_pool)) + 1;
    imcs_e = randi(numel(mcs_pool));
    if isempty(tx_cache{icbw_e, imcs_e})
        [wf_e, fs_e, prm_e, cfg_e] = run_quiet(@step1_transmitter, 4, cfg.standard, cbw_pool{icbw_e}, mcs_pool(imcs_e));
        tx_cache{icbw_e, imcs_e} = make_tx_entry(wf_e, fs_e, prm_e, cfg_e, cbw_pool{icbw_e});
    end
    tx_e = tx_cache{icbw_e, imcs_e};
    try
        [rx_e, fc_e, id_e] = run_quiet(@step2_channel, 3, tx_e.waveform, tx_e.fs, ...
            cfg.channel_model, tx_e.cfg_wlan, t_empty, p_rx_arg);
        rd_e = run_quiet(@step3_receiver, 1, rx_e, tx_e.waveform, tx_e.fs, fc_e, tx_e.params, [], [], id_e);
        for a = 1:n_alg
            det_e = run_quiet(@step4_interpreter, 1, rd_e, tx_e.fs, fc_e, ...
                cfg.p_FA, algs{a}, p_rx_arg, false);
            empty_fa_count(et, a) = numel(det_e);
        end
    catch
        empty_fa_count(et, :) = NaN;
    end
end
summary.empty_n_trials = n_empty;
summary.empty_fa_mean  = mean(empty_fa_count, 1, 'omitnan');
summary.empty_fa_prob  = mean(empty_fa_count > 0, 1, 'omitnan');
summary.n_failed       = nnz(trial_failed);

gate_r_vals = unique(trial_gate_r(ok));
if isempty(gate_r_vals)
    gate_r_meta = NaN;
elseif isscalar(gate_r_vals)
    gate_r_meta = gate_r_vals;
else
    gate_r_meta = [min(gate_r_vals), max(gate_r_vals)];
end
fs_meta     = median(trial_fs(ok), 'omitnan');
gate_v_meta = median(trial_gate_v(ok), 'omitnan');
dv_ray_meta = median(trial_dv_ray(ok), 'omitnan');

mc = struct();
mc.cfg        = cfg;
mc.alg_ids    = alg_ids;
mc.alg_names  = cellfun(@(s) s.name, algs, 'UniformOutput', false);
mc.alg_desc   = cellfun(@(s) s.description_pl, algs, 'UniformOutput', false);
mc.class_keys = {cfg.classes.key};
mc.bins       = bins;
mc.summary    = summary;
mc.meta       = struct('fs', fs_meta, 'fc', fc, 'gate_r', gate_r_meta, 'gate_v', gate_v_meta, ...
    'dv_rayleigh', dv_ray_meta, 'cbw_pool', {cbw_pool}, 'mcs_pool', mcs_pool, ...
    'elapsed_s', elapsed_s, 'created', char(datetime('now')));
mc.raw        = struct('trial', rec_trial, 'class', rec_class, 'rcs', rec_rcs, ...
    'range_m', rec_range, 'velocity_mps', rec_vel, 'cbw_mhz', rec_cbw_mhz, 'mcs', rec_mcs, ...
    'hit', rec_hit, 'err_r', rec_err_r, 'err_v', rec_err_v, 'pnfr_dB', rec_pnfr, ...
    'trial_cbw_mhz', trial_cbw_mhz, 'trial_mcs', trial_mcs, ...
    'trial_gate_r', trial_gate_r, 'trial_gate_v', trial_gate_v, ...
    'trial_failed', trial_failed, ...
    'trial_n_det', trial_n_det, 'trial_n_fa', trial_n_fa, ...
    'trial_iter', trial_iter, 'trial_resid', trial_resid);
mc.report     = build_report(mc);

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

function targets = draw_scene(classes, default_range_lim)
% DRAW_SCENE Random scene: per-class target count, uniform range (with optional
% per-class cls.range_lim), uniform |v| with random sign.
% No anti-collision constraint: close targets may mask each other, as in reality.
targets = struct('type', {}, 'rcs', {}, 'range_m', {}, 'velocity_mps', {}, 'class_idx', {});
for c = 1:numel(classes)
    cls = classes(c);
    if isfield(cls, 'range_lim') && ~isempty(cls.range_lim)
        cls_range_lim = cls.range_lim;
    else
        cls_range_lim = default_range_lim;
    end
    n_c = cls.count_set(randi(numel(cls.count_set)));
    for k = 1:n_c
        r_m   = cls_range_lim(1) + diff(cls_range_lim) * rand();
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

function [cbw_pool, mcs_pool] = normalize_tx_pools(cbw_in, mcs_in)
if iscell(cbw_in) || isstring(cbw_in)
    cbw_pool = cellstr(cbw_in(:).');
else
    cbw_pool = {char(cbw_in)};
end
mcs_pool = reshape(double(mcs_in), 1, []);
end

function entry = make_tx_entry(waveform, fs, params, cfg_wlan, cbw_str)
entry = struct('waveform', waveform, 'fs', fs, 'params', params, ...
    'cfg_wlan', cfg_wlan, 'cbw_mhz', str2double(regexprep(cbw_str, '\D', '')));
end

function s = format_cbw_pool(cbw_pool)
if numel(cbw_pool) == 1
    s = cbw_pool{1};
else
    mhz = cellfun(@(c) regexprep(c, '\D', ''), cbw_pool, 'UniformOutput', false);
    s = ['CBW' strjoin(mhz, '/')];
end
end

function s = format_mcs_pool(mcs_pool)
if numel(mcs_pool) == 1
    s = sprintf('MCS %d', mcs_pool(1));
elseif isequal(mcs_pool, min(mcs_pool):max(mcs_pool))
    s = sprintf('MCS %d..%d', min(mcs_pool), max(mcs_pool));
else
    s = ['MCS [' strjoin(arrayfun(@num2str, mcs_pool, 'UniformOutput', false), ',') ']'];
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
v_sign_mismatch = (reshape(v_hat, 1, []) .* reshape(v_true, [], 1)) < 0;
cost = hypot(dr / gate_r, dv / gate_v);
cost(dr > gate_r | dv > gate_v | v_sign_mismatch) = inf;
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

if isfield(cfg, 'p_rx_dBm') && ~isempty(cfg.p_rx_dBm)
    p_rx_rpt = sprintf('P_rx %.1f dBm', cfg.p_rx_dBm);
else
    p_rx_rpt = 'P_rx default';
end

[cbw_pool, mcs_pool] = normalize_tx_pools(cfg.cbw, cfg.mcs);
if isscalar(mc.meta.gate_r)
    dr_str = sprintf('%.3f m', mc.meta.gate_r);
else
    dr_str = sprintf('%.3f..%.3f m', mc.meta.gate_r(1), mc.meta.gate_r(2));
end

txt = sprintf('\n  ===== Monte Carlo summary [%s] =====\n', cfg.name);
txt = [txt, sprintf('  %s %s %s | %s | %s | p_FA %.0e | %d trials (%d failed) | %.1f s\n', ...
    cfg.standard, format_cbw_pool(cbw_pool), format_mcs_pool(mcs_pool), ...
    cfg.channel_model, p_rx_rpt, cfg.p_FA, ...
    cfg.n_trials, S.n_failed, mc.meta.elapsed_s)];
txt = [txt, sprintf('  Gate: dR = %s, dv = %.2f m/s (%.2f x Rayleigh %.2f m/s)\n', ...
    dr_str, mc.meta.gate_v, cfg.gate_v_factor, mc.meta.dv_rayleigh)];

bin_hdr = strjoin(arrayfun(@(lo, hi) sprintf('%5.0f-%-3.0f', lo, hi), ...
    B.edges(1:end-1), B.edges(2:end), 'UniformOutput', false), ' ');

for a = 1:n_alg
    txt = [txt, sprintf('\n  --- %s ---\n', mc.alg_names{a})]; %#ok<AGROW>
    txt = [txt, sprintf('  mean detections/frame %.2f | false alarms/frame %.2f | empty K=0 FA/frame %.2f (P_FA %.1f%%) | iterations %.1f | residuals %.1f\n', ...
        S.mean_n_det(a), S.mean_n_fa(a), S.empty_fa_mean(a), 100 * S.empty_fa_prob(a), S.mean_iter(a), S.mean_resid(a))]; %#ok<AGROW>
    for c = 1:n_cls
        txt = [txt, sprintf('  %-12s N=%4d | P_D %5.1f%% [%4.1f, %4.1f] | R50 %s | R80 %s | RMSE_R %.2f m | RMSE_v %.2f m/s | PNFR %.1f dB\n', ...
            mc.class_keys{c}, S.n_targets(c), 100 * S.pd(a, c), 100 * S.pd_lo(a, c), 100 * S.pd_hi(a, c), ...
            fmt_range(S.r50(a, c), B.edges), fmt_range(S.r80(a, c), B.edges), ...
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
