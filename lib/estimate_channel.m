function [H_shifted, H_raw_shifted, zeta_dB, H_no_static_shifted] = estimate_channel(F_rx, F_tx, params)
% ESTIMATE_CHANNEL Channel frequency response estimation, static echo removal, and DC interpolation.
%
% Inputs:
%   F_rx   - Demodulated received subcarrier matrix [Nfft x n_symbols]
%   F_tx   - Demodulated reference subcarrier matrix [Nfft x n_symbols]
%   params - Struct with Wi-Fi parameters (active_mask, dc_indices)
%
% Outputs:
%   H_shifted           - Centered channel matrix after static echo removal and DC interpolation
%   H_raw_shifted       - Centered direct channel estimate before static echo removal
%   zeta_dB             - Subcarrier-division noise enhancement factor E[|X|^2]*E[1/|X|^2] [dB]
%   H_no_static_shifted - Centered channel matrix after slow-time mean subtraction (before DC interpolation)

% 1. Channel frequency response estimation via element-wise subcarrier division (F_rx / F_tx)
    epsilon = 1e-9;
    act_mask_unshifted = ifftshift(params.active_mask);
    H = F_rx ./ (F_tx + epsilon);
    H = H .* act_mask_unshifted;

    % Scale-invariant subcarrier-division noise enhancement factor E[|X|^2] * E[1/|X|^2] on active tones
    X_act = F_tx(logical(act_mask_unshifted), :);
    pwr_x = abs(X_act(:)).^2;
    zeta_dB = 10 * log10(mean(pwr_x) * mean(1 ./ (pwr_x + epsilon^2)));

    % 2. Shift DC to spectrum center and remove static echoes via slow-time mean subtraction
    H_raw_shifted       = fftshift(H, 1);
    H_no_static_shifted = H_raw_shifted - mean(H_raw_shifted, 2);

    % 3. Linearly interpolate internal DC null gaps
    H_shifted = interpolate_dc_nulls(H_no_static_shifted, params.dc_indices);
end
