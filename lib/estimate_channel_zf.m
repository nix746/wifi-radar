function [H_shifted, H_raw_shifted] = estimate_channel_zf(F_rx, F_tx, params)
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

    % 1. Zero-Forcing (ZF) channel estimation in unshifted FFT domain
    epsilon = 1e-9;
    H = F_rx ./ (F_tx + epsilon);
    H = H .* ifftshift(params.active_mask);

    % 2. Shift zero frequency (DC) to the center of the spectrum
    H_raw_shifted = fftshift(H, 1);

    % 3. Slow-time MTI filter: subtract temporal mean to remove static clutter (0 Hz)
    H_shifted = H_raw_shifted - mean(H_raw_shifted, 2);

    % 4. DC null repair: linearly interpolate each contiguous gap of internal nulls
    dc = params.dc_indices(:).';
    if ~isempty(dc)
        gap_starts = [dc(1), dc(find(diff(dc) > 1) + 1)];
        gap_ends   = [dc(diff(dc) > 1), dc(end)];

        for g = 1:numel(gap_starts)
            idx_gap   = gap_starts(g) : gap_ends(g);
            idx_left  = idx_gap(1) - 1;
            idx_right = idx_gap(end) + 1;

            weights = (1:numel(idx_gap)).' / (numel(idx_gap) + 1);
            H_shifted(idx_gap, :) = H_shifted(idx_left, :) + ...
                weights .* (H_shifted(idx_right, :) - H_shifted(idx_left, :));
        end
    end
end
