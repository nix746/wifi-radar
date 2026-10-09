function fig_dir = get_figures_dir(subfolder)
% GET_FIGURES_DIR Returns the active directory for saving generated figures.
% If an active directory is set in MATLAB root appdata ('wifi_radar_figures_dir'),
% it uses that directory. Otherwise, creates a new timestamped run folder under
% results/figures/ and stores it in appdata for subsequent calls.
%
% Optional Input:
%   subfolder - string/char name of subfolder inside the figures directory

    base_dir = getappdata(0, 'wifi_radar_figures_dir');
    
    if isempty(base_dir)
        [lib_dir, ~, ~] = fileparts(mfilename('fullpath'));
        project_root = fullfile(lib_dir, '..');
        timestamp_str = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
        base_dir = fullfile(project_root, 'results', 'figures', sprintf('run_%s', timestamp_str));
        setappdata(0, 'wifi_radar_figures_dir', base_dir);
    end

    if nargin >= 1 && ~isempty(subfolder)
        fig_dir = fullfile(base_dir, subfolder);
    else
        fig_dir = base_dir;
    end

    if ~exist(fig_dir, 'dir')
        mkdir(fig_dir);
    end
end
