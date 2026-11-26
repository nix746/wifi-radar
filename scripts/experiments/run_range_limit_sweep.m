function res = run_range_limit_sweep(panels, cache_file, force_recompute, ranges_m)
% RUN_RANGE_LIMIT_SWEEP Monte-Carlo averaged single-target range sweep in TGax
% channel models across 1 or more WLAN panels and 6 target profiles.
% Computes mean PNFR(R) [dB] via lib/compute_pnfr with window-derived guard boxes
% and exact CFAR threshold eta/sigma2_hat via step4_interpreter.
%
% Inputs:
%   panels          - Struct array with fields:
%                       title, standard, cbw, mcs, p_rx_dBm, (optional) channel_model
%   cache_file      - Path to .mat cache file (reused if config matches)
%   force_recompute - Ignore cache when true (default: false)
%   ranges_m        - Range grid in meters (default: 2:5:62)
%
% Output:
%   res             - Struct with cfg_sig, panels, profiles, ranges_m, pnfr_dB,
%                     cfar_dB, r_max_m, and elapsed_s

if nargin < 2, cache_file = ''; end
if nargin < 3 || isempty(force_recompute), force_recompute = false; end
if nargin < 4 || isempty(ranges_m), ranges_m = 2 : 5 : 62; end

n_mc          = 4;
p_FA          = 1e-3;
default_model = 'Model-C';

panel_models = cell(1, numel(panels));
for p = 1:numel(panels)
    if isfield(panels(p), 'channel_model') && ~isempty(panels(p).channel_model)
        panel_models{p} = panels(p).channel_model;
    else
        panel_models{p} = default_model;
    end
end

sig = char(963); sq = char(178);
profiles = [ ...
    struct('key', 'car_fast',   'label', sprintf('Samochód – szybki (%s = 10 m%s, 15 m/s)', sig, sq),   'type', 'car',   'vel', 15.0, 'color', [0.49, 0.18, 0.56], 'ls', '-',  'marker', 'd'), ...
    struct('key', 'car_slow',   'label', sprintf('Samochód – wolny (%s = 10 m%s, 2 m/s)', sig, sq),     'type', 'car',   'vel',  2.0, 'color', [0.49, 0.18, 0.56], 'ls', '--', 'marker', 'v'), ...
    struct('key', 'cyclist',    'label', sprintf('Rowerzysta (%s = 1 m%s, 5,5 m/s)', sig, sq),          'type', 'human', 'vel',  5.5, 'color', [0.00, 0.45, 0.74], 'ls', '-',  'marker', '^'), ...
    struct('key', 'pedestrian', 'label', sprintf('Pieszy (%s = 1 m%s, 1,4 m/s)', sig, sq),              'type', 'human', 'vel',  1.4, 'color', [0.00, 0.45, 0.74], 'ls', '--', 'marker', 'o'), ...
    struct('key', 'pet_fast',   'label', sprintf('Zwierzę – bieg (%s = 0,1 m%s, 6 m/s)', sig, sq),      'type', 'pet',   'vel',  6.0, 'color', [0.85, 0.33, 0.10], 'ls', '-',  'marker', 's'), ...
    struct('key', 'pet_slow',   'label', sprintf('Zwierzę – chód (%s = 0,1 m%s, 1,5 m/s)', sig, sq),    'type', 'pet',   'vel',  1.5, 'color', [0.85, 0.33, 0.10], 'ls', '--', 'marker', 'p') ...
    ];

cfg_sig = struct('panels', panels, 'panel_models', {panel_models}, 'ranges_m', ranges_m, ...
    'n_mc', n_mc, 'p_FA', p_FA, 'profile_keys', {{profiles.key}}, 'profile_vels', [profiles.vel]);

recompute = true;
if ~isempty(cache_file) && ~force_recompute && isfile(cache_file)
    S = load(cache_file, 'res');
    if isfield(S, 'res') && isfield(S.res, 'cfg_sig') && isequaln(S.res.cfg_sig, cfg_sig)
        res = S.res;
        recompute = false;
        fprintf('  Loaded cached range-limit sweep: %s\n', cache_file);
    end
end

n_pan = numel(panels);
n_cls = numel(profiles);
n_rng = numel(ranges_m);

if recompute
    pnfr_dB     = nan(n_pan, n_cls, n_rng);
    cfar_dB     = nan(n_pan, 1);
    r_max_m     = nan(n_pan, n_cls);
    t_start     = tic;

    for p = 1:n_pan
        pan     = panels(p);
        model_p = panel_models{p};
        if isfield(pan, 'p_rx_dBm') && ~isempty(pan.p_rx_dBm)
            p_rx_arg = pan.p_rx_dBm;
            p_rx_str = sprintf('P_rx = %.1f dBm', p_rx_arg);
        else
            p_rx_arg = [];
            p_rx_str = 'P_rx = default';
        end
        fprintf('  [Panel %d/%d] %s (%s, %s, MCS %d, %s, %s)...\n', ...
            p, n_pan, pan.title, pan.standard, pan.cbw, pan.mcs, model_p, p_rx_str);

        rng(42, 'twister');
        [waveform, fs, params, cfg] = run_quiet(@step1_transmitter, 4, pan.standard, pan.cbw, pan.mcs);
        dr_ray     = 3e8 / (2 * fs);
        pnfr_guard = [];
        dv_ray     = [];

        for c = 1:n_cls
            prof = profiles(c);
            for r = 1:n_rng
                tgt       = struct('type', prof.type, 'range_m', ranges_m(r), 'velocity_mps', prof.vel);
                pnfr_vals = nan(1, n_mc);
                for mc_i = 1:n_mc
                    rng(1000 + mc_i, 'twister');
                    [rx, fc, intrinsic_delay] = run_quiet(@step2_channel, 3, waveform, fs, model_p, cfg, tgt, p_rx_arg);
                    rd       = run_quiet(@step3_receiver, 1, rx, waveform, fs, fc, params, [], [], intrinsic_delay);

                    if isnan(cfar_dB(p)) || isempty(pnfr_guard)
                        [~, ~, ~, eta_p, ~, dg_p] = run_quiet(@step4_interpreter, 6, rd, fs, fc, p_FA, 'coherent', p_rx_arg);
                        cfar_dB(p) = 10 * log10(eta_p / dg_p.sigma2_hat);
                        pnfr_guard = [ceil(dg_p.N_win_null / 2), ceil(dg_p.M_win_null / 2)];
                        T_cpi      = rd.n_symbols * (rd.Nfft + rd.Ncp) / fs;
                        dv_ray     = 3e8 / (2 * fc * T_cpi);
                    end

                    % Unified Rayleigh-cell local lookup with sign consistency
                    r_win      = abs(rd.axis_range - ranges_m(r)) <= max(1.0 * dr_ray, 1.5);
                    v_win      = (rd.axis_velocity * prof.vel >= 0) & (abs(rd.axis_velocity - prof.vel) <= dv_ray);
                    r_idx_cand = find(r_win);
                    v_idx_cand = find(v_win);
                    sub_P      = rd.Per_F(r_idx_cand, v_idx_cand);
                    [~, lin]   = max(sub_P(:));
                    [ir_l, iv_l] = ind2sub(size(sub_P), lin);
                    r_pk = r_idx_cand(ir_l);
                    v_pk = v_idx_cand(iv_l);

                    m_pnfr = compute_pnfr(rd.CPer_F, [r_pk, v_pk], pnfr_guard);
                    pnfr_vals(mc_i) = m_pnfr.pnfr_dB(1);
                end
                pnfr_dB(p, c, r) = mean(pnfr_vals, 'omitnan');
            end

            curve = reshape(pnfr_dB(p, c, :), 1, []);
            r_max_m(p, c) = crossing_range(ranges_m, curve, cfar_dB(p));
        end
    end

    res = struct('cfg_sig', cfg_sig, 'panels', panels, 'profiles', profiles, ...
        'ranges_m', ranges_m, 'pnfr_dB', pnfr_dB, 'cfar_dB', cfar_dB, ...
        'r_max_m', r_max_m, 'elapsed_s', toc(t_start));

    if ~isempty(cache_file)
        cache_dir = fileparts(cache_file);
        if ~isempty(cache_dir) && ~isfolder(cache_dir)
            mkdir(cache_dir);
        end
        save(cache_file, 'res');
        fprintf('  Cached range-limit results to: %s (%.1f s)\n', cache_file, res.elapsed_s);
    end
end

% Console R_max summary table
fprintf('\n  --- Estimated Detection Range Limits R_max [m] (PNFR >= CFAR threshold) ---\n');
for p = 1:n_pan
    fprintf('  [%s | CFAR = %.1f dB]\n', panels(p).title, res.cfar_dB(p));
    for c = 1:n_cls
        fprintf('    %-40s R_max = %s\n', profiles(c).label, fmt_rmax(res.r_max_m(p, c), ranges_m));
    end
end
fprintf('\n');
end

function r = crossing_range(x, y, level)
j = find(y < level, 1, 'first');
if isempty(j)
    r = Inf;
elseif j == 1
    r = -Inf;
else
    r = x(j - 1) + (y(j - 1) - level) * (x(j) - x(j - 1)) / (y(j - 1) - y(j));
end
end

function s = fmt_rmax(r, ranges_m)
if isinf(r) && r > 0
    s = sprintf('> %.0f m', ranges_m(end));
elseif isinf(r)
    s = sprintf('< %.0f m', ranges_m(1));
else
    s = sprintf('%.1f m', r);
end
end

function varargout = run_quiet(fn, n_out, varargin)
varargout = cell(1, n_out);
evalc('[varargout{1:n_out}] = fn(varargin{:});');
end
