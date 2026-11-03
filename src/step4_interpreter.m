function [targets_found, CPer_clean, threshold, pnfr] = step4_interpreter(radar_data, fs, fc, WIFI_STANDARD, ENABLE_VISUALIZATIONS, num_targets, margin_dB)
% STEP4_INTERPRETER Coherent CLEAN target extraction, physical axes, and PNFR evaluation.
%
% Inputs:
%   radar_data            - Struct returned by step3_receiver
%   fs                    - Sampling frequency [Hz]
%   fc                    - Carrier frequency [Hz]
%   WIFI_STANDARD         - Standard name ('802.11a', '802.11ax')
%   ENABLE_VISUALIZATIONS - Logical flag to enable diagnostic plots
%   num_targets           - (Optional) Maximum number of moving targets to extract (default: 2)
%   margin_dB             - (Optional) Adaptive stopping margin above MAD noise floor [dB]
%
% Outputs:
%   targets_found         - [K x 2] Matrix of detected grid indices [range_idx, doppler_idx]
%   CPer_clean            - Residual complex periodogram after target cancellation
%   threshold             - Adaptive stopping threshold value applied (linear amplitude)
%   pnfr                  - Struct with Peak-to-Noise Floor Ratio metrics (from compute_pnfr)

    if nargin < 5 || isempty(ENABLE_VISUALIZATIONS)
        ENABLE_VISUALIZATIONS = false;
    end
    if nargin < 6 || isempty(num_targets)
        num_targets = 2;
    end
    if nargin < 7
        margin_dB = [];
    end

    fprintf('>> Running CLEAN Target Interpreter...\n');

    %% 1. Unpack Radar Data
    CPer_base = radar_data.CPer_base;
    W_2D      = radar_data.W_2D;
    N_per     = radar_data.N_per;
    M_per     = radar_data.M_per;
    Nfft      = radar_data.Nfft;
    n_symbols = radar_data.n_symbols;
    Ncp       = radar_data.Ncp;

    %% 2. Iterative Coherent Target Cancellation (Coherent CLEAN)
    fprintf('  Executing CLEAN algorithm (max targets: %d)...\n', num_targets);
    [CPer_clean, targets_found, threshold] = run_coherent_clean( ...
        CPer_base, W_2D, N_per, M_per, Nfft, n_symbols, num_targets, margin_dB);

    %% 3. Calibrated Physical Axes and PNFR Metric
    if isfield(radar_data, 'axis_range') && isfield(radar_data, 'axis_velocity')
        axis_range    = radar_data.axis_range;
        axis_velocity = radar_data.axis_velocity;
    else
        [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per);
    end

    pnfr = compute_pnfr(CPer_base, targets_found);

    fprintf('  Detected Targets (Physical Coordinates):\n');
    for i = 1:size(targets_found, 1)
        r_m  = axis_range(targets_found(i, 1));
        v_ms = axis_velocity(targets_found(i, 2));
        fprintf('    Target %d: Range = %.2f m, Velocity = %+.2f m/s, PNFR = %.1f dB\n', ...
            i, r_m, v_ms, pnfr.pnfr_dB(i));
    end

    %% 4. Diagnostic Visualization (Before vs After CLEAN)
    if ENABLE_VISUALIZATIONS
        Per_dB_base  = 10 * log10((1 / (Nfft * n_symbols)) * abs(CPer_base).^2  + 1e-9);
        Per_dB_clean = 10 * log10((1 / (Nfft * n_symbols)) * abs(CPer_clean).^2 + 1e-9);
        fig_title    = sprintf('Wi-Fi Radar - Target Detection & CLEAN Cancellation (%s)', WIFI_STANDARD);
        clean_results(Per_dB_base, Per_dB_clean, axis_velocity, axis_range, targets_found, fig_title);
    end
end
