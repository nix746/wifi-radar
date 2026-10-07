function plot_signal_time_domain(waveform, fs, fig_title)
    % PLOT_SIGNAL_TIME_DOMAIN Visualizes the I and Q components of a signal
    
    t_axis = (0:length(waveform)-1) / fs * 1e6;
    
    figure('Name', fig_title, 'Color', 'white', 'Position', [100, 100, 800, 400]);
    plot(t_axis, real(waveform)); 
    hold on;
    plot(t_axis, imag(waveform)); 
    hold off;
    
    title(fig_title);
    xlabel('Time [\mus]'); ylabel('Amplitude');
    legend('In-Phase (I)', 'Quadrature (Q)', 'Location', 'northeast');
    grid on; axis tight;
    
    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    fig_dir = fullfile(current_dir, '..', 'results', 'figures');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(gcf, fig_file);
end
