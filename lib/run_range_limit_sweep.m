function [res, fig] = run_range_limit_sweep(panels, title_str, cache_file, force_recompute)
% RUN_RANGE_LIMIT_SWEEP Rigid single-target range sweep in Model-A (TGax dual-slope,
% d_BP = 5 m) across 4 WLAN panels (varying CBW or MCS) and 6 target profiles.
% Computes PNFR(R) [dB] via lib/compute_pnfr and exact CFAR threshold eta/sigma2_hat
% via step4_interpreter, then renders a 2x2 comparison figure.
%
% Inputs:
%   panels          - Struct array (length 4) with fields:
%                       title, standard, cbw, mcs, p_rx_dBm
%   title_str       - Super-title (Polish)
%   cache_file      - Path to .mat cache file (reused if config matches)
%   force_recompute - Ignore cache when true (default: false)

if nargin < 3, cache_file = ''; end
if nargin < 4 || isempty(force_recompute), force_recompute = false; end

ranges_m = 2 : 1 : 30;
p_FA     = 1e-3;
model    = 'Model-A';

sig = char(963); sq = char(178);
profiles = [ ...
    struct('key', 'car_fast',   'label', sprintf('Samochód – szybki (%s = 10 m%s, 15 m/s)', sig, sq),   'type', 'car',   'vel', 15.0, 'color', [0.49, 0.18, 0.56], 'ls', '-',  'marker', 'd'), ...
    struct('key', 'car_slow',   'label', sprintf('Samochód – wolny (%s = 10 m%s, 2 m/s)', sig, sq),     'type', 'car',   'vel',  2.0, 'color', [0.49, 0.18, 0.56], 'ls', '--', 'marker', 'v'), ...
    struct('key', 'cyclist',    'label', sprintf('Rowerzysta (%s = 1 m%s, 5,5 m/s)', sig, sq),          'type', 'human', 'vel',  5.5, 'color', [0.00, 0.45, 0.74], 'ls', '-',  'marker', '^'), ...
    struct('key', 'pedestrian', 'label', sprintf('Pieszy (%s = 1 m%s, 1,4 m/s)', sig, sq),              'type', 'human', 'vel',  1.4, 'color', [0.00, 0.45, 0.74], 'ls', '--', 'marker', 'o'), ...
    struct('key', 'pet_fast',   'label', sprintf('Zwierzę – bieg (%s = 0,1 m%s, 6 m/s)', sig, sq),      'type', 'pet',   'vel',  6.0, 'color', [0.85, 0.33, 0.10], 'ls', '-',  'marker', 's'), ...
    struct('key', 'pet_slow',   'label', sprintf('Zwierzę – chód (%s = 0,1 m%s, 1,5 m/s)', sig, sq),    'type', 'pet',   'vel',  1.5, 'color', [0.85, 0.33, 0.10], 'ls', '--', 'marker', 'p') ...
    ];

cfg_sig = struct('panels', panels, 'ranges_m', ranges_m, 'p_FA', p_FA, ...
    'model', model, 'profile_keys', {{profiles.key}}, 'profile_vels', [profiles.vel]);

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
        pan = panels(p);
        if isfield(pan, 'p_rx_dBm') && ~isempty(pan.p_rx_dBm)
            p_rx_arg = pan.p_rx_dBm;
            p_rx_str = sprintf('P_rx = %.1f dBm', p_rx_arg);
        else
            p_rx_arg = [];
            p_rx_str = 'P_rx = default';
        end
        fprintf('  [Panel %d/%d] %s (%s, %s, MCS %d, %s)...\n', ...
            p, n_pan, pan.title, pan.standard, pan.cbw, pan.mcs, p_rx_str);

        rng(42, 'twister');
        [waveform, fs, params, cfg] = run_quiet(@step1_transmitter, 4, pan.standard, pan.cbw, pan.mcs);
        dr_ray = 3e8 / (2 * fs);

        for c = 1:n_cls
            prof = profiles(c);
            for r = 1:n_rng
                tgt = struct('type', prof.type, 'range_m', ranges_m(r), 'velocity_mps', prof.vel);
                rng(23, 'twister');
                [rx, fc] = run_quiet(@step2_channel, 2, waveform, fs, model, cfg, tgt, p_rx_arg);
                rd       = run_quiet(@step3_receiver, 1, rx, waveform, fs, fc, params);

                if isnan(cfar_dB(p))
                    [~, ~, ~, eta_p, ~, dg_p] = run_quiet(@step4_interpreter, 6, rd, fs, fc, pan.standard, p_FA, 'coherent');
                    cfar_dB(p) = 10 * log10(eta_p / dg_p.sigma2_hat);
                end

                % Local peak lookup around true range (allows MTI slow-target Doppler shift)
                r_win = abs(rd.axis_range - ranges_m(r)) <= max(1.0 * dr_ray, 1.5);
                if prof.vel < 4.0
                    v_win = rd.axis_velocity >= 0.5 & rd.axis_velocity <= 10.0;
                else
                    v_win = abs(rd.axis_velocity - prof.vel) <= 4.0;
                end
                r_idx_cand = find(r_win);
                v_idx_cand = find(v_win);
                sub_P = rd.Per_F(r_idx_cand, v_idx_cand);
                [~, lin] = max(sub_P(:));
                [ir_l, iv_l] = ind2sub(size(sub_P), lin);
                r_pk = r_idx_cand(ir_l);
                v_pk = v_idx_cand(iv_l);

                m_pnfr = compute_pnfr(rd.CPer_F, [r_pk, v_pk]);
                pnfr_dB(p, c, r) = m_pnfr.pnfr_dB(1);
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

% 2x2 tiledlayout with clean non-overlapping title and shared south legend
fig = figure('Name', title_str, 'Color', 'w', 'Position', [60, 60, 1280, 900], 'Visible', 'off');
tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, title_str, 'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

letters = 'abcd';
h_leg   = gobjects(1, n_cls + 2);

for p = 1:n_pan
    ax = nexttile(tl, p);
    hold(ax, 'on');
    for c = 1:n_cls
        prof  = profiles(c);
        curve = reshape(res.pnfr_dB(p, c, :), 1, []);
        h = plot(ax, ranges_m, curve, ...
            'Color', prof.color, 'LineStyle', prof.ls, 'Marker', prof.marker, ...
            'MarkerFaceColor', prof.color, 'MarkerSize', 3.8, 'LineWidth', 1.6, ...
            'DisplayName', prof.label);
        if p == 1, h_leg(c) = h; end
    end
    h_cfar = yline(ax, res.cfar_dB(p), '-.k', 'LineWidth', 1.5, 'DisplayName', 'Próg detekcji CFAR (p_FA = 10^-3)');
    h_dbp  = xline(ax, 5.0, ':k', 'LineWidth', 1.4, 'DisplayName', 'Granica LoS/NLOS (d_BP = 5 m)');
    if p == 1
        h_leg(n_cls + 1) = h_cfar;
        h_leg(n_cls + 2) = h_dbp;
    end
    hold(ax, 'off');

    xlim(ax, [ranges_m(1), ranges_m(end)]);
    ylim(ax, [5, 70]);
    xticks(ax, 2:4:30);
    yticks(ax, 10:10:70);
    title(ax, sprintf('%s) %s', letters(p), panels(p).title), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel(ax, 'Odległość bistatyczna [m]', 'FontSize', 10.5, 'FontWeight', 'bold');
    ylabel(ax, 'Kontrast celu PNFR [dB]', 'FontSize', 10.5, 'FontWeight', 'bold');
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.25, 'Box', 'on', 'LineWidth', 1.0, 'FontSize', 10);
end

leg = legend(h_leg, 'Orientation', 'horizontal', 'NumColumns', 2, ...
    'FontSize', 9.5, 'Interpreter', 'none');
leg.Layout.Tile = 'south';
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
