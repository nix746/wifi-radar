function radar_heatmap(matrix_data, fig_title, x_label, y_label)
    % PLOT_HEATMAP Plots a 2D matrix as a heatmap (useful for F_rx and H)
    
    figure('Name', fig_title, 'Color', 'white', 'Position', [100, 100, 600, 450]);
    
    % We assume the input is complex, so we plot the magnitude in dB
    % Add epsilon to avoid log(0)
    matrix_dB = 20 * log10(abs(matrix_data) + 1e-9);
    
    imagesc(matrix_dB);
    axis xy; % Origin at bottom-left
    colormap('parula');
    colorbar;
    
    title(fig_title);
    xlabel(x_label);
    ylabel(y_label);
    
    fig_dir = get_figures_dir();
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(gcf, fig_file);
    fprintf("  Result plot saved to: %s\n", fig_file);
end
