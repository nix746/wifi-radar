function fig = plot_range_limits(res, title_str)
% PLOT_RANGE_LIMITS Renders PNFR(R) detection range-limit curves from
% run_range_limit_sweep results.
%
% Inputs:
%   res       - Output struct of run_range_limit_sweep (single panel)
%   title_str - Figure title (Polish)
%
% Output:
%   fig       - Invisible figure handle (shown/exported by save_thesis_figure)

panel    = res.panels(1);
profiles = res.profiles;
ranges_m = res.ranges_m;
n_cls    = numel(profiles);

if isfield(panel, 'channel_model') && ~isempty(panel.channel_model)
    model_name = panel.channel_model;
else
    model_name = 'Model-C';
end
tgax_p = get_tgax_propagation_params(model_name);

fig = figure('Name', title_str, 'Color', 'w', 'Position', [100, 100, 900, 560], 'Visible', 'off');
tl  = tiledlayout(fig, 1, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
ax  = nexttile(tl, 1);

if ranges_m(end) <= 45
    tick_step = 5;
else
    tick_step = 10;
end
mk_step = max(1, round(2.0 / median(diff(ranges_m))));
mk_idx  = 1 : mk_step : numel(ranges_m);

h_leg = gobjects(1, n_cls + 2);
hold(ax, 'on');
for c = 1:n_cls
    prof  = profiles(c);
    curve = reshape(res.pnfr_dB(1, c, :), 1, []);
    h_leg(c) = plot(ax, ranges_m, curve, ...
        'Color', prof.color, 'LineStyle', prof.ls, 'Marker', prof.marker, ...
        'MarkerIndices', mk_idx, ...
        'MarkerFaceColor', prof.color, 'MarkerSize', 4.5, 'LineWidth', 1.7, ...
        'DisplayName', prof.label);
end
h_leg(n_cls + 1) = yline(ax, res.cfar_dB(1), '-.k', 'LineWidth', 1.5, ...
    'DisplayName', 'Próg detekcji CFAR (p_FA = 10^-3)');
if isfinite(tgax_p.d_bp)
    h_leg(n_cls + 2) = xline(ax, tgax_p.d_bp, ':k', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('Granica LoS/NLOS (d_BP = %g m)', tgax_p.d_bp));
end
hold(ax, 'off');

xlim(ax, [0, ranges_m(end)]);
ylim(ax, [5, 85]);
xticks(ax, 0:tick_step:ranges_m(end));
yticks(ax, 10:10:80);
title(ax, title_str, 'FontSize', 12.5, 'FontWeight', 'bold', 'Interpreter', 'none');
if isfield(panel, 'title') && ~isempty(panel.title)
    subtitle(ax, panel.title, 'FontSize', 10.5, 'Interpreter', 'none');
end
xlabel(ax, 'Odległość bistatyczna [m]', 'FontSize', 10.5, 'FontWeight', 'bold');
ylabel(ax, 'Kontrast celu PNFR [dB]', 'FontSize', 10.5, 'FontWeight', 'bold');
grid(ax, 'on');
set(ax, 'GridAlpha', 0.25, 'Box', 'on', 'LineWidth', 1.0, 'FontSize', 10);

h_leg = h_leg(isgraphics(h_leg));
leg = legend(h_leg, 'Orientation', 'horizontal', 'NumColumns', 2, ...
    'FontSize', 9.5, 'Interpreter', 'none');
leg.Layout.Tile = 'south';
end
