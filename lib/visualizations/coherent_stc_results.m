function coherent_stc_results(Per_F_base, Per_F_after, axis_velocity, axis_range, targets, fig_title, alg)
% COHERENT_STC_RESULTS Plots Range-Doppler periodograms before and after Coherent STC.

    if nargin < 7 || isempty(alg)
        alg = get_detection_algorithm('coherent');
    end
    if nargin < 6 || isempty(fig_title)
        fig_title = sprintf('Wi-Fi Radar - %s', alg.full_name);
    end

    Per_dB_base  = 10 * log10(Per_F_base + 1e-12);
    Per_dB_after = 10 * log10(Per_F_after + 1e-12);

    fig = figure('Name', fig_title, ...
                 'Color', 'white', 'Position', [100, 100, 1200, 520]);

    c_lims = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];
    v_lims = [axis_velocity(1), axis_velocity(end)];
    r_max  = min(150, axis_range(end));

    % Subplot 1: Original Range-Doppler Periodogram
    subplot(1, 2, 1);
    imagesc(axis_velocity, axis_range, Per_dB_base);
    axis xy; colormap('jet');
    title(sprintf('1. Original Range-Doppler Periodogram (Before %s)', alg.name));
    xlabel('Velocity [m/s]'); ylabel('Range [m]');
    ylim([0 r_max]); xlim(v_lims); clim(c_lims);
    hold on;
    if ~isempty(targets)
        plot([targets.v_hat], [targets.d_hat], ...
             'kx', 'MarkerSize', 12, 'LineWidth', 2.2);
        legend('Localized Targets', 'Location', 'northeast');
    end
    hold off;
    grid on; box on;

    % Subplot 2: Residual Periodogram after Coherent STC
    subplot(1, 2, 2);
    imagesc(axis_velocity, axis_range, Per_dB_after);
    axis xy; colormap('jet');
    title(sprintf('2. Residual Periodogram (After %s)', alg.name));
    xlabel('Velocity [m/s]'); ylabel('Range [m]');
    ylim([0 r_max]); xlim(v_lims); clim(c_lims);
    cbar = colorbar; cbar.Label.String = 'Power [dB]';
    grid on; box on;

    % Save figure
    fig_dir    = get_figures_dir();
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file   = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(fig, fig_file);
    fprintf("  Result plot saved to: %s\n", fig_file);
end
