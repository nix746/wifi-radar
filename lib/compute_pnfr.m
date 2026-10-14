function metrics = compute_pnfr(CPer, target_idx, guard)
% COMPUTE_PNFR Peak-to-Noise Floor Ratio of targets on a Range-Doppler map.
%
%   PNFR = 10*log10( P_peak / P_floor )   [dB]
%
%   P_peak  - power of the strongest bin inside the guard box around each
%             given target position (tolerates +-1 bin offsets).
%   P_floor - mean power of all bins outside the guard boxes of ALL targets
%             (ML noise-power estimate, cf. Braun 2014, eq. 3.98). Residual
%             clutter and sidelobes left outside the guard boxes are counted
%             as part of the floor, i.e. it is a noise-plus-interference floor.
%
%   Equivalent to the PNFR metric of the 5G NR passive radar paper (eq. 7)
%   and to the "SNR_out" (detection peak height) used by Szwej.
%
% Inputs:
%   CPer       - Complex (or power) Range-Doppler periodogram [N_per x M_per]
%   target_idx - Target positions [K x 2] as [range_idx, doppler_idx]
%   guard      - (Optional) Half-size of the guard box [g_range, g_doppler]
%                in bins (default: [16, 8], i.e. the Blackman-Harris main lobe
%                with 4x range zero-padding and up to 2x Doppler zero-padding)
%
% Output (struct):
%   metrics.pnfr_dB     - PNFR per target [K x 1]
%   metrics.peak_dB     - Peak power per target [K x 1] (unnormalized, dB)
%   metrics.floor_dB    - Noise floor power (unnormalized, dB)
%   metrics.peak_idx    - Refined peak positions [K x 2]
%   metrics.noise_mask  - Logical mask of bins used for the floor estimate

    if nargin < 3 || isempty(guard)
        guard = [16, 8];
    end

    P = abs(CPer).^2;
    [N_per, M_per] = size(P);
    K = size(target_idx, 1);

    noise_mask = true(N_per, M_per);
    peak_lin = zeros(K, 1);
    peak_idx = zeros(K, 2);

    for k = 1 : K
        % Guard box with circular wrap (both FFT axes are periodic)
        r_box = mod(target_idx(k, 1) - 1 + (-guard(1) : guard(1)), N_per) + 1;
        d_box = mod(target_idx(k, 2) - 1 + (-guard(2) : guard(2)), M_per) + 1;
        noise_mask(r_box, d_box) = false;

        % Peak search restricted to +-1 bin around the given position
        r_loc = mod(target_idx(k, 1) - 1 + (-1 : 1), N_per) + 1;
        d_loc = mod(target_idx(k, 2) - 1 + (-1 : 1), M_per) + 1;
        P_loc = P(r_loc, d_loc);
        [peak_lin(k), i_max] = max(P_loc(:));
        [ir, id] = ind2sub(size(P_loc), i_max);
        peak_idx(k, :) = [r_loc(ir), d_loc(id)];
    end

    floor_lin = mean(P(noise_mask));

    metrics.pnfr_dB    = 10 * log10(peak_lin / floor_lin);
    metrics.peak_dB    = 10 * log10(peak_lin);
    metrics.floor_dB   = 10 * log10(floor_lin);
    metrics.peak_idx   = peak_idx;
    metrics.noise_mask = noise_mask;
end
