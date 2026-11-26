function fig = plot_range_limits(res, title_str)
% PLOT_RANGE_LIMITS Renders single-panel or multi-panel PNFR(R) detection
% range-limit curves from run_range_limit_sweep results.
%
% Inputs:
%   res       - Output struct of run_range_limit_sweep
%   title_str - Figure title / super-title (Polish)
%
% Output:
%   fig       - Invisible figure handle (shown/exported by save_thesis_figure)

panels   = res.panels;
profiles = res.profiles;
ranges_m = res.ranges_m;
n_pan    = numel(panels);
n_cls    = numel(profiles);

panel_models = cell(1, n_pan);
if isfield(res, 'cfg_sig') && isfield(res.cfg_sig, 'panel_models') && numel(res.cfg_sig.panel_models) == n_pan
    panel_models = res.cfg_sig.panel_models;
else
    for p = 1:n_pan
        if isfield(panels(p), 'channel_model') && ~isempty(panels(p).channel_model)
            panel_models{p} = panels(p).channel_model;
        else
            panel_models{p} = 'Model-C';
        end
    end
end

if n_pan == 1
    fig = figure('Name', title_str, 'Color', 'w', 'Position', [100, 100, 900, 560], 'Visible', 'off');
    tl  = tiledlayout(fig, 1, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
else
    n_cols = 2;
    n_rows = ceil(n_pan / n_cols);
    fig = figure('Name', title_str, 'Color', 'w', 'Position', [60, 60, 1280, 450 * n_rows], 'Visible', 'off');
    tl  = tiledlayout(fig, n_rows, n_cols, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, title_str, 'FontSize', 13.5, 'FontWeight', 'bold', 'Interpreter', 'none');
end

letters = 'abcd';
h_leg   = gobjects(1, n_cls + 2);

r_span = ranges_m(end);
if r_span <= 45
    tick_step = 5;
else
    tick_step = 10;
end

mk_step = max(1, round(2.0 / median(diff(ranges_m))));
mk_idx  = 1 : mk_step : numel(ranges_m);

for p = 1:n_pan
    ax     = nexttile(tl, p);
    tgax_p = get_tgax_propagation_params(panel_models{p});
    hold(ax, 'on');
    for c = 1:n_cls
        prof  = profiles(c);
        curve = reshape(res.pnfr_dB(p, c, :), 1, []);
        h = plot(ax, ranges_m, curve, ...
            'Color', prof.color, 'LineStyle', prof.ls, 'Marker', prof.marker, ...
            'MarkerIndices', mk_idx, ...
            'MarkerFaceColor', prof.color, 'MarkerSize', 4.5, 'LineWidth', 1.7, ...
            'DisplayName', prof.label);
        if p == 1, h_leg(c) = h; end
    end
    h_cfar = yline(ax, res.cfar_dB(p), '-.k', 'LineWidth', 1.5, 'DisplayName', 'Próg detekcji CFAR (p_FA = 10^-3)');
    if isfinite(tgax_p.d_bp)
        h_dbp = xline(ax, tgax_p.d_bp, ':k', 'LineWidth', 1.4, ...
            'DisplayName', sprintf('Granica LoS/NLOS (d_BP = %g m)', tgax_p.d_bp));
    else
        h_dbp = gobjects(0);
    end
    if p == 1
        h_leg(n_cls + 1) = h_cfar;
        if ~isempty(h_dbp)
            h_leg(n_cls + 2) = h_dbp;
        end
    end
    hold(ax, 'off');

    xlim(ax, [0, ranges_m(end)]);
    ylim(ax, [5, 85]);
    xticks(ax, 0:tick_step:ranges_m(end));
    yticks(ax, 10:10:80);
    if n_pan == 1
        title(ax, title_str, 'FontSize', 12.5, 'FontWeight', 'bold', 'Interpreter', 'none');
        if isfield(panels(1), 'title') && ~isempty(panels(1).title)
            subtitle(ax, panels(1).title, 'FontSize', 10.5, 'Interpreter', 'none');
        end
    else
        title(ax, sprintf('%s) %s', letters(p), panels(p).title), ...
            'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
    end
    xlabel(ax, 'Odległość bistatyczna [m]', 'FontSize', 10.5, 'FontWeight', 'bold');
    ylabel(ax, 'Kontrast celu PNFR [dB]', 'FontSize', 10.5, 'FontWeight', 'bold');
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.25, 'Box', 'on', 'LineWidth', 1.0, 'FontSize', 10);
end

h_leg = h_leg(isgraphics(h_leg));
leg = legend(h_leg, 'Orientation', 'horizontal', 'NumColumns', 2, ...
    'FontSize', 9.5, 'Interpreter', 'none');
leg.Layout.Tile = 'south';
end
