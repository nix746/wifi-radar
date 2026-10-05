function [H_shifted] = estimate_channel_zf(F_rx, F_tx, Nfft)
    % ESTIMATE_CHANNEL_ZF 
    % Zero-Forcing channel estimation, mask application, MTI filter, and DC gap repair.
    
    epsilon = 1e-9;
    H = F_rx ./ (F_tx + epsilon);

    % Active subcarrier mask for IEEE 802.11a (52 data/pilot subcarriers, excluding guard bands)
    mask_shifted = zeros(Nfft, 1);
    mask_shifted(7:32)  = 1; % Lower subcarriers [-26 to -1]
    mask_shifted(34:59) = 1; % Upper subcarriers [1 to 26]
    H = H .* ifftshift(mask_shifted);

    % MTI Filter: eliminate static reflection at direct path (0 m, 0 Hz)
    H_shifted = fftshift(H, 1);
    H_shifted = H_shifted - mean(H_shifted, 2);

    % DC carrier repair: interpolate DC gap at carrier index 33 to prevent spectral leakage
    H_shifted(33, :) = (H_shifted(32, :) + H_shifted(34, :)) / 2;
end
