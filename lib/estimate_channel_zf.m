function [H_shifted, H_raw_shifted, zeta_zf_dB, H_mti_shifted] = estimate_channel_zf(F_rx, F_tx, params)
% ESTIMATE_CHANNEL_ZF Zero-Forcing channel estimation, MTI filtering, and DC gap repair.
%
% Inputs:
%   F_rx   - Demodulated received subcarrier matrix [Nfft x n_symbols]
%   F_tx   - Demodulated reference subcarrier matrix [Nfft x n_symbols]
%   params - Struct with Wi-Fi parameters (active_mask, dc_indices)
%
% Outputs:
%   H_shifted     - Centered channel matrix after MTI filtering and DC interpolation
%   H_raw_shifted - Centered raw channel matrix before MTI filtering
%   zeta_zf_dB    - Zero-Forcing noise enhancement factor E[|X|^2]*E[1/|X|^2] [dB]
%   H_mti_shifted - Centered channel matrix after MTI filtering (before DC interpolation)

% 1. Zero-Forcing (ZF) channel estimation in unshifted FFT domain
    epsilon = 1e-9;
    act_mask_unshifted = ifftshift(params.active_mask);
    H = F_rx ./ (F_tx + epsilon);
    H = H .* act_mask_unshifted;

    % Scale-invariant ZF noise enhancement factor E[|X|^2] * E[1/|X|^2] on active tones
    X_act = F_tx(logical(act_mask_unshifted), :);
    pwr_x = abs(X_act(:)).^2;
    zeta_zf_dB = 10 * log10(mean(pwr_x) * mean(1 ./ (pwr_x + epsilon^2)));

    % 2. Shift DC to spectrum center and suppress static clutter via slow-time MTI
    H_raw_shifted = fftshift(H, 1);
    H_mti_shifted = H_raw_shifted - mean(H_raw_shifted, 2);

    % 3. Linearly interpolate internal DC null gaps
    H_shifted = interpolate_dc_nulls(H_mti_shifted, params.dc_indices);
end
