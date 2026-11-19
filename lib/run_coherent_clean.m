function [CPer_clean, targets_found, threshold, CPer_history] = run_coherent_clean(...
    CPer_base, W_2D, N_per, M_per, Nfft, n_symbols, num_targets, margin_dB, apply_mti)
% RUN_COHERENT_CLEAN
% Iterative Coherent Target Cancellation (CLEAN Algorithm).
% Supports both fixed iterations and dynamic noise threshold stopping.
%
% Inputs:
%   CPer_base      - Initial 2D Range-Doppler periodogram (complex)
%   W_2D           - 2D window matrix in frequency-time domain
%   N_per, M_per   - Range and Doppler FFT grid sizes
%   Nfft, n_symbols- Active subcarriers and symbols count
%   num_targets    - (Optional) Maximum number of targets to detect (default: 2)
%   margin_dB      - (Optional) Threshold margin above median noise floor [dB]
%   apply_mti      - (Optional) Apply MTI filter to reconstructed target PSF (default: false)
%
% Outputs:
%   CPer_clean     - Residual periodogram after coherent target cancellation
%   targets_found  - [Nx2] Matrix of detected grid indices [range_idx, doppler_idx]
%   threshold      - Stopping threshold value applied (linear amplitude)
%   CPer_history   - (Optional) Cell array with periodogram snapshots {Raw, iter 1, iter 2, ...}

    if nargin < 7 || isempty(num_targets)
        num_targets = 2;
    end
    if nargin < 9 || isempty(apply_mti)
        apply_mti = false;
    end

    % Calculate stopping threshold if margin_dB is specified
    if nargin >= 8 && ~isempty(margin_dB)
        noise_sigma = median(abs(CPer_base(:))) / 0.6745;
        threshold = noise_sigma * 10^(margin_dB / 20);
    else
        threshold = 0;
    end

    CPer_clean = CPer_base;
    targets_found = [];
    if nargout >= 4
        CPer_history = {CPer_base};
    end

    for i = 1 : num_targets
        % Find maximum amplitude in current residual periodogram
        [max_val, idx] = max(abs(CPer_clean(:)));

        % Stopping criterion: terminate if residual peak drops below threshold
        if max_val < threshold
            break;
        end

        [r_idx, d_idx] = ind2sub([N_per, M_per], idx);
        targets_found = [targets_found; r_idx, d_idx];

        complex_val = CPer_clean(r_idx, d_idx);

        % Reconstruct target point spread function in frequency/time domain
        P = zeros(N_per, M_per);
        P(r_idx, d_idx) = 1;
        H_full = fft(ifft(ifftshift(P, 2), M_per, 2), N_per, 1);

        % Apply measurement pipeline filtering (MTI) and 2D windowing
        H_crop = H_full(1:Nfft, 1:n_symbols);
        if apply_mti
            H_crop = H_crop - mean(H_crop, 2);
        end
        H_crop_win = H_crop .* W_2D;

        % Periodogram of the reconstructed single target
        CPer_target = fftshift(fft(ifft(H_crop_win, N_per, 1), M_per, 2), 2);
        CPer_target_norm = CPer_target / CPer_target(r_idx, d_idx);

        % Coherent subtraction of target and its sidelobes
        CPer_clean = CPer_clean - complex_val * CPer_target_norm;

        if nargout >= 4
            CPer_history{end + 1} = CPer_clean;
        end
    end
end
