function clean_results(Per_dB_base, Per_dB_clean, axis_velocity, axis_range, targets_found, fig_title)
    % PLOT_CLEAN_RESULTS Plots the Range-Doppler maps before and after CLEAN
    
    if nargin < 6
        fig_title = 'Wi-Fi Radar - Target Detection & CLEAN Cancellation';
    end
    
    fig = figure('Name', fig_title, ...
                 'Color', 'white', 'Position', [100, 100, 1200, 520]);

    c_lims = [max(Per_dB_base(:)) - 60, max(Per_dB_base(:))];

    % Subplot 1: Original Range-Doppler Map
    subplot(1, 2, 1);
    imagesc(axis_velocity, axis_range, Per_dB_base);
    axis xy; colormap('jet');
    title('1. Original Range-Doppler Map (Before CLEAN)');
    xlabel('Velocity [m/s]'); ylabel('Range [m]');
    ylim([0 150]); xlim([-60 60]); clim(c_lims);
    hold on;
    if ~isempty(targets_found)
        plot(axis_velocity(targets_found(:, 2)), axis_range(targets_found(:, 1)), ...
             'kx', 'MarkerSize', 12, 'LineWidth', 2.2);
        legend('Localized Targets', 'Location', 'northeast');
    end
    grid on;

    % Subplot 2: Cleaned Residual Map
    subplot(1, 2, 2);
    imagesc(axis_velocity, axis_range, Per_dB_clean);
    axis xy; colormap('jet');
    title('2. Residual Background (After Coherent CLEAN)');
    xlabel('Velocity [m/s]'); ylabel('Range [m]');
    ylim([0 150]); xlim([-60 60]); clim(c_lims);
    cbar = colorbar; cbar.Label.String = 'Power [dB]';
    grid on;
    
    % Save figure
    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    fig_dir = fullfile(current_dir, '..', '..', 'results', 'figures');
    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir);
    end
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(fig, fig_file);
    fprintf("  Result plot saved to: %s\n", fig_file);
end
