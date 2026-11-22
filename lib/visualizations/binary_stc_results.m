function binary_stc_results(Per_F_base, B, axis_velocity, axis_range, targets, fig_title, alg)
% BINARY_STC_RESULTS Plots Range-Doppler periodogram and binary map B after Binary STC (Braun Fig. 3.13).

    if nargin < 7 || isempty(alg)
        alg = get_detection_algorithm('binary');
    end
    if nargin < 6 || isempty(fig_title)
        fig_title = sprintf('Wi-Fi Radar - %s', alg.full_name);
    end

    Per_dB_base = 10 * log10(Per_F_base + 1e-12);

    fig = figure('Name', fig_title, ...
                 'Color', 'white', 'Position', [100, 100, 1200, 520]);

    c_lims = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];
    v_lims = [axis_velocity(1), axis_velocity(end)];
    r_max  = min(150, axis_range(end));

    % Subplot 1: Original Range-Doppler Periodogram with detections
    ax1 = subplot(1, 2, 1);
    imagesc(ax1, axis_velocity, axis_range, Per_dB_base);
    axis(ax1, 'xy');
    colormap(ax1, 'jet');
    title(ax1, sprintf('1. Original Range-Doppler Periodogram (Before %s)', alg.name));
    xlabel(ax1, 'Velocity [m/s]');
    ylabel(ax1, 'Range [m]');
    ylim(ax1, [0 r_max]);
    xlim(ax1, v_lims);
    clim(ax1, c_lims);
    hold(ax1, 'on');
    if ~isempty(targets)
        plot(ax1, [targets.v_hat], [targets.d_hat], ...
             'kx', 'MarkerSize', 12, 'LineWidth', 2.2);
        legend(ax1, 'Localized Targets', 'Location', 'northeast');
    end
    hold(ax1, 'off');
    cbar = colorbar(ax1);
    cbar.Label.String = 'Power [dB]';
    grid(ax1, 'on');
    box(ax1, 'on');

    % Subplot 2: Final Binary Map B (1 = unmasked, 0 = cancelled main lobe)
    ax2 = subplot(1, 2, 2);
    imagesc(ax2, axis_velocity, axis_range, double(B));
    axis(ax2, 'xy');
    colormap(ax2, gray(2));
    clim(ax2, [0 1]);
    title(ax2, sprintf('2. Binary Cancellation Map B (After %s)', alg.name));
    xlabel(ax2, 'Velocity [m/s]');
    ylabel(ax2, 'Range [m]');
    ylim(ax2, [0 r_max]);
    xlim(ax2, v_lims);
    grid(ax2, 'on');
    box(ax2, 'on');

    % Save figure
    fig_dir    = get_figures_dir();
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file   = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(fig, fig_file);
    fprintf("  Result plot saved to: %s\n", fig_file);
end
