function fig = plot_detection_vs_range(mc, styles, title_str)
% PLOT_DETECTION_VS_RANGE Two-panel P_D(R) plot (Binary STC | Coherent STC) with
% 95% Wilson confidence intervals for every target class.
%
% Inputs:
%   mc        - Output struct of run_detection_monte_carlo
%   styles    - Struct array (one per class, same order as mc.cfg.classes):
%               label (Polish legend text), color [1x3], marker
%   title_str - Figure super-title (Polish)
%
% Output:
%   fig       - Invisible figure handle (shown/exported by save_thesis_figure)

    min_count = 3; % Bins with fewer samples are not plotted

    edges   = mc.bins.edges;
    centers = mc.bins.centers;
    n_alg   = numel(mc.alg_names);
    n_cls   = numel(styles);
    bin_w   = mean(diff(edges));
    offsets = ((1:n_cls) - (n_cls + 1) / 2) * 0.07 * bin_w; % Avoid overlapping error bars
    letters = 'abcd';

    fig = figure('Name', title_str, 'Color', 'w', 'Position', [80, 100, 1280, 540], 'Visible', 'off');
    sgtitle(title_str, 'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');

    for a = 1:n_alg
        ax = subplot(1, n_alg, a);
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

            errorbar(ax, centers + offsets(c), pd, pd - lo, hi - pd, ...
                'Color', styles(c).color, 'Marker', styles(c).marker, ...
                'MarkerFaceColor', styles(c).color, 'MarkerSize', 6.5, ...
                'LineWidth', 1.8, 'CapSize', 6, 'DisplayName', styles(c).label);
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
        legend(ax, 'Location', 'southoutside', 'Orientation', 'horizontal', ...
            'NumColumns', min(n_cls, 2), 'FontSize', 9.5, 'Interpreter', 'none');
    end
end
