function plot_constellation(symbols, fig_title)
    % PLOT_CONSTELLATION Visualizes the constellation diagram of complex symbols
    
    figure('Name', fig_title, 'Color', 'white', 'Position', [100, 100, 500, 500]);
    plot(real(symbols), imag(symbols), '.', 'MarkerSize', 10);
    title(fig_title);
    xlabel('In-Phase');
    ylabel('Quadrature');
    grid on;
    axis square;
    
    % Adjust limits based on data
    max_val = max(abs(symbols(:))) * 1.2;
    if max_val > 0
        xlim([-max_val max_val]);
        ylim([-max_val max_val]);
    end
    
    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    fig_dir = fullfile(current_dir, '..', 'results', 'figures');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(gcf, fig_file);
end
