function fig = gen_fig_4_6a_range_limits_cbw(show_figure, save_png, force_recompute)
% GEN_FIG_4_6A_RANGE_LIMITS_CBW
% Experiment SIM-6a: Single-target range detection limits PNFR(R) across
% channel bandwidths (20, 40, 80, 160 MHz) in TGax Model-A (dual-slope, d_BP = 5 m)
% at MCS 0, P_rx = -63 dBm (constant AP EIRP, NF = 7 dB).
%
% Output file: thesis/img/ch4_sim/rys_4_6a_zasieg_graniczny_cbw.png

if nargin < 1 || isempty(show_figure),     show_figure     = true;  end
if nargin < 2 || isempty(save_png),        save_png        = true;  end
if nargin < 3 || isempty(force_recompute), force_recompute = false; end

project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
addpath(project_root);
project_root = init_paths();

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.6a: Range Limits PNFR(R) vs CBW (Exp. SIM-6a)\n');
fprintf('=================================================================\n');

panels = [ ...
    struct('title', 'Pasmo 20 MHz (CBW20, SNR = 31,0 dB)',  'standard', '802.11ax', 'cbw', 'CBW20',  'mcs', 0), ...
    struct('title', 'Pasmo 40 MHz (CBW40, SNR = 28,0 dB)',  'standard', '802.11ax', 'cbw', 'CBW40',  'mcs', 0), ...
    struct('title', 'Pasmo 80 MHz (CBW80, SNR = 24,9 dB)',  'standard', '802.11ax', 'cbw', 'CBW80',  'mcs', 0), ...
    struct('title', 'Pasmo 160 MHz (CBW160, SNR = 21,9 dB)','standard', '802.11ax', 'cbw', 'CBW160', 'mcs', 0) ...
    ];

cache_file = fullfile(project_root, 'results', 'exp6a_range_limits_cbw.mat');
[~, fig] = run_range_limit_sweep(panels, ...
    'Zasięg graniczny detekcji PNFR(R) w funkcji szerokości pasma (802.11ax, MCS 0, Model-A)', ...
    cache_file, force_recompute);

save_thesis_figure(fig, 'ch4_sim', 'rys_4_6a_zasieg_graniczny_cbw.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
