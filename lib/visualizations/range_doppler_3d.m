function range_doppler_3d(RD_Map, axis_velocity, axis_range, fig_title)
    % PLOT_RANGE_DOPPLER_3D Visualizes the 3D mesh of the Range-Doppler map
    
    RD_Map_dB = 20*log10(abs(RD_Map) + 1e-9);
    
    figure('Name', fig_title, 'Color', 'white', 'Position', [100, 100, 900, 600]);
    
    % Wyświetlanie surowej mapy 3D
    mesh(axis_velocity, axis_range, RD_Map_dB);
    
    title(fig_title);
    xlabel('Velocity [m/s]');
    ylabel('Range [m]');
    zlabel('Power [dB]');
    colormap('jet');
    colorbar;
    
    [current_dir, ~, ~] = fileparts(mfilename('fullpath'));
    fig_dir = fullfile(current_dir, '..', '..', 'results', 'figures');
    if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
    safe_title = regexprep(lower(fig_title), '[^a-z0-9]', '_');
    fig_file = fullfile(fig_dir, sprintf('%s.png', safe_title));
    saveas(gcf, fig_file);
end
