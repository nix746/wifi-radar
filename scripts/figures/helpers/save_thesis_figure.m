function out_file = save_thesis_figure(fig, chapter_dir, filename, show_figure, save_png)
% SAVE_THESIS_FIGURE Exports a figure at 300 DPI and controls window visibility.
%
% Inputs:
%   fig         - Handle to the generated MATLAB figure
%   chapter_dir - Subdirectory inside thesis/img/ (e.g., 'ch2_theory', 'ch3_impl', 'ch4_sim')
%   filename    - Output PNG filename (e.g., 'rys_3_1_macierz_transmitancji_h.png')
%   show_figure - (Optional) Keep window visible on screen (default: true)
%   save_png    - (Optional) Export 300 DPI PNG to thesis/img/ (default: true)
%
% Output:
%   out_file    - Absolute path to exported PNG, or '' when save_png is false

if nargin < 4 || isempty(show_figure)
    show_figure = true;
end
if nargin < 5 || isempty(save_png)
    save_png = true;
end

if save_png
    init_path = which('init_paths');
    if ~isempty(init_path)
        project_root = fileparts(init_path);
    else
        project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    end
    out_dir = fullfile(project_root, 'thesis', 'img', chapter_dir);
    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end
    out_file = fullfile(out_dir, filename);
    % Export before toggling visibility so OS window scaling cannot alter PNG dimensions
    exportgraphics(fig, out_file, 'Resolution', 300);
    fprintf('  Figure saved to: %s\n', out_file);
else
    out_file = '';
end

if show_figure
    set(fig, 'WindowStyle', 'normal', 'Visible', 'on');
    drawnow;
else
    close(fig);
end
end
