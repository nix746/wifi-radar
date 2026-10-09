function [H_shifted] = estimate_channel_zf(F_rx, F_tx, params)
    % ESTIMATE_CHANNEL_ZF 
    % Zero-Forcing channel estimation, mask application, MTI filter, and DC gap repair.
    
    epsilon = 1e-9;
    H = F_rx ./ (F_tx + epsilon);

    % Apply active subcarrier mask
    H = H .* ifftshift(params.active_mask);

    % MTI Filter: eliminate static reflection at direct path (0 m, 0 Hz)
    H_shifted = fftshift(H, 1);
    H_shifted = H_shifted - mean(H_shifted, 2);

    % DC carrier repair: interpolate DC gap to prevent spectral leakage
    dc = params.dc_indices;
    if length(dc) == 1
        % Single DC carrier (e.g., 802.11a)
        H_shifted(dc, :) = (H_shifted(dc-1, :) + H_shifted(dc+1, :)) / 2;
    else
        % Multiple DC nulls (e.g., 802.11ax)
        left_val = H_shifted(dc(1)-1, :);
        right_val = H_shifted(dc(end)+1, :);
        step = (right_val - left_val) / (length(dc) + 1);
        for i = 1:length(dc)
            H_shifted(dc(i), :) = left_val + i * step;
        end
    end
end
