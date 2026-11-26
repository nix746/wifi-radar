function fig = plot_detection_vs_range(mc, styles, title_str, d_bp_m)
% PLOT_DETECTION_VS_RANGE Two-panel P_D(R) plot (Binary STC | Coherent STC) with
% 95% Wilson confidence intervals for every target class.
%
% Inputs:
%   mc        - Output struct of run_detection_monte_carlo
%   styles    - Struct array (one per class, same order as mc.cfg.classes):
%               label (Polish legend text), color [1x3], marker
%   title_str - Figure super-title (Polish)
%   d_bp_m    - (Optional) TGax LoS/NLOS breakpoint distance [m] to mark (default: [])
%
% Output:
%   fig       - Invisible figure handle (shown/exported by save_thesis_figure)

if nargin < 4
    d_bp_m = [];
end

min_count = 3; % Bins with fewer samples are not plotted

edges   = mc.bins.edges;
centers = mc.bins.centers;
n_alg   = numel(mc.alg_names);
n_cls   = numel(styles);
bin_w   = mean(diff(edges));
offsets = ((1:n_cls) - (n_cls + 1) / 2) * 0.07 * bin_w; % Avoid overlapping error bars
letters = 'abcd';

has_dbp = ~isempty(d_bp_m) && isfinite(d_bp_m);
n_leg   = n_cls + double(has_dbp);
h_leg   = gobjects(1, n_leg);

fig = figure('Name', title_str, 'Color', 'w', 'Position', [80, 100, 1280, 560], 'Visible', 'off');
tl  = tiledlayout(fig, 1, n_alg, 'TileSpacing', 'compact', 'Padding', 'compact');
title(tl, title_str, 'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

for a = 1:n_alg
    ax = nexttile(tl, a);
    hold(ax, 'on');
    for c = 1:n_cls
        n  = reshape(mc.bins.n(a, c, :), 1, []);
        pd = reshape(mc.bins.pd(a, c, :), 1, []);
        lo = reshape(mc.bins.ci_lo(a, c, :), 1, []);
        hi = reshape(mc.bins.ci_hi(a, c, :), 1, []);
        sparse_bins = n < min_count;
        pd(sparse_bins) = NaN;
        lo(sparse_bins) = NaN;
        hi(sparse_bins) = NaN;

        h = errorbar(ax, centers + offsets(c), pd, pd - lo, hi - pd, ...
            'Color', styles(c).color, 'Marker', styles(c).marker, ...
            'MarkerFaceColor', styles(c).color, 'MarkerSize', 6.5, ...
            'LineWidth', 1.8, 'CapSize', 6, 'DisplayName', styles(c).label);
        if a == 1
            h_leg(c) = h;
        end
    end
    if has_dbp
        h_dbp = xline(ax, d_bp_m, ':k', 'LineWidth', 1.5, ...
            'DisplayName', sprintf('Granica LoS/NLOS (d_BP = %g m)', d_bp_m));
        if a == 1
            h_leg(n_cls + 1) = h_dbp;
        end
    end
    hold(ax, 'off');

    xlim(ax, [edges(1), edges(end)]);
    ylim(ax, [0, 1.05]);
    xticks(ax, edges);
    yticks(ax, 0:0.2:1);
    title(ax, sprintf('%s) %s (%s)', letters(a), mc.alg_names{a}, mc.alg_desc{a}), ...
        'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
    xlabel(ax, 'Odległość bistatyczna [m]', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel(ax, 'Prawdopodobieństwo detekcji P_D', 'FontSize', 11, 'FontWeight', 'bold');
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.25, 'Layer', 'top', 'Box', 'on', 'LineWidth', 1.1, 'FontSize', 10.5);
end

n_cols = min(n_leg, 3);
if n_leg == 4
    n_cols = 2;
end
leg = legend(h_leg, 'Orientation', 'horizontal', 'NumColumns', n_cols, ...
    'FontSize', 9.5, 'Interpreter', 'none');
leg.Layout.Tile = 'south';
end
