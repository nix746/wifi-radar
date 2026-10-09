function [project_root, src_dir, lib_dir, scripts_dir] = init_paths()
% INIT_PATHS Configures MATLAB paths for the Wi-Fi Radar project.
% Adds the source code, libraries, and scripts directories to the path.
%
% Outputs:
%   project_root - Absolute path to the project root directory
%   src_dir      - Absolute path to the src/ directory
%   lib_dir      - Absolute path to the lib/ directory
%   scripts_dir  - Absolute path to the scripts/ directory

    [project_root, ~, ~] = fileparts(mfilename('fullpath'));
    
    src_dir = fullfile(project_root, 'src');
    lib_dir = fullfile(project_root, 'lib');
    vis_dir = fullfile(lib_dir, 'visualizations');
    scripts_dir = fullfile(project_root, 'scripts');
    
    addpath(src_dir);
    addpath(lib_dir);
    addpath(vis_dir);
    addpath(scripts_dir);
end
