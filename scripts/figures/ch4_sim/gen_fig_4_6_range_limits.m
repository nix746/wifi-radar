function fig = gen_fig_4_6_range_limits(show_figure, save_png, force_recompute)
% GEN_FIG_4_6_RANGE_LIMITS
% Experiment SIM-6: Single-target range detection limits PNFR(R) across
% target classes in TGax Model-C (dual-slope, d_BP = 5 m) for 802.11ax,
% CBW40 (40 MHz), MCS 5 (64-QAM, r = 2/3), P_rx = -50 dBm (NF = 7 dB).
%
% Output file: thesis/img/ch4_sim/rys_4_6_zasieg_graniczny.png

if nargin < 1 || isempty(show_figure),     show_figure     = true;  end
if nargin < 2 || isempty(save_png),        save_png        = true;  end
if nargin < 3 || isempty(force_recompute), force_recompute = false; end

project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
addpath(project_root);
project_root = init_paths();

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.6: Range Limits PNFR(R) (Exp. SIM-6)\n');
fprintf('=================================================================\n');

panel = struct( ...
    'title',         'IEEE 802.11ax, CBW40 (40 MHz), MCS 5 (64-QAM, r = 2/3), TGax Model-C, P_rx = -50 dBm', ...
    'standard',      '802.11ax', ...
    'cbw',           'CBW40', ...
    'mcs',           5, ...
    'channel_model', 'Model-C', ...
    'p_rx_dBm',      -50.0);

ranges_m   = 1 : 0.5 : 42;
cache_file = fullfile(project_root, 'results', 'exp6_range_limits.mat');
res        = run_range_limit_sweep(panel, cache_file, force_recompute, ranges_m);
fig        = plot_range_limits(res, 'Zasięg graniczny detekcji PNFR(R) dla różnych klas obiektów');

save_thesis_figure(fig, 'ch4_sim', 'rys_4_6_zasieg_graniczny.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
