function figs = run_all_figures(show_figures, save_png, chapter_filter)
% RUN_ALL_FIGURES Generates and displays all thesis figures (Chapters 2-4).
%
% Usage:
%   run_all_figures()                  % Generate, save PNGs, and open 9 separate windows
%   run_all_figures(true, false)       % Display figures only without overwriting PNGs
%   run_all_figures(false, true)       % Headless batch export to thesis/img/
%   run_all_figures(true, true, 'ch4') % Run only Chapter 4 figures
%
% Inputs:
%   show_figures   - (Optional) Open each figure in its own window (default: true)
%   save_png       - (Optional) Save 300 DPI PNGs to thesis/img/ (default: true)
%   chapter_filter - (Optional) 'all' (default), 'ch2'/2, 'ch3'/3, or 'ch4'/4
%
% Output:
%   figs           - Array of open figure handles (empty when show_figures is false)

if nargin < 1 || isempty(show_figures)
    show_figures = true;
end
if nargin < 2 || isempty(save_png)
    save_png = false;
end
if nargin < 3 || isempty(chapter_filter)
    chapter_filter = 'all';
end

project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..');
addpath(project_root);
project_root = init_paths();

filter_key = normalize_chapter_filter(chapter_filter);

if show_figures
    close all force;
end

jobs = [ ...
    struct('id', '2.1', 'chapter', 'ch2', 'label', 'Subcarrier allocation (802.11a vs 802.11ax)',      'fn', @gen_fig_2_1_subcarrier_allocation), ...
    struct('id', '3.1', 'chapter', 'ch3', 'label', 'Channel transfer matrix H(k,l) before/after MTI', 'fn', @gen_fig_3_1_channel_matrix_h), ...
    struct('id', '3.2', 'chapter', 'ch3', 'label', '2D/3D Range-Doppler map before/after DSP',        'fn', @gen_fig_3_2_range_doppler), ...
    struct('id', '3.3', 'chapter', 'ch3', 'label', 'DSP pipeline stages decomposition',               'fn', @gen_fig_3_3_dsp_stages), ...
    struct('id', '4.1', 'chapter', 'ch4', 'label', 'Range resolution vs bandwidth (20-160 MHz)',      'fn', @gen_fig_4_1_bandwidth_cut), ...
    struct('id', '4.2', 'chapter', 'ch4', 'label', 'Doppler velocity aliasing (802.11a vs 802.11ax)', 'fn', @gen_fig_4_2_doppler_aliasing), ...
    struct('id', '4.3', 'chapter', 'ch4', 'label', 'MCS order vs ZF noise enhancement & PNFR',        'fn', @gen_fig_4_3_noise_enhancement), ...
    struct('id', '4.4', 'chapter', 'ch4', 'label', 'TGax multipath clutter & MTI suppression',        'fn', @gen_fig_4_4_tgax_mti_cut), ...
    struct('id', '4.5', 'chapter', 'ch4', 'label', 'Binary STC vs Coherent STC (30 dB dynamic range)','fn', @gen_fig_4_5_clean_cut) ...
    ];

if ~strcmp(filter_key, 'all')
    jobs = jobs(strcmp({jobs.chapter}, filter_key));
end

fprintf('=================================================================\n');
fprintf('  Wi-Fi Passive Radar - Thesis Figures Runner (%d figures)\n', numel(jobs));
fprintf('  Show windows: %d | Save 300 DPI PNG: %d | Filter: %s\n', show_figures, save_png, filter_key);
fprintf('=================================================================\n\n');

figs = gobjects(0);
t_total = tic;

for idx = 1:numel(jobs)
    job = jobs(idx);
    fprintf('[%d/%d] Figure %s: %s\n', idx, numel(jobs), job.id, job.label);
    t_fig = tic;
    fig = job.fn(show_figures, save_png);
    elapsed = toc(t_fig);
    fprintf('  Completed Figure %s in %.2f s.\n\n', job.id, elapsed);

    if show_figures && ~isempty(fig) && isgraphics(fig)
        figs(end + 1) = fig; %#ok<AGROW>
    end
end

total_time = toc(t_total);
fprintf('=================================================================\n');
fprintf('  Finished %d figure(s) in %.2f s.\n', numel(jobs), total_time);
if save_png
    fprintf('  PNG output directory: %s\n', fullfile(project_root, 'thesis', 'img'));
end
if show_figures
    fprintf('  Open figure windows: %d\n', numel(figs));
end
fprintf('=================================================================\n');
end

function key = normalize_chapter_filter(chapter_filter)
if isnumeric(chapter_filter) && isscalar(chapter_filter)
    key = sprintf('ch%d', round(chapter_filter));
elseif ischar(chapter_filter) || (isstring(chapter_filter) && isscalar(chapter_filter))
    raw = lower(strtrim(char(chapter_filter)));
    switch raw
        case {'all', ''}
            key = 'all';
        case {'2', 'ch2', 'ch2_theory'}
            key = 'ch2';
        case {'3', 'ch3', 'ch3_impl'}
            key = 'ch3';
        case {'4', 'ch4', 'ch4_sim'}
            key = 'ch4';
        otherwise
            error('Unsupported chapter_filter ''%s''. Use ''all'', ''ch2'', ''ch3'', or ''ch4''.', raw);
    end
else
    error('Invalid chapter_filter type.');
end

if ~ismember(key, {'all', 'ch2', 'ch3', 'ch4'})
    error('Unsupported chapter_filter ''%s''. Use ''all'', ''ch2'', ''ch3'', or ''ch4''.', key);
end
end
