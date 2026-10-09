function power_spectral_density(waveform, fs, fig_title)
    % PLOT_POWER_SPECTRAL_DENSITY Visualizes the PSD of a waveform
    
    [pxx, f] = pwelch(waveform, [], [], [], fs, 'centered');
    
    figure('Name', fig_title, 'Color', 'white', 'Position', [100, 100, 800, 400]);
    plot(f/1e6, 10*log10(pxx), 'LineWidth', 1.2);
    title(fig_title);
    xlabel('Frequency [MHz]');
    ylabel('Power [dB/Hz]');
    grid on;
    xlim([-15 15]);
    
    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    fig_dir = fullfile(current_dir, '..', 'results', 'figures');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(gcf, fig_file);
end
