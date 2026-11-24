function [targets, CPer_F, Per_F, eta, pnfr, diag_info] = step4_interpreter( ...
    radar_data, fs, fc, WIFI_STANDARD, p_FA, stc_method)
% STEP4_INTERPRETER Target detection via Successive Target Cancellation (Braun 2014) and PNFR evaluation.
% Algorithm selection, naming, and dispatch are centralized in get_detection_algorithm.
%
% Inputs:
%   radar_data    - Struct returned by step3_receiver
%   fs            - Sampling frequency [Hz]
%   fc            - Carrier frequency [Hz]
%   WIFI_STANDARD - Standard name ('802.11a', '802.11ax')
%   p_FA          - (Optional) CFAR false-alarm probability per frame (default: 1e-3)
%   stc_method    - (Optional) Detection algorithm ID or config struct
%                   from get_detection_algorithm (default: registry default)
%
% Outputs:
%   targets       - Struct array of detected targets (d_hat, v_hat, sigma_RCS_hat, etc.)
%   CPer_F        - Residual/masked complex periodogram after cancellation
%   Per_F         - Residual/masked real-valued periodogram after cancellation
%   eta           - CFAR detection threshold (linear power, Braun eq. 3.95)
%   pnfr          - Struct with Peak-to-Noise Floor Ratio metrics (from compute_pnfr)
%   diag_info     - (Optional) Diagnostic struct from the selected detection algorithm

    if nargin < 5 || isempty(p_FA)
        p_FA = 1e-3;
    end
    if nargin < 6
        stc_method = [];
    end

    alg = get_detection_algorithm(stc_method);
    fprintf('>> Running Target Detection Interpreter: %s (%s)...\n', alg.full_name, alg.id);

    %% 1. Unpack Radar Data
    CPer_F_in = radar_data.CPer_F;
    Per_F_in  = radar_data.Per_F;
    Nfft      = radar_data.Nfft;
    Ncp       = radar_data.Ncp;
    N_per     = radar_data.N_per;
    M_per     = radar_data.M_per;

    %% 2. Target Detection & Cancellation (Braun 2014, Sec. 3.3.7)
    fprintf('  Executing %s (CFAR p_FA = %.1e)...\n', alg.name, p_FA);
    [targets, CPer_F, Per_F, eta, diag_info] = alg.run(radar_data, fs, fc, p_FA);
    diag_info.method         = alg.id;
    diag_info.algorithm_name = alg.name;
    diag_info.algorithm      = alg;

    %% 3. Calibrated Physical Axes and PNFR Metric
    if isfield(radar_data, 'axis_range') && isfield(radar_data, 'axis_velocity')
        axis_range    = radar_data.axis_range;
        axis_velocity = radar_data.axis_velocity;
    else
        [axis_range, axis_velocity] = calculate_physical_axes(fs, fc, Nfft, Ncp, N_per, M_per);
    end

    if ~isempty(targets)
        target_idx = [[targets.r_idx].', [targets.d_idx].'];
        pnfr = compute_pnfr(CPer_F_in, target_idx);
    else
        pnfr = struct( ...
            'pnfr_dB', zeros(0, 1), ...
            'peak_dB', zeros(0, 1), ...
            'floor_dB', 10 * log10(mean(abs(CPer_F_in(:)).^2)), ...
            'peak_idx', zeros(0, 2), ...
            'noise_mask', true(size(CPer_F_in)));
    end

    fprintf('  CFAR threshold eta = %.3e (noise sigma^2_hat = %.3e) | Iterations: %d (residuals rejected: %d)\n', ...
        eta, diag_info.sigma2_hat, diag_info.num_iterations, diag_info.num_residuals);
    fprintf('  Detected Targets (%d):\n', numel(targets));
    for k = 1 : numel(targets)
        fprintf('    Target %d: Range = %.2f m, Velocity = %+.2f m/s, RCS = %.2f m^2, PNFR = %.1f dB\n', ...
            k, targets(k).d_hat, targets(k).v_hat, targets(k).sigma_RCS_hat, pnfr.pnfr_dB(k));
    end
end
