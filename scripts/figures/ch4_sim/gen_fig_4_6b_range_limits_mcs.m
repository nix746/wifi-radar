function fig = gen_fig_4_6b_range_limits_mcs(show_figure, save_png, force_recompute)
% GEN_FIG_4_6B_RANGE_LIMITS_MCS
% Experiment SIM-6b: Single-target range detection limits PNFR(R) across
% modulation orders (MCS 0, 4, 8, 11) in TGax Model-A (dual-slope, d_BP = 5 m)
% at CBW80 (80 MHz), P_rx = -63 dBm (SNR_eff = 24.9 dB, NF = 7 dB).
%
% Output file: thesis/img/ch4_sim/rys_4_6b_zasieg_graniczny_mcs.png

if nargin < 1 || isempty(show_figure),     show_figure     = true;  end
if nargin < 2 || isempty(save_png),        save_png        = true;  end
if nargin < 3 || isempty(force_recompute), force_recompute = false; end

project_root = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
addpath(project_root);
project_root = init_paths();

fprintf('=================================================================\n');
fprintf('  Generating Fig. 4.6b: Range Limits PNFR(R) vs MCS (Exp. SIM-6b)\n');
fprintf('=================================================================\n');

panels = [ ...
    struct('title', 'MCS 0 (BPSK, r = 1/2)',      'standard', '802.11ax', 'cbw', 'CBW80', 'mcs',  0), ...
    struct('title', 'MCS 4 (16-QAM, r = 3/4)',    'standard', '802.11ax', 'cbw', 'CBW80', 'mcs',  4), ...
    struct('title', 'MCS 8 (256-QAM, r = 3/4)',   'standard', '802.11ax', 'cbw', 'CBW80', 'mcs',  8), ...
    struct('title', 'MCS 11 (1024-QAM, r = 5/6)', 'standard', '802.11ax', 'cbw', 'CBW80', 'mcs', 11) ...
    ];

cache_file = fullfile(project_root, 'results', 'exp6b_range_limits_mcs.mat');
[~, fig] = run_range_limit_sweep(panels, ...
    'Zasięg graniczny detekcji PNFR(R) w funkcji rzędu modulacji MCS (802.11ax, CBW80, Model-A)', ...
    cache_file, force_recompute);

save_thesis_figure(fig, 'ch4_sim', 'rys_4_6b_zasieg_graniczny_mcs.png', show_figure, save_png);
if ~show_figure
    fig = [];
end
fprintf('=================================================================\n');
end
